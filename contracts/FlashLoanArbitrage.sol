// contracts/FlashLoan.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";



contract FlashLoanArbitrage is FlashLoanSimpleReceiverBase {
    address payable owner;

    // Aave ERC20 Token addresses on Goerli network
    address private immutable daiAddress =
        0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49;
    address private immutable usdcAddress =
        0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43;
    address private dexContractAddress =
        0xAC54736713733d58c4CD9815584663b2476014cc;

    IERC20 private dai;
    IERC20 private usdc;
    IDex private dexContract;

    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);

        dai = IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
        dexContract = IDex(dexContractAddress);
    }

    /**
        This function is called after your contract has received the flash loaned amount
     */
   

    function requestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    function approveUSDC(uint256 _amount) external returns (bool) {
        return usdc.approve(dexContractAddress, _amount);
    }

    function allowanceUSDC() external view returns (uint256) {
        return usdc.allowance(address(this), dexContractAddress);
    }

    function approveDAI(uint256 _amount) external returns (bool) {
        return dai.approve(dexContractAddress, _amount);
    }

    function allowanceDAI() external view returns (uint256) {
        return dai.allowance(address(this), dexContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    receive() external payable {}
}