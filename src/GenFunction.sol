// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library GenFunction {
    struct Function {
        string name;
        string returnType;
        string params;
        string body;
    }

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

     function gens(Function[] memory func) public pure returns (string memory) {
        string memory x = "";

        for (uint256 i=0; i < func.length; i++) {
            x = string(abi.encodePacked(x, gen(func[i]), "\\n"));
        }
        return x;
    }
}