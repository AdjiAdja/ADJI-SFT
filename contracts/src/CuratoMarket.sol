// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @notice Marketplace non-custodial: NFT tetap di wallet penjual sampai terjual.
contract CuratoMarket is ReentrancyGuard {
    struct Listing { address seller; address nft; uint256 id; uint256 price; bool active; }

    uint256 public constant FEE_BPS = 100; // 1%
    address public immutable treasury;
    uint256 public count;
    mapping(uint256 => Listing) public listings;

    event Listed(uint256 indexed listingId, address indexed seller, address nft, uint256 id, uint256 price);
    event Cancelled(uint256 indexed listingId);
    event Sold(uint256 indexed listingId, address indexed buyer, uint256 price);

    constructor(address _treasury) { treasury = _treasury; }

    function list(address nft, uint256 id, uint256 price) external returns (uint256 lid) {
        require(price > 0, "price");
        IERC721 t = IERC721(nft);
        require(t.ownerOf(id) == msg.sender, "not owner");
        require(t.isApprovedForAll(msg.sender, address(this)) || t.getApproved(id) == address(this), "approve first");
        lid = ++count;
        listings[lid] = Listing(msg.sender, nft, id, price, true);
        emit Listed(lid, msg.sender, nft, id, price);
    }

    function cancel(uint256 lid) external {
        Listing storage l = listings[lid];
        require(l.active && l.seller == msg.sender, "not allowed");
        l.active = false;
        emit Cancelled(lid);
    }

    function buy(uint256 lid) external payable nonReentrant {
        Listing memory l = listings[lid];
        require(l.active, "inactive");
        require(msg.value == l.price, "wrong value");
        require(IERC721(l.nft).ownerOf(l.id) == l.seller, "seller moved NFT");
        listings[lid].active = false; // effects sebelum interaksi

        uint256 fee = l.price * FEE_BPS / 10_000;
        uint256 royalty; address receiver;
        if (IERC165(l.nft).supportsInterface(type(IERC2981).interfaceId)) {
            (receiver, royalty) = IERC2981(l.nft).royaltyInfo(l.id, l.price);
            if (royalty > l.price - fee) royalty = l.price - fee;
        }
        IERC721(l.nft).safeTransferFrom(l.seller, msg.sender, l.id);
        _pay(treasury, fee);
        if (royalty > 0) _pay(receiver, royalty);
        _pay(l.seller, l.price - fee - royalty);
        emit Sold(lid, msg.sender, l.price);
    }

    function _pay(address to, uint256 amt) private {
        (bool ok,) = to.call{value: amt}("");
        require(ok, "payment failed");
    }
}
