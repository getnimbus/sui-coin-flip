
#[test_only]
module nimbus::coin_flip_tests {
    use sui::test_scenario;
    use std::debug;
    use sui::random;
    use sui::random::{Random, update_randomness_state_for_testing};
    use sui::test_scenario::{ctx, next_tx};
    use nimbus::coin_flip::{Self};

    #[test]
    fun test_e2e() {
        let user = @0x0;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;

        // Setup randomness
        random::create_for_testing(ctx(scenario));
        test_scenario::next_tx(scenario, user);
        let mut random_state = test_scenario::take_shared<Random>(scenario);
        update_randomness_state_for_testing(
            &mut random_state,
            0,
            x"1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F",
            test_scenario::ctx(scenario),
        );
       
        // flip coin
        let mut seen_head = false;
        let mut i = 0;
        while (i < 20) {
            next_tx(scenario, user);
            let result = coin_flip::flip(&random_state, 1, ctx(scenario));
            debug::print(&result);
            seen_head = seen_head || result == b"WIN".to_string();
            i = i + 1;
        };
        
        assert!(seen_head, 1);

        test_scenario::return_shared(random_state);
        test_scenario::end(scenario_val);
    }
}