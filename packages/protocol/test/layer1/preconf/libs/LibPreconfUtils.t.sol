// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/src/Test.sol";
import "forge-std/src/console2.sol";
import "src/layer1/preconf/libs/LibPreconfUtils.sol";

/// @title LibBridgedToken
/// @custom:security-contact security@taiko.xyz
contract TestLibPreconfUtils is Test {
    function test_getBeaconBlockRoot() public {
        bytes32 root = LibPreconfUtils.getBeaconBlockRoot(block.timestamp);
        assertEq(root, bytes32(0));

        vm.etch(
            LibPreconfConstants.getBeaconBlockRootContract(),
            address(new BeaconBlockRootImpl()).code
        );

        vm.warp(block.timestamp + 48);
        assertEq(block.timestamp, 49);

        root = LibPreconfUtils.getBeaconBlockRoot(20);
        assertEq(root, bytes32(uint256(20)));

        root = LibPreconfUtils.getBeaconBlockRoot(37);
        assertEq(root, bytes32(uint256(37)));

        root = LibPreconfUtils.getBeaconBlockRoot(38);
        assertEq(root, 0);
    }
}

contract BeaconBlockRootImpl {
    fallback(bytes calldata input) external returns (bytes memory) {
        require(input.length == 32, "Invalid calldata length");
        uint256 _timestamp;
        assembly {
            _timestamp := calldataload(0)
        }
        return abi.encode(bytes32(_timestamp - 12));
    }
}
