# ContentIDRegistry Contracts

![License: GPL](https://img.shields.io/badge/license-GPLv2-blue)![Version Badge](https://img.shields.io/badge/version-0.4.4-lightgrey.svg)

The contracts are upgradable, following the [Open Zeppelin Proxy Upgrade Pattern](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies). Each contract will be explained in brief detail below.

**_PriceAdaptor_**

> This is the contract that controls the price of storage, the price of storage depends on the storage size and storage time

**_ContentIDRegistry_**

> Anyone can send events to the ipfs storage service through this contract. When the ipfs storage service receives the event, it will verify the size of the file or folder. If the storage size is the same as or larger than the verification size of the storage service, the storage service will Pin this file or folder, if the verification fails, it will be regarded as an invalid transaction

## Get Started

```
npm install @4everland/content-id-registry-contracts
```

## Examples

**_calculate file or directory value_**

```
const token = ${token address}
const signer = ${eth signer}
const fileSize = ${file size}
const expiration = ${file expiration}
const contentIDRegistry = ContentIDRegistry__factory.connect(${ContentIDRegistry_contract}, signer)
const value = await contentIDRegistry.getValue(token, fileSize, expiration)
console.log('value', value)
```

**_insert cid_**

```
const token = ${token address}
const signer = ${eth signer}
const cid = ${cid}
const fileSize = ${file size}
const expiration = ${file expiration}
const contentIDRegistry = ContentIDRegistry__factory.connect(${ContentIDRegistry_contract}, signer)
const tx = await contentIDRegistry.insert(token, cid, fileSize, expiration)
console.log('tx', tx)
const receipt = await tx.wait()
console.log('receipt', receipt)
```

**_renew cid_**

```
const token = ${token address}
const signer = ${eth signer}
const cid = ${cid}
const expiration = ${file expiration}
const contentIDRegistry = ContentIDRegistry__factory.connect(${ContentIDRegistry_contract}, signer)
const tx = await contentIDRegistry.renew(token, cid, expiration)
console.log('tx', tx)
const receipt = await tx.wait()
console.log('receipt', receipt)
```

## Contract Addresses

The testnet runs on Mumbai currently. The addresses for both of these can be found in `./deployments`.

## Copyright

Copyright &copy; 2022 4everland.

Licensed under [GPL license](LICENSE).
