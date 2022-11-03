// SPDX-License-Identifier: GPL-3.0-only

pragma solidity >=0.8.4;

import '@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './interfaces/IERC20.sol';
import './interfaces/IPriceAdaptor.sol';

/// @author Alexandas
/// @dev IPFS content id registry
contract ContentIDRegistry is Initializable {
	using SafeMathUpgradeable for uint256;

	struct ContentMeta {
		uint256 size;
		uint256 expiration;
		uint256 updateAt;
	}

	IPriceAdaptor public priceAdaptor;

	IERC20[] public tokens;

	// token -> decimals
	mapping(IERC20 => uint256) public tokenDecimals;

	/// @dev ipfs contentId contentId meta
    mapping(address => mapping(string => ContentMeta)) public metas;

	/// @dev emit when ipfs contentId inserted or updated
	/// @param account user account
	/// @param contentId ipfs contentId
	/// @param size ipfs contentId size
	/// @param expiration ipfs contentId expiration
	event Upset(address account, string contentId, uint256 size, uint256 expiration);

	/// @dev emit when ipfs contentId removed
	/// @param account user account
	/// @param contentId ipfs contentId
	event Remove(address account, string contentId);

    constructor() initializer {}

	/// @dev proxy initialize function
	function initialize(IPriceAdaptor _priceAdaptor, IERC20 token, uint256 decimals) external initializer {
		priceAdaptor = _priceAdaptor;
		_addToken(token, decimals);
	}

	function tokenLength() public view returns(uint256) {
		return tokens.length;
	}

	function _addToken(IERC20 token, uint256 decimals) internal {
		require(!tokenExists(token), 'ContentIDRegistry: token exists');
		tokenDecimals[token] = decimals;
		tokens.push(token);
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
			_insert(token, msg.sender, contentIds[i], sizes[i], expirations[i]);
		}
	}

	/// @dev insert multiple ipfs contentId for accounts
	/// @param token ERC20 token
	/// @param contentIds array of ipfs contentIds
	/// @param extraSizes array of ipfs contentId extra size
	function updateSizeMult(
		IERC20 token,
		string[] memory contentIds,
		uint256[] memory extraSizes
	) external {
		require(contentIds.length == extraSizes.length, 'ContentIDRegistry: invalid parameter length.');
		for (uint256 i = 0; i < contentIds.length; i++) {
			_updateSize(token, msg.sender, contentIds[i], extraSizes[i]);
		}
	}

	/// @dev update multiple extra expirations for ipfs contentId
	/// @param token ERC20 token
	/// @param contentIds array of ipfs contentIds
    /// @param extraExpirations array of ipfs contentId extra expirations
	function updateExpirationMult(
		IERC20 token,
		string[] memory contentIds,
        uint256[] memory extraExpirations
	) external {
		require(contentIds.length == extraExpirations.length, 'ContentIDRegistry: invalid parameter length.');
		for (uint256 i = 0; i < contentIds.length; i++) {
			_updateExpiration(token, msg.sender, contentIds[i], extraExpirations[i]);
		}
	}

	/// @dev insert ipfs contentId
	/// @param token ERC20 token
	/// @param contentId ipfs contentId
	/// @param size ipfs contentId size
    /// @param expiration of ipfs contentId count
	function insert(
		IERC20 token,
		string memory contentId,
		uint256 size,
		uint256 expiration
	) external {
		_insert(token, msg.sender, contentId, size, expiration);
	}

	/// @dev update extra size for ipfs contentId
	/// @param token ERC20 token
	/// @param contentId ipfs contentId
	/// @param extraSize ipfs contentId extra size
	function updateSize(
		IERC20 token,
		string memory contentId,
		uint256 extraSize
	) external {
		_updateSize(token, msg.sender, contentId, extraSize);
	}

	/// @dev update extra expiration for ipfs contentId
	/// @param token ERC20 token
	/// @param contentId ipfs contentId
	/// @param extraExpiration ipfs contentId extra expiration
	function updateExpiration(
		IERC20 token,
		string memory contentId,
		uint256 extraExpiration
	) external {
		_updateExpiration(token, msg.sender, contentId, extraExpiration);
	}

	function _insert(
		IERC20 token,
		address account,
		string memory contentId,
		uint256 size,
        uint256 expiration
	) internal {
		require(tokenExists(token), 'ContentIDRegistry: nonexistent token');
		require(!exists(account, contentId) || isExpired(account, contentId), 'ContentIDRegistry: contentId exists');
		require(size > 0, 'ContentIDRegistry: invalid size');
		require(expiration > 0, 'ContentIDRegistry: invalid expiration');
		uint256 value = priceAdaptor.getValue(size, expiration);
		value = matchValueToDecimals(token, value);
		token.transferFrom(account, address(this), value);
		metas[account][contentId] = ContentMeta({
			size: size,
			expiration: expiration,
			updateAt: block.timestamp
		});
		emit Upset(account, contentId, size, expiredAt(account, contentId));
	}

	function _updateSize(
		IERC20 token,
		address account,
		string memory contentId,
		uint256 extraSize
	) internal {
		require(tokenExists(token), 'ContentIDRegistry: nonexistent token');
		require(exists(account, contentId) && !isExpired(account, contentId), 'ContentIDRegistry: nonexistent contentId');
		require(extraSize > 0, 'ContentIDRegistry: invalid extra size');
		uint256 value = priceAdaptor.getValue(extraSize, 1);
		value = matchValueToDecimals(token, value);
		token.transferFrom(account, address(this), value);
		metas[account][contentId].size = metas[account][contentId].size.add(extraSize);
		emit Upset(account, contentId, getSize(account, contentId), expiredAt(account, contentId));
	}

	function _updateExpiration(
		IERC20 token,
		address account,
		string memory contentId,
		uint256 extraExpiration
	) internal {
		require(tokenExists(token), 'ContentIDRegistry: nonexistent token');
		require(exists(account, contentId) && !isExpired(account, contentId), 'ContentIDRegistry: nonexistent contentId');
		uint256 value = priceAdaptor.getValue(extraExpiration, 1);
		value = matchValueToDecimals(token, value);
		token.transferFrom(account, address(this), value);
		metas[account][contentId].expiration = metas[account][contentId].expiration.add(extraExpiration);
		emit Upset(account, contentId, getSize(account, contentId), expiredAt(account, contentId));
	}

	function getSize(address account, string memory contentId) public view returns(uint256) {
		return metas[account][contentId].size;
	}

	function getExpiration(address account, string memory contentId) public view returns(uint256) {
		return metas[account][contentId].expiration;
	}

	function getUpdateAt(address account, string memory contentId) public view returns(uint256) {
		return metas[account][contentId].updateAt;
	}

	function exists(address account, string memory contentId) public view returns(bool) {
		return metas[account][contentId].size > 0;
	}

	function expiredAt(address account, string memory contentId) public view returns(uint256) {
		return metas[account][contentId].expiration.add(metas[account][contentId].updateAt);
	}

	function isExpired(address account, string memory contentId) public view returns(bool) {
		return expiredAt(account, contentId) >= block.timestamp;
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

	function tokenExists(IERC20 token) public view returns(bool) {
		return tokenDecimals[token] > 0;
	}

	function matchValueToDecimals(IERC20 token, uint256 value) public view returns(uint256) {
		require(tokenExists(token), 'nonexistent token');
		uint256 decimals = tokenDecimals[token];
		if (decimals >= 30) {
			return value.mul(10 ** (decimals-30));
		}
		return value.div(10 ** (30-decimals));
	}

}
