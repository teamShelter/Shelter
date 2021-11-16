pragma solidity ^0.5.0;

import './ERC20.sol';

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner =_newOwner;
    }
}

contract Router is Ownable {
    using SafeMath for uint256;
     
    // MyERC20 private SLT = MyERC20(0xF57DD27A7F2c02834dB0717b45bbbF6210254Ed5);
    // MyERC20 private USDT = MyERC20(0x31352C4c123208725Ab7D6999f25478Ec59104A1);
    // MyERC20 private BUSD = MyERC20(0xb78F8131F94bD37c8D5d9f1884bFe5526DB275CE);
    
    MyERC20 private SLT = MyERC20(0xF1845722f5d52C324039c5F6ebA2cc1e4621ed13);
    MyERC20 private USDT = MyERC20(0x55d398326f99059fF775485246999027B3197955);
    MyERC20 private BUSD = MyERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    
    
    uint256 private price = 1 * (10 ** 6);
    uint256 private percentage = 10 * (10  ** 6);
    uint256 private time = now;

    event SwapLog(string pair, address wallet, uint256 amount);
    
    function _compareStrings(string memory a, string memory b) private view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function Swap(string memory pair, uint256 amount) public returns (bool) {
        require(_compareStrings(pair, 'SLTUSDT') || _compareStrings(pair, 'SLTBUSD') || _compareStrings(pair, 'USDTSLT') || _compareStrings(pair, 'BUSDSLT'));
        
        if (_compareStrings(pair, 'SLTUSDT') || _compareStrings(pair, 'SLTBUSD')) {
            SLT.transferFrom(msg.sender, owner, amount);
        } else if (_compareStrings(pair, 'USDTSLT')) {
            USDT.transferFrom(msg.sender, owner, amount);
        } else if (_compareStrings(pair, 'BUSDSLT')) {
            BUSD.transferFrom(msg.sender, owner, amount);
        }
        
        if (_compareStrings(pair, 'USDTSLT') || _compareStrings(pair, 'BUSDSLT')) {
            SLT.transferFrom(owner, msg.sender, amount.div(_getNowPrice()).mul(10**6));
        } else if (_compareStrings(pair, 'SLTUSDT')) {
            USDT.transferFrom(owner, msg.sender, amount.mul(_getNowPrice().div(10).mul(9)).div(10**6));
        } else if (_compareStrings(pair, 'SLTBUSD')) {
            BUSD.transferFrom(owner, msg.sender, amount.mul(_getNowPrice().div(10).mul(9)).div(10**6));
        }
        emit SwapLog(pair, msg.sender, amount);
        
        return true;
    }
    
    function _getNowPrice() private view returns (uint256) {
        return price;
    }
    
    function getNowPrice() public view returns (uint256) {
        return _getNowPrice();
    }
    
    function setPercentage(uint256 _percentage) public onlyOwner returns (bool) {
        percentage = _percentage;
        
        return true;
    }
    
    function estimatePrice(string memory pair, uint256 amount) public view returns (uint256) {
        require(_compareStrings(pair, 'SLTUSDT') || _compareStrings(pair, 'SLTBUSD') || _compareStrings(pair, 'USDTSLT') || _compareStrings(pair, 'BUSDSLT'));
        
        uint256 tmp = 0;
        if (_compareStrings(pair, 'USDTSLT') || _compareStrings(pair, 'BUSDSLT')) {
            tmp = amount.div(_getNowPrice()).mul(10**6);
        } else if (_compareStrings(pair, 'SLTUSDT')) {
            tmp = amount.mul(_getNowPrice().div(10).mul(9)).div(10**6);
        } else if (_compareStrings(pair, 'SLTBUSD')) {
            tmp = amount.mul(_getNowPrice().div(10).mul(9)).div(10**6);
        }
        
        return tmp;
    }
    
    function getNowTime() public view returns (uint256) {
        return now;
    }
    
    function getPercentage() public view returns (uint256) {
        return percentage;
    }
    
    function setPrice(uint256 _price) public onlyOwner returns (bool) {
        price = _price;
        return true;
    }
    
    function getPrice() public view returns (uint256) {
        return price;
    }
}
