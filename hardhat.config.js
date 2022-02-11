require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      }
    ],
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545"
    },
    hardhat: {
      // See its defaults
    },
    // kovan: {
    //   url: "https://kovan.infura.io/v3/da065385393a447d9a72058b65c5806b",
    //   accounts: {
    //             mnemonic: MNEMONIC,
    //         },
    //   saveDeployments: true,
    // }
  }
};