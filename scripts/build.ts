#!/usr/bin/env node

import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { exit } from 'shelljs';
import { loadAndRewriteJson } from '../lib/tts_json_helper';

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

console.log(chalk.magentaBright('Done!\n'));

onCleanup();
