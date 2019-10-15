const path = require('path')
const fs = require('fs-extra')
const exec = require('child_process').exec

const buildPath = path.resolve(__dirname, 'build')
fs.removeSync(buildPath) // delete folder and its content

const contractsPath = path.resolve(__dirname, 'contracts', 'Campaign.vy')

// recreate build folder
fs.ensureDirSync(buildPath)

// compile contract and save ABI output
exec(`vyper -f abi ${contractsPath} > ${path.resolve(buildPath, 'campaign.json')}`)
