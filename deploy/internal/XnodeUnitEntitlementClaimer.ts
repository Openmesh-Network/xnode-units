import { Address, DeployInfo, Deployer } from "../../web3webdeploy/types";

export interface DeployXnodeUnitEntitlementClaimerSettings
  extends Omit<DeployInfo, "contract" | "args"> {
  xnodeUnitEntitlement: Address;
}

export async function deployXnodeUnitEntitlementClaimer(
  deployer: Deployer,
  settings: DeployXnodeUnitEntitlementClaimerSettings
): Promise<Address> {
  return await deployer
    .deploy({
      id: "XnodeUnitEntitlementClaimer",
      contract: "XnodeUnitEntitlementClaimer",
      args: [
        settings.xnodeUnitEntitlement,
        "0x57b5F9b5504fb47a9E1E6D8ecc7DfEE1724F9c0a",
      ],
      ...settings,
    })
    .then((deployment) => deployment.address);
}
