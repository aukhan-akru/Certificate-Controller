const express = require("express");
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
const cors = require("cors");
app.use(cors());
const Web3 = require("web3");
const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const mnemonic = fs.readFileSync(".secret").toString().trim();
let provider = new HDWalletProvider(mnemonic, `http://127.0.0.1:8545`)
// let provider = new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/a44491b2e0774ebfab5c8eb71e64035e`)
const web3 = new Web3(provider);
const contract = require("./SimpleToken.json")

let accounts;
  
// 1. The function ID which ensures the certificate can’t be used on another function. 
// 2. The parameters which ensure the input parameters have been validated by the issuer.
// 3. A validity date which ensures the certificate can’t be used after the validity date.
// 4. A nonce which ensures the certificate can’t be used twice. 


web3.eth.getAccounts().then(async (_accounts) => {
  accounts = _accounts;
  // console.log(`accounts`, accounts);
  
  const _contract = new web3.eth.Contract(contract.abi,contract.address)
   await _contract.methods.transfer(accounts[2],web3.utils.toWei("100")).send({from:accounts[0]})

   let bal1 = (await _contract.methods.balanceOf(accounts[3]).call()).toString()
console.log("before--->",bal1)
  const nonce = await _contract.methods.checkNonce(accounts[2]).call() //change to get Nonce
  // console.log("nonce:",nonce)

  let exDate = Math.ceil((Date.now()/1000))+600;
  console.log("exDate",exDate)
 let args = [
    /*  funcId: */await _contract.methods.getSelector("issue(address,uint256,bytes)").call(),
    /* to: */accounts[3],
    /* value: */web3.utils.toWei("11"),
    /* nonce: */nonce
 ]

  console.log(args)
  let certificate  = await _contract.methods.methodHash(...args).call();
  console.log("hash:---->",certificate)
   let  data = await web3.eth.personal.sign(certificate,accounts[0])
  console.log("sig:------->",data)

// let _data = exDate.toString() + data.toString(); 
let cert  =await _contract.methods.getCert(exDate.toString(),data).call();
console.log("cert:-------->",cert)
// let a = await web3.eth.accounts.recover(certificate,data)
// console.log("---->",a) 
let res = await _contract.methods.issue(accounts[3],web3.utils.toWei("11"),cert).send({from:accounts[2]})
  let bal = (await _contract.methods.balanceOf(accounts[3]).call()).toString()
console.log("after--->",bal)

});

  
  
  // var selfsigned = require('selfsigned');
  // var attrs = [{ name: 'commonName', value: 'aukhan@akru.co' }];
  // var pems = selfsigned.generate(attrs, {
  //   keySize: 2048, // the size for the private key in bits (default: 1024)
  //   days: 30, // how long till expiry of the signed certificate (default: 365)
  //   algorithm: 'sha256', // sign the certificate with specified algorithm (default: 'sha1')
  //   extensions: [{ name: 'basicConstraints', cA: true }], // certificate extensions array
  //   pkcs7: false, // include PKCS#7 as part of the output (default: false)
  //   clientCertificate: false, // generate client cert signed by the original key (default: false)
  //   clientCertificateCN: 'AsadUllahKhan' // client certificate's common name (default: 'John Doe jdoe123')
  // });
  // console.log(pems)




  app.listen(4000,()=>console.log("listening at 4000"))