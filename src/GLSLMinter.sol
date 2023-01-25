// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import './metadata-renderer/IERC721Drop.sol';

contract GLSLMinter  {

    /**
     * This is the point of entry to minting a remix.
     * Can be used by multiple drop contracts (for example, for different songs)
     */
    function purchase(
      address payable dropsContractAddress
      ) public payable
    {
        // First mint a blank token
        address to = msg.sender;
        IERC721Drop(dropsContractAddress)
            .adminMint(to, 1);
    }
}