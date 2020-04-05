/**
 * Represents a scriptable entity in TTS.
 */
export interface Scriptable {
  /**
   * Lua, if any, for this entity.
   */
  LuaScript: string;

  /**
   * XML, if any, for this entity.
   */
  XmlUI: string;
}

/**
 * Represents the top-level JSON structure of a mod/save file.
 */
export interface Save extends Scriptable {
  /**
   * Objects contained in the mod.
   */
  ObjectStates: Component[];

  /**
   * Version of TTS this save file is from.
   */
  VersionNumber: string;
}

export interface Component extends Scriptable {
  /**
   * If this object can contain other objects, an array of those objects.
   */
  ContainedObjects?: Component[];

  /**
   * Name of the object.
   */
  Name: string;

  /**
   * A custom name of the object.
   */
  Nickname: string;

  /**
   * Unique ID of the object.
   */
  GUID: string;

  /**
   * Alternative states for this object.
   */
  States?: { [index: string]: Component };
}
