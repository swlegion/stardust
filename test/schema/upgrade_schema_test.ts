// Checks that the schemas defined for units are working properly.

import * as child from 'child_process';
import path from 'path';

const runAjv = path.join('node_modules', '.bin', 'ajv');
const schema = path.join('data', 'schema', 'upgrade.json');
const refers = path.join('data', 'schema', 'model.json');

test('should pass', () => {
  const check = path.join(
    'test',
    'schema',
    'data',
    'valid_upgrade_schema.json',
  );
  child.execSync(
    `${runAjv} test -s ${schema} -r ${refers} -d ${check} --valid`,
  );
});

test('should fail on missing properties', () => {
  const check = path.join(
    'test',
    'schema',
    'data',
    'invalid_upgrade_schema_1.json',
  );
  child.execSync(
    `${runAjv} test -s ${schema} -r ${refers} -d ${check} --invalid`,
  );
});

test('should fail on invalid properties', () => {
  const check = path.join(
    'test',
    'schema',
    'data',
    'invalid_upgrade_schema_2.json',
  );
  child.execSync(
    `${runAjv} test -s ${schema} -r ${refers} -d ${check} --invalid`,
  );
});
