// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {CuratoNFT} from "../src/CuratoNFT.sol";
import {CuratoMarket} from "../src/CuratoMarket.sol";
import {CuratoCuration} from "../src/CuratoCuration.sol";

contract Deploy is Script {
    function run() external {
        address treasury = vm.envAddress("TREASURY");
        vm.startBroadcast();
        CuratoNFT nft = new CuratoNFT();
        CuratoMarket market = new CuratoMarket(treasury);
        CuratoCuration cur = new CuratoCuration(address(nft));
        vm.stopBroadcast();
        console.log("nft:", address(nft));
        console.log("market:", address(market));
        console.log("cur:", address(cur));
    }
}
