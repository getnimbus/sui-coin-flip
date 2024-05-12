
#[test_only]
module nimbus::coin_flip_tests {
    use sui::test_scenario;
    use std::debug;
    use sui::test_scenario::{ctx, next_tx};
    use nimbus::coin_flip::{Self, Round};

    #[test]
    fun test_e2e() {
        let user1 = @0x0;
        let user2 = @0x1;
        let mut scenario_val = test_scenario::begin(user1);
        let scenario = &mut scenario_val;
        coin_flip::init_for_testing(ctx(scenario));

        // Get global object round
        test_scenario::next_tx(scenario, user1);
        let mut round = test_scenario::take_shared<Round>(scenario);

        // Get sig for each round here
        // https://drand.cloudflare.com/52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971/public/1
        scenario.next_tx(user1);
        debug::print(&round);
        let result= coin_flip::flip(&mut round, 1, x"b55e7cb2d5c613ee0b2e28d6750aabbb78c39dcc96bd9d38c2c2e12198df95571de8e8e402a0cc48871c7089a2b3af4b");
        debug::print(&result);

        scenario.next_tx(user1);
        debug::print(&round);
        let result = coin_flip::flip(&mut round, 1, x"b6b6a585449b66eb12e875b64fcbab3799861a00e4dbf092d99e969a5eac57dd3f798acf61e705fe4f093db926626807");
        debug::print(&result);

        // User2 is the winner since the mod of the hash results in 1
        scenario.next_tx(user2);
        debug::print(&round);
        let result = coin_flip::flip(&mut round, 1, x"b3fab6df720b68cc47175f2c777e86d84187caab5770906f515ff1099cb01e4deaa027075d860823e49477b93c72bd64");
        debug::print(&result);

        test_scenario::return_shared(round);
        test_scenario::end(scenario_val);
    }
}