// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @notice Kurasi koleksi unggulan dengan quadratic voting.
/// Tiap pemegang NFT Curato dapat 100 kredit per ronde (7 hari). Biaya n suara pada satu koleksi = n^2 kredit.
contract CuratoCuration {
    uint256 public constant CREDITS = 100;
    uint256 public constant ROUND = 7 days;
    IERC721 public immutable pass;

    address[] public candidates;
    mapping(address => bool) public isCandidate;
    mapping(uint256 => mapping(address => uint256)) public votesFor;                    // ronde => koleksi => suara
    mapping(uint256 => mapping(address => mapping(address => uint256))) public cast;    // ronde => pemilih => koleksi => suara
    mapping(uint256 => mapping(address => uint256)) public spent;                       // ronde => pemilih => kredit terpakai

    event Proposed(address indexed collection, address indexed by);
    event Voted(uint256 indexed round, address indexed voter, address indexed collection, uint256 votes, uint256 cost);

    constructor(address _pass) { pass = IERC721(_pass); }

    function round() public view returns (uint256) { return block.timestamp / ROUND; }
    function candidatesLength() external view returns (uint256) { return candidates.length; }

    function propose(address collection) external {
        require(pass.balanceOf(msg.sender) > 0, "holders only");
        require(!isCandidate[collection], "already proposed");
        isCandidate[collection] = true;
        candidates.push(collection);
        emit Proposed(collection, msg.sender);
    }

    function vote(address collection, uint256 n) external {
        require(pass.balanceOf(msg.sender) > 0, "holders only");
        require(isCandidate[collection] && n > 0, "bad vote");
        uint256 r = round();
        uint256 prev = cast[r][msg.sender][collection];
        uint256 cost = (prev + n) ** 2 - prev ** 2;
        require(spent[r][msg.sender] + cost <= CREDITS, "credits");
        spent[r][msg.sender] += cost;
        cast[r][msg.sender][collection] = prev + n;
        votesFor[r][collection] += n;
        emit Voted(r, msg.sender, collection, n, cost);
    }
}
