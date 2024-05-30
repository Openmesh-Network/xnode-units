import { Address, DeployInfo, Deployer } from "../../web3webdeploy/types";

export interface DeployXnodeUnitEntitlementSettings
  extends Omit<DeployInfo, "contract" | "args"> {
  xnodeUnit: Address;
}

export async function deployXnodeUnitEntitlement(
  deployer: Deployer,
  settings: DeployXnodeUnitEntitlementSettings
): Promise<Address> {
  return await deployer
    .deploy({
      id: "XnodeUnitEntitlement",
      contract: "XnodeUnitEntitlement",
      args: [settings.xnodeUnit],
      ...settings,
    })
    .then((deployment) => deployment.address);
}
