import sanitize from 'sanitize-filename';

const replaceWithUnderscores = /\-|\s|\:|\./g;
const collapseUnderscores = /\_\_+/g;
const removeCharacters = /\(|\)|\[|\]|\{|\}|\<|\>|\!|\'|\"|\`/g;

/**
 * Returns the provided filename normalized.
 *
 * @param {String} name
 */
export function normalizeName(name: string): string {
  const result = name
    .replace(replaceWithUnderscores, '_')
    .replace(removeCharacters, '')
    .replace(collapseUnderscores, '_');
  return sanitize(result).toLowerCase();
}
