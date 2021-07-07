// import Contract from './contracts/Contract.json'

const options = {
  web3: {
    block: false,
    fallback: {
      type: 'ws',
      url: 'ws://127.0.0.1:7545'
    }
  },
  // contracts: [Contract],
  polls: {
    accounts: 15000
  }
}

export default options
