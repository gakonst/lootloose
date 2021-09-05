const { ethers } = require('ethers')
const args = process.argv.slice(2);

if(args.length != 1) {
  console.log(`please supply the correct parameters:
    metadata
  `)
  process.exit(1);
}

let meta = args[0]
meta = meta.replace("data:application/json;base64,", "");
meta = new Buffer(meta, "base64").toString();
meta = JSON.parse(meta);

const abi = JSON.parse('[{"inputs":[{"components":[{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"description","type":"string"},{"internalType":"string","name":"image","type":"string"},{"components":[{"internalType":"string","name":"trait_type","type":"string"},{"internalType":"string","name":"value","type":"string"}],"internalType":"struct Attribute[]","name":"attributes","type":"tuple[]"}],"internalType":"struct Data","name":"data","type":"tuple"}],"name":"foo","outputs":[],"stateMutability":"nonpayable","type":"function"}]')
const iface = new ethers.utils.Interface(abi)

meta = [
  [
    meta.name,
    meta.description,
    meta.image,
    meta.attributes,
  ]
]
// TODO: Is there a better way to do this, instead of fake-encoding
// as a function and stripping the function selector?
encoded = iface.encodeFunctionData("foo", meta)
process.stdout.write("0x" + encoded.slice(10))
