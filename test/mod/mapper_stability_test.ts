import path from 'path';
import { ModRepoMapper } from '../../lib/mod/mapper';

test('extracting and embedding should build a stable result', () => {
  const srcDir = path.join('src');
  const mapper = new ModRepoMapper();
  const srcTree = mapper.readMapSync(srcDir, 'global');
  const outJson = mapper.buildSave(srcTree);
  const buildTree = mapper.mapSave(outJson);
  expect(srcTree).toEqual(buildTree);
});
