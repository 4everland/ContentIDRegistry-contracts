// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.4;

interface IPriceAdaptor {

	event PriceUpdated(uint256 _price);

	/// @dev return cost of content with specific content size and expiration
	/// @param size content size
	/// @param expiration content expiration
	/// @return token value in decimals(30)
	function getValue(
		uint256 size,
		uint256 expiration
	) external view returns (uint256);

	/// @dev get amount resource with value at a specific block
	/// @param value token value in decimals(30)
	/// @param expiration content expiration
	/// @return size content size
	function getSizeWith(
		uint256 value,
		uint256 expiration
	) external view returns (uint256);

	/// @dev get amount resource with value at a specific block
	/// @param value token value in decimals(30)
	/// @param size content size
	/// @return content expiration
	function getExpirationWith(
		uint256 value,
		uint256 size
	) external view returns (uint256);
}