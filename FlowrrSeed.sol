// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FlowrrSeed is Ownable{

    uint256 private constant baseDivider = 10000;
    uint32 private feePercents = 0;
    address public feeAddr;
    bool public avail_wd = true;
    address public devAddress;

    //Modifier
    modifier onlyGovernance() {
        require(
            (msg.sender == devAddress || msg.sender == owner()),
            "onlyGovernance:: Not gov"
        );
        _;
    }

    //Token Address
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public SEED;
    address public FLOWRR;
    
    //Events
    event DepositToken(uint256 uid, address account, uint256 amount, address token, uint256 fees);
    event WithdrawToken(address account, uint256 amount, address token);
    event SwapToken(address account, uint256 swap_amt, uint256 rec_amt, string action);

    constructor(
        address _seedAddr,
        address _flowrrAddr,
        address _feeAddr,
        address _devAddress
    ) {
        SEED = _seedAddr;
        FLOWRR = _flowrrAddr;
        feeAddr = _feeAddr;
        devAddress = _devAddress;
    }

    //BNB----------------------------
    receive() external payable{
        revert();
    }
    //Token--------------------------
    function depositToken(uint256 uid, uint256 amount, address _tokenAddress) external {
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount);
        uint256 fees = amount * uint256(feePercents) / baseDivider;
        IERC20(_tokenAddress).transfer(feeAddr, fees);
        emit DepositToken(uid, msg.sender, amount, _tokenAddress, fees);
    }

    function withdrawToken(address account, uint256 amount, address _tokenAddress) external onlyGovernance {
        require(avail_wd, "Withdraw Currently Unavailable");
        IERC20(_tokenAddress).transfer(account, amount);
        emit WithdrawToken(account, amount, _tokenAddress);
    }

    function swapSeed_Flowrr(uint256 amount) external {
        IERC20(SEED).transferFrom(msg.sender, address(this), amount);
        IERC20(FLOWRR).transfer(msg.sender, amount/10);
        emit SwapToken(msg.sender, amount, amount/10, "seed_to_flowrr");
    }

    function swapFlowrr_Usdt(uint256 amount) external {
        IERC20(FLOWRR).transferFrom(msg.sender, address(this), amount);
        IERC20(USDT).transfer(msg.sender, amount);
        emit SwapToken(msg.sender, amount, amount, "flowrr_to_usdt");
    }

    //Dev
    function getFeePercent() external onlyGovernance view returns(uint32) {
        return feePercents;
    }

    function switch_wd() external onlyGovernance {
        avail_wd = !avail_wd;
    }

    function update_fees(uint32 _percent) external onlyGovernance{
        feePercents = _percent;
    }

    function update_feeAddr(address _addr) external onlyGovernance{
        require(_addr != address(0), "_Zero Address");
        feeAddr = _addr;
    }

    function changeDev(address account) external onlyOwner {
        require(account != address(0), "Address 0");
        devAddress = account;
    }

}