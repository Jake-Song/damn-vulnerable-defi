const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('Pass Calldata', function () {
    let player, recepient;
    let token, custom;
    
    const CUSTOM_TOKEN_BALANCE = 1000000n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [ player, recepient ] = await ethers.getSigners();

        // Deploy Damn Valuable Token contract
        token = await (await ethers.getContractFactory('DamnValuableToken', player)).deploy();
        
        // Deploy Custom
        custom = await (await ethers.getContractFactory('Custom', player)).deploy();
        
        await token.transfer(custom.address, CUSTOM_TOKEN_BALANCE);
        
        expect(await token.balanceOf(custom.address)).to.eq(CUSTOM_TOKEN_BALANCE);
       
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
        let methodIdForPlayer = ethers.utils.id("transfer(address,uint256)").slice(0, 10);
        console.log(methodIdForPlayer);
        let calldata = ethers.utils.solidityPack(["bytes4", "address", "uint256"], [methodIdForPlayer, recepient.address, CUSTOM_TOKEN_BALANCE]);
        let calldata2 = ethers.utils.hexConcat([
            methodIdForPlayer, 
            ethers.utils.defaultAbiCoder.encode(['address', 'uint256'], [recepient.address, CUSTOM_TOKEN_BALANCE])
        ]);
        console.log("calldata: ", calldata);
        console.log("calldata2: ",calldata2);
        
        await custom.connect(player).execute(token.address, calldata2);
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        expect(await token.balanceOf(custom.address)).to.eq(0);
        expect(await token.balanceOf(recepient.address)).to.eq(CUSTOM_TOKEN_BALANCE);
    });
});
