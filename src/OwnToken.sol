//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OwnToken is ERC20 {
    constructor(uint256 _initialsupply) ERC20("NovaToken", "NOVA") {
        _mint(msg.sender, _initialsupply);
    }
}
