// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {OpenmeshENSReverseClaimable} from "../lib/openmesh-admin/src/OpenmeshENSReverseClaimable.sol";

import {IXnodeUnit} from "./IXnodeUnit.sol";

contract XnodeUnit is ERC721, AccessControl, OpenmeshENSReverseClaimable, IXnodeUnit {
    bytes32 public constant MINT_ROLE = keccak256("MINT");
    bytes32 public constant BURN_ROLE = keccak256("BURN");
    bytes32 public constant METADATA_ROLE = keccak256("METADATA");
    string private metadataUri = "https://erc721.openmesh.network/metadata/xu/";

    constructor() ERC721("Xnode Unit", "XU") {
        _grantRole(DEFAULT_ADMIN_ROLE, OPENMESH_ADMIN);
    }

    /// @inheritdoc ERC721
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControl)
        returns (bool)
    {
        return _interfaceId == type(IXnodeUnit).interfaceId || ERC721.supportsInterface(_interfaceId)
            || AccessControl.supportsInterface(_interfaceId);
    }

    /// @inheritdoc IXnodeUnit
    function mint(address to, uint256 tokenId) external onlyRole(MINT_ROLE) {
        _mint(to, tokenId);
    }

    /// @inheritdoc IXnodeUnit
    function burn(uint256 tokenId) external {
        if (msg.sender != _ownerOf(tokenId)) {
            // If not owned by you, need BURN role.
            _checkRole(BURN_ROLE);
        }

        _burn(tokenId);
    }

    /// @inheritdoc ERC721
    function _baseURI() internal view override returns (string memory) {
        return metadataUri;
    }

    /// @inheritdoc IXnodeUnit
    function updateMetadata(string calldata _metadataUri) external onlyRole(METADATA_ROLE) {
        metadataUri = _metadataUri;
    }
}
