const { parseEther } = require("ethers/lib/utils");

async function deploy_MultisigWallet(){

  console.log("Deploying MultisigWallet");
  console.log("------------------------------------------------------");
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const MultisigWallet = await ethers.getContractFactory("MultisigWallet");
  const contract = await MultisigWallet.deploy();
  await contract.deployed();

  console.log("[MultisigWallet] address:", contract.address);

}
deploy_MultisigWallet().then().catch();