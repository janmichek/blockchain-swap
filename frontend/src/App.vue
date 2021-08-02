<template>
  <div
    v-if="!isLoading"
    id="app">
    <header>
      <h1>Swap DAPP</h1>
      Account {{ account }}
      <br>
      Balance: {{ web3.utils.fromWei(balance, 'ether') }}
    </header>
    <section>
      <h2>Buy Tokens</h2>
      <div>
        <label>Input</label>
        <br>
        <strong>Eth Balance: {{ web3.utils.fromWei(ethBalance, 'ether') }} ETH</strong>
        <br>
        <input type="text" @input="updateBuyOutput">
      </div>

      <div>
        <label>Output</label>
        <br>
        <strong>Token Balance: {{ web3.utils.fromWei(tokenBalance, 'ether') }} DAPP</strong>
        <br>
        <input type="text" disabled :value="buyOutput">
      </div>

      <div>
        Exchange Rate: 1 ETH = 100 DApp
      </div>

      <button @click="swapBuyTokens">Swap to DAPP</button>
    </section>

    <section>
      <h2>Sell Tokens</h2>
      <div>
        <label>Input</label>
        <br>
        <strong>Token Balance: {{ web3.utils.fromWei(tokenBalance, 'ether') }} DAPP</strong>
        <br>
        <input type="text" @input="updateSellOutput">
      </div>

      <div>
        <label>Output</label>
        <br>
        <strong>Eth Balance: {{ web3.utils.fromWei(ethBalance, 'ether') }} ETH</strong>
        <br>
        <input type="text" disabled :value="sellOutput">
      </div>

      <div>
        Exchange Rate: 100 DApp = 1 ETH
      </div>
      <button @click="swapSellTokens">Swap to ETH</button>
    </section>
  </div>
  <div v-else>
    isLoading
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
        buyOutput: 0,
        buyInput: 0,
        sellOutput: 0,
        sellInput: 0,
        web3: undefined,
        isLoading: true,
        balance: 0,
      }
    },
    async mounted () {
      await this.loadBlockchainData()
    },

    methods: {
      async loadBlockchainData () {
        if (typeof window.ethereum !== 'undefined') {
          this.web3 = new Web3(window.ethereum)
          const netId = await this.web3.eth.net.getId()
          const accounts = await this.web3.eth.getAccounts()
          this.account = accounts[0]
          this.ethBalance = await this.web3.eth.getBalance(this.account)

          //load balance
          if (typeof accounts[0] !== 'undefined') {
            this.balance = await this.web3.eth.getBalance(accounts[0])
          } else {
            window.alert('Please login with MetaMask')
          }

          //load contracts
          try {
            this.ethSwap = new this.web3.eth.Contract(EthSwap.abi, EthSwap.networks[netId].address)
            this.token = new this.web3.eth.Contract(Token.abi, Token.networks[netId].address)
            // call() from web3

            this.tokenBalance = await this.token.methods.balanceOf(this.account).call()
            this.isLoading = false

          } catch (e) {
            /* eslint-disable no-console*/

            console.log('Error', e)
            window.alert('Contracts not deployed to the current network')
          }
        } else {
          window.alert('Please install MetaMask')
        }
      },

      updateBuyOutput (e) {
        this.buyInput = e.target.value.toString()
        this.buyOutput = (this.buyInput * 100).toString()
      },
      updateSellOutput (e) {
        this.sellInput = e.target.value.toString()
        this.sellOutput = (this.sellInput / 100).toString()
      },
      swapBuyTokens () {
        // send() from web3
        this.isLoading = true

        const converted = this.web3.utils.toWei(this.buyInput.toString(), 'ether')
        this.ethSwap.methods.buyTokens()
          .send({ value: converted, from: this.account })
          .on('transactionHash', () => {
            this.isLoading = false
            window.location.reload(true)
          })

      },
      swapSellTokens () {
        this.isLoading = true
        const converted = this.web3.utils.toWei(this.sellInput.toString(), 'ether')
        this.token.methods.approve(this.ethSwap._address, converted).send({ from: this.account })
          .on('transactionHash', () => {
              this.ethSwap.methods.sellTokens(converted)
                .send({ from: this.account })
                .on('transactionHash', () => {
                this.isLoading = false
                window.location.reload(true)
              })
            },
          )
      },
    },
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
  }
</style>
