// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./IERC6551Registry.sol";

contract ProofBearer is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    AccessControl
{
    error TranferProhibited();
    bool public transferAllowed = false;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TOGGLE_ROLE = keccak256("TOGGLE_ROLE");
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    uint256 private _nextTokenId;

    constructor() ERC721("SoulBoundAccountToken", "SBTA") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TRANSFER_ROLE, msg.sender);
        _grantRole(TOGGLE_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function toggleTransfers(
        bool state
    ) external onlyRole(TOGGLE_ROLE) whenNotPaused {
        transferAllowed = state;
    }

    function safeMint(address to, string memory uri) external whenNotPaused {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
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

    function _transfer(address from, address to, uint256 tokenId) internal override {
        if (
            !hasRole(TRANSFER_ROLE, from) ||
            from != address(0) ||
            to != address(0)
        ) revert TranferProhibited();
        ERC721._transfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
