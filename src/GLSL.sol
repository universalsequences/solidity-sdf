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

contract GLSL {

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
        // color1: 0.28, 0.914, 0.34
        // color2: 0.636, 1, 0.375
        // grey: 0.30, .30, .30
        Gen.Variable[] memory variables = new Gen.Variable[](1);
        Gen.Function [] memory functions = new Gen.Function[](1);

        {
            
            string[] memory sdfs = Layout.gridRect(
                4, 4, 100, 100, 150, getWidths(), getHeights());

            sdfs = sdfs.prune(getIndicesToPrune());

            // setup the scene with "smooth union" and throw in the sdfs into it
            Gen.Function memory sceneFn = Scenes.create(
                Scenes.Scene(sdfs), 
                Scenes.OperationType.SMOOTH_UNION, 
                "scene1", 
                ".38");
        
            // save the sdf to a variable so that we don't repeat code/recompute in GPU
            variables[0] = Gen.Variable(
                "sceneSDF", "vec3", Scenes.gen(sdfs, sceneFn));

            functions[0] = sceneFn;
        }  

        string memory color;
        {
            string memory sdf;
            string memory mix;
            string memory powderMix;
            Layers.Layer[] memory layers = new Layers.Layer[](1);
            {
                sdf = variables[0].name.getX();
                mix = variables[0].name.getY();
                powderMix = mix.pow("2.0");
            }
            layers[0] = Layers.create(sdf).withColor(
                Gen.mix(
                    Gen.black,
                    Gen.white,
                    Gen.smoothstep(
                        "-.08",
                        "0.001", 
                        sdf.mult(powderMix)
                    )
                )
            );
            color = Layers.draw(layers, Gen.black);
        }

        return Gen.fragColor(color, functions, variables);
    }

    function getWidths() private returns (int[] memory) {
        int[] memory widths = new int[](16);
        widths[0] = 100;
        widths[1] = 0;
        widths[2] = 300;            
        widths[3] = 0;    
        widths[4] = 100;    
        widths[5] = 0;
        widths[6] = 0;
        widths[7] = 0;
        widths[8] = 200;
        widths[9] = 100;
        widths[10] = 100;
        widths[11] = 100;
        widths[12] = 300;
        widths[13] = 0;
        widths[14] = 100;
        widths[15] = 0;
        return widths;
    }

    function getHeights() private returns (int[] memory) {
        int[] memory heights = new int[](16);
            heights[0] = 100;
            heights[1] = 0;
            heights[2] = 100;
            heights[3] = 0;
            heights[4] = 300;
            heights[5] = 0;
            heights[6] = 100;
            heights[7] = 0;
            heights[8] = 100;
            heights[9] = 100;
            heights[10] = 100;
            heights[11] = 100;
            heights[12] = 100;
            heights[13] = 0;
            heights[14] = 100;
            heights[15] = 0;
        return heights;
    }

    function getIndicesToPrune() public pure returns (uint[] memory) {
        uint[] memory indicesToPrune = new uint256[](11);
        indicesToPrune[0] = 1;
        indicesToPrune[1] = 3;
        indicesToPrune[2] = 5;
        indicesToPrune[3] = 6;
        indicesToPrune[4] = 7;
        indicesToPrune[5] = 13;
        indicesToPrune[6] = 15;
        indicesToPrune[7] = 8;
        indicesToPrune[8] = 9;
        indicesToPrune[9] = 14;
        indicesToPrune[10] = 10;
        return indicesToPrune;
    }

    function generate() public returns (string memory) {
        string memory m = HTMLBoilerplate.withShaders(
            vertexShader(),
            fragmentShader());
        return m;
    }
}
