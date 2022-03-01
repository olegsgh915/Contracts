// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/token/ERC20/extensions/ERC20Burnable.sol";

import "./owner/Operator.sol";

/*


██████╗░███████╗███╗░░██╗████████╗░░░██████╗░███████╗███████╗██╗
██╔══██╗██╔════╝████╗░██║╚══██╔══╝░░░██╔══██╗██╔════╝██╔════╝██║
██████╔╝█████╗░░██╔██╗██║░░░██║░░░░░░██║░░██║█████╗░░█████╗░░██║
██╔══██╗██╔══╝░░██║╚████║░░░██║░░░░░░██║░░██║██╔══╝░░██╔══╝░░██║
██║░░██║███████╗██║░╚███║░░░██║░░░██╗██████╔╝███████╗██║░░░░░██║
╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝░░░╚═╝░░░╚═╝╚═════╝░╚══════╝╚═╝░░░░░╚═╝

The Decentrilized Housing Authority is a revolutionary philithropic endevor
that aims to provide affordable housing to users across the globe.

Learn More @ https://rent.defi

*/

contract RShare is ERC20Burnable, Operator {
    using SafeMath for uint256;

    // TOTAL MAX SUPPLY = 80,000 rSHAREs
    uint256 public constant FARMING_POOL_REWARD_ALLOCATION = 59500 ether;
    uint256 public constant COMMUNITY_FUND_POOL_ALLOCATION = 5500 ether;
    uint256 public constant DEV_FUND_POOL_ALLOCATION = 5000 ether;
    uint256 public constant HOUSING_FUND_POOL_ALLOCATION = 5000 ether;
    uint256 constant TEAM_FUND_POOL_ALLOCTION = 5000 ether;

    uint256 public constant VESTING_DURATION = 365 days;
    uint256 public startTime;
    uint256 public endTime;

    uint256 public communityFundRewardRate;
    uint256 public devFundRewardRate;
    uint256 public housingFundRewardRate;
    uint256 public teamFundRewardRate;

    address public communityFund;
    address public devFund;
    address public housingFund;
    address teamFund;
    
    uint256 public communityFundLastClaimed;
    uint256 public devFundLastClaimed;
    uint256 public housingFundLastClaimed;
    uint256 teamFundLastClaimed;

    bool public rewardPoolDistributed = false;

    constructor(uint256 _startTime, address _communityFund, address _devFund, address _housingFund, address _teamFund) ERC20("RSHARE", "RSHARE") {
        _mint(msg.sender, 1 ether); // mint 1 ROMB Share for initial pools deployment

        startTime = _startTime;
        endTime = startTime + VESTING_DURATION;

        communityFundLastClaimed = startTime;
        devFundLastClaimed = startTime;
        housingFundLastClaimed = startTime;
        teamFundLastClaimed = startTime;

        communityFundRewardRate = COMMUNITY_FUND_POOL_ALLOCATION.div(VESTING_DURATION);
        devFundRewardRate = DEV_FUND_POOL_ALLOCATION.div(VESTING_DURATION);
        housingFundRewardRate = HOUSING_FUND_POOL_ALLOCATION.div(VESTING_DURATION);
        teamFundRewardRate = TEAM_FUND_POOL_ALLOCTION.div(VESTING_DURATION);


        require(_devFund != address(0), "Address cannot be 0");
        devFund = _devFund;

        require(_communityFund != address(0), "Address cannot be 0");
        communityFund = _communityFund;

        require(_housingFund != address(0), "Address cannot be 0");
        housingFund = _housingFund;

        require(_communityFund != address(0), "Address cannot be 0");
        teamFund = _teamFund;
    }
    

    function setTreasuryFund(address _communityFund) external {
        require(msg.sender == devFund, "!dev");
        communityFund = _communityFund;
    }

    function setDevFund(address _devFund) external {
        require(msg.sender == devFund, "!dev");
        require(_devFund != address(0), "zero");
        devFund = _devFund;
    }

    function setHousingFund(address _housingFund) external {
        require(msg.sender == housingFund, "!dev");
        require(_housingFund != address(0), "zero");
        housingFund = _housingFund;
    }
     function setTeamFund(address _teamFund) external {
        require(msg.sender == teamFund, "!dev");
        require(_teamFund != address(0), "zero");
        teamFund = _teamFund;
    }

    function unclaimedTreasuryFund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (communityFundLastClaimed >= _now) return 0;
        _pending = _now.sub(communityFundLastClaimed).mul(communityFundRewardRate);
    }

    function unclaimedDevFund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (devFundLastClaimed >= _now) return 0;
        _pending = _now.sub(devFundLastClaimed).mul(devFundRewardRate);
    }

    function unclaimedHousingFund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (housingFundLastClaimed >= _now) return 0;
        _pending = _now.sub(housingFundLastClaimed).mul(housingFundRewardRate);
    }

    function unclaimedTeamFund() public view returns (uint256 _pending) {
        uint256 _now = block.timestamp;
        if (_now > endTime) _now = endTime;
        if (teamFundLastClaimed >= _now) return 0;
        _pending = _now.sub(teamFundLastClaimed).mul(teamFundRewardRate);
    }
    /**
     * @dev Claim pending rewards to community and dev fund
     */
    function claimRewards() external {
        uint256 _pending = unclaimedTreasuryFund();
        if (_pending > 0 && communityFund != address(0)) {
            _mint(communityFund, _pending);
            communityFundLastClaimed = block.timestamp;
        }
        _pending = unclaimedDevFund();
        if (_pending > 0 && devFund != address(0)) {
            _mint(devFund, _pending);
            devFundLastClaimed = block.timestamp;
        }
        _pending = unclaimedHousingFund();
        if (_pending > 0 && housingFund != address(0)) {
            _mint(housingFund, _pending);
            housingFundLastClaimed = block.timestamp;
        }
        _pending = unclaimedTeamFund();
        if (_pending > 0 && teamFund != address(0)) {
            _mint(teamFund, _pending);
            teamFundLastClaimed = block.timestamp;
        }
    }

    /**
     * @notice distribute to reward pool (only once)
     */
    function distributeReward(address _farmingIncentiveFund) external onlyOperator {
        require(!rewardPoolDistributed, "Can only distribute once!");
        require(_farmingIncentiveFund != address(0), "!_farmingIncentiveFund");
        rewardPoolDistributed = true;
        _mint(_farmingIncentiveFund, FARMING_POOL_REWARD_ALLOCATION);
    }

    function burn(uint256 amount) public override {
        super.burn(amount);
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        _token.transfer(_to, _amount);
    }
}
