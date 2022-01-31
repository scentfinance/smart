const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ScentStaking", function () {
  it("Should return the new greeting once it's changed", async function () {
    const ScentStaking = await ethers.getContractFactory("ScentStaking");
    const scentStaking = await ScentStaking.deploy("Hello, world!");
    await scentStaking.deployed();

    expect(await scentStaking.greet()).to.equal("Hello, world!");

    const setGreetingTx = await scentStaking.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await scentStaking.greet()).to.equal("Hola, mundo!");
  });
});
