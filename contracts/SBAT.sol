// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IERC6551Registry.sol";

contract SoulBoundAccountToken is ERC721 {
    error TranferProhibited();
    error NotOwner();

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("SoulBoundAccountToken", "SBTA") {}

    function safeMint(address to) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) revert NotOwner();
        _burn(tokenId);
    }

    function tokenAccount(uint256 tokenId) public view returns (address) {
        IERC6551Registry Registry = IERC6551Registry(
            0x02101dfB77FDE026414827Fdc604ddAF224F0921
        );
        return
            Registry.account(
                0x2D25602551487C3f3354dD80D76D54383A243358,
                10,
                address(this),
                tokenId,
                0
            );
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal pure {
        if (from != address(0) || to != address(0)) revert TranferProhibited();
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }
}
