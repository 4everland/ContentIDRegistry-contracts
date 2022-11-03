// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MockToken is ERC20 {
	constructor() ERC20('MockToken', 'MockToken') {
		_mint(msg.sender, 1e30);
	}
}
