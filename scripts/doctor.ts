#!/usr/bin/env node

import chalk from 'chalk';
import * as os from 'os';
import { createDevLink, findSavesDir } from '../lib/tts_mod_helper';

// Say Hello.
console.log(chalk.magentaBright('\nStardust Doctor: Diagnosing...\n'));

console.log('  * Platform', chalk.cyanBright(os.platform().toUpperCase()));

let savesDir: string;

// Find the "Tabletop Simulator/Saves" directory.
try {
  savesDir = findSavesDir();
  console.log(
    '  *',
    chalk.greenBright('Found "Saves"'),
    chalk.grey(`${savesDir}`),
  );
} catch (e) {
  console.error(
    '  *',
    chalk.redBright('Could not find "Saves"'),
    chalk.grey(`${e}`),
  );
}

// Create a symbolic link if needed.
if (createDevLink(savesDir)) {
  console.log('  *', chalk.greenBright('Created Link to "Stardust"'));
} else {
  console.log('  *', chalk.greenBright('Found Link to "Stardust"'));
}

// Say Goodbye.
console.log(chalk.magentaBright('\nDone!'));
