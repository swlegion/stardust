import fs from 'fs-extra';
import * as os from 'os';
import path from 'path';

/**
 * Returns the "Saves" directory for Tabletop Simulator.
 *
 * If cannot be found, then throws a runtime error.
 */
export function findSavesDir(): string {
  let dir: string;
  switch (os.platform()) {
    case 'win32':
      dir = path.join(
        process.env.USERPROFILE,
        'My Games',
        'Tabletop Simulator',
        'Saves',
      );
      break;
    default:
      // TODO: Implement support for Mac and Linux.
      throw new Error(`Unsupported: ${os.platform()}.`);
  }
  if (!fs.pathExistsSync(dir)) {
    throw new Error(`Could not find "Saves" at "${dir}".`);
  }
  return dir;
}
