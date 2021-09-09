// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
// use latest solidity version at time of writing, need not worry about overflow and underflow

/// @title ERC20 Contract


/// My Account = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
/// Account to Block = 0xDEE7796E89C82C36BAdd1375076f39D69FafE252 
/// other account to Block = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

contract Token {

    // My Variables
    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply;
    uint public time = block.timestamp;

    struct AssetProperty {
        uint amount;
        uint relaseTime;
    }

    struct UserDetails {
        address role;
        AssetProperty asset;
    }


    mapping(address => UserDetails) public balanceOf;
    mapping(address => mapping (address => bool)) public blockedAddressDetails;


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(string memory _name, string memory _symbol, uint _decimals, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply; 
        balanceOf[msg.sender] = UserDetails(msg.sender, AssetProperty(_totalSupply, block.timestamp));
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        require(balanceOf[msg.sender].role == msg.sender, "Sorry! you are not the owner.");
        require(blockedAddressDetails[msg.sender][_to] == false, "You have been blocked by owner!!!!!");
        require(balanceOf[msg.sender].asset.amount >= _value, "Insuffcient balance!");

        // if(balanceOf[msg.sender].role != msg.sender) {
        //     return false;
        // }

        // if(blockedAddressDetails[msg.sender][_to]) {
        //     return false;
        // }

        // if(balanceOf[msg.sender].amount >= _value) {
        //     return false;
        // }
        
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0), "Address doen't not found.");
        require((balanceOf[_from].asset.relaseTime <= block.timestamp), "You asset is locked for transfer currently.");
        balanceOf[_from].asset.amount = balanceOf[_from].asset.amount - (_value);
        balanceOf[_to].asset.amount = balanceOf[_to].asset.amount + (_value);
        balanceOf[_to].asset.relaseTime = (block.timestamp * 1 days);
        

        emit Transfer(_from, _to, _value);
    }

    
    function blockAddress(address _addressToBlock) public {
        blockedAddressDetails[msg.sender][_addressToBlock] = true;
    }

    function unblockAddress(address _addressToBlock) public {
        blockedAddressDetails[msg.sender][_addressToBlock] = false;
    }
}

