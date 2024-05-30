// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2, Vm} from "../lib/forge-std/src/Test.sol";
import {XnodeUnit} from "../src/XnodeUnit.sol";
import {XnodeUnitEntitlement, IXnodeUnitEntitlement} from "../src/XnodeUnitEntitlement.sol";
import {Openmesh} from "../lib/openmesh-admin/src/Openmesh.sol";

import {EIP712Utils} from "./utils/EIP712Utils.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract XnodeUnitEntitlementTest is Test, Openmesh {
    using Strings for uint256;

    XnodeUnit public xnodeUnit;
    XnodeUnitEntitlement public xnodeUnitEntitlement;
    bytes32 public xnodeUnitEntitlementDomain;

    function setUp() public {
        xnodeUnit = new XnodeUnit();
        xnodeUnitEntitlement = new XnodeUnitEntitlement(xnodeUnit);
        xnodeUnitEntitlementDomain = EIP712Utils.getDomainSeparator(
            EIP712Utils.EIP712Domain({
                name: "Xnode Unit Entitlement",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(xnodeUnitEntitlement)
            })
        );

        bytes32 mintRole = xnodeUnit.MINT_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnit.grantRole(mintRole, address(xnodeUnitEntitlement));
    }

    function test_interfaces() external view {
        assert(xnodeUnitEntitlement.supportsInterface(type(IXnodeUnitEntitlement).interfaceId));
        // As according to spec: https://eips.ethereum.org/EIPS/eip-165
        assert(xnodeUnitEntitlement.supportsInterface(0x01ffc9a7));
        assert(!xnodeUnitEntitlement.supportsInterface(0xffffffff));
    }

    function test_allowMint(address to, uint256 tokenId) public {
        vm.assume(to != address(0) && to.code.length == 0);

        bytes32 mintRole = xnodeUnitEntitlement.MINT_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnitEntitlement.grantRole(mintRole, address(this));

        xnodeUnitEntitlement.mint(to, tokenId);
        vm.assertEq(xnodeUnitEntitlement.ownerOf(tokenId), to);
    }

    function test_revertMint(address to, uint256 tokenId) public {
        vm.assume(to != address(0) && to.code.length == 0);

        vm.expectRevert();
        xnodeUnitEntitlement.mint(to, tokenId);
    }

    function test_allowActivate(address to, uint256 tokenId) public {
        test_allowMint(to, tokenId);

        vm.prank(to);
        xnodeUnitEntitlement.activate(tokenId);
    }

    function test_revertActivateTwice(address to, uint256 tokenId) public {
        test_allowMint(to, tokenId);

        vm.startPrank(to);
        xnodeUnitEntitlement.activate(tokenId);

        vm.expectRevert();
        xnodeUnitEntitlement.activate(tokenId);
        vm.stopPrank();
    }

    function test_allowActivateBySig(string memory walletLabel, uint256 tokenId) public {
        Vm.Wallet memory wallet = vm.createWallet(walletLabel);
        test_allowMint(wallet.addr, tokenId);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementDomain, keccak256(abi.encode(xnodeUnitEntitlement.ACTIVATE_TYPEHASH(), tokenId))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wallet, digest);
        xnodeUnitEntitlement.activateBySig(tokenId, v, r, s);
    }

    function test_revertActivateBySigTwice(string memory walletLabel, uint256 tokenId) public {
        Vm.Wallet memory wallet = vm.createWallet(walletLabel);
        test_allowMint(wallet.addr, tokenId);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementDomain, keccak256(abi.encode(xnodeUnitEntitlement.ACTIVATE_TYPEHASH(), tokenId))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wallet, digest);
        xnodeUnitEntitlement.activateBySig(tokenId, v, r, s);
        vm.expectRevert();
        xnodeUnitEntitlement.activateBySig(tokenId, v, r, s);
    }

    function test_revertActivate(address to, uint256 tokenId) public {
        vm.assume(to != address(this));
        test_allowMint(to, tokenId);

        vm.expectRevert();
        xnodeUnitEntitlement.activate(tokenId);
    }

    function test_revertTransferAfterActivate(address to, uint256 tokenId) public {
        test_allowMint(to, tokenId);

        vm.startPrank(to);
        xnodeUnitEntitlement.activate(tokenId);

        vm.expectRevert();
        xnodeUnitEntitlement.transferFrom(to, to, tokenId);
        vm.stopPrank();
    }

    function test_allowUpdateMetadata(address to, uint256 tokenId, string memory _metadataUri) public {
        test_allowMint(to, tokenId); // need a token to be able to request metadata

        bytes32 metadataRole = xnodeUnitEntitlement.METADATA_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnitEntitlement.grantRole(metadataRole, address(this));

        xnodeUnitEntitlement.updateMetadata(_metadataUri);
        vm.assertEq(xnodeUnitEntitlement.tokenURI(tokenId), string.concat(_metadataUri, tokenId.toString()));
    }

    function test_revertUpdateMetadata(string memory _metadataUri) public {
        vm.expectRevert();
        xnodeUnitEntitlement.updateMetadata(_metadataUri);
    }
}
