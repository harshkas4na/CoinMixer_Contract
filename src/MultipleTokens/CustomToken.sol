// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
    uint256 public mintPrice;
    uint256 public burnValue;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _mintPrice,
        uint256 _burnValue
    ) ERC20(name, symbol) Ownable(msg.sender) {
        mintPrice = _mintPrice;
        burnValue = _burnValue;
    }

    function mint() public payable {
        require(msg.value >= mintPrice, "Insufficient Ether sent");

        uint256 amountToMint = msg.value / mintPrice;  // Calculate the number of tokens to mint
        _mint(msg.sender, amountToMint * 10**decimals()); // Mint tokens with the correct number of decimals
    }

    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _burn(msg.sender, amount);
        uint256 ethToReturn = (amount * burnValue) / 1 ether;
        payable(msg.sender).transfer(ethToReturn);
    }

    function withdrawEther() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setBurnValue(uint256 _burnValue) public onlyOwner {
        burnValue = _burnValue;
    }
}
