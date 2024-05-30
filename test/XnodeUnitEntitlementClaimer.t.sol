// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2, Vm} from "../lib/forge-std/src/Test.sol";
import {XnodeUnit} from "../src/XnodeUnit.sol";
import {XnodeUnitEntitlement} from "../src/XnodeUnitEntitlement.sol";
import {XnodeUnitEntitlementClaimer} from "../src/XnodeUnitEntitlementClaimer.sol";
import {Openmesh} from "../lib/openmesh-admin/src/Openmesh.sol";

import {EIP712Utils} from "./utils/EIP712Utils.sol";

contract XnodeUnitEntitlementClaimerTest is Test, Openmesh {
    XnodeUnit public xnodeUnit;
    XnodeUnitEntitlement public xnodeUnitEntitlement;
    XnodeUnitEntitlementClaimer public xnodeUnitEntitlementClaimer;
    bytes32 public xnodeUnitEntitlementClaimerDomain;

    Vm.Wallet public signer;

    function setUp() public {
        xnodeUnit = new XnodeUnit();
        xnodeUnitEntitlement = new XnodeUnitEntitlement(xnodeUnit);
        signer = vm.createWallet("signer");
        xnodeUnitEntitlementClaimer = new XnodeUnitEntitlementClaimer(xnodeUnitEntitlement, signer.addr);
        xnodeUnitEntitlementClaimerDomain = EIP712Utils.getDomainSeparator(
            EIP712Utils.EIP712Domain({
                name: "Xnode Unit Entitlement Claimer",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(xnodeUnitEntitlementClaimer)
            })
        );

        bytes32 xuMintRole = xnodeUnit.MINT_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnit.grantRole(xuMintRole, address(xnodeUnitEntitlement));

        bytes32 xueMintRole = xnodeUnitEntitlement.MINT_ROLE();
        vm.prank(OPENMESH_ADMIN);
        xnodeUnitEntitlement.grantRole(xueMintRole, address(xnodeUnitEntitlementClaimer));
    }

    function test_allowClaim(address receiver, bytes32 codeHash, uint32 claimBefore) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && claimBefore > block.timestamp);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementClaimerDomain,
            keccak256(abi.encode(xnodeUnitEntitlementClaimer.CLAIM_TYPEHASH(), receiver, codeHash, claimBefore))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
    }

    function test_revertClaimAfterClaimBefore(address receiver, bytes32 codeHash, uint32 claimBefore) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && claimBefore < block.timestamp);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementClaimerDomain,
            keccak256(abi.encode(xnodeUnitEntitlementClaimer.CLAIM_TYPEHASH(), receiver, codeHash, claimBefore))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        vm.expectRevert();
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
    }

    function test_revertClaimWrongSigner(
        string memory walletLabel,
        address receiver,
        bytes32 codeHash,
        uint32 claimBefore
    ) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && claimBefore > block.timestamp);
        Vm.Wallet memory wrongSigner = vm.createWallet(walletLabel);
        vm.assume(wrongSigner.addr != signer.addr);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementClaimerDomain,
            keccak256(abi.encode(xnodeUnitEntitlementClaimer.CLAIM_TYPEHASH(), receiver, codeHash, claimBefore))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongSigner, digest);
        vm.expectRevert();
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
    }

    function test_revertClaimTwice(address receiver, bytes32 codeHash, uint32 claimBefore) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && claimBefore > block.timestamp);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementClaimerDomain,
            keccak256(abi.encode(xnodeUnitEntitlementClaimer.CLAIM_TYPEHASH(), receiver, codeHash, claimBefore))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
        vm.expectRevert();
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
    }

    function test_revertClaimAfterActivate(address receiver, bytes32 codeHash, uint32 claimBefore) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && claimBefore > block.timestamp);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementClaimerDomain,
            keccak256(abi.encode(xnodeUnitEntitlementClaimer.CLAIM_TYPEHASH(), receiver, codeHash, claimBefore))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
        vm.prank(receiver);
        xnodeUnitEntitlement.activate(uint256(codeHash));
        vm.expectRevert();
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
    }

    function test_revertClaimAfterActivateAndBurn(address receiver, bytes32 codeHash, uint32 claimBefore) public {
        vm.assume(receiver != address(0) && receiver.code.length == 0 && claimBefore > block.timestamp);

        bytes32 digest = EIP712Utils.getTypedDataHash(
            xnodeUnitEntitlementClaimerDomain,
            keccak256(abi.encode(xnodeUnitEntitlementClaimer.CLAIM_TYPEHASH(), receiver, codeHash, claimBefore))
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
        vm.startPrank(receiver);
        xnodeUnitEntitlement.activate(uint256(codeHash));
        xnodeUnit.burn(uint256(codeHash));
        vm.stopPrank();
        vm.expectRevert();
        xnodeUnitEntitlementClaimer.claim(receiver, codeHash, claimBefore, v, r, s);
    }
}
