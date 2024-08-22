// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TODOList {
    struct Todo {
        string name;
        bool isFinished;
    }
    Todo[] public list;

    function create(string memory _name) external {
        list.push(
            Todo({
                name: _name,
                isFinished: false
            })
        );
    }

    function modifyName(uint256 _index, string memory _name) external {
        list[_index].name = _name;
    }

    function modifyName2(uint256 _index, string memory _name) external {
        Todo storage temp = list[_index];
        temp.name = _name;
    }

    function modifyStatus1(uint256 _index, bool _status) external {
        list[_index].isFinished = _status;
    }
    function modifyStatus2(uint256 _index) external {
        list[_index].isFinished = !list[_index].isFinished;
    }

    function get1(uint256 _index) external view returns(string memory _name, bool _status) {
        Todo memory temp = list[_index];
        return (temp.name, temp.isFinished);
    }

    function get2(uint256 _index) external view returns(string memory _name, bool _status) {
        Todo storage temp = list[_index];
        return (temp.name, temp.isFinished);
    }
}