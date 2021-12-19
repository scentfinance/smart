const { countries } = require("../scripts/constants");
const { expect } = require("chai");
const { ethers } = require("hardhat");
require("dotenv").config();
const TOKEN_ADDRESS = process.env.TOKEN_ADDRESS;

describe("Battle", function () {
  it("Should return token contract address", async function () {
    const Battle = await ethers.getContractFactory("Battle");
    const battle = await Battle.deploy(countries, TOKEN_ADDRESS);
    await battle.deployed();

    expect((await battle.getTokenAddress()).toLowerCase()).to.equal(
      TOKEN_ADDRESS.toLowerCase()
    );

    // expect(await battle.greet()).to.equal("Hello, world!");

    // const setGreetingTx = await battle.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await battle.greet()).to.equal("Hola, mundo!");
  });
});
