module.exports = {
  pluginOptions: {
    apollo: {
      enableMocks: true,
      enableEngine: false
    }
  },
  devServer: {
    proxy: {
      "/graphql": {
        target: "http://localhost:5000",
      }
    }
  }
}