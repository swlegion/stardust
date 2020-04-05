#!/usr/bin/env node

import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { exit } from 'shelljs';
import { ModRepoMapper } from '../lib/mod/mapper';
import { concatAndMergeData } from '../lib/tts_json_helper';

function onCleanup(): void {
  exit(0);
}

process.on('SIGINT', onCleanup);

console.log(chalk.magentaBright('\nStardust Development Tool\n'));
console.log('Starting up build process...');

console.log('Copying and re-building mod...');
const modInSourceTree = path.join('src');
const modInOutputDir = path.join('.build', 'stardust', 'Stardust.json');
const mapper = new ModRepoMapper();
const modMetaTree = mapper.readMapSync(modInSourceTree, 'global');
mapper.writeMapSync(modInOutputDir, modMetaTree);

console.log('Concatenating and merging JSON...');
const mergedJson = concatAndMergeData();
const jsonInOutputDir = path.join('.build', 'data.json');
fs.writeFileSync(jsonInOutputDir, mergedJson);

console.log(chalk.magentaBright('Done!\n'));

onCleanup();
