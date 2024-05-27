import { Address, Deployer } from "../web3webdeploy/types";
import { DeployCounterSettings, deployCounter } from "./counters/Counter";
import {
  DeployProxyCounterSettings,
  deployProxyCounter,
} from "./counters/ProxyCounter";
import {
  SetInitialCounterValueSettings,
  setInitialCounterValue,
} from "./counters/SetInitialCounterValue";

export interface DeploymentSettings {
  counterSettings: DeployCounterSettings;
  proxyCounterSettings: Omit<DeployProxyCounterSettings, "counter">;
  setInitialCounterValueSettings: Omit<
    SetInitialCounterValueSettings,
    "counter"
  >;
  forceRedeploy?: boolean;
}

export interface Deployment {
  counter: Address;
  proxyCounter: Address;
}

export async function deploy(
  deployer: Deployer,
  settings?: DeploymentSettings
): Promise<Deployment> {
  if (settings?.forceRedeploy !== undefined && !settings.forceRedeploy) {
    const existingDeployment = await deployer.loadDeployment({
      deploymentName: "latest.json",
    });
    if (existingDeployment !== undefined) {
      return existingDeployment;
    }
  }

  const counter = await deployCounter(
    deployer,
    settings?.counterSettings ?? {}
  );
  const proxyCounter = await deployProxyCounter(deployer, {
    ...(settings?.proxyCounterSettings ?? {}),
    counter: counter,
  });
  await setInitialCounterValue(deployer, {
    ...(settings?.setInitialCounterValueSettings ?? {
      counterValue: BigInt(3),
    }),
    counter: counter,
  });

  const deployment = {
    counter: counter,
    proxyCounter: proxyCounter,
  };
  await deployer.saveDeployment({
    deploymentName: "latest.json",
    deployment: deployment,
  });
  return deployment;
}
