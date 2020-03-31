import fs from 'fs-extra';
import path from 'path';
import { TTSBase, TTSMod } from './types/tts_json';

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
