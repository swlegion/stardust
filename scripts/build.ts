#!/usr/bin/env node

import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import shell, { exit } from 'shelljs';
import { ModRepoMapper } from '../lib/mod/mapper';
import { createDevLink, findSavesDir } from '../lib/mod/tools';
import { concatAndMergeData } from '../lib/tts_json_helper';

function onCleanup(): void {
  exit(0);
}

process.on('SIGINT', onCleanup);

console.log(chalk.magentaBright('\nStardust Development Tool\n'));
console.log('Starting up build process...');

const savesDir = findSavesDir();
console.log('Found TTS installation', savesDir);
createDevLink(savesDir);

const modInSourceTree = path.join('src');
console.log('Copying and re-building mod from', modInSourceTree);

const modInOutputDir = path.join('.build', 'mod', 'stardust.json');
const mapper = new ModRepoMapper();
const modMetaTree = mapper.readMapSync(modInSourceTree, 'global');

console.log('Saving mod to', modInOutputDir);
const save = mapper.buildSave(modMetaTree);
fs.writeFileSync(modInOutputDir, JSON.stringify(save, null, '  '));

console.log('Concatenating and merging JSON...');
const mergedJson = concatAndMergeData();
const jsonInOutputDir = path.join('.build', 'data.json');
fs.writeFileSync(jsonInOutputDir, mergedJson);

console.log('Preparing HTML...');
const inputHtml = fs.readFileSync('index.html', { encoding: 'UTF-8' });
const gitCommit = shell.exec('git rev-parse --short HEAD', { silent: true });
const replaceHtml = inputHtml.replace(/\{\%COMMIT\%\}/g, gitCommit);
const htmlInOutputDir = path.join('.build', 'index.html');
fs.writeFileSync(htmlInOutputDir, replaceHtml);

console.log(chalk.magentaBright('\nDone!\n'));

onCleanup();
