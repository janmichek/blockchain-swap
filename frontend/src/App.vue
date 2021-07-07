<template>
  <div v-if="isDrizzleInitialized" id="app">
    <div>Hello world</div>
  </div>
  <div v-else>
    Loading
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    name: 'app',
    computed: mapGetters('drizzle', ['isDrizzleInitialized']),
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }
</style>
