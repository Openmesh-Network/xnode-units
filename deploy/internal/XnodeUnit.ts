import { Address, DeployInfo, Deployer } from "../../web3webdeploy/types";

export interface DeployXnodeUnitSettings
  extends Omit<DeployInfo, "contract" | "args"> {}

export async function deployXnodeUnit(
  deployer: Deployer,
  settings: DeployXnodeUnitSettings
): Promise<Address> {
  return await deployer
    .deploy({
      id: "XnodeUnit",
      contract: "XnodeUnit",
      ...settings,
    })
    .then((deployment) => deployment.address);
}
