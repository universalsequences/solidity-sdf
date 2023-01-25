// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./core/HTMLBoilerplate.sol";
import "./core/Gen.sol";
import "./sdf/Layers.sol";
import "./sdf/Scenes.sol";
import "./sdf/Layout.sol";
import "./lib/ListUtils.sol";
import "./generative/Puzzle.sol";
import "./core/Vectors.sol";

contract PuzzleMaker {

    using Gen for string;
    using Gen for Gen.Variable;
    using Layers for Layers.Layer;
    using ListUtils for string[];
    using Vectors for string;


    function vertexShader() public pure returns (string memory) {
        return "attribute vec4 aVertexPosition;\\n"
            "void main() {\\n"
            "gl_Position = aVertexPosition;\\n"
            "}\\n";
    }
    
    function fragmentShader() public returns (string memory) {    
        string[] memory sdfs = Layout.gridRect(
                4, 4, 180, 180, [int(145), int(190)], "0.0", 180);
        
        string[3] memory colors = [
            "vec4(1.0, 0.0, 0.0, 1.0)", 
            "vec4(0.4, 0.0, 0.9, 1.0)", 
            "vec4(0.8, 0.6, 0.9, 1.0)"];

        string[][] memory partitioned = Puzzle.partitionAndCombine(
            sdfs, 4, getAlgo());

        Layers.Layer[] memory layers = new Layers.Layer[](partitioned.length);
        Gen.Variable[] memory variables = new Gen.Variable[](partitioned.length);
        Gen.Function[] memory functions = new Gen.Function[](partitioned.length);

        for (uint i=0; i < partitioned.length; i++) {
            // setup the scene with "smooth union" and throw in the sdfs into it
            functions[i] = Scenes.create(
                Scenes.Scene(partitioned[i]), 
                Scenes.OperationType.SMOOTH_UNION, 
                string(abi.encodePacked("scene", Conversion.uint2str(i))),
                ".156"
                );
        
            // save the outputted SDF values to a variable so 
            // that we don't repeat code/recompute in GPU
            variables[i] = Gen.Variable(
                string(abi.encodePacked("sceneSDF", Conversion.uint2str(i))),
                 "vec3", 
                Scenes.gen(partitioned[i], functions[i]));
            string memory sdf = variables[i].name.getX();
            string memory mix = variables[i].name.getZ();
            // create a layer

            string memory color;
            string memory ss;
            {
                ss = Gen.smoothstep("-0.15", "0.056", sdf);
                color = Gen.mix(
                    colors[i%colors.length],
                     "vec4(0.5, 0.5, 0.5, 1.0)",
                    ss
                );
            }
            layers[i] = Layers.create(sdf)
                .withColor(
                    Gen.rand().mult(".068").mult(ss).add(
                        Gen.mix(
                            color
                            ,
                            "vec4(0.4, 0.2, 0.9, 1.0)",
                        mix.pow(".5").mult(".8")))
                )
                .withBlur("0.008");
            if (i % 3 > 0) {
                layers[i] = layers[i].withIntersection(
                    Gen.rand().mult(".039").add(
                        Gen.mix(
                            Gen.black,
                            "vec4(.2, .2, .2, 1.0)",
                            Gen.sub(Gen.uv.getY(), Gen.uv.getX())
                        )
                    )
                );
            }      
        }
         return Gen.fragColor(
            Layers.draw(layers, "vec4(0., 0., 0., 1.0)"), 
            functions, variables);
    }  

    function getAlgo() private returns (int8[] memory) {
        int8[] memory algo = new int8[](16);
        algo[0] = 1;
        algo[1] = 3;
        algo[2] = 4;            
        algo[3] = -1;    
        algo[4] = 4;    
        algo[5] = 3;
        algo[6] = 0;
        algo[7] = 6;
        algo[8] = 5;
        algo[9] = 2;
        algo[10] = 5;
        algo[11] = 6;
        algo[12] = -1;
        algo[13] = 1;
        algo[14] = -1;
        algo[15] = -1;
        return algo;
    }

    function generate() public returns (string memory) {
    
        string memory m = HTMLBoilerplate.withShaders(
            vertexShader(),
            fragmentShader());
        return m;
    }
}
