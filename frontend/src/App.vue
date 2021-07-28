<template>
  <div v-if="!loading" id="app">
    <header>
      Account {{ account }}
    </header>
    <div>
      <div>
        <label>Input</label>
        <br>
        <strong>Eth Balance: {{ ethBalance }}</strong>
        <br>
        <input type="text" @input="updateOutput">
      </div>

      <div>
        <label>Output</label>
        <br>
        <strong>Token Balance: {{ tokenBalance }}</strong>
        <br>
        <input type="text" disabled :value="output">
      </div>

      <div>
        1 ETH = 100 DApp
      </div>

      <button @click="swap">Swap</button>
    </div>
  </div>
  <div v-else>
    Loading
  </div>
</template>

<script>
  import Web3 from "web3"
  import Token from './contracts/Token.json'
  import EthSwap from './contracts/EthSwap.json'


  export default {
    name: 'app',
    data () {
      return {
        account: '',
        token: null,
        ethSwap: null,
        tokenBalance: 0,
        ethBalance: 0,
        output: 0,
        input: 1,
        loading: true,
      }
    },
    computed: {
      ethBalanceFormatted () {
        return window.web3.utils.fromWei(this.ethBalance, 'Ether')
      },
    },
    async mounted () {
      await this.loadWeb3()
      await this.loadBlockchainData()
    },

    methods: {
      async loadWeb3 () {
        if (window.ethereum) {
          window.web3 = new Web3(window.ethereum)
          await window.ethereum.enable()
        } else if (window.web3) {
          window.web3 = new Web3(window.web3.currentProvider)
        } else {
          window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
      },
      async loadBlockchainData () {
        const web3 = window.web3
        const accounts = await web3.eth.getAccounts()
        this.account = accounts[0]
        this.ethBalance = await web3.eth.getBalance(this.account)

        const networkId = await web3.eth.net.getId()
        const tokenData = Token.networks[networkId]

        const ethSwapData = EthSwap.networks[networkId]
        if (ethSwapData) {
          this.ethSwap = new web3.eth.Contract(EthSwap.abi, ethSwapData.address)
        } else {
          window.alert('EthSwap contract not deployed to detected network')
        }

        if (tokenData) {
          this.token = new web3.eth.Contract(Token.abi, tokenData.address)
          // call() from web3

          this.tokenBalance = await this.token.methods.balanceOf(this.account).call()
        } else {
          window.alert('Token contract not deployed to detected network')
        }

        this.loading = false
      },

      updateOutput (e) {
        this.input = e.target.value.toString()
        this.output = (this.input * 100).toString()
      },
      swap () {
        // send() from web3
        this.loading = true
        const converted = window.web3.utils.toWei(this.input, 'Ether')
        this.ethSwap.methods.buyTokens()
          .send({ value: converted, from: this.account })
          .on('transactionHash', () => (this.loading = false))
      },
    },
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
  }
</style>
