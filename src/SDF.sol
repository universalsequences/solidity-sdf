// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GenFunction.sol";
import "./Primitive.sol";
import "./Conversion.sol";

library SDF {
    
    function circle(
        string memory position, 
        string memory radius) public pure returns (string memory) {    
        return string(
            abi.encodePacked(
                "length(uv - ", position, ") - ", radius      
            )
        );
    }

    function circle(
        string memory position, 
        int  radius) public pure returns (string memory) {    
        return string(
            abi.encodePacked(
                "length(uv - ", position, ") - ", Conversion.int2float(radius)
            )
        );
    }

    function rect(
        string memory position, 
        string memory dimensions, 
        string memory corner) public pure returns (string memory) {    
        return string(
            abi.encodePacked(
                "sdfRect(uv - ", position, ", ", dimensions, ", ", corner, ")"      
            )
        );
    }
    
    function genFunctions() public pure returns (string memory) {
        return _sdfRect();
    }

    function union(string memory a, string memory b) public pure returns (string memory) {
        return Primitive.gen("min", a, b);
    }

    function subtraction(string memory a, string memory b) public pure returns (string memory) {
        return Primitive.gen("max", string(abi.encodePacked("-", a)), b);
    }

    function intersection(string memory a, string memory b) public pure returns (string memory) {
        return Primitive.gen("max", a, b);
    }

    
    function _sdfRect() private pure returns (string memory) {
        return GenFunction.gen(
            GenFunction.Function(
                "sdfRect",
                "float",
                "vec2 p, vec2 b, vec4 r",

                // body
                "r.xy = (p.x>0.0)?r.xy : r.zw;\\n"
                "r.x  = (p.y>0.0)?r.x  : r.y;\\n"
                "vec2 q = abs(p)-b+r.x;\\n"
                "return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;\\n"
            )
        );
    }
}