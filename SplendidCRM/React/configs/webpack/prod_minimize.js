// production config
const { merge } = require('webpack-merge');
const {resolve} = require('path');

const commonConfig = require('./common');

// mode: development or production
module.exports = merge(commonConfig, {
  mode: 'production',
  entry: './index.tsx',
  devtool: 'source-map',
  output: {
    filename: 'js/SteviaCRM.js',
    path: resolve(__dirname, '../../dist'),
    publicPath: '/',
  },
  plugins: [],
  optimization: {
    minimize: true
  }
});
