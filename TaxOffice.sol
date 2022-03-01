// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";

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
contract TaxOffice is Operator {
    address public rent;

    constructor(address _rent) {
        require(_rent != address(0), "rent address cannot be 0");
        rent = _rent;
    }

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
        return ITaxable(rent).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return ITaxable(rent).includeAddress(_address);
    }

    function setTaxableRentOracle(address _rentOracle) external onlyOperator {
        ITaxable(rent).setRentOracle(_rentOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(rent).setTaxOffice(_newTaxOffice);
    }
}
