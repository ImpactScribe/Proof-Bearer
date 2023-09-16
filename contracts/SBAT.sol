// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IERC6551Registry.sol";

contract SoulBoundAccountToken is
    ERC721,
    ERC721Enumerable,
    ERC721Burnable,
    AccessControl
{
    error TranferProhibited();
    bool transferAllowed = false;
    bytes32 public constant TOGGLE_ROLE = keccak256("TOGGLE_ROLE");
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("SoulBoundAccountToken", "SBTA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFER_ROLE, msg.sender);
        _grantRole(TOGGLE_ROLE, msg.sender);
    }

    function toggleTransfers(bool state) external onlyRole(TOGGLE_ROLE) {
        transferAllowed = state;
    }

    function safeMint(address to) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function tokenAccount(uint256 tokenId) public view returns (address) {
        return
            IERC6551Registry(0x02101dfB77FDE026414827Fdc604ddAF224F0921)
                .account(
                    0x2D25602551487C3f3354dD80D76D54383A243358,
                    10,
                    address(this),
                    tokenId,
                    0
                );
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal view {
        if (
            !hasRole(TRANSFER_ROLE, from) ||
            from != address(0) ||
            to != address(0)
        ) revert TranferProhibited();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
