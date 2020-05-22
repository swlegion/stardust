import minimist from 'minimist';
import { extractToMod } from '../src';

(async (): Promise<void> => {
  const args = minimist(process.argv.slice(2));
  await extractToMod({
    useGitHubAsAssetSource: !!args['use-github-for-assets'],
  });
})();
