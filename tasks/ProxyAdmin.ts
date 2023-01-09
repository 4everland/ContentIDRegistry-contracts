import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { ContentIDRegistry, ProxyAdmin } from './Contracts'

task('ProxyAdmin:upgrade:ContentIDRegistry')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const proxyAdmin = await ProxyAdmin(env)
		const contentIDRegistry = await ContentIDRegistry(env)
		const tx = await proxyAdmin.upgrade(contentIDRegistry.address, '0x9763dd26e2F2D496E3f7A8f1DBa0d8EB042E8726')
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

module.exports = {}