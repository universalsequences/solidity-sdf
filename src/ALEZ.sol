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
import "forge-std/console.sol";

contract ALEZ {

    using Gen for string;
    using Gen for Gen.Variable;
    using Layers for Layers.Layer;
    using Vectors for string;
    using ListUtils for string[];

    function vertexShader() public pure returns (string memory) {
        return "attribute vec4 aVertexPosition;\\n"
            "void main() {\\n"
            "gl_Position = aVertexPosition;\\n"
            "}\\n";
    }
    
    function fragmentShader() public  returns  (string memory) {   
        string[] memory sdfs = Layout.gridRect(
                4, 4, 180, 180, [int(145), int(195)], "0.0", 180);
        string[3] memory colors = [
            "vec4(.86, 0.77, 0.77, 1.0)", 
            "vec4(0.914, 0.85, 0.92, 1.0)", 
            "vec4(0.9, 0.95, 0.94, 1.0)"
            ];

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

        }

        for (uint i=0; i < partitioned.length; i++) {
            string memory sdf = variables[i].name.getX();
            string memory mixAvg = variables[i].name.getZ();
            // create a layer

            string memory color;
            string memory ss;
            {
                ss = Gen.smoothstep("-0.15", "0.056", sdf);
                color = Gen.mix(
                    colors[i%colors.length],
                     "vec4(0.4, 0.35, 0.98, 1.0)",
                    ss
                );
            }
            layers[i] = Layers.create(sdf)
                .withColor(
                    Gen.rand().mult(".068").mult(ss).add(
                        Gen.mix(
                            color,
                            Gen.mix(
                                Gen.black,
                                "vec4(1.0, 0.90, 0.9, 1.0)",
                                Gen.mult(Gen.uv.getY(), Gen.uv.getX())),
                        mixAvg.pow(".5").mult(".8")))
                )
                .withBlur("0.008");
            if (i % 3 > 0) {
                layers[i] = layers[i].withIntersection(
                    Gen.rand().mult(".039").add(
                        Gen.mix(
                            "vec4(.96, .84, .87, 1.0)",
                            "vec4(.86, .86, .93, 1.0)",
                            Gen.sub(Gen.uv.getY(), Gen.uv.getX())
                        )
                    )
                );
            }      
        }

        string memory grad = Gen.mix(
            Gen.black,
            "vec4(.09, .09, .12, 1.0)",
            Gen.uv.getX().mult(Gen.uv.getY())
        );

         return Gen.fragColor(
            Layers.draw(layers, grad.add(Gen.rand().mult("0.06"))), 
            functions, variables);
    }  

    function getAlgo() private pure returns (int8[] memory) {
        int8[] memory algo = new int8[](16);
        algo[0] = -1;
        algo[1] = 4;
        algo[2] = 6;            
        algo[3] = 6;    
        algo[4] = 3;    
        algo[5] = 4;
        algo[6] = 4;
        algo[7] = -1;
        algo[8] = -1;
        algo[9] = -1;
        algo[10] = -1;
        algo[11] = 2;
        algo[12] = -1;
        algo[13] = -1;
        algo[14] = -1;
        algo[15] = 0;
        return algo;
    }

    function generate() public returns (string memory) {
        string memory m = HTMLBoilerplate.withShaders(
            vertexShader(),
            fragmentShader());
        return m;
    }
}
