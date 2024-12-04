//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

// import {Script} from "forge-std/Script.sol";
import {Script, console} from "forge-std/Script.sol";
import {OwnToken} from "../src/OwnToken.sol";

contract DeployOwnToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external returns (OwnToken) {
        vm.startBroadcast();

        OwnToken nova = new OwnToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        return nova;
    }
}
