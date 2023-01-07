const { expect } = require('chai')
const { ethers } = require('hardhat')

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether')
}

const ether = tokens
describe('FlashLoan', () => {
    let token, flashLoan, flashLoanReceiver
    let deployer

    beforeEach(async () => {
        //Set up accounts
        accounts = await ethers.getSigners()
        deployer = accounts[0]

        //Load accounts
        const FlashLoan = await ethers.getContractFactory('FlashLoan')
        const FlashLoanReceiver = await ethers.getContractFactory('FlashLoanReceiver')
        const Token = await ethers.getContractFactory('Token')

        //Deploy token
        token = await Token.deploy('Dapp University', 'DAPP', 1000000)

        //Deploy flash loan pool
        flashLoan = await FlashLoan.deploy(token.address)

        //Deposit tokens into flash loan pool
        let transaction = token.connect(deployer).approve(flashLoan.address, tokens(1000000))
        await transaction.wait
        transaction = await flashLoan.connect(deployer).depositTokens(tokens(1000000))
        await transaction.wait()

        //Deploy flash loan receiver
        flashLoanReceiver = await FlashLoanReceiver.deploy(flashLoan.address)
    })

    describe('Deployment', () => {
        it('Tokens can be sent to the flash loan pool contract', async () => {
            expect(await token.balanceOf(flashLoan.address)).to.be.equal(tokens(1000000))
        })
    })

    describe('Borrowing funds', () => {
        it('Borrows funds from the pool', async () => {
            let amount = tokens(100)
            let transaction = await flashLoanReceiver.connect(deployer).executeFlashLoan(amount)
            let result = await transaction.wait()
            await expect(transaction).to.emit(flashLoanReceiver, 'LoanReceived').withArgs(token.address, amount)
        })
    })
})