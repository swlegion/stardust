#!/usr/bin/env node

import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { exit } from 'shelljs';
import { embedMetaToSave, readMetaFromSource } from '../lib/mod';
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
const modMetaTree = readMetaFromSource('global', modInSourceTree);
const metaToSave = embedMetaToSave(modMetaTree);
fs.writeFileSync(modInOutputDir, JSON.stringify(metaToSave, null, '  '));

console.log('Concatenating and merging JSON...');
const mergedJson = concatAndMergeData();
const jsonInOutputDir = path.join('.build', 'data.json');
fs.writeFileSync(jsonInOutputDir, mergedJson);

console.log(chalk.magentaBright('Done!\n'));

onCleanup();
