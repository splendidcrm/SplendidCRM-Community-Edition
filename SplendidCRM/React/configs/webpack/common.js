// shared config (dev and prod)
const { resolve } = require('path');
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const WebpackPwaManifest = require('webpack-pwa-manifest');
var HardSourceWebpackPlugin = require('hard-source-webpack-plugin');
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
        loaders: [
          {
            loader: 'thread-loader',
            options: { 
              workers: 4
            }
          },
          {
          loader:'ts-loader',
          options: {
            transpileOnly: true,
            happyPackMode: true
          }
        }],
        exclude: /node_modules/
      },
      {
        test: /\.css$/,
        use: ['style-loader', { loader: 'css-loader', options: { importLoaders: 1 } }, 'postcss-loader',],
      },
      {
        test: /\.scss$/,
        loaders: [
          'style-loader',
          { loader: 'css-loader', options: { importLoaders: 1 } },
          'postcss-loader',
          'sass-loader',
        ],
      },
      {
        test: /\.(woff(2)?|ttf|eot|svg)(\?v=\d+\.\d+\.\d+)?$/,
        loader: 'file-loader'
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loaders: [
          'url-loader',
        ],
      },
    ],
  },
  plugins: [
    new ForkTsCheckerWebpackPlugin({
      checkSyntacticErrors: true,
      tsconfig: '../tsconfig.json',
      measureCompilationTime: true,
      useTypescriptIncrementalApi: true,
      memoryLimit: 4096
    }),
    new HardSourceWebpackPlugin(),
    new HtmlWebpackPlugin({ template: 'index.html.ejs', mobile: false }),
    new WebpackPwaManifest({
      name: 'SplendidCRM Web App',
      short_name: 'SplendidCRM',
      description: 'The official SplendidCRM web application',
      background_color: '#ffffff',
      crossorigin: 'use-credentials', //can be null, use-credentials or anonymous
      icons: [
        {
          src: resolve('src/favicon.ico'),
          sizes: [16, 32]
        }
      ]
    })
  ],
  performance: {
    hints: false,
  },
  externals: function (context, request, callback) {
    if (/xlsx|canvg|pdfmake/.test(request)) {
      return callback(null, "commonjs " + request);
    }
    callback();
  }
};
