// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Gen {

    uint8 constant public DECIMAL_PLACES = 3; // 3 ==> 0.003 , 30 => 0.03, 300 => 0.3 => 3000 => 3

    string constant public time = "time";
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

    struct Function {
        string name;
        string returnType;
        string params;
        string body;
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

    function primitive(string memory funcName, string memory a) public pure returns (string memory) {
        return string(abi.encodePacked(funcName, "(", a, ")"));
    }

    function primitive(string memory funcName, string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(funcName, "(", a, ",", b, ")"));
    }

    function primitive(string memory funcName, string memory a, string  memory b, string memory c) public pure returns (string memory) {
        return string(abi.encodePacked(funcName, "(", a, ",", b, ",", c, ")"));
    }

    function mod(string memory a, string memory b) public pure returns (string memory){
        return primitive("mod", a, b);
    }

    function pow(string memory a, string memory b) public pure returns (string memory){
        return primitive("pow", a, b);
    }

    function length(string memory a) public pure returns (string memory){
        return primitive("length", a);
    }

    function fwidth(string memory a) public pure returns (string memory) {
        return primitive("fwidth", a);
    }

    function sin(string memory a) public pure returns (string memory) {
        return primitive("sin", a);
    }

    function cos(string memory a) public pure returns (string memory) {
        return primitive("cos", a);
    }

    function atan(string memory a, string memory b) public pure returns (string memory) {
        return primitive("atan", a, b);
    }

    function smoothstep(string memory a, string memory b, string memory c) public pure returns (string memory) {
        return primitive("smoothstep", a, b, c);
    }

    function mix(string memory a, string memory b, string memory c) public pure returns (string memory) {
        return primitive("mix", a, b, c);
    }

    function rand() public pure returns (string memory) {
        return "fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453)";
    }

    function fragColor(string memory a) public pure returns (string memory){
        Function[] memory functions = new Function[](0);
        Variable[] memory variables = new Variable[](0);
        return fragColor(a, functions, variables);
    }

    function fragColor(
        string memory a, 
        Function[] memory functions, 
        Variable[] memory variables) public pure returns (string memory){
        return string(
            abi.encodePacked(
                "precision highp float;\\n"
                "uniform float time;\\n"
                "uniform vec2 res;\\n",
                SDF_FUNCTIONS,
                gen(functions),
                "void main() {\\n",
                "vec2 uv = ", _uv, ";\\n",
                generateVariables(variables),
                "gl_FragColor = ", a, ";\\n}"));
    }

    function generateVariables(Variable[] memory variables) public pure returns (string memory) {
        string memory code = "";
        for (uint256 i=0; i < variables.length; i++) {
            code = string(abi.encodePacked(
                code,
                variables[i].glType, " ", variables[i].name, " = ", variables[i].value, ";\\n"));
        }
        return code;
    }

    /**
     Functions for generating different types (functions & variables)
     */
    function gen(Function memory func) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                func.returnType, " ", func.name, "(", func.params, ") {\\n",
                func.body,
                "\\n",
                "}\\n"
            )
        );
    }
  
    function gen(Function[] memory func) public pure returns (string memory) {
        string memory code = "";

        for (uint256 i=0; i < func.length; i++) {
            code = string(abi.encodePacked(code, gen(func[i]), "\\n"));
        }
        return code;
    }

    string constant public SDF_FUNCTIONS = "mat2 rotate2D(float angle) {\\n"
    "return mat2(\\n"
    "cos(angle), -sin(angle),sin(angle),cos(angle));\\n"
    "}\\n"
    "float sdfRect(vec2 p, vec2 b, vec4 r, float angle) {\\n"
    "r.xy = (p.x>0.0)?r.xy : r.zw;\\n"
    "r.x  = (p.y>0.0)?r.x  : r.y;\\n"
    "p *= rotate2D(angle);\\n"
    "vec2 q = abs(p)-b+r.x;\\n"
    "return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;\\n"
    "}\\n";
}
 
