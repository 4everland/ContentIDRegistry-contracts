import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { 
	ContentIDRegistry__factory,
	PriceAdaptor__factory,
	MockToken__factory,
	ProxyAdmin__factory
} from '../types'

export const ContentIDRegistry = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get('ContentIDRegistry_Proxy')
	const signers = await env.ethers.getSigners()
	return ContentIDRegistry__factory.connect(deployment.address, signers[0])
}

export const PriceAdaptor = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get('PriceAdaptor')
	const signers = await env.ethers.getSigners()
	return PriceAdaptor__factory.connect(deployment.address, signers[0])
}

export const ProxyAdmin = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get('ProxyAdmin')
	const signers = await env.ethers.getSigners()
	return ProxyAdmin__factory.connect(deployment.address, signers[0])
}

export const MockToken = async (env: HardhatRuntimeEnvironment) => {
	const deployment = await env.deployments.get('MockToken')
	const signers = await env.ethers.getSigners()
	return MockToken__factory.connect(deployment.address, signers[0])
}