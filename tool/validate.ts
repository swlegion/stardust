import { exec, exit } from 'shelljs';

/**
 * Executes a tool on the command-line.
 *
 * @param name
 * @param args
 */
function runTool(name: string, ...args: string[]): void {
  console.log(`\nEXEC: ${name}`);
  console.log(...args);
  const result = exec(`${name} ${args.join(' ')}`);
  if (result.code !== 0) {
    console.error(`FAIL: ${name}`, args);
    exit(1);
  } else {
    console.log(`DONE: ${name}`);
  }
}

// Validate that the save files are valid.

runTool(
  'ajv',
  '-d "./dist/Stardust.json"',
  '-s "./node_modules/@matanlurey/tts-save-format/src/schema/SaveState.json"',
  '-r "./node_modules/@matanlurey/tts-save-format/src/schema/*.json"',
  '--errors=line',
  '--changes=line',
);
