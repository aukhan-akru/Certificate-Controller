//  SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";
import "./CertificateController.sol";
contract SimpleToken is ERC20, CertificateController {
    constructor()
        ERC20("simple token", "ST")
        CertificateController(msg.sender, true)
    {
        _mint(msg.sender, 100000000 ether);
    }

    function issue(
        address to,
        uint256 value,
        bytes memory data
    ) external isValidCertificate(data) {
        transfer(to, value);
    }

    function getSelector(string calldata func) public pure returns (bytes4) {
        return bytes4(keccak256(bytes(func)));
    }
}
