import fs from 'fs-extra';
import glob from 'glob';
import path from 'path';
import { DataBlob, Unit } from './types/schema';
import { TTSBase, TTSMod } from './types/tts_json';

const rewriteBasePath = `file://${path.posix.resolve('.')}/`.replace(
  /\\/g,
  '/',
);

function rewriteInclude(include: string): string {
  const lines = include.split('\n');
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.indexOf('#include ') === 0) {
      const include = line.substring('#include '.length);
      let relative = path.join('src', include);
      if (path.extname(relative) === '') {
        relative = `${relative}.ttslua`;
      }
      const loaded = fs.readFileSync(relative, { encoding: 'UTF-8' });
      lines[i] = rewriteInclude(loaded);
    } else if (line.indexOf('~#/') !== -1) {
      lines[i] = line.replace('~#/', rewriteBasePath);
    }
  }
  return lines.join('\n');
}

function rewriteIncludes(object: TTSBase): void {
  const lua = object.LuaScript;
  object.LuaScript = rewriteInclude(lua);
  const xml = object.XmlUI;
  object.XmlUI = rewriteInclude(xml);
}

/**
 * Loads and concatenates all of the JSON data in `data/` into a single blob.
 */
export function concatAndMergeData(
  options: { format: boolean } = { format: true },
): string {
  const blob: DataBlob = { units: [], upgrades: [] };
  const units = glob.sync(path.join('data', 'unit', '**', '*.json'));
  for (const unit of units) {
    const rewrittenUnit = JSON.parse(
      fs.readFileSync(unit, { encoding: 'UTF-8' }),
    ) as Unit;
    rewrittenUnit.card = rewrittenUnit.card.replace('./', rewriteBasePath);
    rewrittenUnit.models = rewrittenUnit.models
      ? rewrittenUnit.models.map((model) => {
          model.render = model.render.replace('./', rewriteBasePath);
          if (typeof model.texture === 'string') {
            model.texture = model.texture.replace('./', rewriteBasePath);
          }
          return model;
        })
      : [];
    blob.units.push(rewrittenUnit);
  }
  return JSON.stringify(blob, null, options.format ? '  ' : undefined);
}

/**
 * Loads the provided string as a mod, and returns it re-written as needed.
 *
 * @param json Full JSON string of the mod file.
 */
export function loadAndRewriteJson(
  json: string,
  options: { format: boolean } = { format: true },
): string {
  const mod = JSON.parse(json) as TTSMod;
  rewriteIncludes(mod);
  return JSON.stringify(mod, null, options.format ? '  ' : undefined);
}
