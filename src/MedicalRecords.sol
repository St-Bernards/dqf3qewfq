// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./MedicalCard.sol";

contract Record is Ownable {
    MedicalCard private _medicalCard = new MedicalCard();

    //Mapping of patients addresses to their medical records addresses.
    mapping(address => uint256) private personnToRecord;

    //Mapping of patients addresses to the medicals addresses that can modify their records.
    mapping(address => address) private recordModificationApproval;

    //Whitelist with gas optimization 1/0
    mapping(address => uint256) private medicalWhitelist;

    // mapping people To Delegated
    mapping(address => address) private patientToDelegated;

    function createMedicalRecord(string memory ipfsLink)
        public
        returns (uint256)
    {
        uint256 tokenId = _medicalCard.createMedicalCard(ipfsLink, msg.sender);

        personnToRecord[msg.sender] = tokenId;

        return tokenId;
    }

    function getMedicalRecord() public view returns (uint256) {
        return personnToRecord[msg.sender];
    }

    function addRecordModificationApproval(address _medical, uint256 _tokenId)
        public
    {
        require(
            medicalWhitelist[_medical] == 1,
            "Only whitelisted medical can modify records."
        );
        address _patient = _medicalCard.ownerOf(_tokenId);
        require(
            _patient == msg.sender ||
                patientToDelegated[_patient] == msg.sender,
            "Only patient or delegated can modify records."
        );
        recordModificationApproval[_patient] = _medical;
    }

    function removeRecordModificationApproval(address _patient) public {
        require(
            patientToDelegated[_patient] == msg.sender ||
                msg.sender == _patient,
            "Only delegated can modify records."
        );
        recordModificationApproval[_patient] = address(0);
    }

    // the medical ater modifying the ips record will get a new IPFS URI and will modify the mapping in the medical record

    function getURI(address _patient) public view returns (string memory) {
        require(
            recordModificationApproval[_patient] == msg.sender ||
                _patient == msg.sender ||
                patientToDelegated[_patient] == msg.sender,
            "Only approved medical, patient or delegated can see records."
        );
        uint256 cardID = personnToRecord[_patient];
        return _medicalCard.tokenURI(cardID);
    }

    function setNewURI(address _patient, string memory newURI) public {
        require(
            recordModificationApproval[_patient] == msg.sender,
            "Only approved medical can modify records."
        );
        uint256 cardID = personnToRecord[msg.sender];
        _medicalCard.changeTokenURI(cardID, newURI);
        recordModificationApproval[msg.sender] = address(0);
    }

    function delegateMedicalRecord(uint256 _tokenId, address _to) public {
        require(
            _medicalCard.ownerOf(_tokenId) == msg.sender,
            "Only owner can delegate medical record."
        );
        patientToDelegated[msg.sender] = _to;
    }

    function endDelegation(uint256 _tokenId) public {
        require(
            _medicalCard.ownerOf(_tokenId) == msg.sender,
            "Only owner can end delegation."
        );
        patientToDelegated[msg.sender] = address(0);
    }

    function addMedicalToWhitelist(address _medical) public onlyOwner {
        medicalWhitelist[_medical] = 1;
    }
}
