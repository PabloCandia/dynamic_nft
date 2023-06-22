pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// The Provable API provides oracle services and is one possible source of external data.
import "github.com/provable-things/ethereum-api/provableAPI.sol";

// ERC721 contract inherits from the OpenZeppelin's ERC721 contract and the Provable API
contract DynamicNFT is ERC721, usingProvable {
    // The contract owner's address
    address private _contractOwner;

    // Mapping from token ID to metadata
    mapping (uint256 => string) private _tokenMeta;

    // Constructor that sets the contract owner's address and token details
    constructor() ERC721("DynamicNFT", "DNFT") {
        _contractOwner = msg.sender; // The sender is the owner
    }

    // Minting new token
    function mint(address to, uint256 tokenId, string memory meta) public {
        // Only the contract owner can mint new tokens
        require(msg.sender == _contractOwner, "Only contract owner can mint");

        // Check if the token already exists
        require(!_exists(tokenId), "ERC721: token already minted");

        // Call the internal _mint function from the inherited ERC721 contract
        _mint(to, tokenId);

        // Set the initial metadata of the token
        _setTokenMeta(tokenId, meta);
    }

    // Internal function to set the token metadata
    function _setTokenMeta(uint256 tokenId, string memory meta) internal virtual {
        // Check if the token exists before setting the metadata
        require(_exists(tokenId), "ERC721: URI set of nonexistent token");

        // Set the metadata in the mapping
        _tokenMeta[tokenId] = meta;
    }

    // Public function to get the metadata of a token
    function tokenMeta(uint256 tokenId) public view virtual returns (string memory) {
        // Check if the token exists before getting the metadata
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");

        // Return the metadata from the mapping
        return _tokenMeta[tokenId];
    }

    // Update the metadata of a token with data from an oracle
    function updateMetaWithOracle(uint256 tokenId) public payable {
        // Only the contract owner can update the metadata
        require(msg.sender == _contractOwner, "Only contract owner can update meta");

        // This line starts the Provable query (not free, needs some Ether in contract)
        // Returns random datasource as example. Replace "random" with the required datasource
        // For more information, refer to Provable data-sources: https://docs.provable.xyz/#data-sources
        provable_query("URL", "json(https://api.provable.xyz/random.json).result");
    }

    // The Provable API will call this function when it has a result
    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) override public {
        // Check that the Provable API has sent the callback
        require(msg.sender == provable_cbAddress());

        // Update the metadata of a token with the result from the oracle
        _setTokenMeta(1, _result); // For simplicity, token 1 is updated. Replace it with required tokenId
    }
}
