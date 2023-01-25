// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../lib/Conversion.sol";

library Vectors {
    function vec2(
        string memory r,
        string memory g)
        public pure returns (string memory){
        return string(abi.encodePacked("vec2(", r, ",", g, ")"));
    }

    function vec2(
        int r,
        int g)
        public pure returns (string memory){
        return string(
            abi.encodePacked(
                "vec2(", 
                Conversion.int2float(r), ",", 
                Conversion.int2float(g), ")"));
    }

    function vec3(
        string memory r,
        string memory g,
        string memory b)
        public pure returns (string memory){
        return string(abi.encodePacked("vec3(", r, ",", g, ",", b, ")"));
    }

    function vec3(
        int r,
        int g,
        int b)
        public pure returns (string memory){
        return string(
            abi.encodePacked(
                "vec3(", 
                Conversion.int2float(r), ",", 
                Conversion.int2float(g), ",",
                Conversion.int2float(b), ")"
                ));
    }

    function vec4(
        string memory r,
        string memory g,
        string memory b,
        string memory a)
        public pure returns (string memory){
        return string(abi.encodePacked("vec4(", r, ",", g, ",", b, ",", a, ")"));
    }

    function vec4(
        int r,
        int g,
        int b,
        int a)
        public pure returns (string memory){
        return string(
            abi.encodePacked(
                "vec4(", 
                Conversion.int2float(r), ",", 
                Conversion.int2float(g), ",",
                Conversion.int2float(b), ",",
                Conversion.int2float(a), ")"
                ));
    }

    // following extract fields from vectors (x,y,z,w)
    function getX(string memory a) public pure returns (string memory) {
        return _extract(a, "x");
    }

    function getY(string memory a) public pure returns (string memory) {
        return _extract(a, "y");
    }

    function getZ(string memory a) public pure returns (string memory) {
        return _extract(a, "z");
    }


    function getW(string memory a) public pure returns (string memory) {
        return _extract(a, "w");
    }

    function _extract(string memory a, string memory field) private pure returns (string memory) {
        return string(abi.encodePacked(
            a, ".", field
        ));
    }

}