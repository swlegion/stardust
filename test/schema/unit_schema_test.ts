import * as child from 'child_process';
import path from 'path';

const runAjv = path.join('node_modules', '.bin', 'ajv');
const schema = path.join('data', 'schema', 'unit.json');

test('should pass', () => {
  const check = path.join('test', 'schema', 'data', 'valid_unit_schema.json');
  child.execSync(`${runAjv} test -s ${schema} -d ${check} --valid`);
});

test('should fail on missing properties', () => {
  const check = path.join(
    'test',
    'schema',
    'data',
    'invalid_unit_schema_1.json',
  );
  child.execSync(`${runAjv} test -s ${schema} -d ${check} --invalid`);
});

test('should fail on invalid properties', () => {
  const check = path.join(
    'test',
    'schema',
    'data',
    'invalid_unit_schema_2.json',
  );
  child.execSync(`${runAjv} test -s ${schema} -d ${check} --invalid`);
});