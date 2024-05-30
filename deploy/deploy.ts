import { Address, Deployer } from "../web3webdeploy/types";
import { DeployXnodeUnitSettings, deployXnodeUnit } from "./internal/XnodeUnit";
import {
  DeployXnodeUnitEntitlementSettings,
  deployXnodeUnitEntitlement,
} from "./internal/XnodeUnitEntitlement";
import {
  DeployXnodeUnitEntitlementClaimerSettings,
  deployXnodeUnitEntitlementClaimer,
} from "./internal/XnodeUnitEntitlementClaimer";

export interface XnodeUnitsDeploymentSettings {
  xnodeUnitSettings: DeployXnodeUnitSettings;
  xnodeUnitEntitlementSettings: Omit<
    DeployXnodeUnitEntitlementSettings,
    "xnodeUnit"
  >;
  xnodeUnitEntitlementClaimerSettings: Omit<
    DeployXnodeUnitEntitlementClaimerSettings,
    "xnodeUnitEntitlement"
  >;
  forceRedeploy?: boolean;
}

export interface XnodeUnitsDeployment {
  xnodeUnit: Address;
  xnodeUnitEntitlement: Address;
  xnodeUnitEntitlementClaimer: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: XnodeUnitsDeploymentSettings
): Promise<XnodeUnitsDeployment> {
  if (settings?.forceRedeploy !== undefined && !settings.forceRedeploy) {
    const existingDeployment = await deployer.loadDeployment({
      deploymentName: "latest.json",
    });
    if (existingDeployment !== undefined) {
      return existingDeployment;
    }
  }

  const xnodeUnit = await deployXnodeUnit(
    deployer,
    settings?.xnodeUnitSettings ?? {}
  );

  const xnodeUnitEntitlement = await deployXnodeUnitEntitlement(deployer, {
    xnodeUnit: xnodeUnit,
    ...(settings?.xnodeUnitEntitlementSettings ?? {}),
  });

  const xnodeUnitEntitlementClaimer = await deployXnodeUnitEntitlementClaimer(
    deployer,
    {
      xnodeUnitEntitlement: xnodeUnitEntitlement,
      ...(settings?.xnodeUnitEntitlementClaimerSettings ?? {}),
    }
  );

  const deployment: XnodeUnitsDeployment = {
    xnodeUnit: xnodeUnit,
    xnodeUnitEntitlement: xnodeUnitEntitlement,
    xnodeUnitEntitlementClaimer: xnodeUnitEntitlementClaimer,
  };
  await deployer.saveDeployment({
    deploymentName: "latest.json",
    deployment: deployment,
  });
  return deployment;
}
