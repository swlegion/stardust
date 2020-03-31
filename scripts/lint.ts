#!/usr/bin/env node

import { requireTool, runTool } from '../lib/script_helper';

// lints typescript, json.
requireTool('eslint');

// lints json based on json schema.
requireTool('ajv');

runTool('eslint', '--ignore-path .gitignore', '"**/*.{js,ts,json}"');

runTool(
  'ajv',
  '-s "./data/schema/unit.json"',
  '-r "./data/schema/model.json"',
  '-d "./data/unit/**/*.json"',
);

runTool(
  'ajv',
  '-s "./data/schema/upgrade.json"',
  '-r "./data/schema/model.json"',
  '-d "./data/upgrade/**/*.json"',
);
