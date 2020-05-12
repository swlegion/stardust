function callComputeFormation(args)
  local name = args[1]
  local func = _create2LineFormation
  if name == '2-line' then
    func = _create2LineFormation
  end
  if name == 'derpy' then
    func = _createDerpyBattleLineFormation
  end
  return func(args[2], args[3], args[4])
end

-- Computes a list of positions to achieve a formation.
--
-- For example for 2 miniatures:
--     [U]
--   [L]
--
-- For 3:
--       [U]
--     [U]
--   [L]
--
-- For 4:
--         [U]
--       [U]
--     [U]
--   [L]
--
-- Returns a list of positions/rotations to use per mini index. For example:
--  {
--    -- 1: Identity location (e.g. where the unit leader is)
--    { x, y, z },
--
--    -- 2: Where to place mini 2 of N
--    { x, y, z }
--
--    -- ...
--  }
--
-- TODO: Make this much better and/or customizable.
function _createDerpyBattleLineFormation(
  -- {x, y, z} size of the unit leader model.
  bounds,

  -- Number of miniatures total in the unit.
  count,

  -- Position {x, y, z} of the unit leader mini.
  position
)
  local results = {}
  for i = 1, count, 1 do
    table.insert(results, {
      position[1] + bounds[1] * (i - 1),
      position[2] + 0,
      position[3] + bounds[3] * (i - 1)
    })
  end
  return results
end

-- See _createDerpyBattleLineFormation.
function _create2LineFormation(
  bounds,
  count,
  position
)
  local results = {}
  for i = 1, count, 1 do
    table.insert(results, {
      position[1] + bounds[1] * (i - 1 - math.floor((i-1)/2) * 2),
      position[2],
      position[3] + bounds[3] * math.floor(i/2 - 1/2)
    })
  end
  return results
end