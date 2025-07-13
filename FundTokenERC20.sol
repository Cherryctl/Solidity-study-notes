// SPDX-License-Identifier: MIT
// 许可证声明，指明此合约的开源协议为 MIT，可以自由复制、使用、修改

pragma solidity ^0.8.20;

// 导入 Chainlink 预言机接口，用于获取 ETH/USD 价格
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    // 定义映射，记录每个用户最后一次 fund 的金额
    mapping(address => uint256) public FundsToAmount;

    // 定义映射，记录每个用户累计的 fund 总金额
    mapping(address => uint256) public User_Amount;

    // 定义最小转账金额，2 * 10^18，单位为 USD * 10^18（使用 Chainlink 数据时常以 8 位精度返回，需要自行换算）
    uint256 MINIMUM_VALUE = 2 * 10 ** 18; // 2 USD

    // 定义目标金额常量，10 * 10^18，达到此值后 owner 可提取资金
    uint256 constant getAmount = 10 * 10 ** 18;

    // 合约拥有者地址
    address public owner;

    //时间戳
    uint256 deploymentTimestamp;

    //锁仓时长
    uint256 lockTime;

    address erc20Addr;

    bool public getFundSuccess = false;

    // Chainlink 预言机接口对象
    AggregatorV3Interface internal dataFeed;

    // 构造函数，部署合约时执行
    constructor(uint256 _lockTime) {
        // 指定 Chainlink Sepolia testnet ETH/USD 价格预言机合约地址
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // 将部署者设置为 owner
        owner = msg.sender;
        // 部署时记录时间
        deploymentTimestamp=block.timestamp;
        //锁仓时长
        lockTime=_lockTime;
    }

    // 更换 owner
    function transferOwnership(address new_owner) public onlyOwner {
        owner = new_owner;
    }

    // fund 函数：用户向合约转账 ETH
    function fund() external payable {
        // 检查转入 ETH 金额（换算成 USD）是否大于最小值
        require(convertETHToUSD(msg.value) >= MINIMUM_VALUE, "Send more ETH");

        //判断是否在锁定期外
        require(block.timestamp<lockTime+deploymentTimestamp,"Windows is closed");

        // 记录用户本次转账金额
        FundsToAmount[msg.sender] = msg.value;
        //用户总的募集资金
        User_Amount[msg.sender] +=FundsToAmount[msg.sender];

    }

    // 从 Chainlink 获取最新 ETH/USD 价格（带8位小数，单位：USD*10^8）
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /* uint80 roundId */,
            int256 answer, // 预言机返回的 ETH/USD 价格
            /* uint256 startedAt */,
            /* uint256 updatedAt */,
            /* uint80 answeredInRound */
        ) = dataFeed.latestRoundData();
        return answer;
    }

    // 将 ETH 金额转换为 USD 金额
    function convertETHToUSD(uint256 ETH_Amount) internal view returns (uint256) {
        uint256 ETH_Price = uint256(getChainlinkDataFeedLatestAnswer()); // 当前 ETH/USD 价格，单位 USD*10^8
        // 计算公式：ETH 数量 * ETH 单价 / 10^8（Chainlink 返回带 8 位小数）
        return ETH_Amount * ETH_Price / (10 ** 8);
    }

    // getFund 函数：当合约总资金 >= getAmount 时，owner 可提取全部资金
    function getFund() external windowClosed onlyOwner {
        // 检查合约当前余额（换算成 USD）是否 >= getAmount
        require(convertETHToUSD(address(this).balance) >= getAmount, "Not enough Funds");

        // transfer 方法：转账 ETH，若失败则 revert
        //payable(msg.sender).transfer(address(this).balance);

        // send 方法：转账 ETH，返回 bool 表示成功或失败（此处注释掉）
        /*
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "Fail to Transfer Fund");
        */

        // call 方法：更低层调用，返回 (bool success, bytes memory data)
        // 格式示例: (bool success, bytes memory result) = addr.call{value:value}("");
        bool success;
        (success, ) = payable(msg.sender).call{value:address(this).balance}("");
        require(success, "transfer failed");

        // 清空调用者的 FundsToAmount 记录
        FundsToAmount[msg.sender] = 0;
        //标注提取是否成功
        getFundSuccess = true;
    }

    // refund 函数：当合约总资金 < getAmount 时，用户可申请退款
    function refund() external {
        // 检查合约余额（换算成 USD）是否小于目标金额
        require(convertETHToUSD(address(this).balance) < getAmount, "Enough Funds");

        require(block.timestamp>=lockTime+deploymentTimestamp,"Windows is not closed");//需判断合约余额是否达到目标，因此不能直接调用onlyOwner

        // 调用 call 方法退款给用户
        bool success;
        (success, ) = payable(msg.sender).call{value:User_Amount[msg.sender]}("");
        require(success, "transfer failed");
        // 清空调用者的 FundsToAmount 记录
        FundsToAmount[msg.sender] = 0;
        User_Amount[msg.sender] =0;
    }

    function setFunderToAmount(address _funder ,uint256 amountToUpdata) external {
        require(msg.sender==erc20Addr,"You don't have permission to call this function");
        User_Amount[_funder]=amountToUpdata;
    }

    function setErc20Addr(address _erc20Addr)public onlyOwner{
        erc20Addr = _erc20Addr;
    }

    //判断是否在锁定期内,
    modifier windowClosed(){
        require(block.timestamp>=lockTime+deploymentTimestamp,"Windows is not closed");
        _;//放在require后可节省gas
    }

    // 确保只有 owner 可以调用
    modifier onlyOwner(){
        require(msg.sender==owner, "This function can only called by the owner");
        _; //放在require后可节省gas
    }

}
