// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MultipleTokens/CustomToken.sol"; // Import the CustomToken contract

contract TokenDistribution is Ownable {
    struct Token {
        CustomToken tokenContract;
        string symbol;
    }

    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenSymbols;

    event TokensMinted(string symbol, address recipient, uint256 amount);
    event Distribution(address indexed user, uint256 etherReceived);

    constructor() Ownable(msg.sender) {
        // Initialize with your token addresses
        _addToken("UT", 0xbFB179D21A082cBb30ff245b6bCAb8a5b5566bAa);
        _addToken("PRT", 0x48526edd858a05f8591c0BA38c10f7493174ee1E);
        _addToken("MIT", 0xCf19DeBf8359fd17bd36AdBd71869CA9E8E4FacC);
        _addToken("USDT", 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0);
    }

    function _addToken(string memory symbol, address tokenAddress) internal {
        bytes32 symbolBytes = keccak256(abi.encodePacked(symbol));
        require(address(tokens[symbolBytes].tokenContract) == address(0), "Token already exists");

        tokens[symbolBytes] = Token(CustomToken(tokenAddress), symbol);
        tokenSymbols.push(symbolBytes);
    }

    function distributeTokens(
        uint256 _senderValue,
        address[] memory recipients,
        uint256[] memory percentages,
        string[] memory _tokenSymbols
    ) public payable {
        require(_senderValue > 0, "Must send some Ether");
        require(recipients.length == percentages.length && percentages.length == _tokenSymbols.length, "Array lengths must match");

        uint256 totalPercentage = 0;
        for (uint i = 0; i < percentages.length; i++) {
            totalPercentage += percentages[i];
        }
        require(totalPercentage == 100, "Total percentage must be 100");

        uint256 totalEtherDistributed = 0;

        for (uint i = 0; i < recipients.length; i++) {
            bytes32 symbolBytes = keccak256(abi.encodePacked(_tokenSymbols[i]));
            Token storage token = tokens[symbolBytes];
            require(address(token.tokenContract) != address(0), "Token does not exist");

            uint256 etherForThisToken = (_senderValue * percentages[i]) / 100;
            uint256 mintPrice = token.tokenContract.mintPrice();
            uint256 amountToMint = (etherForThisToken * 1e18) / mintPrice;

            // Mint tokens directly to the recipient
            token.tokenContract.mint{value: etherForThisToken}();
            token.tokenContract.transfer(recipients[i], amountToMint);

            emit TokensMinted(token.symbol, recipients[i], amountToMint);

            totalEtherDistributed += etherForThisToken;
        }

        require(totalEtherDistributed == _senderValue, "Total distributed value must match sent Ether");

        emit Distribution(msg.sender, _senderValue);
    }

    receive() external payable {
        address[] memory recipients = new address[](3);
        recipients[0] = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        recipients[1] = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
        recipients[2] = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;

        uint256[] memory percentages = new uint256[](3);
        percentages[0] = 50;
        percentages[1] = 30;
        percentages[2] = 20;

        string[] memory _tokenSymbols = new string[](3);
        _tokenSymbols[0] = "UT";
        _tokenSymbols[1] = "PRT";
        _tokenSymbols[2] = "MIT";

        distributeTokens(msg.value, recipients, percentages, _tokenSymbols);
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}