--- Functions for computing formations.
--
-- @module Formation_Controller

--- Computes a formation for a unit.
--
-- @param args The `name`, `bounds`, `count`, and `position` to compute.
--
-- @usage
-- computeFormation({
--   -- Optional. Defaults to `2-line`.
--   name = '2-line',
--   bounds = {1, 1, 1},
--   count = 4,
--   position = {0, 0, 0},
-- })
--
-- @return A list of positions to use per mini-index.
function computeFormation(args)
  local name = args.name
  local func = _create2LineFormation
  if name == '2-line' then
    func = _create2LineFormation
  end
  if name == 'derpy' then
    func = _createDerpyBattleLineFormation
  end
  return func(args.bounds, args.count, args.position)
end

--- Computes a list of positions to achieve a basic formation.
--
-- @local
--
-- @param bounds {x, y, z} size of the unit leader model.
-- @param count Number of miniatures total in the unit.
-- @param position {x, y, z} position of the unit leader model.
--
-- @usage
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
-- @return A list of positions/rotations to use per mini index.
--
-- @see Formation_Controller:computeFormation
function _createDerpyBattleLineFormation(
  bounds,
  count,
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

--- Computes a list of positions to achieve a 2-by-2 formation.
--
-- @local
--
-- @param bounds {x, y, z} size of the unit leader model.
-- @param count Number of miniatures total in the unit.
-- @param position {x, y, z} position of the unit leader model.
--
-- @return A list of positions/rotations to use per mini index.
--
-- @see Formation_Controller:computeFormation
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
