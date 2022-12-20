// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.4;

import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';
import './PayTokens.sol';
import './interfaces/IPriceAdaptor.sol';

/// @author Alexandas
/// @dev IPFS content id registry
contract ContentIDRegistry is PayTokens {
	using SafeMathUpgradeable for uint256;

	struct ContentMeta {
		uint256 size;
		uint256 expiration;
		uint256 createAt;
	}

	IPriceAdaptor public priceAdaptor;

	/// @dev ipfs contentId contentId meta
    mapping(address => mapping(string => ContentMeta)) public metas;

	/// @dev emit when ipfs contentId inserted or updated
	/// @param account user account
	/// @param contentId ipfs contentId
	/// @param size ipfs contentId size
	/// @param expiredAt ipfs contentId expiredAt
	event Upset(address account, string contentId, uint256 size, uint256 expiredAt);

	/// @dev emit when ipfs contentId removed
	/// @param account user account
	/// @param contentId ipfs contentId
	event Remove(address account, string contentId);

    constructor() initializer {}

	/// @dev proxy initialize function
	function initialize(address admin, IPriceAdaptor _priceAdaptor, IERC20 token) external initializer {
		priceAdaptor = _priceAdaptor;
		__Init_Pay_Token(admin, token);
	}

	/// @dev insert multiple ipfs contentId for accounts
	/// @param token ERC20 token
	/// @param contentIds array of ipfs contentIds
	/// @param sizes array of ipfs contentId size
    /// @param expirations array of ipfs contentId expirations
	function insertMult(
		IERC20 token,
		string[] memory contentIds,
		uint256[] memory sizes,
        uint256[] memory expirations
	) external {
		require(contentIds.length == sizes.length, 'ContentIDRegistry: invalid parameter length.');
		require(contentIds.length == expirations.length, 'ContentIDRegistry: invalid parameter length.');
		for (uint256 i = 0; i < contentIds.length; i++) {
			_insert(token, msg.sender, msg.sender, contentIds[i], sizes[i], expirations[i]);
		}
	}

	/// @dev insert ipfs contentId
	/// @param token ERC20 token
	/// @param contentId ipfs contentId
	/// @param size ipfs contentId size
    /// @param expiration of ipfs contentId expiration
	function insert(
		IERC20 token,
		string memory contentId,
		uint256 size,
		uint256 expiration
	) external {
		_insert(token, msg.sender, msg.sender, contentId, size, expiration);
	}

	function _insert(
		IERC20 token,
		address from,
		address account,
		string memory contentId,
		uint256 size,
        uint256 expiration
	) internal {
		require(tokenExists(token), 'ContentIDRegistry: nonexistent token');
		require(!exists(account, contentId) || isExpired(account, contentId), 'ContentIDRegistry: contentId exists or nonexpired contentId');
		require(size > 0 || expiration > 0, 'ContentIDRegistry: invalid params');
		uint256 value = getValue(token, size, expiration);
		token.transferFrom(from, address(this), value);
		metas[account][contentId] = ContentMeta({
			size: size,
			expiration: expiration,
			createAt: block.timestamp
		});
		emit Upset(account, contentId, size, expiredAt(account, contentId));
	}

	/// @dev renew ipfs contentId
	/// @param token ERC20 token
	/// @param contentId ipfs contentId
    /// @param expiration of ipfs contentId expiration
	function renew(
		IERC20 token,
		string memory contentId,
        uint256 expiration
	) external {
		_renew(token, msg.sender, msg.sender, contentId, expiration);
	}

	function _renew(
		IERC20 token,
		address from,
		address account,
		string memory contentId,
        uint256 expiration
	) internal {
		require(tokenExists(token), 'ContentIDRegistry: nonexistent token');
		require(exists(account, contentId), 'ContentIDRegistry: nonexistent contentId');
		require(!isExpired(account, contentId), 'ContentIDRegistry: ');
		require(expiration > 0, 'ContentIDRegistry: invalid params');
		uint256 size = getSize(account, contentId);
		uint256 value = getValue(token, size, expiration);
		token.transferFrom(from, address(this), value);
		metas[account][contentId].expiration = expiration.add(getExpiration(account, contentId));
		emit Upset(account, contentId, size, expiredAt(account, contentId));
	}

	function getSize(address account, string memory contentId) public view returns(uint256) {
		return metas[account][contentId].size;
	}

	function getExpiration(address account, string memory contentId) public view returns(uint256) {
		return metas[account][contentId].expiration;
	}

	function exists(address account, string memory contentId) public view returns(bool) {
		return metas[account][contentId].size > 0;
	}

	function expiredAt(address account, string memory contentId) public view returns(uint256) {
		require(exists(account, contentId), 'ContentIDRegistry: nonexistent contentId');
		return metas[account][contentId].expiration.add(metas[account][contentId].createAt);
	}

	function isExpired(address account, string memory contentId) public view returns(bool) {
		return expiredAt(account, contentId) < block.timestamp;
	}

	/// @dev remove ipfs contentId
	/// @param contentIds array of ipfs contentIds
	function removeMult(string[] memory contentIds) external {
		for (uint256 i = 0; i < contentIds.length; i++) {
			_remove(msg.sender, contentIds[i]);
		}
	}

	/// @dev remove ipfs contentId
	/// @param contentId ipfs contentId id
	function remove(string memory contentId) external{
		_remove(msg.sender, contentId);
	}

	function _remove(
		address account,
		string memory contentId
	) internal {
		require(exists(account, contentId), 'ContentIDRegistry: nonexistent contentId');
		delete metas[account][contentId];
		emit Remove(account, contentId);
	}

	function getValue(IERC20 token, uint256 size, uint256 expiration) public view returns(uint256 value) {
		require(tokenExists(token), 'ContentIDRegistry: nonexistent token');
		value = priceAdaptor.getValue(tokens[token], size, expiration);
	}

}
