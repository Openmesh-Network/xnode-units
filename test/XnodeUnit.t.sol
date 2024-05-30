// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "../lib/forge-std/src/Test.sol";
import {XnodeUnit, IXnodeUnit} from "../src/XnodeUnit.sol";
import {Openmesh} from "../lib/openmesh-admin/src/Openmesh.sol";

import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract XnodeUnitTest is Test, Openmesh {
    using Strings for uint256;

    XnodeUnit public xnodeUnit;

    function setUp() public {
        xnodeUnit = new XnodeUnit();
    }

    function test_interfaces() external view {
        assert(xnodeUnit.supportsInterface(type(IXnodeUnit).interfaceId));
        // As according to spec: https://eips.ethereum.org/EIPS/eip-165
        assert(xnodeUnit.supportsInterface(0x01ffc9a7));
        assert(!xnodeUnit.supportsInterface(0xffffffff));
    }

    function test_allowMint(address to, uint256 tokenId) public {
        vm.assume(to != address(0) && to.code.length == 0);

        bytes32 mintRole = xnodeUnit.MINT_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnit.grantRole(mintRole, address(this));

        xnodeUnit.mint(to, tokenId);
        vm.assertEq(xnodeUnit.ownerOf(tokenId), to);
    }

    function test_revertMint(address to, uint256 tokenId) public {
        vm.assume(to != address(0) && to.code.length == 0);

        vm.expectRevert();
        xnodeUnit.mint(to, tokenId);
    }

    function test_ownerBurn(address to, uint256 tokenId) public {
        test_allowMint(to, tokenId);

        vm.prank(to);
        xnodeUnit.burn(tokenId);
    }

    function test_allowBurn(address to, uint256 tokenId) public {
        test_allowMint(to, tokenId);

        bytes32 burnRole = xnodeUnit.BURN_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnit.grantRole(burnRole, address(this));

        xnodeUnit.burn(tokenId);
    }

    function test_revertBurn(address to, uint256 tokenId) public {
        vm.assume(to != address(this));
        test_allowMint(to, tokenId);

        vm.expectRevert();
        xnodeUnit.burn(tokenId);
    }

    function test_allowUpdateMetadata(address to, uint256 tokenId, string memory _metadataUri) public {
        test_allowMint(to, tokenId); // need a token to be able to request metadata

        bytes32 metadataRole = xnodeUnit.METADATA_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnit.grantRole(metadataRole, address(this));

        xnodeUnit.updateMetadata(_metadataUri);
        vm.assertEq(xnodeUnit.tokenURI(tokenId), string.concat(_metadataUri, tokenId.toString()));
    }

    function test_revertUpdateMetadata(string memory _metadataUri) public {
        vm.expectRevert();
        xnodeUnit.updateMetadata(_metadataUri);
    }
}
