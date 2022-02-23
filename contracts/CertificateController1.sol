/*
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
//  SPDX-License-Identifier: un-licence
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "hardhat/console.sol";

// CertificateController comment...
contract CertificateController {

  // If set to 'true', the certificate control is activated
  bool _certificateControllerActivated;

  // Address used by off-chain controller service to sign certificate
  mapping(address => bool) internal _certificateSigners;

  // A nonce used to ensure a certificate can be used only once
  mapping(address => uint256) internal _checkCount;

  event Checked(address sender);

  constructor(address _certificateSigner, bool activated)  {
    _setCertificateSigner(_certificateSigner, true);
    _certificateControllerActivated = activated;
  }

  /**
   * @dev Modifier to protect methods with certificate control
   */
  modifier isValidCertificate(bytes memory data) {
 bytes memory msgData = msg.data;
        
        bytes32 amount;
        assembly{
          
            amount := mload(add(msgData,68))
        }
       
       
    if(_certificateControllerActivated) {
      require(_certificateSigners[msg.sender] || _checkCertificate(data, uint256(amount), bytes4(msgData)), "54"); // 0x54	transfers halted (contract paused)

      _checkCount[msg.sender] += 1; // Increment sender check count

      emit Checked(msg.sender);
    }

    _;
  }

  /**
   * @dev Modifier to protect methods with certificate control
   */
  /* modifier isValidPayableCertificate(bytes memory data) {

    require(_certificateSigners[msg.sender] || _checkCertificate(data, msg.value, 0x00000000), "54"); // 0x54	transfers halted (contract paused)

    _checkCount[msg.sender] += 1; // Increment sender check count

    emit Checked(msg.sender);
    _;
  } */


  /**
   * @dev Get number of transations already sent to this contract by the sender
   * @param sender Address whom to check the counter of.
   * @return uint256 Number of transaction already sent to this contract.
   */
  function checkCount(address sender) external view returns (uint256) {
    return _checkCount[sender];
  }

  /**
   * @dev Get certificate signer authorization for an operator.
   * @param operator Address whom to check the certificate signer authorization for.
   * @return bool 'true' if operator is authorized as certificate signer, 'false' if not.
   */
  function certificateSigners(address operator) external view returns (bool) {
    return _certificateSigners[operator];
  }

  /**
   * @dev Set signer authorization for operator.
   * @param operator Address to add/remove as a certificate signer.
   * @param authorized 'true' if operator shall be accepted as certificate signer, 'false' if not.
   */
  function _setCertificateSigner(address operator, bool authorized) internal {
    require(operator != address(0)); // Action Blocked - Not a valid address
    _certificateSigners[operator] = authorized;
  }

  /**
   * @dev Get activation status of certificate controller.
   */
  function certificateControllerActivated() external view returns (bool) {
    return _certificateControllerActivated;
  }

  /**
   * @dev Activate/disactivate certificate controller.
   * @param activated 'true', if the certificate control shall be activated, 'false' if not.
   */
  function _setCertificateControllerActivated(bool activated) internal {
    _certificateControllerActivated = activated;
  }

  /**
   * @dev Checks if a certificate is correct
   * @param data Certificate to control
   */
  function _checkCertificate(
    bytes memory data,
    uint256 amount,
    bytes4 functionID
  )
    internal
    view
    returns(bool)
  {
    uint256 counter = _checkCount[msg.sender];

    uint256 e;
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Certificate should be 97 bytes long
    if (data.length != 97) {
      return false;
    }

    // Extract certificate information and expiration time from payload
    assembly {
      // Retrieve expirationTime & ECDSA elements from certificate which is a 97 long bytes
      // Certificate encoding format is: <expirationTime (32 bytes)>@<r (32 bytes)>@<s (32 bytes)>@<v (1 byte)>
      e := mload(add(data, 0x20))

      r := mload(add(data, 0x40))
      s := mload(add(data, 0x60))
      v := byte(0, mload(add(data, 0x80)))
    }

    // Certificate should not be expired
    if (e < block.timestamp) {
      return false;
    }

    if (v < 27) {
      v += 27;
    }

    // Perform ecrecover to ensure message information corresponds to certificate
    if (v == 27 || v == 28) {
      // Extract payload and remove data argument
      address to;
      bytes32 msgData;
      assembly{
        to := mload(add(msgData,36))
      }
      // Pack and hash
      bytes memory pack = abi.encodePacked(
        address(this),
        functionID,
        to,
        amount, // value
        e, // exDate
        counter // nonce
      );
      bytes32 _hash = keccak256(pack);

      // Check if certificate match expected transactions parameters
      if (_certificateSigners[ecrecover(keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            _hash
                        )
                    ), v, r, s)]) {
        return true;
      }
    }
    return false;
  }
  
  function methodHash(bytes4 funcSig, address _to, uint256 _value,uint256 exDate, uint256 _nonce)
        public
        view
        returns (bytes32)
    {
      return keccak256(abi.encodePacked(address(this),funcSig, _to, _value,exDate, _nonce));

    }

}




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
        bytes memory data
    ) external 
    // isValidCertificate(data) 
    {
        console.logBytes(msg.data);
        bytes memory msgData = msg.data;
        bytes4 funId;
        bytes32 arg1;
        bytes32 arg2;
        assembly{
            funId:= mload(add(msgData,32))
            arg1 := mload(add(msgData,36))
            arg2 := mload(add(msgData,68))
        }
        console.logBytes4(funId);
        console.logBytes32(arg1);
        console.logUint(uint256(arg2));
        // transfer(to,value);
    }




// function getSelector(string calldata func) public pure returns(bytes4){
// return bytes4(keccak256(bytes(func)));
// }

}


