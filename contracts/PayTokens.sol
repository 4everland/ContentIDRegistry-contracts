// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.4;

import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';

import './interfaces/IERC20.sol';

/// @author Alexandas
/// @dev pay tokens contract
contract PayTokens is OwnableUpgradeable {
	using SafeMathUpgradeable for uint256;

	// token -> decimals
	mapping(IERC20 => uint8) public tokens;

	/// @dev emit when pay token added
	/// @param token token address
	/// @param decimals token decimals
	event AddToken(IERC20 token, uint8 decimals);

	/// @dev emit when pay token removed
	/// @param token token address
	event RemoveToken(IERC20 token);

    constructor() initializer {}

	function __Init_Pay_Token(address admin, IERC20 token) internal onlyInitializing {
		_transferOwnership(admin);
		_addToken(token);
	}

	function addToken(IERC20 token) external onlyOwner {
		_addToken(token);
	}

	function removeToken(IERC20 token) external onlyOwner {
		_removeToken(token);
	}

	function _addToken(IERC20 token) internal {
		require(!tokenExists(token), 'PayTokens: token exists');
		tokens[token] = token.decimals();
	}

	function _removeToken(IERC20 token) internal {
		require(tokenExists(token), 'PayTokens: nonexistent token');
		delete tokens[token];
	}

	function tokenExists(IERC20 token) public view returns(bool) {
		return tokens[token] > 0;
	}

}
