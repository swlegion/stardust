_GUIDS = {
  PLAY_AREA = '9be545'
}

function onLoad()
  drawTemporaryUI()
end

function drawTemporaryUI()
  self.createButton({
    click_function = 'toggleSIL',
    function_owner = self,
    label = 'Toggle SIL',
    position = {0, 0.25, -1.0},
    rotation = {0, 180, 0},
    width = 600,
    height = 250,
    font_size = 100,
    color = 'Grey',
    font_color = 'White',
    tooltip = 'Toggle Silouhettes',
  })

  self.createButton({
    click_function = 'findLOS',
    function_owner = self,
    label = 'Find LOS',
    position = {0, 0.25, -1.5},
    rotation = {0, 180, 0},
    width = 600,
    height = 250,
    font_size = 100,
    color = 'Grey',
    font_color = 'White',
    tooltip = 'Determine LOS from selected Unit Leader',
  })
end

function toggleSIL()
  local table = getObjectFromGUID(_GUIDS.PLAY_AREA)
  if not table then
    return
  end
  local minis = table.call('callGetAllUnitLeaders')
  for _, mini in ipairs(minis) do
    mini.call('toggleSilouhettes')
  end
end

function findLOS(_, color)
  local selected = Player[color].getSelectedObjects()
  for _, object in ipairs(selected) do
    if object.getVar('_IS_UNIT_LEADER') then
      Player[color].lookAt({
        position = object.getPosition(),
      })
      _showLOSFrom(object)
    end
  end
end

function _showLOSFrom(leaderMini)
  local table = getObjectFromGUID(_GUIDS.PLAY_AREA)
  local minis = table.call('callGetAllTargets')
  for _, mini in ipairs(minis) do
    if not leaderMini.call('callIsPartOfUnit', {mini.guid}) then
      _showLOSTo(leaderMini, mini)
    end
  end
end

function _showLOSTo(fromMini, toMini)
  local from = fromMini.getPosition()
  local to = toMini.getPosition()
  Wait.time(function()
    Physics.cast({
      origin = from,
      direction = {
        x = to.x - from.x,
        y = to.y - from.y,
        z = to.z - from.z,
      },
      debug = true,
    })
  end, 1.5)
end
