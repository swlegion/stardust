import fs from 'fs-extra';
import mock from 'mock-fs';
import path from 'path';
import { MappedComponent, ModRepoMapper } from '../../lib/mod/mapper';

let mapper: ModRepoMapper;

beforeEach(() => (mapper = new ModRepoMapper()));

test('should load a trivial [empty] save', () => {
  const actual = mapper.mapSave({
    LuaScript: '-- Lua',
    ObjectStates: [],
    VersionNumber: '1.0',
    XmlUI: '<!-- Xml -->',
  });
  expect(actual).toMatchInlineSnapshot(`
    Object {
      "children": Array [],
      "lua": "-- Lua",
      "meta": Object {
        "VersionNumber": "1.0",
      },
      "name": "global",
      "xml": "<!-- Xml -->",
    }
  `);
});

test('should load a save with a few children', () => {
  const actual = mapper.mapSave({
    LuaScript: '-- Lua',
    ObjectStates: [
      {
        Name: 'Block',
        GUID: 'A12345',
        LuaScript: '',
        Nickname: 'Red Block',
        XmlUI: '',
      },
      {
        Name: 'Block',
        GUID: 'B12345',
        LuaScript: '',
        Nickname: 'Blue Block',
        XmlUI: '',
      },
    ],
    VersionNumber: '1.0',
    XmlUI: '<!-- Xml -->',
  });
  expect(actual).toMatchInlineSnapshot(`
    Object {
      "children": Array [
        Object {
          "children": Array [],
          "lua": "",
          "meta": Object {
            "GUID": "A12345",
            "Name": "Block",
            "Nickname": "Red Block",
          },
          "name": "red_block.A12345",
          "xml": "",
        },
        Object {
          "children": Array [],
          "lua": "",
          "meta": Object {
            "GUID": "B12345",
            "Name": "Block",
            "Nickname": "Blue Block",
          },
          "name": "blue_block.B12345",
          "xml": "",
        },
      ],
      "lua": "-- Lua",
      "meta": Object {
        "VersionNumber": "1.0",
      },
      "name": "global",
      "xml": "<!-- Xml -->",
    }
  `);
});

test('should load a save with a few un-GUID-ed children', () => {
  const actual = mapper.mapSave({
    LuaScript: '-- Lua',
    ObjectStates: [
      {
        Name: 'Bag',
        GUID: 'A12345',
        LuaScript: '',
        Nickname: '',
        XmlUI: '',
        ContainedObjects: [
          {
            Name: 'Card',
            GUID: '',
            LuaScript: '',
            Nickname: '',
            XmlUI: '',
          },
          {
            Name: 'Card',
            GUID: '',
            LuaScript: '',
            Nickname: '',
            XmlUI: '',
          },
          {
            Name: 'Card',
            GUID: 'B12345',
            LuaScript: '',
            Nickname: 'Joker',
            XmlUI: '',
          },
        ],
      },
    ],
    VersionNumber: '1.0',
    XmlUI: '<!-- Xml -->',
  });
  expect(actual).toMatchInlineSnapshot(`
    Object {
      "children": Array [
        Object {
          "children": Array [
            Object {
              "children": Array [],
              "lua": "",
              "meta": Object {
                "GUID": "",
                "Name": "Card",
                "Nickname": "",
              },
              "name": "card.i.0",
              "xml": "",
            },
            Object {
              "children": Array [],
              "lua": "",
              "meta": Object {
                "GUID": "",
                "Name": "Card",
                "Nickname": "",
              },
              "name": "card.i.1",
              "xml": "",
            },
            Object {
              "children": Array [],
              "lua": "",
              "meta": Object {
                "GUID": "B12345",
                "Name": "Card",
                "Nickname": "Joker",
              },
              "name": "joker.B12345",
              "xml": "",
            },
          ],
          "lua": "",
          "meta": Object {
            "GUID": "A12345",
            "Name": "Bag",
            "Nickname": "",
          },
          "name": "bag.A12345",
          "xml": "",
        },
      ],
      "lua": "-- Lua",
      "meta": Object {
        "VersionNumber": "1.0",
      },
      "name": "global",
      "xml": "<!-- Xml -->",
    }
  `);
});

test('should save a simple tree to disk', () => {
  const map: MappedComponent = {
    name: 'global',
    meta: {
      VersionNumber: '1.0',
    },
    lua: '-- Lua',
    xml: '<!-- Xml -->',
    children: [
      {
        children: [],
        lua: '',
        meta: {
          GUID: 'A12345',
          Name: 'Block',
          Nickname: 'Red Block',
        },
        name: 'red_block.A12345',
        xml: '',
      },
      {
        children: [],
        lua: '',
        meta: {
          GUID: 'B12345',
          Name: 'Block',
          Nickname: 'Blue Block',
        },
        name: 'blue_block.B12345',
        xml: '',
      },
    ],
  };

  mock({
    src: {},
  });

  mapper.writeMapSync('src', map);
  const global = fs.readJsonSync(path.join('src', 'global.json'));
  const red = fs.readJsonSync(
    path.join('src', 'global', 'red_block.A12345.json'),
  );
  const blue = fs.readJsonSync(
    path.join('src', 'global', 'blue_block.B12345.json'),
  );
  mock.restore();

  expect(global).toMatchInlineSnapshot(`
    Object {
      "$children": Array [
        "red_block.A12345",
        "blue_block.B12345",
      ],
      "VersionNumber": "1.0",
    }
  `);

  expect(red).toMatchInlineSnapshot(`
    Object {
      "$children": Array [],
      "GUID": "A12345",
      "Name": "Block",
      "Nickname": "Red Block",
    }
  `);

  expect(blue).toMatchInlineSnapshot(`
    Object {
      "$children": Array [],
      "GUID": "B12345",
      "Name": "Block",
      "Nickname": "Blue Block",
    }
  `);
});
