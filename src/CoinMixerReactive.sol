// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import "../IReactive.sol";
import "../ISubscriptionService.sol";

contract InsuranceReactive is IReactive {
    uint256 private constant REACTIVE_IGNORE = 0xa65f96fc951c35ead38878e0f0b7a3c744a6f5ccc1476b313353ce31712313ad;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;

    uint256 private constant RECEIVE_EVENT_TOPIC_0 = 0x4def474aca53bf221d07d9ab0f675b3f6d8d2494b8427271bcf43c018ef1eead;

    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;

    bool private vm;
    ISubscriptionService private service;
    address private destinationContract;

    constructor(address service_address, address _l1) {
        service = ISubscriptionService(service_address);
        bytes memory payload1 = abi.encodeWithSignature(
            "subscribe(uint256,address,uint256,uint256,uint256,uint256)",
            SEPOLIA_CHAIN_ID,
            _l1,
            RECEIVE_EVENT_TOPIC_0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );
        (bool subscription_result1,) = address(service).call(payload1);
        require(subscription_result1, "Subscription failed");

        destinationContract = _l1;
    }

    function react(
        uint256 chain_id,
        address /*_contract*/,
        uint256 topic_0,
        uint256 topic_1,
        uint256 /*topic_2 */,
        uint256 /*topic_3*/,
        bytes calldata /* data */,
        uint256 /* block number */,
        uint256 /* op_code */
    ) external {
        require(topic_0 == RECEIVE_EVENT_TOPIC_0, "Unexpected topic");

        bytes memory payload = abi.encodeWithSignature(
            "distributeTokens(address,address,address[],uint256[],string[])",
             topic_1,
             ["0xE026E9dC9c5D5Bb11b434F14e0fB5da3A40DdD97","0x7F74c7FE218dEd3E8895e819356cf14B2CfBA122","0xE4057c9e102D86E5820ED9b99d251D943E9b308d"],
             [50,30,20],
             ["UT","PRT","MIT"]
            
        );
        emit Callback(chain_id, destinationContract, CALLBACK_GAS_LIMIT, payload);
    }
}
