// SPDX-License-Identifier: MIT 


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

pragma solidity ~0.8.24<0.9.0;
contract SignatureNFT is ERC721 {
    address immutable public signer;
    mapping(address => bool) public mintedAddress;

    constructor(string memory _name, string memory _symbol, address _signer) ERC721(_name, _symbol) {
        signer = _signer;
    }

    function mint(address _account, uint _tokenId, bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _enthSignerMessageHash = MessageHashUtils.toEthSignedMessageHash(_msgHash);

        require(verify(_enthSignerMessageHash, _signature), "Invalid signature");
        require(!mintedAddress[_account], "Already minted!");

        _mint(_account, _tokenId);
        mintedAddress[_account] = true;

    }

    function getMessageHash(address _account, uint _tokenId) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) public view returns(bool) {
        address recovered = ECDSA.recover(_msgHash, _signature);
        return recovered == signer;
    }
}