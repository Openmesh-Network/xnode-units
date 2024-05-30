// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import {IXnodeUnitEntitlement} from "./IXnodeUnitEntitlement.sol";

contract XnodeUnitEntitlementClaimer is Ownable, EIP712 {
    error ProofExpired();
    error InvalidProof();

    event Claimed(address receiver, bytes32 codeHash);

    bytes32 public constant CLAIM_TYPEHASH = keccak256("Claim(address receiver,bytes32 codeHash,uint32 claimBefore)");
    IXnodeUnitEntitlement public immutable xnodeUnitEntitlement;

    constructor(IXnodeUnitEntitlement _xnodeUnitEntitlement, address _signer)
        Ownable(_signer)
        EIP712("Xnode Unit Entitlement Claimer", "1")
    {
        xnodeUnitEntitlement = _xnodeUnitEntitlement;
    }

    function claim(address receiver, bytes32 codeHash, uint32 claimBefore, uint8 v, bytes32 r, bytes32 s) external {
        if (block.timestamp > claimBefore) {
            revert ProofExpired();
        }

        address signer = ECDSA.recover(
            _hashTypedDataV4(keccak256(abi.encode(CLAIM_TYPEHASH, receiver, codeHash, claimBefore))), v, r, s
        );
        if (signer != owner()) {
            revert InvalidProof();
        }

        xnodeUnitEntitlement.mint(receiver, uint256(codeHash));
        emit Claimed(receiver, codeHash);
    }
}
