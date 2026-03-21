import livereload from 'rollup-plugin-livereload';
import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import { terser } from 'rollup-plugin-terser';

const isRelease = process.env.NODE_ENV === 'production';

export default [{
  input: 'src/storage/js/dashboard.js',
  output: [
    {
      name: 'UI',
      file: 'src/storage/assets/dashboard.js',
      format: 'iife'
    }
  ],
  plugins: [
    // Automatic page refresh after any changes
    (!isRelease) &&livereload('src/storage/assets/dashboard.js'),
    nodeResolve(),
    commonjs({
      include: 'node_modules/**',
      requireReturnsDefault: 'auto'
    }),
    ...(isRelease ? [terser()] : [])
  ]
}];