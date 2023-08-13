const withCss = require('@zeit/next-css');
const CompressionPlugin = require('compression-webpack-plugin')
const withOptimizedImages = require('next-optimized-images');
const withFonts = require('next-fonts');

let config = withFonts(withOptimizedImages(withCss({
  webpack(config) {
    config.plugins.push(new CompressionPlugin({
      test: /\.(css|js|svg|eot|ttf)$/,
      minRatio: 100000
    }));
    return config;
  }
})))

config.useFileSystemPublicRoutes = false;
let routes = {};
if (process.env.NODE_ENV === 'production') {
  routes = {
    frontendRoute: 'https://guessgoals.com',
    backendRoute:  'https://api.guessgoals.com',
    cableRoute:    'wss://api.guessgoals.com/cable'
  }
} else if (process.env.NODE_ENV === 'development') {
  routes = {
    frontendRoute: 'http://localhost:5000',
    backendRoute:  'http://localhost:3000',
    cableRoute:    'ws://localhost:3000/cable'
  }
} else if (process.env.NODE_ENV === 'test') {
  routes = {
    frontendRoute: 'http://localhost:5000',
    backendRoute:  'http://localhost:3000',
    cableRoute:    'ws://localhost:3000/cable'
  }
}
module.exports = {
  ...config,
  distDir: '../_next',
  publicRuntimeConfig: {
    ...routes
  }
};