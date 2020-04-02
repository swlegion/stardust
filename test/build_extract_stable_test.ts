import path from 'path';
import {
  embedMetaToSave,
  extractMetaFromSave,
  readMetaFromSource,
} from '../lib/mod';

test('building and extracting are stable operations', () => {
  // Read src/** as a JSON tree.
  const sourceTree = readMetaFromSource('global', path.join('src'));

  // Write the JSON tree into the save-file JSON format.
  const rebuildMod = embedMetaToSave(sourceTree);

  // Convert the save-file JSON format back into the JSON tree.
  const rebuildSrc = extractMetaFromSave(rebuildMod);

  expect(sourceTree).toEqual(rebuildSrc);
});
