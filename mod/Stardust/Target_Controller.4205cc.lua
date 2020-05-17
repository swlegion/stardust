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

_USE_SIMPLE_2D_DISTANCE = false

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
  if _USE_SIMPLE_2D_DISTANCE then
    return _distance2D(
      args.from.position.x,
      args.from.position.z,
      args.to.position.x,
      args.to.position.z
    )
  end
  return _distanceFlatCenterToCenter(
    _radiusOfBase(args.from.bounds),
    _radiusOfBase(args.to.bounds),
    args.from.position.x,
    args.from.position.z,
    args.from.rotation.x,
    args.from.rotation.z,
    args.to.position.x,
    args.to.position.z,
    args.to.rotation.x,
    args.to.rotation.z
  )
end

function _radiusOfBase(bounds)
  -- TODO: Accomodate for non-circle-bases (e.g. the Occupier).
  return bounds.x / 2
end

function _distance2D(x1, y1, x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt(dx * dx + dy * dy)
end

-- TODO: Find or add a Lua-based Matrix library.
function _distanceFlatCenterToCenter(
  radius1,
  radius2,
  x1,
  z1,
  rx1,
  rz1,
  x2,
  z2,
  rx2,
  rz2
)
  -- X and Z Values Only.
  local posA = {x1, z1}
  local posB = {x2, z2}
  local rotA = {rx1, rz1}
  local rotB = {rx2, rz2}

  -- Convert to radians before doing trig.
  rotA = _matrix2x1ToRadians(rotA)
  rotA = {
    {math.cos(rotA[2]), 0},
    {0, math.cos(rotA[1])},
  }
  rotB = _matrix2x1ToRadians(rotB)
  rotB = {
    {math.cos(rotB[2]), 0},
    {0, math.cos(rotB[1])},
  }

  -- Vector from point A to point B.
  local distanceAB = _matrix2x1Subtract(posB, posA)
  local distanceBA = _matrix2x1Multiply(distanceAB, -1)
  local distanceAB2 = _matrix2x1MultiplyByMatrix(distanceAB, distanceAB)
  local distanceFlat = math.sqrt(
    distanceAB2[1] +
    distanceAB2[2]
  )

  -- Divide by length of vector to get just the direction of the vector.
  local abUnitVector = _matrix2x1Divide(distanceAB, distanceFlat)
  local baUnitVector = _matrix2x1Multiply(abUnitVector, -1)

  -- Multiply by radius to find the point on the base that is closest to unit B
  -- NOTE: This will always be the closest point for rotations < 90DEG in X/Z.
  local baseVectorA = _matrix2x1Multiply(abUnitVector, radius1)
  local baseVectorB = _matrix2x1Multiply(baUnitVector, radius2)

  -- Rotate the vectors.
  local rotatedVectorA = _matrix2x2x1DotBy2x1(rotA, baseVectorA)
  local rotatedVectorB = _matrix2x2x1DotBy2x1(rotB, baseVectorB)

  -- We can then multiply with the unit vector from before and get the portion
  -- of our new vector that is still in the same direction as our closest path
  -- to unit B.
  local projectedA = _matrix2x1Dot(rotatedVectorA, abUnitVector)
  local projectedB = _matrix2x1Dot(rotatedVectorB, baUnitVector)

  -- Distance "flat" is their center-to-center distance.
  return distanceFlat - projectedA - projectedB
end

--- Converts a `2x1` matrix `m` to radians.
--
-- @param m Array with two elements, both numbers.
--
-- @local
function _matrix2x1ToRadians(m)
  return _matrix2x1Multiply(m, math.pi / 180)
end

--- Returns a `2x1` matrix `a` subtracted by `b`.
--
-- @param a Array with two elements, both numbers.
-- @param b Array with two elements, both numbers.
--
-- @local
-- @usage
-- local result = _matrix2x1Subtract({4, 6}, {1, 2})
-- print(result) -- {3, 4}
function _matrix2x1Subtract(a, b)
  return {
    a[1] - b[1],
    a[2] - b[2],
  }
end

--- Returns a `2x1` matrix `m` multiplied by `p`.
--
-- @param m Array with two elements, both numbers.
-- @param p Product.
--
-- @local
-- @usage
-- local result = _matrix2x1Multiply({2, 3}, 2)
-- print(result) -- {4, 6}
function _matrix2x1Multiply(m, p)
  return {
    m[1] * p,
    m[2] * p,
  }
end

--- Returns a `2x1` matrix `a` multiplied by another matrix `b`.
--
-- @param a Array with two elements, both numbers.
-- @param b Array with two elements, both numbers.
--
-- @local
-- @usage
-- local result = _matrix2x1MultiplyByMatrix({2, 3}, {4, 2})
-- print(result) -- {8, 6}
function _matrix2x1MultiplyByMatrix(a, b)
  return {
    a[1] * b[1],
    a[2] * b[2],
  }
end

--- Returns a `2x1` matrix `m` divided by `d`.
--
-- @param m Array with two elements, both numbers.
-- @param d Dividend.
--
-- @local
-- @usage
-- local result = _matrix2x1Divide({2, 4}, 2)
-- print(result) -- {1, 2}
function _matrix2x1Divide(m, d)
  return {
    m[1] / d,
    m[2] / d,
  }
end

--- Returns the dot product of a 2x2x1 matricies `a` by a 2x1 `b`.
--
-- @see _matrix2x1Dot
--
-- @param a Array with two elements, both arrays with two number elements.
-- @param b Array with two elements, both numbers.
--
-- @local
-- @usage
-- local result = _matrix2x1Dot({{1, 2}, {3, 2}}, {2, 4})
-- print(result) -- {9, 14} (1 * 2 + 2 * 4, 3 * 2 + 2 * 4)
function _matrix2x2x1DotBy2x1(a, b)
  return {
    _matrix2x1Dot(a[1], b),
    _matrix2x1Dot(a[2], b),
  }
end

--- Returns the dot product of 2x1 matricies `a` and `b`.
--
-- The dot product is multiplying matching members, then summing them up.
--
-- @param a Array with two elements, both numbers.
-- @param b Array with two elements, both numbers.
--
-- @local
-- @usage
-- local result = _matrix2x1Dot({1, 2}, {2, 4})
-- print(result) -- 9 (1 * 2 + 2 * 4)
function _matrix2x1Dot(a, b)
  return a[1] * b[1] + a[2] * b[2]
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
