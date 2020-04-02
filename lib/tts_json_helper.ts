import fs from 'fs-extra';
import glob from 'glob';
import path from 'path';
import { DataBlob, Unit } from './types/schema';

const rewriteBasePath = `file://${path.posix.resolve('.')}/`.replace(
  /\\/g,
  '/',
);
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
