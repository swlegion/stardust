_GUIDS = {
  PLACE_MINI_HERE = '592e2c',
  TOOL = 'd7256f',
}

_NULL_COLLIDER = 'http://cloud-3.steamusercontent.com/ugc/1008188722681990449/1EC41678BBC8A1138273F916DE4DDDEFC0289849/'

_TOOLS = {
  -- Speed 1
  {
    mesh = 'http://cloud-3.steamusercontent.com/ugc/785234780854759842/01D41C421A255FA3851BD89F18C85B5B294545EB/',
    diffuse = 'http://cloud-3.steamusercontent.com/ugc/785234780854759947/54081B46AD51B4601980DE9C7AC85FA76DDB09EA/',
    tint = {1.0, 1.0, 1.0},
  },
  -- Speed 2
  {
    mesh = 'http://cloud-3.steamusercontent.com/ugc/785234780854723671/BBF8FA3F838F18A0A774CB6F275A69922A829BDE/',
    diffuse = 'http://cloud-3.steamusercontent.com/ugc/785234780854724909/C072D675F67ED9DE36A6ECBC57399DB0497034C5/',
    tint = {0.5, 0.5, 0.5}
  },

  -- Speed 3
  {
    mesh = 'http://cloud-3.steamusercontent.com/ugc/785234780854760704/CE714393A691700C653EAD87BF876BA9194CDE9C/',
    diffuse = 'http://cloud-3.steamusercontent.com/ugc/785234780854771943/3C734C233CD0ECF47797501CBFBE21E0AB8A84F0/',
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
  ghost.setVar('moveGuid', mini.guid)
  ghost.setScale({1, 1, 1})
  ghost.setLock(false)
  return ghost
end

function _spawnMovementTool(mini, speed)
  _copyMiniAsGhost(mini)
end
