module nimbus::coin_flip {
    use sui::random;
    use sui::random::{Random, new_generator};
    use std::string;
    use sui::event;

    const EInvalidParams: u64 = 0;

    const HEAD: u8 = 1;
    const TAIL: u8 = 2;

    // ====== Events ======

    /// For when user trigger flip coin
    public struct PlayEvent has copy, drop {
        user_input: u8,
        result: u8
    }

    // ====== Functions ======

    /// This function uses arithmetic_is_less_than to determine the coin head or tail in a way that consumes the same
    /// amount of gas regardless of the value of the random number.
    entry fun flip(r: &Random, user_input: u8, ctx: &mut TxContext): string::String {
        assert!(user_input >= 1 && user_input <= 2, EInvalidParams);

        let mut generator = new_generator(r, ctx);
        let v = random::generate_u8_in_range(&mut generator, 1, 100);

        let is_head = arithmetic_is_less_than(v, 50, 100); // probability of 50%
        let is_tail = 1 - is_head; // probability of 50%
        let result = is_head * HEAD + is_tail * TAIL;

        // simply create new type instance and emit it
        event::emit(PlayEvent { user_input, result });

        let mut _status = b"LOSE".to_string();
        if (user_input == result) {
            _status = b"WIN".to_string();
        };
        _status
    }

    // Implements "is v < w? where v <= v_max" using integer arithmetic. Returns 1 if true, 0 otherwise.
    // Safe in case w and v_max are independent of the randomenss (e.g., fixed).
    // Does not check if v <= v_max.
    fun arithmetic_is_less_than(v: u8, w: u8, v_max: u8): u8 {
        assert!(v_max >= w && w > 0, EInvalidParams);
        let v_max_over_w = v_max / w;
        let v_over_w = v / w; // 0 if v < w, [1, v_max_over_w] if above
        (v_max_over_w - v_over_w) / v_max_over_w
    }
}