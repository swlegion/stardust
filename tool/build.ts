import minimist from 'minimist';
import { buildToDist } from '../src';

(async (): Promise<void> => {
  const args = minimist(process.argv.slice(2));
  await buildToDist({
    useGitHubAsAssetSource: !!args['use-github-for-assets'],
  });
})();
