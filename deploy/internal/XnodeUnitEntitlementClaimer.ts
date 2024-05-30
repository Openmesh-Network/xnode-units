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
        "0xaF7E68bCb2Fc7295492A00177f14F59B92814e70",
      ],
      ...settings,
    })
    .then((deployment) => deployment.address);
}
