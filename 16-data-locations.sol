// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DataLocations {
    uint256[] public arr;
    mapping(uint256 => address) public map;

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) myStructs;

    function f() public {
        // call _f with state variables
        _f(arr, map, myStructs[1]);

        // get a struct from a mapping
        MyStruct storage myStruct = myStructs[1];
        // create a struct in memory
        MyStruct memory myMemStruct = MyStruct(0);
    }

    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
        _map[0] = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        _map[1] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        _arr.push(1);
        _arr.push(2);
        _arr.push(3);
        _myStruct.foo = 123;
    }

    // You can return memory variables
    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        // do something with memory array
        
        // return _arr;
    }

    function h(uint256[] calldata _arr) external {
        // do something with calldata array
    }
}