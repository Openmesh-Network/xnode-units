// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library EIP712Utils {
    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    function getDomainSeparator(EIP712Domain memory domain) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                TYPE_HASH,
                keccak256(bytes(domain.name)),
                keccak256(bytes(domain.version)),
                domain.chainId,
                domain.verifyingContract
            )
        );
    }

    // structHash: keccak256(abi.encode(TYPEHASH, arg1, arg2, arg3, ...));
    function getTypedDataHash(bytes32 domainSeparator, bytes32 structHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
