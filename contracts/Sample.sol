// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;

// contract GetYourSig {
    
//     function e() public pure returns (bytes4) {
//         return msg.sig;
//     }
//     function f() public pure returns (bytes4) {
//         return (bytes4(msg.data[0]) | bytes4(msg.data[1]) >> 8 |
//             bytes4(msg.data[2]) >> 16 | bytes4(msg.data[3]) >> 24);
//     }
    
//     function g() public pure returns (bytes4 funcId) {
//         bytes memory msgData = msg.data;
//         assembly{
//             funcId := mload(add(msgData,32))
//         }
//     }



// function h() public pure returns(bytes4){
// return bytes4(msg.data);
// }


//    function transferWithData(
//         address to,
//         uint256 value,
//         bytes memory data
//     ) external 
//     // isValidCertificate(data) 
//     {
//         console.logBytes(msg.data);
//         bytes memory msgData = msg.data;
//         bytes4 funId;
//         bytes32 arg1;
//         bytes32 arg2;
//         assembly{
//             funId:= mload(add(msgData,32))
//             arg1 := mload(add(msgData,36))
//             arg2 := mload(add(msgData,68))
//         }
//         console.logBytes4(funId);
//         console.logBytes32(arg1);
//         console.logUint(uint256(arg2));
//         // transfer(to,value);
//     }

// }