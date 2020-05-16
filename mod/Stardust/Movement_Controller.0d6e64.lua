--- Logic for moving units.
--
-- @module Movement_Controller

--- Reference data for movement speed and templates.
--
-- @usage
-- local speedToUse = 2
-- _DATA[speedToUse].tool            -- {mesh = '...obj', texture = '...jpg'}
--
-- local baseSize = 'Small'
-- _DATA[speedToUse].rings[baseSize] -- '...unity3d'
--
-- @local
_DATA = {
  -- Speed 1.
  {
    tool = {
      mesh = 'https://assets.swlegion.dev/tools/movement/rulers/speed.1.obj',
      texture = 'http://localhost:8080/tools/movement/rulers/speed.1.jpg',
    },

    rings = {
      Small = 'http://localhost:8080/tools/movement/ranges/small.1.unity3d',
    }
  },

  -- Speed 2.
  {
    tool = {
      mesh = 'http://localhost:8080/tools/movement/rulers/speed.2.obj',
      texture = 'http://localhost:8080/tools/movement/rulers/speed.2.jpg',
    },

    rings = {
      Small = 'http://localhost:8080/tools/movement/ranges/small.2.unity3d',
    }
  },

  -- Speed 3.
  {
    tool = {
      mesh = 'http://localhost:8080/tools/movement/rulers/speed.3.obj',
      texture = 'http://localhost:8080/tools/movement/rulers/speed.3.jpg',
    },

    rings = {
      Small = 'http://localhost:8080/tools/movement/ranges/small.3.unity3d',
    }
  },
}

function onLoad()
  drawTemporaryUI()
end

function drawTemporaryUI()
  self.createButton({
    click_function = 'spawnMOV',
    function_owner = self,
    label = 'Move',
    position = {0, 0.25, -1.0},
    rotation = {0, 180, 0},
    width = 600,
    height = 250,
    font_size = 100,
    color = 'Grey',
    font_color = 'White',
    tooltip = 'Spawn Movement Options',
  })
end

--- Spawns movement options for the selected unit leaders.
--
-- @local
--
-- @param _ Unused.
-- @param color Player color that clicks the button.
function spawnMOV(_, color)
  local selected = Player[color].getSelectedObjects()
  for _, object in ipairs(selected) do
    if object.getVar('IS_UNIT_LEADER') then
      _spawnMovementTool(object, 2)
    end
  end
end

function _copyMiniAsGhost(mini, position, rotation)
  if not position then
    position = mini.getPosition()
  end
  if not rotation then
    rotation = mini.getRotation()
  end
  mini.setScale({0, 0, 0})
  local ghost = getObjectFromGUID(_GUIDS.PLACE_MINI_HERE).clone({
    position = position,
    rotation = rotation,
    callback_function = function()
      Wait.time(function()
        mini.setScale({1, 1, 1})
      end, 1)
    end
  })
  local custom = mini.getCustomObject()
  ghost.setCustomObject({
    diffuse = custom.diffuse,
    mesh = custom.mesh,
    collider = _NULL_COLLIDER,
  })
  ghost.setVar('setupUnitProxy', mini.guid)
  ghost.setScale({1, 1, 1})
  ghost.setLock(false)
  return ghost
end

function _spawnMovementTool(mini, speed)
  _copyMiniAsGhost(mini)
end
