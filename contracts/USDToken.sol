// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDToken is ERC20, Ownable {
    // Set decimals to represent 0.001 as the smallest unit
    uint8 private constant _customDecimals = 3;

    constructor(uint256 initialSupply) ERC20("USD Token", "USD") {
        // Mint the initial supply with custom decimals applied
        _mint(msg.sender, initialSupply * (10 ** _customDecimals));
    }

    // Override the decimals function to return custom decimals
    function decimals() public view virtual override returns (uint8) {
        return _customDecimals;
    }

    // Function to increase the token supply, only callable by the owner
    function increaseSupply(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount * (10 ** _customDecimals));
    }

    // Function to decrease the token supply, only callable by the owner
    function decreaseSupply(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount * (10 ** _customDecimals));
    }
}
