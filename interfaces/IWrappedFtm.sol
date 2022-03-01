// SPDX-License-Identifier: Unknown

pragma solidity >=0.6.0 <0.8.0;

import "../utils/token/ERC20/IERC20.sol";

interface IWrappedFtm is IERC20 {
    function deposit() external payable returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);

}

