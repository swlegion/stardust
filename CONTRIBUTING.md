# Getting Started

1. It is highly recommended to download and install [Visual Studio Code][dl-vsc].

   A. Install [Prettier for Visual Studio Code][ext-prettier]
   B. Install [ESLint for Visual Studio Code][ext-es-lint]
   C. Install [Jest for Visual Studio Code][ext-jest]
   D. Install [Lua Formatter for Visual Studio Code][ext-lua-format]

2. Download and install [NodeJS][dl-node].

3. Clone and download `git@github.com:swlegion/stardust.git`.

4. Navigate to `stardust` in your terminal, and initialize with `npm install`.

[dl-vsc]: https://code.visualstudio.com/download
[dl-node]: https://nodejs.org/en/download/
[ext-prettier]: vscode:extension/esbenp.prettier-vscode
[ext-es-lint]: vscode:extension/dbaeumer.vscode-eslint
[ext-jest]: vscode:extension/Orta.vscode-jest
[ext-lua-format]: vscode:extension/Koihik.vscode-lua-format

# Commands

The simplest command to use is `npm run presubmit`, which runs all of the
commands below, ensuring that your code will be able to be submitted upstream.

## `npm run doctor`

Runs common initialization tasks and checks for development.

## `npm run build`

Runs a build, which right now copies and initializes the mod JSON file in the
ouput directory (`.build/stardust`), which in turn makes it accessible to load
in Tabletop Simulator in `Saves`.

You may also run `npm run watch` to re-run the build when something changes.

## `npm run lint`

Checks the source for common style and conformance issues. We use this tool to
ensure that code and JSON data that is written by different people all looks
and operates mostly the same.

You can fix many common problems automatically using
[Visual Studio Code][dl-vsc] or by running `npm run fix`.

## `npm run test`

Runs all the test cases.
