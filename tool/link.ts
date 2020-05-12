import { createSymlink } from '../src';

(async (): Promise<void> => {
  await createSymlink(process.argv[2]);
})();
