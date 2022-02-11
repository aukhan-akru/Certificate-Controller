
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./CertificateController.sol";
import "hardhat/console.sol";
contract SimpleToken is ERC20,CertificateController{

    constructor(
    )  ERC20("simple token", "ST") 
    CertificateController(msg.sender,true)
    {
        
        _mint(msg.sender, 100000000 ether);
    }

// "transferWithData(address,uint256,bytes)"

    function transferWithData(
        address to,
        uint256 value,
        bytes memory data,
        bytes32 metahash,
        uint256 nonce
    ) external isValidCertificate(data,metahash,nonce) {
    
    transfer(to,value);
    }



function getSelector(string calldata func) public pure returns(bytes4){
return bytes4(keccak256(bytes(func)));
}

}