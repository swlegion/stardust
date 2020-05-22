# stardust

An experimental Tabletop Simulator mod for a popular miniatures game.

## Getting Started

[Download Node.js][1] and then setup the development tools:

```sh
$ npm install
```

[1]: https://nodejs.org/en/download/

You can then build and start Tabletop Simulator automatically:

```sh
$ npm start
```

It is highly recommended to install and use the [Atom Editor][2] with the
official [Tabletop Simulator plugin][3] at this time. You can make edits,
and then when you are ready save over the generated file:

![Example](https://user-images.githubusercontent.com/168174/81742133-78055300-9454-11ea-8fc7-8162c9e8898e.png)

Upon closing Tabletop Simulator, the files in `mod` will be updated
automatically.

[2]: https://atom.io/
[3]: https://atom.io/packages/tabletopsimulator-lua

## Multiplayer sessions

The current workflow is optimized around local (single-player) sessions. To demo
with someone else, you will need to use an asset server that is reachable for
the other users. Currently, you can use _GitHub_ as the source of the truth:

```sh
# Builds dist/Stardust.json, but with assets pointing to:
# `https://raw.githubusercontent.com/swlegion/stardust/master/assets/`
#
# ... this does mean that you cannot use in-progress/local-only assets.
$ npm run build -- --use-github-for-assets
```

## Advanced users

If you are feeling up to it, or don't develop on Windows:

```sh
# Builds dist/Stardust.json
$ npm run build

# Creates a link from dist/ to the provided directory (your TTS/Saves directory).
#
# See: https://www.pcgamingwiki.com/wiki/Tabletop_Simulator
#
#   macOS (OS X)	~/Library/Tabletop Simulator/
#   Linux	~/.local/share/Tabletop Simulator/
$ npm run link -- "~/path/to/saves/dir"

# Runs the local asset server
$ npm run serve
```

You can now load up Tabletop Simulator manually, and open `TTSDevLink/Stardust`.
When you are done making any changes to this save file, you can run the command:

```sh
$ npm run extract
```

... to reflect the changes into the `mod/` folder.
