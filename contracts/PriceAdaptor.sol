// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.0;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';
import './interfaces/IPriceAdaptor.sol';

/// @author Alexandas
/// @dev Content price adaptor contract
contract PriceAdaptor is IPriceAdaptor, OwnableUpgradeable {
	using SafeMathUpgradeable for uint256;

	/// @dev return current price
	uint256 public price;

	uint8 public immutable decimals = 36;

	constructor() initializer {}

	/// @dev proxy initialize function
	/// @param owner contract owner
	function initialize(address owner, uint256 _price) external initializer {
		_transferOwnership(owner);
		_setPrice(_price);
	}

	/// @dev update price
	/// @param _price price
	function setPrice(uint256 _price) external onlyOwner {
		_setPrice(_price);
	}

	function _setPrice(uint256 _price) internal {
		price = _price;
		emit PriceUpdated(_price);
	}

	/// @dev return cost of content with specific content size and expiration
	/// @param size content size
	/// @param expiration content expiration
	/// @return token value in decimals(30)
	function getValue(
		uint256 size,
		uint256 expiration
	) public view override returns (uint256) {
		require(size > 0 || expiration > 0, 'PriceAdaptor: invalid params');
		return price.mul(size).mul(expiration);
	}

	/// @dev get content size 
	/// @param value token value in decimals(30)
	/// @param expiration content expiration
	/// @return size content size
	function getSizeWith(
		uint256 value,
		uint256 expiration
	) public view override returns (uint256) {
		return value.div(expiration).div(price);
	}

	/// @dev get content expiration
	/// @param value token value in decimals(30)
	/// @param size content size
	/// @return content expiration
	function getExpirationWith(
		uint256 value,
		uint256 size
	) public view override returns (uint256) {
		return value.div(size).div(price);
	}

	function getValue(uint8 tokenDecimals, uint256 size, uint256 expiration) public view override returns(uint256 value) {
		value = getValue(size, expiration);
		value = matchValueToToken(tokenDecimals, value);
	}

	function matchValueToToken(uint8 tokenDecimals, uint256 value) public pure override returns(uint256) {
		require(tokenDecimals > 0, 'PriceAdaptor: invalid token decimals');
		if (tokenDecimals >= decimals) {
			return value.mul(10 ** (tokenDecimals - decimals));
		}
		return value.div(10 ** (decimals - tokenDecimals));
	}

}
