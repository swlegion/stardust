_GUIDS = {
  MINIATURE = 'b34d79',
  FORMATIONS = '53afc7',
  SILOUHETTE = '767062',
}

function callSpawnUnit(args)
  _spawnUnit(args[1], args[2], args[3] or {0, 0, 0})
end

function _spawnUnit(
  unit,
  position,
  rotation,
  formation
)
  -- Spawn unit leader immediately.
  _spawnUnitModel(
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
          'callComputeFormation',
          {
            formation,
            miniLeader.getBounds().size,
            count,
            position,
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
                miniLeader.call('callConnectTo', {spawnedMini})
                spawnedMini.call('callConnectTo', {miniLeader})
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
  clone.setVar('is_unit_leader', isLeader)
  clone.setTable('data', data)
end

function callSpawnSilouhette(args)
  return _spawnSilouhette(args[1], args[2], args[3])
end

function _spawnSilouhette(position, rotation)
  local clone = getObjectFromGUID(_GUIDS.SILOUHETTE).clone({
    position = position,
    rotation = rotation,
    scale = {1, 1, 1},
  })
  return clone
end