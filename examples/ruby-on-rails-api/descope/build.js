const build = require('esbuild')
const chokidar = require('chokidar');
const dotenv = require('dotenv');
const envFile = '.env';
dotenv.config({ path: envFile })

const buildOptions = {
    entryPoints: ['app/javascript/**/*.js', "app/javascript/**/*.jsx"],
    outdir: 'app/assets/builds',
    bundle: true,
    sourcemap: true,
    format: 'esm',
    publicPath: '/assets',
    loader: {
        '.js': 'jsx',
    },
    define: {
        'process.env.REACT_APP_PROJECT_ID': `"${process.env.REACT_APP_PROJECT_ID}"`,
    }
}

chokidar.watch('app/javascript/**/*').on('change', async () => {
    try {
        console.log('File change detected, rebuilding...');
        await build.build(buildOptions);
        console.log('Build succeeded.');
    } catch (e) {
        console.error('Build failed.', e);
    }
});