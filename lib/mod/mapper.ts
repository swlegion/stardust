import fs from 'fs-extra';
import path from 'path';
import sanitize from 'sanitize-filename';
import { Component, Save } from './json';

const replaceWithUnderscores = /\-|\s|\:|\./g;
const collapseUnderscores = /\_\_+/g;
const removeCharacters = /\(|\)|\[|\]|\{|\}|\<|\>|\!|\'|\"|\`/g;

/**
 * Returns the provided filename normalized.
 *
 * @param {String} name
 */
function normalizeName(name: string): string {
  const result = name
    .replace(replaceWithUnderscores, '_')
    .replace(removeCharacters, '')
    .replace(collapseUnderscores, '_');
  return sanitize(result).toLowerCase();
}

/**
 * Represents a TTS component split into logical parts for source control.
 *
 * TODO: Support states.
 */
export interface MappedComponent {
  /**
   * Child components.
   */
  children: MappedComponent[];

  /**
   * Any information that would be saved in `{name}.json`.
   */
  meta: object;

  /**
   * Computed identifier of the component.
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

const internalChildrenField = '$Children';

/**
 * Provides mapping functionality to store/restore a save JSON as a source tree.
 *
 * Given a `Mod.json`, we map it to something like:
 * ```
 * > src/
 *   > global/
 *     > object/
 *     > object.json
 *   > global.json
 *   > global.lua
 *   > global.xml
 * ```
 */
export class ModRepoMapper {
  private buildComponent(component: MappedComponent): Component {
    return {
      ...component.meta,
      ContainedObjects: component.children.map(this.buildComponent.bind(this)),
      LuaScript: component.lua,
      XmlUI: component.xml,
    } as Component;
  }

  /**
   * Returns a {Save} file from a tree of mapped components.
   *
   * @param global
   */
  public buildSave(global: MappedComponent): Save {
    return {
      ...global.meta,
      ObjectStates: global.children.map(this.buildComponent.bind(this)),
      LuaScript: global.lua,
      XmlUI: global.xml,
    } as Save;
  }

  private mapComponent(component: Component, index: number): MappedComponent {
    const meta = { ...component };
    delete meta.ContainedObjects;
    delete meta.LuaScript;
    delete meta.XmlUI;
    return {
      children: (component.ContainedObjects || []).map((o, i) =>
        this.mapComponent(o, i),
      ),
      meta: meta,
      name: this.nameComponent(component, index),
      lua: component.LuaScript,
      xml: component.XmlUI,
    };
  }

  /**
   * Returns a {Save} file mapped to a {MappedComponent} tree.
   *
   * @param {Save} save
   */
  public mapSave(save: Save): MappedComponent {
    const meta = { ...save };
    delete meta.LuaScript;
    delete meta.ObjectStates;
    delete meta.XmlUI;
    return {
      children: save.ObjectStates.map(this.mapComponent.bind(this)),
      meta: meta,
      name: 'global',
      lua: save.LuaScript,
      xml: save.XmlUI,
    };
  }

  private nameComponent(component: Component, index: number): string {
    const name: string[] = [];
    if (component.Nickname) {
      name.push(normalizeName(component.Nickname));
    } else if (component.Name) {
      name.push(normalizeName(component.Name));
    }
    name.push(component.GUID || `i.${index}`);
    return name.join('.');
  }

  /**
   * Reads a mapped component tree from disk.
   *
   * @param {String} target
   * @param {String} name
   */
  public readMapSync(target: string, name: string): MappedComponent {
    const base = path.join(target, name);
    const meta = fs.readJsonSync(`${base}.json`);
    let lua = '';
    let xml = '';
    if (fs.existsSync(`${base}.lua`)) {
      lua = fs.readFileSync(`${base}.lua`, { encoding: 'UTF-8' });
    }
    if (fs.existsSync(`${base}.xml`)) {
      xml = fs.readFileSync(`${base}.xml`, { encoding: 'UTF-8' });
    }
    const children: string[] = meta[internalChildrenField] || [];
    meta.children = children.map((c) => this.readMapSync(base, c));
    delete meta[internalChildrenField];
    return {
      children: children.map((c) => this.readMapSync(base, c)),
      name: name,
      meta: meta,
      lua: lua,
      xml: xml,
    };
  }

  /**
   * Write the provided mapped component tree to disk.
   *
   * Returns an array of strings of child files written to disk.
   *
   * @param {String} target
   * @param {MappedComponent} component
   */
  public writeMapSync(target: string, component: MappedComponent): string[] {
    const base = path.join(target, component.name);
    const meta = { ...component.meta };
    if (component.lua) {
      fs.writeFileSync(`${base}.lua`, component.lua);
    }
    if (component.xml) {
      fs.writeFileSync(`${base}.xml`, component.xml);
    }
    let results: string[] = [];
    if (component.children && component.children.length) {
      if (fs.existsSync(base)) {
        fs.removeSync(base);
      }
      fs.mkdirpSync(base);
      results = component.children.map((c) => {
        this.writeMapSync(base, c);
        return c.name;
      });
    }
    meta[internalChildrenField] = results;
    fs.writeFileSync(`${base}.json`, JSON.stringify(meta, null, '  '));
    return results;
  }
}
