#!/usr/bin/env nod

import fs from 'fs-extra';
import path from 'path';
import { ModRepoMapper } from '../lib/mod/mapper';

const file = path.join('.build', 'stardust', 'Stardust.json');
const mapper = new ModRepoMapper();
const json = mapper.mapSave(fs.readJsonSync(file));
mapper.writeMapSync(path.join('src'), json);
