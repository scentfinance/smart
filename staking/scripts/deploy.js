async function main() {
  const Staking = await ethers.getContractFactory("ScentStaking");

  // Start deployment, returning a promise that resolves to a contract object
  const staking = await Staking.deploy(
    "0xEA7AD0978a263d964d3134FBCf17edA0C60f22fC", // staking token
    "0x04EFd51B5E7282D8bC8ED80f300Cf3365117Bd8B" // rewards token
  );
  console.log("Staking Contract deployed to address:", staking.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
