#!/usr/bin/env nod

import fs from 'fs-extra';
import path from 'path';
import { extractMetaFromSave, writeMetaToSource } from '../lib/mod';
import { Save } from '../lib/mod/json';

const file = path.join('.build', 'stardust', 'Stardust.json');
const json = fs.readJsonSync(file) as Save;
const meta = extractMetaFromSave(json);
writeMetaToSource(meta, path.join('src'));
