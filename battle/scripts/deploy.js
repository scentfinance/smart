const { countries } = "./constants";
const hre = require("hardhat");
const ethers = hre.ethers;
require("dotenv").config();

const TOKEN_ADDRESS = process.env.TOKEN_ADDRESS;
async function main() {
  const Battle = await ethers.getContractFactory("Battle");
  const battle = await Battle.deploy(countries, TOKEN_ADDRESS);

  await battle.deployed();

  console.log("battle deployed to:", battle.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
