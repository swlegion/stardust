--- Logic for moving units.
--
-- @module Movement_Controller

_GUIDS = {
  PLACE_MINI_HERE = '592e2c',
  TOOL = 'd7256f',
}

_NULL_COLLIDER = 'https://assets.swlegion.dev/collider/null.obj'

_TOOLS = {
  -- Speed 1
  {
    mesh = 'http://localhost:8080/tools/speed.1.obj',
    diffuse = 'http://localhost:8080/tools/speed.1.jpg',
    tint = {1.0, 1.0, 1.0},
  },
  -- Speed 2
  {
    mesh = 'http://localhost:8080/tools/speed.2.obj',
    diffuse = 'http://localhost:8080/tools/speed.2.jpg',
    tint = {0.5, 0.5, 0.5}
  },

  -- Speed 3
  {
    mesh = 'http://localhost:8080/tools/speed.3.obj',
    diffuse = 'http://localhost:8080/tools/speed.3.jpg',
    tint = {1.0, 0.2, 0.2}
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