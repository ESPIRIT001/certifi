// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateAuthentication {
    
    // Structure to hold certificate data
    struct Certificate {
        string courseName;
        string studentName;
        uint256 dateIssued;
        bool isValid;
    }
    
    // Mapping to store certificates by their ID
    mapping(bytes32 => Certificate) public certificates;
    
    // Mapping to store trusted issuers (e.g., Coursera)
    mapping(address => bool) public trustedIssuers;
    
    // Owner of the contract
    address public owner;
    
    // Events
    event CertificateIssued(bytes32 indexed certificateId, string courseName, string studentName, uint256 dateIssued);
    event CertificateRevoked(bytes32 indexed certificateId);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyTrustedIssuer() {
        require(trustedIssuers[msg.sender], "Only trusted issuer can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to add a trusted issuer
    function addTrustedIssuer(address issuer) public onlyOwner {
        trustedIssuers[issuer] = true;
    }

    // Function to remove a trusted issuer
    function removeTrustedIssuer(address issuer) public onlyOwner {
        trustedIssuers[issuer] = false;
    }

    // Function to issue a new certificate
    function issueCertificate(bytes32 certificateId, string memory courseName, string memory studentName, uint256 dateIssued) public onlyTrustedIssuer {
        require(certificates[certificateId].dateIssued == 0, "Certificate already exists");
        certificates[certificateId] = Certificate(courseName, studentName, dateIssued, true);
        emit CertificateIssued(certificateId, courseName, studentName, dateIssued);
    }

    // Function to revoke a certificate
    function revokeCertificate(bytes32 certificateId) public onlyTrustedIssuer {
        require(certificates[certificateId].isValid, "Certificate is not valid");
        certificates[certificateId].isValid = false;
        emit CertificateRevoked(certificateId);
    }

    // Function to verify a certificate
    function verifyCertificate(bytes32 certificateId) public view returns (string memory courseName, string memory studentName, uint256 dateIssued, bool isValid) {
        Certificate memory cert = certificates[certificateId];
        return (cert.courseName, cert.studentName, cert.dateIssued, cert.isValid);
    }
}