# Getting Started

1. It is highly recommended to download and install [Visual Studio Code][dl-vsc].

   A. Install [Prettier for Visual Studio Code][ext-prettier]
   B. Isntall [ESLint for Visual Studio Code][ext-es-lint]
   C. Install [Lua Formatter for Visual Studio Code][ext-lua-format]

2. Download and install [NodeJS][dl-node].

3. Clone and download `git@github.com:swlegion/stardust.git`.

4. Navigate to `stardust` in your terminal, and initialize with `npm install`.

[dl-vsc]: https://code.visualstudio.com/download
[dl-node]: https://nodejs.org/en/download/
[ext-prettier]: vscode:extension/esbenp.prettier-vscode
[ext-es-lint]: vscode:extension/dbaeumer.vscode-eslint
[ext-lua-format]: vscode:extension/Koihik.vscode-lua-format

# Commands

## `npm run lint`

Checks the source for common style and conformance issues. We use this tool to
ensure that code and JSON data that is written by different people all looks
and operates mostly the same.

You can fix many common problems automatically using
[Visual Studio Code][dl-vsc] or by running `npm run lint -- --fix`.
