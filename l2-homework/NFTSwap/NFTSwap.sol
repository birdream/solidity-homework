// SPDX-License-Identifier: MIT 
pragma solidity ~0.8.24<0.9.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./RCCApe.sol";

contract NFTSwap is IERC721Receiver {
    event List(address indexed seller, address indexed nftAddr, uint indexed tokenId, uint price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint indexed tokenId, uint price);
    event Revoke(address indexed seller, address indexed nftAddr, uint indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint indexed tokenId, uint newPrice);

    struct Order {
       address owner;
       uint price; 
    }
    mapping(address => mapping(uint => Order)) public nftList;

    fallback() external payable { }

    // 挂单: 卖家上架NFT，合约地址为_nftAddr，tokenId为_tokenId，价格_price为以太坊（单位是wei）
    function list(address _nftAddr, uint _tokenId, uint _price) public {
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval");
        require(_price > 0);

        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;

        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // 购买: 买家购买NFT，合约为_nftAddr，tokenId为_tokenId，调用函数时要附带ETH
    function purchase(address _nftAddr, uint _tokenId) payable public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0);
        require(msg.value >= _order.price);

        // 声明IERC721接口合约变量
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this));

        // 将NFT转给买家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        // 将ETH转给卖家，多余ETH给买家退款
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddr][_tokenId];

        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);
    }

    // 撤单： 卖家取消挂单
    function revoke(address _nftAddr, uint _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender, "Not Owner");

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "NFT Not Found"); // NFT在合约中

        // 将NFT转给卖家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId]; // 删除order

        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    // 调整价格: 卖家调整挂单价格
    function update(address _nftAddr, uint _tokenId, uint _newPrice) public {
        require(_newPrice > 0);
        Order storage _order = nftList[_nftAddr][_tokenId];

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this)); // NFT在合约中

        _order.price = _newPrice;

        // 释放Update事件
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}