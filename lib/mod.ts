import fs from 'fs-extra';
import path from 'path';
import sanitize from 'sanitize-filename';
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

  /**
   * Position.
   */
  __zIndex?: number;
}

function normalize(identifier: string): string {
  return sanitize(identifier.toLowerCase()).trim().replace(/ /g, '_');
}

/**
 * Returns a unique identifier for the provided component.
 *
 * @param component
 */
function canonicalize(component: Component, index: number): string {
  const name = [component.GUID || `$index.${index}`];
  if (component.Nickname) {
    name.push(normalize(component.Nickname));
  } else if (component.Name) {
    name.push(normalize(component.Name));
  }
  return name.join('.');
}

function extractMetaFromComponent(
  component: Component,
  index: number,
): MetaComponent {
  const meta = { ...component };
  const hasChildrenWithGUIDS =
    meta.ContainedObjects && meta.ContainedObjects.some((c) => c.GUID);
  if (hasChildrenWithGUIDS) {
    delete meta.ContainedObjects;
  }
  delete meta.LuaScript;
  delete meta.States;
  delete meta.XmlUI;
  meta['__zIndex'] = index;
  const result: MetaComponent = {
    children: hasChildrenWithGUIDS
      ? (component.ContainedObjects || []).map((v, c) => {
          return extractMetaFromComponent(v, c);
        })
      : [],
    name: canonicalize(component, index),
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

function embedMetaToComponent(component: MetaComponent): Component {
  const copy = { ...component.meta };
  delete copy['__zIndex'];
  const result = {
    ...copy,
    LuaScript: component.lua || '',
    XmlUI: component.xml || '',
  } as Component;
  if (component.children && component.children.length) {
    result.ContainedObjects = component.children.map(embedMetaToComponent);
  }
  return result;
}

/**
 * Writes a meta tree as a save file.
 *
 * @param global
 */
export function embedMetaToSave(global: MetaComponent): Save {
  return {
    ...global.meta,
    ObjectStates: global.children.map(embedMetaToComponent),
    LuaScript: global.lua || '',
    XmlUI: global.xml || '',
  } as Save;
}

/**
 * Writes the meta tree to the provided directory.
 *
 * @param meta
 * @param target
 */
export function writeMetaToSource(meta: MetaComponent, target: string): void {
  const base = path.join(target, meta.name);
  fs.writeFileSync(`${base}.json`, JSON.stringify(meta.meta, null, '  '));
  if (meta.lua) {
    fs.writeFileSync(`${base}.lua`, meta.lua);
  }
  if (meta.xml) {
    fs.writeFileSync(`${base}.xml`, meta.xml);
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
  const meta = fs.readJsonSync(
    path.join(source, `${file}.json`),
  ) as MetaComponent;
  const json = {
    meta: meta,
  } as MetaComponent;
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
    const files = fs
      .readdirSync(children)
      .filter((v) => path.extname(v) === '.json')
      .map((file) => {
        const name = file.split('.').slice(0, -1).join('.');
        return readMetaFromSource(name, children);
      })
      .sort((a, b) => a.__zIndex - b.__zIndex);
    json.children = files;
  }
  return json;
}
