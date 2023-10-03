// NFTCollectible.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTCollectible is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    uint public constant MAX_SUPPLY = 30;
    uint public constant PRICE = 0.01 ether;
    uint public constant MAX_PER_MINT = 3;

    string public baseTokenURI;

    constructor(string memory baseURI) ERC721("NFT Collectible", "NFTC") {
     setBaseURI(baseURI);
    }

     function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIds.current();
        require(
            totalMinted.add(5) < MAX_SUPPLY, "Not enough NFTs"
        );
        for (uint i = 0; i < 5; i++) {
            _mintSingleNFT();
        }
    }
    function _baseURI() internal
                    view
                    virtual
                    override
                    returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current();
        // check fro mint NFT
        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs!");
        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs.");
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
        // すべてのチェックが終わったら、_count 個の NFT をユーザーに Mint する
            _mintSingleNFT();
        }
    }
    function _mintSingleNFT() private {
      uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    // https://app.unchain.tech/learn/Polygon-Generative-NFT/section-2_lesson-1/
    function tokensOfOwner(address _owner)
            external
            view
            returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);
        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);//所有者がindex番目に所有するtokenIdsを取得する関数
        }

        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}