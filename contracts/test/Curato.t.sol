// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CuratoNFT} from "../src/CuratoNFT.sol";
import {CuratoMarket} from "../src/CuratoMarket.sol";
import {CuratoCuration} from "../src/CuratoCuration.sol";

contract CuratoTest is Test {
    CuratoNFT nft; CuratoMarket mkt; CuratoCuration cur;
    address creator = makeAddr("creator");
    address buyer = makeAddr("buyer");
    address treasury = makeAddr("treasury");

    function setUp() public {
        nft = new CuratoNFT();
        mkt = new CuratoMarket(treasury);
        cur = new CuratoCuration(address(nft));
        vm.deal(buyer, 10 ether);
    }

    function test_BuySplitsFeeAndRoyalty() public {
        vm.startPrank(creator);
        uint256 id = nft.mint("ipfs://x", 500);
        nft.setApprovalForAll(address(mkt), true);
        uint256 lid = mkt.list(address(nft), id, 1 ether);
        vm.stopPrank();

        vm.prank(buyer);
        mkt.buy{value: 1 ether}(lid);

        assertEq(nft.ownerOf(id), buyer);
        assertEq(treasury.balance, 0.01 ether);
        assertEq(creator.balance, 0.99 ether); // penjual 0.94 + royalti 0.05
    }

    function test_QuadraticCostCapsVotes() public {
        vm.startPrank(creator);
        nft.mint("ipfs://x", 0);
        cur.propose(address(0xC0));
        cur.vote(address(0xC0), 10); // 10^2 = 100 kredit
        vm.expectRevert("credits");
        cur.vote(address(0xC0), 1);
        vm.stopPrank();
    }

    function test_OnlyHoldersVote() public {
        vm.prank(buyer);
        vm.expectRevert("holders only");
        cur.propose(address(0xC0));
    }
}
