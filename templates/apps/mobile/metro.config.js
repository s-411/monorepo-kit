// metro.config.js — monorepo-aware
//
// Applied to apps/mobile/ AFTER `create-expo-app` runs. The default Metro
// config from create-expo-app does NOT know about workspace roots, symlinks,
// or hoisted node_modules. Without this file, you'll see:
//   - "Cannot find module" errors for workspace deps (@kit/backend etc)
//   - Symlink resolution failures
//   - Stale cache after metro.config changes (require expo start --clear)
//
// Reference: https://docs.expo.dev/guides/monorepos/

const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, '../..');

const config = getDefaultConfig(projectRoot);

// 1. Watch all files in the monorepo so Metro picks up changes in
//    packages/* and apps/web/.
config.watchFolders = [workspaceRoot];

// 2. Resolve modules from both the app's node_modules AND the workspace root's
//    node_modules. With node-linker=hoisted in .npmrc most deps live at the
//    workspace root.
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(workspaceRoot, 'node_modules'),
];

// 3. Force Metro to resolve symlinks. Required for pnpm's symlink layout
//    even with node-linker=hoisted (some links remain).
config.resolver.unstable_enableSymlinks = true;
config.resolver.unstable_enablePackageExports = true;

// 4. (Optional) If you add react-native-svg-transformer later for inline SVG
//    asset import, add it here. Phase 2 of the kit ships this.
//
// const { getDefaultConfig } = require('expo/metro-config');
// const config = getDefaultConfig(__dirname);
// config.transformer.babelTransformerPath = require.resolve(
//   'react-native-svg-transformer'
// );
// config.resolver.assetExts = config.resolver.assetExts.filter(
//   (ext) => ext !== 'svg'
// );
// config.resolver.sourceExts = [...config.resolver.sourceExts, 'svg'];

module.exports = config;
