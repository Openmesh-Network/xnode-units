import { Ether } from "../../web3webdeploy/lib/etherUnits";
import { Address, DeployInfo, Deployer } from "../../web3webdeploy/types";

export interface DeployXnodeUnitsOPENVestingSettings
  extends Omit<DeployInfo, "contract" | "args"> {
  xnodeUnit: Address;
}

export async function deployXnodeUnitsOPENVesting(
  deployer: Deployer,
  settings: DeployXnodeUnitsOPENVestingSettings
): Promise<Address> {
  deployer.startContext("lib/vesting");
  const sOPEN = "0xc7b10907033Ca6e2FC00FCbb8CDD5cD89f141384";
  const amount = Ether(200);
  const start = Math.round(Date.UTC(2024, 6 - 1, 10) / 1000);
  const duration = Math.round(Date.UTC(2025, 6 - 1, 10) / 1000) - start;
  const xnodeUnitsOPENVesting = await deployer
    .deploy({
      id: "XnodeUnitsOPENVesting",
      contract: "MultiERC721TokenLinearERC20TransferVesting",
      args: [sOPEN, amount, start, duration, settings.xnodeUnit],
      ...settings,
    })
    .then((deployment) => deployment.address);
  deployer.finishContext();
  return xnodeUnitsOPENVesting;
}
