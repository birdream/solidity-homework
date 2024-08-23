// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredNum;
    
    struct Transacation {
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }
    Transacation[] public transacations;
    mapping(uint256 => mapping(address => bool)) public approved;

    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    modifier txExists(uint256 txId_) {
        require(txId_ < transacations.length, "tx doesn't exist");
        _;
    }
    modifier notApproved(uint256 txId_) {
        require(!approved[txId_][msg.sender], "tx already approved");
        _;
    }
    modifier notExecuted(uint256 txId_) {
        require(!transacations[txId_].exected, "tx is executed");
        _;
    }

    constructor(address[] memory owners_, uint256 requiredNum_) {
        require(owners_.length > 0, "owner is required");
        require(requiredNum_ > 0 && requiredNum_ <= owners.length, "invalid required number of owner");

        for(uint256 i = 0; i < owners_.length; i++) {
            address owner = owners_[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique"); // 如果重复会抛出错误

            isOwner[owner] = true;
            owners.push(owner);
        }
        requiredNum = requiredNum_;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    function submit(
        address to_,
        uint256 value_,
        bytes calldata data_
    ) external onlyOwner returns(uint256) {
        transacations.push(
            Transacation({
                to: to_,
                value: value_,
                data: data_,
                exected: false
            })
        );
        emit Submit(transacations.length - 1);
        return transacations.length - 1;
    }
    function approve(uint256 txId_) external onlyOwner txExists(txId_) notApproved(txId_) notExecuted(txId_) {
        approved[txId_][msg.sender] = true;
        emit Approve(msg.sender, txId_);
    }
    function execute(uint256 txId_) external onlyOwner txExists(txId_) notApproved(txId_) notExecuted(txId_) {
        require(getApprovalCount(txId_) >= requiredNum, "approvals < required");
        Transacation storage tx = transacations[txId_];
        tx.exected = true;
        (bool success, ) = tx.to.call{value: tx.value}(tx.data);
        require(success, "tx failed");
        emit Execute(txId_);
    }
    function getApprovalCount(uint256 txId_) public view returns(uint256 count) {
        for(uint256 idx = 0; idx < owners.length; idx++) {
            if(approved[txId_][owners[idx]]) {
                count += 1;
            }
        }
    }
    function revoke(uint256 txId_) external onlyOwner txExists(txId_) notExecuted(txId_) {
        require(approved[txId_][msg.sender], "tx not approved");
        approved[txId_][msg.sender] = false;
        emit Revoke(msg.sender, txId_);
    }
}