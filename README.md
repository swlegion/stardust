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
automatically, or you can do it manually using `npm run extract`.

[2]: https://atom.io/
[3]: https://atom.io/packages/tabletopsimulator-lua
