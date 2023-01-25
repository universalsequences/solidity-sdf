// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../core/Gen.sol";
import "../lib/Conversion.sol";

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
        string memory corner,
        string memory rotation) public pure returns (string memory) {    
        return string(
            abi.encodePacked(
                "sdfRect(uv - ", position, ", ", dimensions, ", ", corner, ", ", rotation, ")"      
            )
        );
    }
    
    function union(string memory a, string memory b) public pure returns (string memory) {
        return Gen.primitive("min", a, b);
    }

    function subtraction(string memory a, string memory b) public pure returns (string memory) {
        return Gen.primitive("max", string(abi.encodePacked("-", a)), b);
    }

    function intersection(string memory a, string memory b) public pure returns (string memory) {
        return Gen.primitive("max", a, b);
    }

    
    function _sdfRect() private pure returns (string memory) {
        return Gen.gen(
            Gen.Function(
                "sdfRect",
                "float",
                "vec2 p, vec2 b, vec4 r, float angle",

                // body
                "r.xy = (p.x>0.0)?r.xy : r.zw;\\n"
                "r.x  = (p.y>0.0)?r.x  : r.y;\\n"
                "p *= rotate2D(angle);\\n"
                "vec2 q = abs(p)-b+r.x;\\n"
                "return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;\\n"
            )
        );
    }
}

