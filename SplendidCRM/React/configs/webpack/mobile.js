// production config
const { resolve } = require('path');
const { CheckerPlugin } = require('awesome-typescript-loader');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const webpack = require('webpack');

module.exports = {
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx'],
  },
  context: resolve(__dirname, '../../src'),
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: ['awesome-typescript-loader'],
        exclude: /node_modules/
      },
      {
        test: /\.css$/,
        use: ['style-loader', { loader: 'css-loader', options: { importLoaders: 1 } }, 'postcss-loader',],
      },
      {
        test: /\.scss$/,
        use: [
          'style-loader',
          { loader: 'css-loader', options: { importLoaders: 1 } },
          'postcss-loader',
          'sass-loader',
        ],
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        use: [
          'url-loader',
        ],
      },
    ],
  },
  mode: 'production',
  entry: './index.tsx',
  output: {
    filename: 'js/SteviaCRM.min.js',
    path: resolve(__dirname, '../../www'),
  },
  devtool: 'source-map',
  plugins: [
    new CheckerPlugin(),
    new HtmlWebpackPlugin({ template: 'index.html.ejs', mobile: false }),
  ],
  performance: {
    hints: false,
  },
};
