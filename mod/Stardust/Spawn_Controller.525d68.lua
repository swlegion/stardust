--- Funtions for spawning miniatures.
--
-- @module Spawn_Controller

_GUIDS = {
  MINIATURE = 'b34d79',
  FORMATIONS = '53afc7',
  SILOUHETTE = '767062',
}

--- Creates a unit using the provided table.
--
-- @param args A table referring to the unit to spawn.
--
-- @usage
-- spawnUnit({
--   -- Unit data retrieved from the data controller.
--   data = { },
--
--   -- Vector.
--   position = {0, 0, 0},
--
--   -- Vector. Optional, defaults to {0, 0, 0}.
--   rotation = {0, 0, 0},
--
--   -- Formation. Optional, defaults to '2-line'.
--   formation = '2-line',
-- })
--
-- @return Handle to the spawned unit leader
function spawnUnit(args)
  return _spawnUnit(
    args.data,
    args.position,
    args.rotation or {0, 0, 0},
    args.formation
  )
end

function _spawnUnit(
  unit,
  position,
  rotation,
  formation
)
  -- Spawn unit leader immediately.
  return _spawnUnitModel(
    true,
    unit,
    unit.models[1].mesh,
    unit.models[1].texture,
    position,
    rotation,
    function (miniLeader)
      Wait.frames(function()
        local count = #unit.models
        if count == 1 then
          return
        end
        local formations = getObjectFromGUID(_GUIDS.FORMATIONS)
        local miniSize = miniLeader.getBounds().size
        local formation = formations.call(
          'computeFormation',
          {
            name = formation,
            bounds = miniLeader.getBounds().size,
            position = position,
            count = count,
          }
        )
        for i = 2, count, 1 do
          local texture = unit.models[i].texture or unit.models[1].texture
          local spawned = _spawnUnitModel(
            false,
            unit,
            unit.models[i].mesh,
            texture,
            formation[i],
            rotation,
            function (spawnedMini)
              Wait.frames(function()
                miniLeader.call('connectTo', {spawnedMini})
                spawnedMini.call('connectTo', {miniLeader})
              end, 1)
            end
          )
        end
      end, 1)
    end
  )
end

function _spawnUnitModel(
  isLeader,
  data,
  mesh,
  texture,
  position,
  rotation,
  callback
)
  local target = getObjectFromGUID(_GUIDS.MINIATURE)
  local clone = target.clone({
    position = position,
    rotation = rotation,
    callback_function = callback,
  })
  clone.setCustomObject({
    mesh = mesh,
    diffuse = texture,
  })
  clone.setTable('spawnWithData', {
    data = data,
    isUnitLeader = isLeader,
  })
end

--- Spawns a silouhette at the provided position and rotation.
--
-- @param args The `position` and `rotation` to use.
--
-- @usage
-- spawnSilouhette({
--   position = {0, 0, 0},
--   rotation = {0, 0, 0},
-- })
--
-- @return Handle to the spawned silouhette.
function spawnSilouhette(args)
  return _spawnSilouhette(args.position, args.rotation)
end

-- @local
function _spawnSilouhette(position, rotation)
  local clone = getObjectFromGUID(_GUIDS.SILOUHETTE).clone({
    position = position,
    rotation = rotation,
    scale = {1, 1, 1},
  })
  return clone
end