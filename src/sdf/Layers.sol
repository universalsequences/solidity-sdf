// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../core/Gen.sol";
import "./SDF.sol";

library Layers {
    using Gen for string;

    struct Layer {
        string sdf;
        string blur;
        string color;
        bool intersect;
        string intersectionColor;
    }

    function create(
        string memory sdf) 
    public pure returns (Layer memory) {
        return Layer(
            sdf,
            "0.006",
            Gen.black,
            false,
            ""
        );
    }

    function create(
        string memory sdf, 
        string memory blur, 
        string memory color) 
    public pure returns (Layer memory) {
        return Layer(
            sdf,
            blur,
            color,
            false,
            ""
        );
    }

    function withColor(Layer memory layer, string memory color) public pure returns  (Layer memory) {
        layer.color = color;
        return layer;
    }

    function withBlur(Layer memory layer, string memory blur) public pure returns  (Layer memory) {
        layer.blur = blur;
        return layer;
    }

    function withIntersection(Layer memory layer, string memory color) public pure returns  (Layer memory) {
        layer.intersect = true;
        layer.intersectionColor = color;
        return layer;
    }

    function newLayer(
        string memory sdf, 
        string memory blur, 
        string memory color,
        bool intersection,
        string memory intersectionColor) 
    public pure returns (Layer memory) {
        return Layer(
            sdf,
            blur,
            color,
            intersection,
            intersectionColor
        );
    }

    function draw(Layer memory layer, string memory background) public pure returns( string memory) {
        return Gen.mix(
            background,
            layer.color,
                Gen.smoothstep(
                layer.blur,
                "0.0", //layer.blur.mult(layer.sdf),
                layer.sdf)
        );
    }

    function draw(Layer[] memory layers, string memory background) public pure returns (string memory) {
        string memory unionSoFar = "10000.0";
        for (uint256 i=0; i < layers.length; i++) {
            background = draw(layers[i], background);
            if (i > 0 && layers[i].intersect) {
                background = draw(Layer(
                    SDF.intersection(unionSoFar, layers[i].sdf),
                    layers[i].blur,
                    layers[i].intersectionColor,
                    false,
                    ""
                ), background);
            }
            unionSoFar = SDF.union(unionSoFar, layers[i].sdf);
        }
        return background;
    }
}