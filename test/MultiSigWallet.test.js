const { expect } = require("chai");
const { loadFixture } = require("ethereum-waffle");
const { Contract } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const Web3 = require("web3");


describe("MultiSig Wallet", () => {
    // beforeEach(async() => {
    //     const [owner, acct1, acct2] = await ethers.getSigners();
    //     MultisigWallet = await ethers.getContractFactory("MultisigWallet")
    //     multisigwallet = await MultisigWallet.deploy()
    // })

    async function testFixture() {
        let multisigwallet, MultisigWallet, Erc20dummy, erc20dummy
        const [owner, acct1, acct2, acct3, acct4] = await ethers.getSigners();
        MultisigWallet = await ethers.getContractFactory("MultisigWallet");
        multisigwallet = await MultisigWallet.deploy({value: ethers.utils.parseEther("5")});
        Erc20dummy = await ethers.getContractFactory("ERC20Dummy");
        erc20dummy = await Erc20dummy.deploy(multisigwallet.address);
        return { owner, acct1, acct2, acct3, acct4, multisigwallet, erc20dummy };
      }

    it("Can add Signers", async () => {
        const { owner, acct1, acct2, acct3, multisigwallet } = await loadFixture(testFixture);
        await multisigwallet.addSigners(acct1.address);
        await multisigwallet.addSigners(acct2.address);
        await multisigwallet.addSigners(acct3.address);
        expect(await multisigwallet.signersListed(acct1.address)).to.be.true;

        await expect(multisigwallet.addSigners(acct1.address)).to.be.reverted; // Should fail because Signer Already Listed!
    }) 

    it("Should create ETH transactions", async () => {
        const { owner, acct1, acct2, acct3, acct4, multisigwallet } = await loadFixture(testFixture);
        await multisigwallet.createTransactionETH(acct1.address, 1);
        await expect(multisigwallet.connect(acct4).createTransactionETH(acct1.address, 1)).to.be.reverted;
    })

    it("Should create ERC20 transactions", async () => {
        const { owner, acct1, acct2, acct4, multisigwallet, erc20dummy } = await loadFixture(testFixture);
        await multisigwallet.createTransanctionERC20(acct1.address, 1, erc20dummy.address);
        await expect(multisigwallet.connect(acct4).createTransactionETH(acct1.address, 1)).to.be.reverted;
    })

    it("Should approve transactions", async () => {
        const { owner, acct1, acct2, acct3, acct4, multisigwallet } = await loadFixture(testFixture);
        //await multisigwallet.connect(acct1).approveTransaction(0);
        await multisigwallet.connect(acct2).approveTransaction(0);
        await multisigwallet.connect(acct3).approveTransaction(0);
        await multisigwallet.approveTransaction(0);
        const data = await multisigwallet.transact(0);
        expect(data[2]).to.be.equal(3);

        await expect(multisigwallet.connect(acct4).approveTransaction(0)).to.be.reverted;
    })

    it("Should revoke transactions", async () => {
        const { owner, acct1, acct2, acct4, multisigwallet } = await loadFixture(testFixture);
        await multisigwallet.connect(acct1).revokeTransaction(0);
        const data = await multisigwallet.transact(0);
        expect(data[3]).to.be.equal(1);

        await expect(multisigwallet.connect(acct4).revokeTransaction(0)).to.be.reverted;
    })

    it("Should not approve with same address", async () => {
        const { owner, acct1, acct2, multisigwallet } = await loadFixture(testFixture);
        await expect(multisigwallet.approveTransaction(0)).to.be.reverted;
    })

    it("Should view transactions", async () => {
        const { owner, acct1, acct2, multisigwallet } = await loadFixture(testFixture);
        await multisigwallet.viewTransactions(0);
        await expect(multisigwallet.viewTransactions(5)).to.be.reverted;
    })

    it("Should execute transactions ETH", async () => {
        const { owner, acct1, acct2, acct3, multisigwallet } = await loadFixture(testFixture);
        const initialBalance = await ethers.provider.getBalance(acct1.address);
        await multisigwallet.executeTransactions(0);
        const currentBalance = await ethers.provider.getBalance(acct1.address);
        expect(currentBalance).to.be.above(initialBalance);
    })

    it("Should execute transactions ERC20", async () => {
        const { owner, acct1, acct2, acct3, multisigwallet, erc20dummy } = await loadFixture(testFixture);
        // await erc20dummy.mint(multisigwallet.address, 10);
        await multisigwallet.connect(acct1).approveTransaction(1);
        await multisigwallet.connect(acct2).approveTransaction(1);
        await multisigwallet.connect(acct3).approveTransaction(1);
        await multisigwallet.executeTransactions(1);
        expect(await erc20dummy.balanceOf(acct1.address)).to.equal(1);
    })

    it("Should not execute transactions ERC20 and ETH", async () => {
        const { owner, acct1, acct2, acct3, multisigwallet, erc20dummy } = await loadFixture(testFixture);
        await multisigwallet.createTransanctionERC20(acct1.address, 1, erc20dummy.address);
        await multisigwallet.createTransactionETH(acct1.address, 1);
        await expect (multisigwallet.executeTransactions(2)).to.be.reverted;
    })

})