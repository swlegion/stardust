import * as runner from '@matanlurey/tts-runner';
import * as fs from 'fs-extra';
import path from 'path';
import {
  buildToDist,
  createAutoExec,
  createSymlink,
  deleteAutoExec,
  destroySymlink,
  extractToMod,
} from '../src';

/**
 * Entrypoint to `npm start`.
 */
(async (): Promise<void> => {
  fs.mkdirpSync(path.join('dist', 'edit'));
  await buildToDist();

  console.log('Linking...');
  await createSymlink();

  console.log('Configuring...');
  await createAutoExec();

  console.log('Launching...');
  const tts = await runner.launch();

  tts.process.once('exit', () => {
    console.log('Closing...');
    deleteAutoExec()
      .then(() => destroySymlink())
      .then(() => extractToMod())
      .then(() => {
        fs.removeSync(path.join('dist', 'edit'));
        console.log('Bye!');
        process.exit(0);
      });
  });
})();
