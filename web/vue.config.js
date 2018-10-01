const FlowBabelWebpackPlugin = require('flow-babel-webpack-plugin');
const path = require('path')

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
        target: "http://localhost:5000"
      },
      "/dev-graphql": {
        target: "http://localhost:5000"
      }
    }
  },
  configureWebpack: {
    plugins: [
      new FlowBabelWebpackPlugin()
    ],
    resolve: {
      alias: {
        graphql$: path.resolve(__dirname, 'node_modules/graphql/index.js')
      },
      extensions: [ '.mjs', '.js', '.json', '.jsx', '.css' ]
    },
    module: {
      rules: [
        {
          test: /\.jsx?$/,
          loader: 'babel-loader',
          exclude: /node_modules/,
          query: {
            cacheDirectory: true,
            presets: ['@babel/preset-env', '@babel/preset-react']
          }
        }
      ]
    }
  }
}