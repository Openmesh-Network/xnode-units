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
import { SmartAccountBaseContract } from "../lib/openmesh-admin/lib/smart-account/export/SmartAccountBase";
import {
  DeployXnodeUnitsOPENVestingSettings,
  deployXnodeUnitsOPENVesting,
} from "./internal/XnodeUnitsOPENVesting";

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
  xnodeUnitsOPENVestingSettings: Omit<
    DeployXnodeUnitsOPENVestingSettings,
    "xnodeUnit"
  >;
  forceRedeploy?: boolean;
}

export interface XnodeUnitsDeployment {
  xnodeUnit: Address;
  xnodeUnitEntitlement: Address;
  xnodeUnitEntitlementClaimer: Address;
  xnodeUnitsOPENVesting: Address;
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

  const xnodeUnitAbi = await deployer.getAbi("XnodeUnit");
  const xnodeUnitEntitlementAbi = await deployer.getAbi("XnodeUnitEntitlement");
  deployer.startContext("lib/openmesh-admin");
  const openmeshAdminAbi = [...SmartAccountBaseContract.abi];
  await deployer.execute({
    id: "GrantingMintingRoles",
    abi: openmeshAdminAbi,
    to: "0x24496D746Fd003397790E41d0d1Ce61F4F7fd61f", // Openmesh Admin
    function: "multicall",
    args: [
      [
        deployer.viem.encodeFunctionData({
          abi: openmeshAdminAbi,
          functionName: "performCall",
          args: [
            xnodeUnit,
            BigInt(0),
            deployer.viem.encodeFunctionData({
              abi: xnodeUnitAbi,
              functionName: "grantRole",
              args: [
                deployer.viem.keccak256(deployer.viem.toBytes("MINT")),
                xnodeUnitEntitlement,
              ],
            }),
          ],
        }),
        deployer.viem.encodeFunctionData({
          abi: openmeshAdminAbi,
          functionName: "performCall",
          args: [
            xnodeUnitEntitlement,
            BigInt(0),
            deployer.viem.encodeFunctionData({
              abi: xnodeUnitEntitlementAbi,
              functionName: "grantRole",
              args: [
                deployer.viem.keccak256(deployer.viem.toBytes("MINT")),
                xnodeUnitEntitlement,
              ],
            }),
          ],
        }),
      ],
    ],
    from: "0x6b221aA392146E31743E1beB5827e88284B09753",
  });
  deployer.finishContext();

  const xnodeUnitsOPENVesting = await deployXnodeUnitsOPENVesting(deployer, {
    xnodeUnit: xnodeUnit,
    ...(settings?.xnodeUnitsOPENVestingSettings ?? {}),
  });

  const deployment: XnodeUnitsDeployment = {
    xnodeUnit: xnodeUnit,
    xnodeUnitEntitlement: xnodeUnitEntitlement,
    xnodeUnitEntitlementClaimer: xnodeUnitEntitlementClaimer,
    xnodeUnitsOPENVesting: xnodeUnitsOPENVesting,
  };
  await deployer.saveDeployment({
    deploymentName: "latest.json",
    deployment: deployment,
  });
  return deployment;
}
