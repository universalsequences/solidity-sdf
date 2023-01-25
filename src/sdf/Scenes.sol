// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../core/Gen.sol";
import "../lib/Conversion.sol";

library Scenes {
    enum OperationType{ UNION, SMOOTH_UNION }

    struct Scene {
        string[] sdfs;
    }

    // a scene is a collection of SDFs along w/ a way to operate on them
    // can use a scene to calcutate the sdf/index/mix
    // the goal is to smooth union multiple SDFs and return vec3(sdf,index,mix)
    function create(Scene memory scene,  OperationType operationType, string memory name, string memory k) public pure returns (Gen.Function memory) {
        string memory body = string(abi.encodePacked(
            "vec3 scene = vec3(sdf0, 0.0, 0.0);\\n"
            "float mAccumulator = 0.0;\\n"
            "float d1 = 0.0;\\n"
            "float d2 = 0.0;\\n"
            "float k=", k, ";\\n"
            "float h=0.0;\\n"
            "float m=0.0;\\n"
            "float s=0.0;\\n"
        ));

        for (uint256 i=1; i < scene.sdfs.length; i++) {
            if (operationType == OperationType.UNION) {
                body = string(abi.encodePacked(
                    body,
                    union(i)
                ));
            } else if (operationType == OperationType.SMOOTH_UNION) {
                body = string(abi.encodePacked(
                    body,
                    smoothUnion(i)
                ));
            }
        }
        body = string(abi.encodePacked(
            body,
            "return scene;\\n"
        ));

        // return the function as we need to be able to call it
        return Gen.Function(
            name,
            "vec3",
            getDefinitionParams(scene.sdfs.length),
            body
        );
    }  

    function smoothUnion(uint256 i) public pure returns (string memory) {
        string memory body = string(abi.encodePacked(
            "d2 = scene.x;\\n",
            "d1 = sdf", Conversion.uint2str(i), ";\\n"
            "h = max(k - abs(d1-d2), 0.0)/k;\\n"
            "m = pow(h, 1.5)*0.5;\\n"
            "s = m*k*(1.0/1.5);\\n"
            "mAccumulator += h*h*", Conversion.uint2str(i), ".0;\\n"
            "if (d1 < scene.x) {\\n"
            " scene = vec3(d1 - s,", Conversion.uint2str(i), ".0, mAccumulator + m);"
            "}\\n"
            "else {\\n"
            "  scene = vec3(d2 - s, scene.y, mAccumulator + m);\\n"
            "}\\n"
        ));
        
        return body;
    }

    function union(uint256 i) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "if (scene.x > sdf", Conversion.uint2str(i), ") {\\n"
                "  scene.x = sdf", Conversion.uint2str(i), ";\\n"
                "  scene.y = ", Conversion.uint2str(i), ".0;\\n"
               "}\\n"));
    }

    function gen(string [] memory sdfs, Gen.Function memory func) public pure returns (string memory) {
        return string(abi.encodePacked(
            func.name, "(", getCallParams(sdfs), ")"
        ));
    }

    function gen(Scene memory scene, Gen.Function memory func) public pure returns (string memory) {
        return string(abi.encodePacked(
            func.name, "(", getCallParams(scene.sdfs), ")"
        ));
    }

    function getCallParams(string [] memory sdfs) private pure returns (string memory) {
        string memory joined = "";
        for (uint256 i=0; i < sdfs.length; i++) {
            joined = string(abi.encodePacked(
                joined, sdfs[i], (i < sdfs.length-1 ? "," : "")
            ));
        }
        return joined;
    }
    function getDefinitionParams(uint256 len) private pure returns (string memory) {
        string memory joined = "";
        for (uint256 i=0; i < len; i++) { 
            joined = string(abi.encodePacked(
                joined, "float sdf", Conversion.uint2str(i), (i < len-1 ? "," : "")
            ));
        }
        return joined;
    }
}