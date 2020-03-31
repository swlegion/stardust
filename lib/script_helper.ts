import chalk from 'chalk';
import fs from 'fs-extra';
import path from 'path';
import { exec, exit } from 'shelljs';

const nodeModulesBin = path.join('node_modules', '.bin');

/**
 * Fails and exists if the required tool is not found in `node_modules/.bin`.
 *
 * @param name Name of the tool, e.g. "eslint".
 */
export function requireTool(name: string): void {
  const toolPath = path.join(nodeModulesBin, name);
  if (!fs.existsSync(toolPath)) {
    console.error(`Could not find tool "${name}"`, `Path: ${toolPath}`);
    exit(1);
  }
}

/**
 * Executes a tool on the command-line.
 *
 * @param name
 * @param args
 */
export function runTool(name: string, ...args: string[]): void {
  console.log(chalk.blueBright(`\nEXEC: ${name}`));
  console.log(chalk.grey(...args));
  const result = exec(`${name} ${args.join(' ')}`);
  if (result.code !== 0) {
    console.error(chalk.redBright(`FAIL: ${name}`, args));
    exit(1);
  } else {
    console.log(chalk.greenBright(`DONE: ${name}`));
  }
}
