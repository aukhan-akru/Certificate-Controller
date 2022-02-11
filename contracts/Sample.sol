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

// }