// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {AccessControl} from "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {OpenmeshENSReverseClaimable} from "../lib/openmesh-admin/src/OpenmeshENSReverseClaimable.sol";

import {IXnodeUnit} from "./IXnodeUnit.sol";
import {IXnodeUnitEntitlement} from "./IXnodeUnitEntitlement.sol";

contract XnodeUnitEntitlement is ERC721, EIP712, AccessControl, OpenmeshENSReverseClaimable, IXnodeUnitEntitlement {
    bytes32 public constant MINT_ROLE = keccak256("MINT");
    bytes32 public constant METADATA_ROLE = keccak256("METADATA");
    bytes32 public constant ACTIVATE_TYPEHASH = keccak256("Activate(uint256 tokenId)");
    string private metadataUri = "https://erc721.openmesh.network/metadata/xue/";

    IXnodeUnit public immutable xnodeUnit;

    constructor(IXnodeUnit _xnodeUnit) ERC721("Xnode Unit Entitlement", "XUE") EIP712("Xnode Unit Entitlement", "1") {
        xnodeUnit = _xnodeUnit;
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
        return _interfaceId == type(IXnodeUnitEntitlement).interfaceId || ERC721.supportsInterface(_interfaceId)
            || AccessControl.supportsInterface(_interfaceId);
    }

    /// @inheritdoc IXnodeUnitEntitlement
    function mint(address to, uint256 tokenId) external onlyRole(MINT_ROLE) {
        _mint(to, tokenId);
    }

    /// @inheritdoc IXnodeUnitEntitlement
    function activate(uint256 tokenId) external {
        xnodeUnit.mint(ownerOf(tokenId), tokenId);
        _update(address(this), tokenId, msg.sender); // send entitlement token to this contract using message sender as auth
        emit Activated(tokenId);
    }

    /// @inheritdoc IXnodeUnitEntitlement
    function activateBySig(uint256 tokenId, uint8 v, bytes32 r, bytes32 s) external {
        address signer = ECDSA.recover(_hashTypedDataV4(keccak256(abi.encode(ACTIVATE_TYPEHASH, tokenId))), v, r, s);
        xnodeUnit.mint(ownerOf(tokenId), tokenId);
        _update(address(this), tokenId, signer); // send entitlement token to this contract using signer as auth
        emit Activated(tokenId);
    }

    /// @inheritdoc ERC721
    function _baseURI() internal view override returns (string memory) {
        return metadataUri;
    }

    /// @inheritdoc IXnodeUnitEntitlement
    function updateMetadata(string calldata _metadataUri) external onlyRole(METADATA_ROLE) {
        metadataUri = _metadataUri;
    }
}
