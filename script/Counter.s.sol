// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/metadata-renderer/GLSLMetadataRenderer.sol";
import "../src/DropMaker.sol";
import "../src/GLSLMinter.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        GLSLMinter minter = new GLSLMinter();
        DropMaker x = new DropMaker(address(0xEf440fbD719cC5c3dDCD33b6f9986Ab3702E97A5));
        GLSLMetadataRenderer r = new GLSLMetadataRenderer();
        minter.purchase(payable(x.newDrop("GLSLX", "GLSL", address(0), address(r), address(minter))));
        vm.stopBroadcast();

    }
}
