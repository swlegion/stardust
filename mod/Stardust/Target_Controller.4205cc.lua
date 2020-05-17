--- Targeting/LOS sub-system
--
-- @module Target_Controller

--- Data for creating the correct range finder projection.
--
-- @usage
-- local baseSize = 'Small'
-- _RANGE_FINDERS[baseSize]  -- "...unity3d"
--
-- @local
_RANGE_FINDERS = {
  Small = 'https://assets.swlegion.dev/tools/ranges/small.unity3d',
}

-- TODO: Re-add.
-- Colors used in the range finder for a given range.
--
-- @local
_RANGE_FINDER_COLORS = {
  -- 1
  '#FF0000',

  -- 2
  '#0000FF',

  -- 3
  '#FF6D00',

  -- 4
  '#00FF00',

  -- 5
  '#FFFF00',

  -- 6+
  '#808080',
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

--- Toggles silouhettes for all units in the play area.
--
-- @local
function toggleSIL()
  local table = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Table
  )
  if not table then
    return
  end
  local minis = table.call('getAllUnitLeaders')
  for _, mini in ipairs(minis) do
    mini.call('toggleSilouhettes')
  end
end

--- Spawns a silouhette at the provided position and rotation.
--
-- @param args The `position` and `rotation` to use.
--
-- @usage
-- spawnRangeFinder({
--   position = {0, 0, 0},
--   rotation = {0, 0, 0},
-- })
--
-- @return Handle to the spawned range finder.
function spawnRangeFinder(args)
  local asset = _RANGE_FINDERS.Small
  local object = spawnObject({
    type              = 'Custom_Assetbundle',
    position          = {
      x = args.position.x,
      y = args.position.y + 3,
      z = args.position.z,
    },
    rotation          = args.rotation,
  })
  object.setCustomObject({
    assetbundle = asset,
  })
  object.setLock(true)
  object.interactable = false
  object.setScale({0, 0, 0})
  return object
end

--- Clears floating numbers from all miniatures on the table.
function clearFloatingNumbers()
  local table = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Table
  )
  local minis = table.call('getAllTargets')
  for _, mini in ipairs(minis) do
    mini.call('hideFloatingNumber')
  end
end

--- Returns all miniatures owned by the opposing team.
--
-- @param args A table with the field `team` making the request.
--
-- @return List of miniatures.
--
-- @usage
-- local allEnemies = target.call('findAllEnemyMinis', {
--   team: 'Blue',
-- })
-- for _, mini in allEnemies do
--   -- Do something.
-- end
function findAllEnemyMinis(args)
  local results = {}
  local team = args.team
  local area = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Table
  )
  local minis = area.call('getAllTargets')
  for _, mini in ipairs(minis) do
    local owner = mini.call('getOwner')
    if owner != team then
      table.insert(results, mini)
    end
  end
  return results
end

--- Returns all miniatures owned by the opposing team, grouped into units.
--
-- @param args A table with the field `team` making the request.
--
-- @return List of list of miniatures.
--
-- @usage
-- local allEnemies = target.call('findAllEnemyMinis', {
--   team: 'Blue',
-- })
-- for _, unitGroup in allEnemies do
--   local leader = unitGroup[1]
--   -- Other units are not the leader.
-- end
function groupAllEnemyMinis(args)
  local groups = {}
  local team = args.team
  local area = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Table
  )
  local minis = area.call('getAllTargets')
  -- TODO: Optimize this.
  for _, mini in ipairs(minis) do
    local owner = mini.call('getOwner')
    if owner != team and not mini.getVar('IS_UNIT_LEADER') then
      local leader = mini.call('getUnitLeader')
      if groups[leader] then
        table.insert(groups[leader], mini)
      else
        groups[leader] = {leader, mini}
      end
    end
  end
  local results = {}
  for _, group in ipairs(groups) do
    table.insert(results, group)
  end
  return results
end

--- Returns the range, in game terms (e.g. 2D horizontal only), in inches.
--
-- @param args A table with the field `from` and `to`, each with `position`, `rotation`, `bounds`.
--
-- @return Distance, in inches.
--
-- @usage
-- local distance = target.call('computeDistance', {
--   from = {
--     position = from.getPosition(),
--     rotation = from.getRotation(),
--     bounds   = from.getBounds().size,
--   },
--   to = {
--     position = to.getPosition(),
--     rotation = to.getRotation(),
--     bounds   = to.getBounds().size,
--   }
-- })
function computeDistance(args)
  -- TODO: Implement correctly as a purely horizontal range-check, and make
  -- sure to use the tip of the base for calculations - this is a basically
  -- an estimate.
  return _distance2D(
    args.from.position.x,
    args.from.position.z,
    args.to.position.x,
    args.to.position.z
  )
end

function _distance2D(x1, y1, x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt(dx * dx + dy * dy)
end

--- Shows all ranges of enemy minis of the provided mini.
--
-- @param args A table with the field `origin`.
--
-- @usage
-- target.call('showRangeOfEnemyMinis', {
--   origin = myMini,
-- })
function showRangeOfEnemyMinis(args)
  local origin = args.origin
  local target = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Target
  )
  local allEnemyMinis = target.call('findAllEnemyMinis', {
    team = origin.call('getOwner')
  })
  local position = origin.getPosition()
  local rotation = origin.getRotation()
  local bounds = origin.getBounds().size
  for _, enemy in ipairs(allEnemyMinis) do
    local distance = target.call('computeDistance', {
      from = {
        position = position,
        rotation = rotation,
        bounds = bounds,
      },

      to = {
        position = enemy.getPosition(),
        rotation = enemy.getRotation(),
        bounds = enemy.getBounds().size,
      }
    })

    -- Translate to in-game ranges.
    distance = math.min(6, math.ceil(distance / 6))
    enemy.call('showFloatingNumber', {
      number = distance,
      color = _RANGE_FINDER_COLORS[distance],
    })
  end
end

--- Does a LOS check for the selected unit leaders.
--
-- @param _ Unused
-- @param color Player color that clicks the button
--
-- For every selected object that is a unit leader, LOS is checked.
--
-- @local
function findLOS(_, color)
  local selected = Player[color].getSelectedObjects()
  for _, object in ipairs(selected) do
    if object.getVar('IS_UNIT_LEADER') then
      Player[color].lookAt({
        position = object.getPosition(),
      })
      _showLOSFrom(object)
    end
  end
end

function _showLOSFrom(leaderMini)
  local table = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Table
  )
  local minis = table.call('getAllTargets')
  for _, mini in ipairs(minis) do
    if not leaderMini.call('isPartOfUnit', {guid = mini.guid}) then
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
