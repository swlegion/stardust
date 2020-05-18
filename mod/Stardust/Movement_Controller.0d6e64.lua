--- Logic for moving units.
--
-- @module Movement_Controller

-- TODO: Fix LDoc.
-- Reference data for movement speed and templates.
--
-- @usage
-- local speedToUse = 2
-- _DATA[speedToUse].tool            -- {mesh = '...obj', texture = '...jpg'}
--
-- local baseSize = 'Small'
-- _DATA[speedToUse].rings[baseSize] -- '...unity3d'
--
-- @local
_DATA = {
  -- Speed 1.
  {
    tool = {
      mesh = 'http://localhost:8080/tools/movement/rulers/speed.1.obj',
      texture = 'http://localhost:8080/tools/movement/rulers/speed.1.jpg',
    },

    rings = {
      Small = 'http://localhost:8080/tools/movement/ranges/small.1.unity3d',
    }
  },

  -- Speed 2.
  {
    tool = {
      mesh = 'http://localhost:8080/tools/movement/rulers/speed.2.obj',
      texture = 'http://localhost:8080/tools/movement/rulers/speed.2.jpg',
    },

    rings = {
      Small = 'http://localhost:8080/tools/movement/ranges/small.2.unity3d',
    }
  },

  -- Speed 3.
  {
    tool = {
      mesh = 'http://localhost:8080/tools/movement/rulers/speed.3.obj',
      texture = 'http://localhost:8080/tools/movement/rulers/speed.3.jpg',
    },

    rings = {
      Small = 'http://localhost:8080/tools/movement/ranges/small.3.unity3d',
    }
  },
}

--- Spawns a move finder and ghost at the provided object.
--
-- @param args The `origin` object to use.
--
-- @usage
-- local objects = spawnRangeFinder({
--   origin = someObject,
-- })
-- -- objects.finder
-- -- objects.ghost
--
-- @return table Handle to the spawned range finder and ghost mini.
function spawnMoveFinder(args)
  local initialSpeed = args.initialSpeed or 2
  local origin = args.origin
  local position = origin.getPosition()
  local rotation = origin.getRotation()
  local asset = _DATA[2].rings.Small
  local object = spawnObject({
    type              = 'Custom_Assetbundle',
    position          = {
      x = position.x,
      -- TODO: We can't place this *EXACTLY* at the origin, so we need to
      -- spawn it a *tiny bit* off. There is a better way to do this, of course
      -- but requires more math.
      y = position.y + 0.0001,
      z = position.z,
    },
    rotation = rotation,
  })
  object.setCustomObject({
    assetbundle = asset,
  })
  object.setLock(true)
  object.interactable = false
  object.setScale({0, 0, 0})
  return {
    finder = object,
  }
end

function setProjectedMovementSpeed(args)
  local finder = args.finder
  local speed = args.speed
  local asset = _DATA[speed].rings.Small
  finder.setCustomObject({
    assetbundle = asset,
  })
  finder.reload()
end
