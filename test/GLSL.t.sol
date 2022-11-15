// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GLSL.sol";
import "../src/Conversion.sol";

contract GLSLTest is Test {
    GLSL public glsl;

    function setUp() public {
        glsl = new GLSL();
    }

    function testSetNumber() public {
        glsl.generate();
        
        assertEq(
            Conversion.int2float(-3),
            "-0.003");
    }
}
