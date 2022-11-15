// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./HTMLBoilerplate.sol";
import "./Gen.sol";
import "forge-std/console.sol";
import "./Layers.sol";
import "./Scenes.sol";

contract GLSL {
    function vertexShader() public returns (string memory) {
        return "attribute vec4 aVertexPosition;\\n"
            "void main() {\\n"
            "gl_Position = aVertexPosition;\\n"
            "}\\n";
    }

    function gridRect(int rows, int cols, int w, int h, int spacing) public returns (string [] memory) {
        string[] memory rects  = new string[](uint(rows*cols));
        int c=0;
        // start at -0.2, -0.2
        int x = - (w+spacing)*cols/2 + w;
        int y = - (h+spacing)*rows/2 + h;
        for (int i=0; i < rows; i++) {
            for (int j=0; j < cols; j++) {
                rects[uint(c++)] = SDF.rect(
                    Gen.vec2(x + i*(w+spacing), y + j*(h+spacing)),
                    Gen.vec2(w, h),
                    "vec4(.1, .1, .1, .1)"
                ) ;
            }
        }
        return rects;
    }

    function fragmentShader() public returns (string memory) {
        string[] memory sdfs = gridRect(4, 4, 100, 100, 150);
        
        // setup the scene with "smooth union" and throw in the sdfs into it
        GenFunction.Function memory sceneFn = Scenes.genFunction(
            Scenes.Scene(sdfs), Scenes.OperationType.SMOOTH_UNION, "scene1", "0.25");
        
        // save the sdf to a variable so that we don't repeat code/recompute in GPU
        Gen.Variable[] memory variables = new Gen.Variable[](1);
        variables[0] = Gen.variable(
            "sceneSDF", "vec3", Scenes.gen(sdfs, sceneFn));

        GenFunction.Function [] memory funcs = new GenFunction.Function[](1);
        funcs[0] = sceneFn;

        Layers.Layer[] memory layers = new Layers.Layer[](2);
        layers[0] = Layers.withColor(
            Layers.create(Gen.getX(variables[0].name)),
            Gen.mix(
                Gen.white, 
                "vec4(1.0, .3, .8, 1.0)", 
                Gen.getZ(variables[0].name))
        );

        layers[1] = Layers.withIntersection(
            Layers.withColor(
                Layers.create(sdfs[0]), 
                Gen.mix(
                    "vec4(1.0, 0.0, 0.0, 1.0)",
                    Gen.white,
                    Gen.smoothstep("0.09", "-0.2", sdfs[0]))
            ),
            Gen.black);

        return Gen.fragColor(Layers.draw(layers, Gen.black), "", funcs, variables);
    }

    function generate() public returns (string memory) {
        string memory m = HTMLBoilerplate.withShaders(
            vertexShader(),
            fragmentShader());
        //console.log(m);
        return m;
    }
}
