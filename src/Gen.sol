// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./GenFunction.sol";
import "./SDF.sol";
import "./Primitive.sol";
import "./Conversion.sol";

library Gen {

    uint8 constant public DECIMAL_PLACES = 3; // 3 ==> 0.003 , 30 => 0.03, 300 => 0.3 => 3000 => 3

    string constant public x = "gl_FragCoord.x";
    string constant public y = "gl_FragCoord.y";
    string constant public xy = "gl_FragCoord.xy";
    string constant public res = "res";
    string constant public _uv = "((2.0*gl_FragCoord.xy-res)/res.y)";
    string constant public uv = "uv";
    string constant black = "vec4(0.0, 0.0 , 0.0, 1.0)";
    string constant white = "vec4(1.0, 1.0 , 1.0, 1.0)";

    struct Variable {
        string name;
        string glType;
        string value;
    }

    function variable(string memory name, string memory glType, string memory value) public pure returns ( Variable memory) {
        return Variable(
            name, glType, value
        );
    }
    
    function add(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, "+", b));
    }

    function sub(string memory a, string memory b) public pure returns (string memory){
        return string(abi.encodePacked(a, "-", b));
    }

    function mult(string memory a, string memory b) public pure returns (string memory){
        return string(abi.encodePacked(a, "*", b));
    }

    function div(string memory a, string memory b) public pure returns (string memory){
        return string(abi.encodePacked(a, "/", b));
    }

    function mod(string memory a, string memory b) public pure returns (string memory){
        return Primitive.gen("mod", a, b);
    }

    function length(string memory a) public pure returns (string memory){
        return Primitive.gen("length", a);
    }

    function smoothstep(string memory a, string memory b, string memory c) public pure returns (string memory) {
        return Primitive.gen("smoothstep", a, b, c);
    }

    function mix(string memory a, string memory b, string memory c) public pure returns (string memory) {
        return Primitive.gen("mix", a, b, c);
    }

    function fragColor(string memory a) public pure returns (string memory){
        return fragColor(a, "");
    }

    function fragColor(string memory a, string memory preamble) public pure returns (string memory){
        return string(
            abi.encodePacked(
                "precision highp float;\\n"
                "uniform vec2 res;\\n",
                SDF.genFunctions(),
                "void main() {\\n",
                "vec2 uv = ", _uv, ";\\n",
                 preamble,
                "gl_FragColor = ", a, ";\\n}"));
    }

    function fragColor(string memory a, string memory preamble, GenFunction.Function[] memory functions, Variable[] memory variables) public pure returns (string memory){
        return string(
            abi.encodePacked(
                "precision highp float;\\n"
                "uniform vec2 res;\\n",
                SDF.genFunctions(),
                GenFunction.gens(functions),
                "void main() {\\n",
                "vec2 uv = ", _uv, ";\\n",
                preamble,
                generateVariables(variables),
                "gl_FragColor = ", a, ";\\n}"));
    }

    function generateVariables(Variable[] memory variables) public pure returns (string memory) {
        string memory code = "";
        for (uint256 i=0; i < variables.length; i++) {
            code = string(abi.encodePacked(
                variables[i].glType, " ", variables[i].name, " = ", variables[i].value, ";\\n"));
        }
        return code;
    }

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
 
