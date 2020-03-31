#!/usr/bin/env node

import { requireTool, runTool } from '../lib/script_helper';

// fixes typescript, json.
requireTool('eslint');

// fixes whatever can be automated.
runTool('eslint', '--ignore-path .gitignore', '--fix', '"**/*.{js,ts,json}"');
