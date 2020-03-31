#!/usr/bin/env node

import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { exit } from 'shelljs';

function onCleanup(): void {
  exit(0);
}

process.on('SIGINT', onCleanup);

console.log(chalk.magentaBright('\nStardust Development Tool\n'));
console.log('Starting up build process...');

console.log('Copying mod...');
const modInSourceTree = path.join('src', 'mod', 'Stardust.json');
const modInOutputDir = path.join('.build', 'stardust', 'Stardust.json');
fs.copyFileSync(modInSourceTree, modInOutputDir);

console.log(chalk.magentaBright('Done!\n'));

onCleanup();
