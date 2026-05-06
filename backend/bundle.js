import { bundle } from '@adminjs/bundler';
import { ComponentLoader } from 'adminjs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const componentLoader = new ComponentLoader()
componentLoader.add('Dashboard', path.join(__dirname, 'components/dashboard'));

componentLoader.override('Login', path.join(__dirname, 'components/login'));

await bundle({
  componentLoader,
  destinationDir: '.adminjs',
});

console.log('✅ AdminJS components bundled');