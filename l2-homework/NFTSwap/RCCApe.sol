// SPDX-License-Identifier: MIT
//RCCApe.sol
// by tian
pragma solidity ^0.8.21;

import "./ERC721.sol";

contract RCCApe is ERC721 {
    uint public MAX_APES = 10000; // 总量

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_APES);
        _mint(to, tokenId);
    }
}

// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4