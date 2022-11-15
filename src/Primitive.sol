// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GenFunction.sol";
import "./SDF.sol";

library Primitive {
    function gen(string memory funcName, string memory a) public pure returns (string memory) {
        return string(abi.encodePacked(funcName, "(", a, ")"));
    }

    function gen(string memory funcName, string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(funcName, "(", a, ",", b, ")"));
    }

    function gen(string memory funcName, string memory a, string  memory b, string memory c) public pure returns (string memory) {
        return string(abi.encodePacked(funcName, "(", a, ",", b, ",", c, ")"));
    }
}