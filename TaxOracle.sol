// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./utils/math/SafeMath.sol";
import "./utils/access/Ownable.sol";
import "./utils/token/ERC20/IERC20.sol";

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

contract RentTaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public rent;
    IERC20 public wftm;
    address public pair;

    constructor(
        address _rent,
        address _wftm,
        address _pair
    ) {
        require(_rent != address(0), "$RENT address cannot be 0");
        require(_wftm != address(0), "wftm address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        rent = IERC20(_rent);
        wftm = IERC20(_wftm);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        require(_token == address(rent), "token needs to be $RENT");
        uint256 rentBalance = rent.balanceOf(pair);
        uint256 wftmBalance = wftm.balanceOf(pair);
        return uint144(rentBalance.div(wftmBalance));
    }

    function setRent(address _rent) external onlyOwner {
        require(_rent != address(0), "$Rent address cannot be 0");
        rent = IERC20(_rent);
    }

    function setWftm(address _wftm) external onlyOwner {
        require(_wftm != address(0), "wftm address cannot be 0");
        wftm = IERC20(_wftm);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }



}
