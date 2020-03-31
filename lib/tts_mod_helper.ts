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
        'Documents',
        'My Games',
        'Tabletop Simulator',
        'Saves',
      );
      break;
    default:
      // TODO: Implement support for Mac and Linux.
      throw new Error(`Unsupported: ${os.platform()}.`);
  }
  if (!fs.existsSync(dir)) {
    throw new Error(`Could not find "Saves" at "${dir}".`);
  }
  return dir;
}

/**
 * Creates a symbolic link/shortcut to the saves directory.
 *
 * Returns whether it was created.
 */
export function createDevLink(savesDir: string): boolean {
  const from = path.join(savesDir, 'Stardust');
  const to = path.resolve(path.join('.build', 'stardust'));
  if (
    fs.existsSync(from) &&
    path.relative(fs.readlinkSync(from), path.normalize(to)) === ''
  ) {
    return false;
  }
  switch (os.platform()) {
    case 'win32':
      fs.symlinkSync(to, from, 'junction');
      break;
    default:
      fs.symlinkSync(to, from, 'dir');
      break;
  }
  return true;
}
