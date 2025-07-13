// SPDX-License-Identifier: MIT
// 许可证声明，指明此合约的开源协议为 MIT，可以自由复制、使用、修改

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import{FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20{
    FundMe fundMe;
    constructor(address fundMeaddr)ERC20("Kincoin","KC"){
        //声明合约地址
        fundMe = FundMe(fundMeaddr);
    }

    function mint(uint256 amountToMint) public {
        //判断用户铸造token数量是否大于募资数量
        require(fundMe.User_Amount(msg.sender)>=amountToMint,"You can't mint that much tokens");
        require(fundMe.getFundSuccess(),"No fund has been raised yet!");//getter
        
        _mint(msg.sender, amountToMint);
        //setFunderToAmount传入用户地址和用户输入的铸币数量
        fundMe.setFunderToAmount(msg.sender, fundMe.User_Amount(msg.sender) - amountToMint);
    }

    function claim(uint256 amountToClaim) public {
        //判断用户取通证数量是否会大于余额
        require(balanceOf(msg.sender)>=amountToClaim,"You don't have enough tokens");
        _burn(msg.sender, amountToClaim);

    }
    
}
