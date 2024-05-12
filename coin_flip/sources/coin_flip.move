#[allow(unused_mut_parameter)]
module nimbus::coin_flip {
    use nimbus::drand_lib::{derive_randomness, verify_drand_signature, safe_selection};
    use std::string;
    use sui::event;

    const EInvalidParams: u64 = 0;

    public struct Round has key, store {
        id: UID,
        round: u64
    }

    // ====== Events ======

    /// For when user trigger flip coin
    public struct PlayEvent has copy, drop {
        user_input: u64,
        result: u64
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
    public fun flip(round: &mut Round, user_input: u64, drand_sig: vector<u8>): string::String {
        assert!(user_input >= 1 && user_input <= 2, EInvalidParams);

        // TODO: cannot verify drand sig in mainnet?
        // verify_drand_signature(drand_sig, round.round);

        round.round = round.round + 1;

        // The randomness is derived from drand_sig by passing it through sha2_256 to make it uniform.
        let digest = derive_randomness(drand_sig);

        let result = safe_selection(2, &digest);

        // return the result to user
        let mut status = b"LOSE".to_string();
        if (user_input == result) {
            status = b"WIN".to_string();
        };

        // simply create new type instance and emit it
        event::emit(PlayEvent { user_input, result });

        status
    }
}