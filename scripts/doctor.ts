#!/usr/bin/env node

import chalk from 'chalk';
import { findSavesDir } from '../lib/tts_mod_helper';

chalk.magentaBright('Stardust Doctor: Diagnosing...');

try {
  const savesDir = findSavesDir();
  console.log(
    chalk.greenBright('  * Found "Saves"'),
    chalk.grey(`: ${savesDir}`),
  );
} catch (e) {
  console.error(
    chalk.redBright('  * Could not find "Saves"'),
    chalk.grey(`: ${e}`),
  );
}
