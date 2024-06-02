#[allow(unused_mut_parameter)]
module nimbus::sui_winner {
    use nimbus::drand_lib::{derive_randomness, safe_selection};
    use sui::event;

    public struct Round has key, store {
        id: UID,
        round: u64
    }

    // ====== Events ======

    // Winner of campaign
    public struct Winner has copy, drop {
        prize: u64,
        winning_number: u64
    }

    // ====== Functions ======

    fun init(ctx: &mut TxContext) {
        // Share the object to make it accessible to everyone!
        transfer::share_object(Round {
            id: object::new(ctx),
            round: 1,
        });
    }

    #[test_only]
    // The `init` is not run in tests, and normally a test_only function is
    // provided so that the module can be initialized in tests. Having it public
    // is important for tests located in other modules.
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }

    /// This function uses arithmetic_is_less_than to determine the coin head or tail in a way that consumes the same
    /// amount of gas regardless of the value of the random number.
    /// randomness signature can be gotten from https://drand.cloudflare.com/52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971/public/<round>
    entry fun random(round: &mut Round, prize: u64, drand_sig: vector<u8>): Winner {
        round.round = round.round + 1;

        // The randomness is derived from drand_sig by passing it through sha2_256 to make it uniform.
        let digest = derive_randomness(drand_sig);

        let result = safe_selection(18775, &digest);

        // return the result to user
        let winner = Winner { prize: prize, winning_number: result };

        // emit event
        event::emit(winner);

        winner
    }
}