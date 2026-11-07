// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";

/// @notice NFT sederhana. Pencetak menentukan royalti sendiri (maks 10%), dibaca marketplace lewat ERC-2981.
contract CuratoNFT is ERC721URIStorage, ERC2981 {
    uint256 public nextId;

    constructor() ERC721("Curato", "CRT") {}

    function mint(string calldata uri, uint96 royaltyBps) external returns (uint256 id) {
        require(royaltyBps <= 1000, "royalty > 10%");
        id = nextId++;
        _safeMint(msg.sender, id);
        _setTokenURI(id, uri);
        _setTokenRoyalty(id, msg.sender, royaltyBps);
    }

    function supportsInterface(bytes4 i) public view override(ERC721URIStorage, ERC2981) returns (bool) {
        return super.supportsInterface(i);
    }
}
