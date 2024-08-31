const path = require('path');

module.exports = {
  entry: './src/index.js', // Update this to the correct entry file path
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: 'production',
};
