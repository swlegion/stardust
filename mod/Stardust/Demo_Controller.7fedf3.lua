--- Logic for loading the demo game.
--
-- @module Demo_Controller

_GUIDS = {
  DATA_DISK = '093685',
  SPAWN_CONTROLLER = '525d68',
  DEMO_BARRICADE = '96cf71',
  ORDER_TOKEN = '8049a1',
}

_DEMO = {
  BARRICADES = {
    -- Top Right Corner.
    {6, 0, 12},
    {9, 0, 12},

    -- Top Middle/Left
    {-6, 0, 6},

    -- Center
    {-3, 0, 0},
    {3, 0, 0},

    -- Bottom Middle/Right
    {6, 0, -6},

    -- Bottm Left Corner
    {-12, 0, -12},
    {-9, 0, -12},
  },

  UNITS = {
    {-3, 0, 14},
    {3, 0, 14},
    {-3, 0, -14},
    {3, 0, -14},
  },

  TOKENS = {
    {-3, 0, 12},
    {3, 0, 12},
    -- TODO: Move to Z=-12 once the formation is corrected.
    {-3, 0, -11},
    {3, 0, -11},
  },
}

--- Loads all of the units and terrain for the demo scenario.
function loadDemo()
  -- Spawn terrain.
  local barricade = getObjectFromGUID(_GUIDS.DEMO_BARRICADE)
  local halfWay = #_DEMO.BARRICADES / 2
  for i, position in ipairs(_DEMO.BARRICADES) do
    local rotation = {0, 270, 0}
    if i > halfWay then
      rotation = {0, 90, 0}
    end
    local object = barricade.clone({
      position = position,
      rotation = rotation,
    })
    object.setScale({1, 1, 1})
  end

  -- Spawn units.
  local data = getObjectFromGUID(_GUIDS.DATA_DISK)
  local spawner = getObjectFromGUID(_GUIDS.SPAWN_CONTROLLER)
  local stormTroopers = data.call('findUnit', {
    faction = 'GalacticEmpire',
    rank = 'Corps',
    name = 'Stormtroopers'
  })
  local rebelTroopers = data.call('findUnit', {
    faction = 'RebelAlliance',
    rank = 'Corps',
    name = 'Rebel Troopers'
  })
  local halfWay = #_DEMO.UNITS / 2
  for i, position in ipairs(_DEMO.UNITS) do
    local rotation = {0, 0, 0}
    local unitType = rebelTroopers
    local color = 'Red'
    if i > halfWay then
      unitType = stormTroopers
      color = 'Blue'
      rotation = {0, 180, 0}
    end
    spawner.call('spawnUnit', {
      data = unitType,
      color = color,
      position = position,
      rotation = rotation,
    })
  end

  -- Spawn order tokens.
  local orderToken = getObjectFromGUID(_GUIDS.ORDER_TOKEN)
  for i, position in ipairs(_DEMO.TOKENS) do
    local rotation = {0, 0, 0}
    local color = 'Red'
    if i > halfWay then
      color = 'Blue'
      rotation = {0, 180, 0}
    end
    local object = orderToken.clone({
      position = position,
      rotation = rotation
    })
    object.setLock(false)
    object.setScale({1, 1, 1})
    object.setLuaScript(orderToken.getLuaScript())
    object.setTable('setupOrderToken', {
      rank = 'Corps',
      color = color,
    })
  end
end