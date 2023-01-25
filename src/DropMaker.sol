// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; 
import './metadata-renderer/IZoraNFTCreator.sol';
import './metadata-renderer/IERC721Drop.sol';

contract DropMaker {

    IZoraNFTCreator creator;
    IERC721Drop.SalesConfiguration salesConfig;

    constructor(address creatorAddress) {
        creator = IZoraNFTCreator(creatorAddress);


        salesConfig = IERC721Drop.SalesConfiguration({
            publicSalePrice: 0,
            maxSalePurchasePerAddress: 10,
            publicSaleStart: 0,
            publicSaleEnd: 0,
            presaleStart: 0,
            presaleEnd: 0,
            presaleMerkleRoot: 0x0
            });
    }

    // A reusable function for creating new drops using Zoras Drop contracts
    // with the initial media set
    function newDrop(
      string memory name,
      string memory symbol,
      address fundsRecipient,
      address metadataRenderer,
      address defaultAdmin
      ) public payable returns (address)
    {
        return creator.setupDropsContract(
          name,
          symbol,
          defaultAdmin,
          1000,
          500,
          payable(fundsRecipient),
          salesConfig,
          IMetadataRenderer(metadataRenderer),
          abi.encode(
            "contractURI" // is this relevant?
                     ));
    }
}