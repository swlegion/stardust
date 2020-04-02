import fs from 'fs-extra';
import path from 'path';
import { Component, Save } from './mod/json';

/**
 * Represents a TTS component split into logical parts for source control.
 *
 * TODO: Support states.
 */
interface MetaComponent {
  /**
   * Child components.
   */
  children: MetaComponent[];

  /**
   * Any information that would go in `{name}.json`.
   */
  meta: object;

  /**
   * Computed name of the component.
   *
   * Usually `{index}.{name}.{guid}`, but possibly also `global`.
   */
  name: string;

  /**
   * Lua script.
   */
  lua: string;

  /**
   * XML UI.
   */
  xml: string;
}

function extractMetaFromComponent(
  component: Component,
  index: number,
): MetaComponent {
  const meta = { ...component };
  delete meta.ContainedObjects;
  delete meta.GUID;
  delete meta.LuaScript;
  delete meta.States;
  delete meta.XmlUI;
  const result: MetaComponent = {
    children: (component.ContainedObjects || []).map((v, c) => {
      return extractMetaFromComponent(v, c);
    }),
    name: `${index}.${component.GUID}`,
    lua: component.LuaScript,
    meta: meta,
    xml: component.XmlUI,
  };
  return result;
}

/**
 * Returns the provided save JSON file as a tree of {MetaComponent}.
 *
 * @param save
 */
export function extractMetaFromSave(save: Save): MetaComponent {
  const meta = { ...save };
  delete meta.LuaScript;
  delete meta.ObjectStates;
  delete meta.XmlUI;
  return {
    children: save.ObjectStates.map((v, c) => {
      return extractMetaFromComponent(v, c);
    }),
    name: 'global',
    meta: meta,
    lua: save.LuaScript,
    xml: save.XmlUI,
  };
}

/**
 * Writes the meta tree to the provided directory.
 *
 * @param meta
 * @param target
 */
export function writeMetaToSource(meta: MetaComponent, target: string): void {
  const base = path.join(target, meta.name);
  fs.writeFileSync(
    `${base}.json`,
    JSON.stringify(meta.meta, null, '  ') + '\n',
  );
  if (meta.lua) {
    fs.writeFileSync(`${base}.lua`, meta.lua + '\n');
  }
  if (meta.xml) {
    fs.writeFileSync(`${base}.xml`, meta.xml + '\n');
  }
  if (meta.children && meta.children.length) {
    const childTarget = base;
    if (fs.existsSync(childTarget)) {
      fs.removeSync(childTarget);
    }
    fs.mkdirpSync(childTarget);
    meta.children.forEach((v) => writeMetaToSource(v, childTarget));
  }
}

/**
 * Reads a meta tree from the provided directory.
 *
 * @param file
 * @param source
 */
export function readMetaFromSource(
  file: string,
  source: string,
): MetaComponent {
  const json = fs.readJsonSync(
    path.join(source, `${file}.json`),
  ) as MetaComponent;
  const lua = path.join(source, `${file}.lua`);
  if (fs.existsSync(lua)) {
    json.lua = fs.readFileSync(lua, { encoding: 'UTF-8' });
  } else {
    json.lua = '';
  }
  const xml = path.join(source, `${file}.xml`);
  if (fs.existsSync(xml)) {
    json.xml = fs.readFileSync(xml, { encoding: 'UTF-8' });
  } else {
    json.xml = '';
  }
  const children = path.join(source, file);
  if (fs.existsSync(children)) {
    const collect: MetaComponent[] = [];
    const files = fs
      .readdirSync(children)
      .filter((v) => path.extname(v) === 'json')
      .sort();
    for (const file of files) {
      collect.push(readMetaFromSource(path.basename(file), children));
    }
    json.children = collect;
  }
  return json;
}
