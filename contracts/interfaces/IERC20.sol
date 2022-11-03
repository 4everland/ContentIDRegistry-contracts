// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.4;
import '@openzeppelin/contracts-upgradeable/interfaces/IERC20Upgradeable.sol';

interface IERC20 is IERC20Upgradeable {
	function decimals() external view returns(uint256);
}