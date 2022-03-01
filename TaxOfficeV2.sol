// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./utils/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

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

contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public rent = address(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7);
    address public wftm = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    address public uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29);

    mapping(address => bool) public taxExclusionEnabled;

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(rent).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(rent).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(rent).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(rent).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(rent).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(rent).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(rent).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(rent).isAddressExcluded(_address)) {
            return ITaxable(rent).excludeAddress(_address);
        }
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(rent).isAddressExcluded(_address)) {
            return ITaxable(rent).includeAddress(_address);
        }
    }

    function taxRate() external view returns (uint256) {
        return ITaxable(rent).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtRent,
        uint256 amtToken,
        uint256 amtRentMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtRent != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(rent).transferFrom(msg.sender, address(this), amtRent);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(rent, uniRouter);
        _approveTokenIfNeeded(token, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtRent;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtRent, resultAmtToken, liquidity) = IUniswapV2Router(uniRouter).addLiquidity(
            rent,
            token,
            amtRent,
            amtToken,
            amtRentMin,
            amtTokenMin,
            msg.sender,
            block.timestamp
        );

        if(amtRent.sub(resultAmtRent) > 0) {
            IERC20(rent).transfer(msg.sender, amtRent.sub(resultAmtRent));
        }
        if(amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtRent, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtRent,
        uint256 amtRentMin,
        uint256 amtFtmMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtRent != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(rent).transferFrom(msg.sender, address(this), amtRent);
        _approveTokenIfNeeded(rent, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtRent;
        uint256 resultAmtFtm;
        uint256 liquidity;
        (resultAmtRent, resultAmtFtm, liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{value: msg.value}(
            rent,
            amtRent,
            amtRentMin,
            amtFtmMin,
            msg.sender,
            block.timestamp
        );

        if(amtRent.sub(resultAmtRent) > 0) {
            IERC20(rent).transfer(msg.sender, amtRent.sub(resultAmtRent));
        }
        return (resultAmtRent, resultAmtFtm, liquidity);
    }

    function setTaxableRentOracle(address _rentOracle) external onlyOperator {
        ITaxable(rent).setRentOracle(_rentOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(rent).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(rent).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}
