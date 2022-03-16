// development config
const { merge } = require('webpack-merge');
const webpack = require('webpack');
const commonConfig = require('./common');
let cookie;
module.exports = (env) => merge(commonConfig, {
  mode: 'development',
  entry: [
    'react',
    'webpack-dev-server/client?http://localhost:3000',// bundle the client for webpack-dev-server and connect to the provided endpoint
    'webpack/hot/only-dev-server', // bundle the client for hot reloading, only- means to only hot reload for successful updates
    './index.tsx' // the entry point of our app
  ],
  devServer: {
    hot: true, // enable HMR on the server
    port: 3000,
    historyApiFallback: true,
    proxy: {
      '/SplendidCRM/**': {
        target: 'http://training.splendidcrm.com/',
        secure: false,
        changeOrigin: false,
        pathRewrite: {'^/SplendidCRM' : ''},
        onProxyReq: function (proxyReq, req, res) {
          let headers = Object.keys(req.headers);
          for (let key of headers) {
            proxyReq.setHeader(key, req.headers[key]);
          }
          proxyReq.setHeader('Host', 'training.splendidcrm.com');
        }
      }
    }
  },
  output: {
    publicPath: '/'
  },
  devtool: 'source-map',
  plugins: [
    new webpack.HotModuleReplacementPlugin(), // enable HMR globally
    new webpack.NamedModulesPlugin(), // prints more readable module names in the browser console on HMR updates
    new webpack.DefinePlugin({ 'process.env.PATH': JSON.stringify(env.PATH) })
  ],
});
