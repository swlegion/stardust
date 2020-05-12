import * as expander from '@matanlurey/tts-expander';
import * as fs from 'fs-extra';
import path from 'path';

(async (): Promise<void> => {
  const source = path.join('dist', 'Stardust.json');
  const target = 'mod';
  await fs.remove(target);
  await fs.mkdirp(target);
  const splitter = new expander.SplitIO();
  const modTree = await splitter.readSaveAndSplit(source);
  await splitter.writeSplit(target, modTree);
})();
