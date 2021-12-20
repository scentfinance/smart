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

    expect((await battle.token()).toLowerCase()).to.equal(TOKEN_ADDRESS.toLowerCase());
  });

  it("Should return countries", async function () {
    const Battle = await ethers.getContractFactory("Battle");
    const battle = await Battle.deploy(countries, TOKEN_ADDRESS);
    await battle.deployed();

    expect((await battle.getCountries())[0]).to.equal(countries[0]);
  });

  it("Should reset the game", async function () {
    const Battle = await ethers.getContractFactory("Battle");
    const battle = await Battle.deploy(countries, TOKEN_ADDRESS);
    await battle.deployed();

    const resetTx = await battle.reset(["a team", "b team"], TOKEN_ADDRESS);
    await resetTx.wait();

    expect((await battle.getCountries())[0]).to.equal("a team");
  });
});
