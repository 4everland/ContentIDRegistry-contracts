import '@nomiclabs/hardhat-ethers'
import 'hardhat-deploy'

import { task } from 'hardhat/config'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { ContentIDRegistry, MockToken } from './Contracts'
const cid = 'QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR'

task('ContentIDRegistry:balance')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const token = await MockToken(env)
		const signers = await env.ethers.getSigners()
		const balance = await token.balanceOf(signers[0].address)
		console.log('balance', balance)
	})

task('ContentIDRegistry:Token:approve')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const contentIDRegistry = await ContentIDRegistry(env)
		const token = await MockToken(env)
		const tx = await token.approve(contentIDRegistry.address, '0xffffffffffffffffffffffffffffffff')
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('ContentIDRegistry:insert')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const token = await MockToken(env)
		const contentIDRegistry = await ContentIDRegistry(env)
		const tx = await contentIDRegistry.insert(token.address, cid, 119762, 1000)
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('ContentIDRegistry:remove')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const contentIDRegistry = await ContentIDRegistry(env)
		const tx = await contentIDRegistry.remove(cid)
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('ContentIDRegistry:renew')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const token = await MockToken(env)
		const contentIDRegistry = await ContentIDRegistry(env)
		const tx = await contentIDRegistry.renew(token.address, cid, 100000)
		console.log('tx', tx)
		const receipt = await tx.wait()
		console.log('receipt', receipt)
	})

task('ContentIDRegistry:getValue')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const token = await MockToken(env)
		const contentIDRegistry = await ContentIDRegistry(env)
		const getValue = await contentIDRegistry.getValue(token.address, 119762, 100000)
		console.log('getValue', getValue)
	})

task('ContentIDRegistry:isExpired')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const contentIDRegistry = await ContentIDRegistry(env)
		const signers = await env.ethers.getSigners()
		const isExpired = await contentIDRegistry.isExpired(signers[0].address, cid)
		console.log('isExpired', isExpired)
	})

task('ContentIDRegistry:expiredAt')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const contentIDRegistry = await ContentIDRegistry(env)
		const signers = await env.ethers.getSigners()
		const expiredAt = await contentIDRegistry.expiredAt(signers[0].address, cid)
		console.log('expiredAt', expiredAt)
	})

task('ContentIDRegistry:exists')
	.setAction(async (args: any, env: HardhatRuntimeEnvironment) => {
		const contentIDRegistry = await ContentIDRegistry(env)
		const signers = await env.ethers.getSigners()
		const exists = await contentIDRegistry.exists(signers[0].address, cid)
		console.log('exists', exists)
	})

module.exports = {}