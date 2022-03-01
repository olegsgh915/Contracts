// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

interface IRShareRewardPool {
    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function pendingShare(uint256 _pid, address _user) external view returns (uint256);

    function userInfo(uint _pid, address _user) external view returns (uint amount, uint rewardDebt);
}
