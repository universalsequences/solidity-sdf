// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ALEZ.sol";

contract GLSLTest is Test {
    ALEZ public puzzleMaker;

    function setUp() public {
        puzzleMaker = new ALEZ();
    }

    function testSetNumber() public {
        puzzleMaker.generate();
    }
}
