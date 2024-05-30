// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IXnodeUnit {
    /// @notice Mints a token to an address.
    /// @param to The address receiving the token.
    /// @param tokenId The id of the token to be minted.
    /// @dev This should be behind a permission/restriction.
    function mint(address to, uint256 tokenId) external;

    /// @notice Burns a token.
    /// @param tokenId The id of the token to be burned.
    /// @dev This should be behind a permission/restriction.
    function burn(uint256 tokenId) external;

    /// @notice Updates the metadata.
    /// @param _metadataUri The new metadata uri.
    /// @dev This should be behind a permission/restriction.
    function updateMetadata(string calldata _metadataUri) external;
}
