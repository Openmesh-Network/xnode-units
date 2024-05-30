// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IXnodeUnitEntitlement {
    event Activated(uint256 tokenId);

    /// @notice Mints a token to an address.
    /// @param to The address receiving the token.
    /// @param tokenId The id of the token to be minted.
    /// @dev This should be behind a permission/restriction.
    function mint(address to, uint256 tokenId) external;

    /// @notice Activates a token. You will lose your XnodeUnitEntitlement token and receive the XnodeUnit token it entitles you to.
    /// @param tokenId The id of the token to be activated.
    /// @dev The message sender should be authorized to activate this token.
    function activate(uint256 tokenId) external;

    /// @notice Activates a token with a signature.
    /// @param tokenId The id of the token to be activated.
    /// @param v The v of the signature.
    /// @param r The r of the signature.
    /// @param s The s of the signature.
    /// @dev The signer should be authorized to activate this token.
    function activateBySig(uint256 tokenId, uint8 v, bytes32 r, bytes32 s) external;

    /// @notice Updates the metadata.
    /// @param _metadataUri The new metadata uri.
    /// @dev This should be behind a permission/restriction.
    function updateMetadata(string calldata _metadataUri) external;
}
