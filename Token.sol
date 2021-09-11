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
    uint256 public decimals;
    uint256 public totalSupply;
    uint256 public time = block.timestamp;
    uint256 public updatedTime = (block.timestamp * 1 days);

    struct AssetProperty {
        uint256 amount;
        bool isAvailable;
        uint256 relaseTime;
    }

    struct UserDetails {
        address role;
        AssetProperty asset;
    }


    mapping(address => UserDetails) public balanceOf;
    mapping(address => mapping (address => bool)) public blockedAddressDetails;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply; 
        balanceOf[msg.sender] = UserDetails(msg.sender, AssetProperty(_totalSupply, true, block.timestamp));
    }


    modifier checkOwner () {
        require(balanceOf[msg.sender].role == msg.sender, "Sorry! you are not the owner.");
        _;
    }

    modifier canAvailAsset() {
        require(balanceOf[msg.sender].asset.isAvailable, "You are currently not authorized to access this asset.");
        _;
    }

    modifier isBlocked(address _to) {
        require(blockedAddressDetails[msg.sender][_to] == false, "You have been blocked by owner!!!!!");
        _;
    }

    modifier checkBalance(uint256 _value) {
        require(balanceOf[msg.sender].asset.amount >= _value, "Insuffcient balance!");
        _;
    }

    modifier isVestedTimeReached(){
        require((balanceOf[msg.sender].asset.relaseTime <= block.timestamp), "You asset is locked for transfer currently.");
        _;
    }

    function transfer(address _to, uint256 _value, uint256 _availableAfter) checkOwner canAvailAsset isBlocked(_to) checkBalance(_value) external returns (bool success) {
        _transfer(_to, _value, _availableAfter);
        return true;
    }

    function _transfer(address _to, uint256 _value, uint256 _availableAfter) isVestedTimeReached internal {
        require(_to != address(0), "Address doen't not found.");
        balanceOf[msg.sender].asset.amount = balanceOf[msg.sender].asset.amount - (_value);
        balanceOf[_to].asset.amount = balanceOf[_to].asset.amount + (_value);

        // Implementing token vesting concept
        balanceOf[_to].asset.relaseTime = block.timestamp + ( _availableAfter * 1 days);
        balanceOf[_to].asset.isAvailable = false;
        emit Transfer(msg.sender, _to, _value);
    }

    function blockAddress(address _addressToBlock) public {
        blockedAddressDetails[msg.sender][_addressToBlock] = true;
    }

    function unblockAddress(address _addressToBlock) public {
        blockedAddressDetails[msg.sender][_addressToBlock] = false;
    }

    //  It will make vested tokens available
    function makeAssetAvailable() isVestedTimeReached public returns(bool) {
        balanceOf[msg.sender].asset.isAvailable = true;
    }

}

