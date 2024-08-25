// SPDX-License-Identifier: MIT 
pragma solidity ~0.8.24<0.9.0;
contract MultisigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public ownerCount;
    uint public threshould;
    uint public nonce;

    event ExecutionSuccess(bytes32 txHash);
    event ExecutionFailure(bytes32 txHash);

    constructor(address[] memory _owners, uint _threshould) {
        _setupOwners(_owners, _threshould);
    }

    function _setupOwners(address[] memory _owners, uint _threshould) internal {
        require(threshould == 0, "DQ5000");
        require(_threshould <= _owners.length, "DQ5001");
        require(_threshould >= 1, "DQ5002");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0) && owner != address(this) && !isOwner[owner], "DQ5003");
            owners.push(owner);
            isOwner[owner] = true;
        }
        ownerCount = _owners.length;
        threshould = _threshould;
    }

    function execTrasaction(
        address to,
        uint value,
        bytes memory data,
        bytes memory signatures
    ) public payable virtual returns (bool success) {
        bytes32 txHash = encodeTransactionData(to, value, data, nonce, block.chainid);
        nonce++;
        checkSignatures(txHash, signatures);

        (success, ) = to.call{value: value}(data);
        require(success, "DQ5004");

        if (success) emit ExecutionSuccess(txHash);
        else emit ExecutionFailure(txHash);
    }

    function encodeTransactionData(
        address to,
        uint value,
        bytes memory data,
        uint _nonce,
        uint chainid
    ) public pure returns (bytes32 safeTxHash) {
        safeTxHash = keccak256(
            abi.encode(
                to, value, keccak256(data), _nonce, chainid
            )
        );
    }

    function checkSignatures(bytes32 dataHash, bytes memory signatures) public view {
        uint _threshould = threshould;

        require(threshould > 0, "DQ5005");
        require(signatures.length >= _threshould * 65, "DQ5006");

        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint i;
        for (i = 0; i < _threshould; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v, r, s);
            require(currentOwner > lastOwner && isOwner[currentOwner], "DQ5007");
            lastOwner = currentOwner;
        }
    }

    function signatureSplit(bytes memory signatures, uint256 pos)
        internal 
        pure 
        returns (uint8 v, bytes32 r, bytes32 s) {
            assembly {
                let signaturePos := mul(0x41, pos)
                r := mload(add(signatures, add(signaturePos, 0x20)))
                s := mload(add(signatures, add(signaturePos, 0x40)))
                v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
            }
    }
}