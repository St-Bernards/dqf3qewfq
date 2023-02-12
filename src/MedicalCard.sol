// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MedicalCard is ERC721, ERC721URIStorage {
    uint256 private _tokenIds;

    constructor() public ERC721("MedicalCard", "MC") {}

    function createMedicalCard(string memory ipfsLink, address _patient)
        public
        returns (uint256)
    {
        _tokenIds += 1;
        _mint(_patient, _tokenIds);
        _setTokenURI(_tokenIds, ipfsLink);

        return _tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721, ERC721URIStorage)
    {
        ERC721URIStorage._burn(tokenId);
    }

    function changeTokenURI(uint256 tokenId, string memory newURI) public {
        _setTokenURI(tokenId, newURI);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {}
}
