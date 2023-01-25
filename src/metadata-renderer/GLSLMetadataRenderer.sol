// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import './IMetadataRenderer.sol';
import '../lib/Base64.sol';
import {MetadataRenderAdminCheck} from './MetadataRenderAdminCheck.sol';
import '../GenerativeArt.sol';
contract GLSLMetadataRenderer is IMetadataRenderer, MetadataRenderAdminCheck {

    mapping(address => string) public uriByContract;

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return string(abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(bytes(
            abi.encodePacked(
              "{",
              "\"name\": \"", tokenName(msg.sender, tokenId), "\", ",
              "\"image\": \"", GenerativeArt.generate(), "\""
              "}"
            )))));
    }

    function tokenName(address from, uint256 tokenId) internal view returns (string memory) {
        return "yo";
    }

    function contractURI() external view returns (string memory) {
        string memory uri = uriByContract[msg.sender];
        if (bytes(uri).length == 0) revert();
        return uri;
    }

    function initializeWithData(bytes memory data) external {
        (string memory initialContractURI) = abi   
            .decode(data, (string));

        uriByContract[msg.sender] = initialContractURI;

    }

}