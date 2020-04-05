import { ModRepoMapper } from '../../lib/mod/mapper';

let mapper: ModRepoMapper;

beforeEach(() => (mapper = new ModRepoMapper()));

test('should embed a trivial tree', () => {
  const actual = mapper.buildSave({
    children: [],
    lua: '-- Lua',
    meta: {
      VersionNumber: '1.0',
    },
    name: 'global',
    xml: '<!-- Xml -->',
  });
  expect(actual).toMatchInlineSnapshot(`
    Object {
      "LuaScript": "-- Lua",
      "ObjectStates": Array [],
      "VersionNumber": "1.0",
      "XmlUI": "<!-- Xml -->",
    }
  `);
});

test('should embed a nested tree', () => {
  const actual = mapper.buildSave({
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
    lua: '-- Lua',
    meta: {
      VersionNumber: '1.0',
    },
    name: 'global',
    xml: '<!-- Xml -->',
  });
  expect(actual).toMatchInlineSnapshot(`
    Object {
      "LuaScript": "-- Lua",
      "ObjectStates": Array [
        Object {
          "ContainedObjects": Array [],
          "GUID": "A12345",
          "LuaScript": "",
          "Name": "Block",
          "Nickname": "Red Block",
          "XmlUI": "",
        },
        Object {
          "ContainedObjects": Array [],
          "GUID": "B12345",
          "LuaScript": "",
          "Name": "Block",
          "Nickname": "Blue Block",
          "XmlUI": "",
        },
      ],
      "VersionNumber": "1.0",
      "XmlUI": "<!-- Xml -->",
    }
  `);
});

test('should embed a tree with a stack of cards', () => {
  const actual = mapper.buildSave({
    children: [
      {
        children: [
          {
            children: [],
            lua: '',
            meta: {
              GUID: '',
              Name: 'Card',
              Nickname: '',
            },
            name: 'card.i.0',
            xml: '',
          },
          {
            children: [],
            lua: '',
            meta: {
              GUID: '',
              Name: 'Card',
              Nickname: '',
            },
            name: 'card.i.1',
            xml: '',
          },
          {
            children: [],
            lua: '',
            meta: {
              GUID: 'B12345',
              Name: 'Card',
              Nickname: 'Joker',
            },
            name: 'joker.B12345',
            xml: '',
          },
        ],
        lua: '',
        meta: {
          GUID: 'A12345',
          Name: 'Bag',
          Nickname: '',
        },
        name: 'bag.A12345',
        xml: '',
      },
    ],
    lua: '-- Lua',
    meta: {
      VersionNumber: '1.0',
    },
    name: 'global',
    xml: '<!-- Xml -->',
  });
  expect(actual).toMatchInlineSnapshot(`
    Object {
      "LuaScript": "-- Lua",
      "ObjectStates": Array [
        Object {
          "ContainedObjects": Array [
            Object {
              "ContainedObjects": Array [],
              "GUID": "",
              "LuaScript": "",
              "Name": "Card",
              "Nickname": "",
              "XmlUI": "",
            },
            Object {
              "ContainedObjects": Array [],
              "GUID": "",
              "LuaScript": "",
              "Name": "Card",
              "Nickname": "",
              "XmlUI": "",
            },
            Object {
              "ContainedObjects": Array [],
              "GUID": "B12345",
              "LuaScript": "",
              "Name": "Card",
              "Nickname": "Joker",
              "XmlUI": "",
            },
          ],
          "GUID": "A12345",
          "LuaScript": "",
          "Name": "Bag",
          "Nickname": "",
          "XmlUI": "",
        },
      ],
      "VersionNumber": "1.0",
      "XmlUI": "<!-- Xml -->",
    }
  `);
});
