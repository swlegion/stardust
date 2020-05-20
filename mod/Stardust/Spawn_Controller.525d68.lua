--- Funtions for spawning miniatures.
--
-- @module Spawn_Controller

--- References what collider to use for various base sizes.
--
-- @local
_BASE_SIZE_TO_COLLIDER = {
  Small = "https://assets.swlegion.dev/collider/small.obj",
  Medium = "https://assets.swlegion.dev/collider/medium.obj",
  Large = "https://assets.swlegion.dev/collider/large.obj",
  Huge = "https://assets.swlegion.dev/collider/huge.obj",
  Gigantic = "https://assets.swlegion.dev/collider/gigantic.obj",
}

--- Creates a unit using the provided table.
--
-- @param args A table referring to the unit to spawn.
--
-- @usage
-- spawnUnit({
--   -- Unit data retrieved from the data controller.
--   unit = { },
--
--   -- Upgrade data received from the data controller.
--   upgrades = { ... },
--
--   -- Color the unit belongs to.
--   color = 'Red',
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
    args.unit,
    args.upgrades or {},
    args.color,
    args.position,
    args.rotation or {0, 0, 0},
    args.formation
  )
end

function _spawnUnit(
  unit,
  upgrades,
  color,
  position,
  rotation,
  formation
)
  -- Spawn unit leader immediately.
  return _spawnUnitModel(
    {
      color = color,
      rank = unit.rank,
    },
    unit,
    unit.models[1].mesh,
    unit.models[1].texture,
    unit.base,
    position,
    rotation,
    function (miniLeader)
      Wait.frames(function()
        local count = #unit.models
        for _, u in ipairs(upgrades) do
          if u.model then
            count = count + 1
          end
        end
        if count == 1 then
          return
        end
        local formations = getObjectFromGUID(
          Global.getTable('GUIDS').controllers.Formation
        )
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
        for i = 2, #unit.models, 1 do
          local texture = unit.models[i].texture or unit.models[1].texture
          _spawnUnitModel(
            nil,
            unit,
            unit.models[i].mesh,
            texture,
            unit.base,
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
        i = #unit.models
        for _, u in ipairs(upgrades) do
          i = i + 1
          if u.model then
            _spawnUnitModel(
              nil,
              unit,
              u.model.mesh,
              u.model.texture,
              unit.base,
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
        end
      end, 1)
    end
  )
end

function _spawnUnitModel(
  leader,
  data,
  mesh,
  texture,
  collider,
  position,
  rotation,
  callback
)
  local target = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Miniature
  )
  local clone = target.clone({
    position = position,
    rotation = rotation,
    callback_function = callback,
  })
  clone.setCustomObject({
    mesh = mesh,
    diffuse = texture,
    collider = _BASE_SIZE_TO_COLLIDER[collider],
  })
  clone.setTable('spawnSetup', {
    name = data.name,
    leader = leader,
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
  local clone = getObjectFromGUID(
    Global.getTable('GUIDS').objects.Silouhette
  ).clone({
    position = position,
    rotation = rotation,
    scale = {1, 1, 1},
  })
  return clone
end
