module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ["module:react-native-dotenv", { "moduleName": "@env", "path": ".env", "safe": true, "allowUndefined": false }],
    ['module-resolver', { 'root': ['./src'], 'alias': { '@': './src' } }]
  ],
};
