# Multi Signature Wallet

## Getting Started

I assumed that you already have NodeJS installed on your computer. Get this file into a location, open the command prompt inside that, and then type this.

## Creating a new Hardhat project

```powershell
- mkdir (name of folder)
- cd (name of folder)
- code .
- yarn init
- yarn add --dev hardhat
- npx hardhat
- Create a JavaScript project
- yarn add -- dev @nomiclabs/hardhat-waffle @nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan dotenv chai ethers hardhat-gas-reporter @openzeppelin/contracts
```

Then on the project home, create a file named .env. Inside it, provide the following values:

```.env
INFURA_API_KEY = ""
ALCHEMY_API_KEY_RINKEBY = "" // go to infura, get API key. Important for rinkeby deployment
RINKEBY_ACCOUNT_PK = "" // get this from metamask or etc
RINKEBY_ACCOUNT_A2 = "" // get this from metamask or etc
RINKEBY_ACCOUNT_A3 = "" // get this from metamask or etc

ETHERSCAN_KEY = "" // get this from etherscan. Important for code verification
```

## Testing the Application

You can provide as many examples here, and we will promote it as a more documented application, which means it will become more useful in the future.

```powershell
yarn test
-or-
npx hardhat test
```

This should produce an output similar to this:

```
MultiSig Wallet
  √ Can add Signers
  √ Should create ETH transactions
  √ Should create ERC20 transactions
  √ Should approve transactions
  √ Should revoke transactions
  √ Should not approve with same address
  √ Should view transactions
  √ Should execute transactions ETH
  √ Should execute transactions ERC20
  √ Should not execute transactions ERC20 and ETH
  √ Should view pending transactions
```

## Local Node Testing

We can use ganache to simulate our own blockchain for testing. To run a ganache blockchain instance, type:

```bash
npx hardhat node
```

Later, it should spin the server and provide you with a list of accounts with balances along with their private keys that you could use in configuration or testing.

## Deployment

```js
  const MultisigWallet = await ethers.getContractFactory("MultisigWallet");
  const contract = await MultisigWallet.deploy();
  await contract.deployed();
```

Then you can deploy it in rinkeby if you're confident with it.

```powershell
yarn deploy:rinkeby
-or-
npx hardhat run scripts/deploy.js --network rinkeby
```

Or in mainnet. WARNING. Make sure you know what you are doing!

```powershell
yarn deploy:mainnet
-or-
npx hardhat run scripts/deploy.js --network mainnet
```