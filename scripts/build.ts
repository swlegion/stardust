#!/usr/bin/env node

import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { exit } from 'shelljs';
import { concatAndMergeData, loadAndRewriteJson } from '../lib/tts_json_helper';

function onCleanup(): void {
  exit(0);
}

process.on('SIGINT', onCleanup);

console.log(chalk.magentaBright('\nStardust Development Tool\n'));
console.log('Starting up build process...');

console.log('Copying and re-writing mod...');
const modInSourceTree = path.join('src', 'mod', 'Stardust.json');
const modInOutputDir = path.join('.build', 'stardust', 'Stardust.json');

const modJson = fs.readFileSync(modInSourceTree, { encoding: 'UTF-8' });
const outputJson = loadAndRewriteJson(modJson);
fs.writeFileSync(modInOutputDir, outputJson);

console.log('Concatenating and merging JSON...');
const mergedJson = concatAndMergeData();
const jsonInOutputDir = path.join('.build', 'stardust', 'data.json');
fs.writeFileSync(jsonInOutputDir, mergedJson);

console.log(chalk.magentaBright('Done!\n'));

onCleanup();
