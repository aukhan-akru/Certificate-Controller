
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "hardhat/console.sol";


contract CertificateControllerOld {

  // If set to 'true', the certificate control is activated
  bool _certificateControllerActivated;

  // Address used by off-chain controller service to sign certificate
  mapping(address => bool) internal _certificateSigners;

  // A nonce used to ensure a certificate can be used only once
  mapping(address => uint256) private nonce;

  event Checked(address sender);

  constructor(address _certificateSigner, bool activated)  {
    _setCertificateSigner(_certificateSigner, true);
    _certificateControllerActivated = activated;
  }

  /**
   * @dev Modifier to protect methods with certificate control
   */
  modifier isValidCertificate(bytes memory data, bytes32 metaHash,uint256 _nonce) {

    if(_certificateControllerActivated) {
       require(_certificateSigners[msg.sender] ||  _checkCertificate(data, metaHash,_nonce), "A3"); // Transfer Blocked - Sender lockup period not ended

      nonce[msg.sender] += 1; // Increment sender check nonce

      emit Checked(msg.sender);
    }

    _;
  }


  /**
   * @dev Get number of transations already sent to this contract by the sender
   * @param sender Address whom to check the nonce of.
   * @return uint256 Number of transaction already sent to this contract.
   */
  function checkNonce(address sender) public view returns (uint256) {
    return nonce[sender];
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
   function _checkCertificate(bytes memory data, bytes32 metaHash,uint256 _nonce) internal returns(bool) { // Comments to avoid compilation warnings for unused variables.
     if(data.length > 0 ){
        address signer = getSigner(metaHash, data);
        //make sure signer doesn't come back as 0x0
        require(signer != address(0),"signer can not be zero address");
        // console.logAddress(signer);
        require(_certificateSigners[signer],"signer not authorized");
        require(_nonce == nonce[msg.sender],"nonce not match");
        nonce[msg.sender]++;
       return true;
     } else {
       return false;
     }
   }


  function methodHash(bytes4 funcSig, address _to, uint256 _value,uint256 exDate, uint256 _nonce)
        public
        view
        returns (bytes32)
    {
      return keccak256(abi.encodePacked(address(this),funcSig, _to, _value,exDate, _nonce));

    }

      function getCert(uint256 exDate,bytes memory data)
        public
        pure
        returns (bytes memory)
    {
      return abi.encodePacked(exDate, data);
      

    }

 function getSigner(bytes32 _hash, bytes memory _signature)
        private
        pure
        returns (address)
    {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (_signature.length != 65) {
            return address(0);
        }
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return address(0);
        } else {
            return
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            _hash
                        )
                    ),
                    v,
                    r,
                    s
                );
        }
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
        bytes memory data,
        bytes32 metahash,
        uint256 nonce
    ) external isValidCertificate(data,metahash,nonce) {
    
    transfer(to,value);
    }



function getSelector(string calldata func) public pure returns(bytes4){
return bytes4(keccak256(bytes(func)));
}