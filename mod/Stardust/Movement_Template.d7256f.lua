_JOINT_GUID = nil

function onLoad(saveState)
  if saveState != "" then
    _JOINT_GUID = saveState
  else
    copyAndAttach()
  end
end

function onSave()
  return _JOINT_GUID
end

function onDestroy()
  getObjectFromGUID(_JOINT_GUID).destruct()
  _JOINT_GUID = nil
end

function copyAndAttach()
  local position = self.getPosition()
  local rotation = self.getRotation()
  local copy = self.clone({
    position = position,
    rotation = {
      x = rotation.x,
      y = rotation.y + 180,
      z = rotation.z,
    },
    callback_function = function(instance)
      -- Counter-intuitive, but we want the spawned object to "settle" into the
      -- position we gave it (which overlaps our existing piece), and then join
      -- it so the "ball"-part of the templates overlap.
      Wait.time(function()
        instance.jointTo(self, {
          ['type'] = 'Hinge',
          ['axis'] = {0, 0.1, 0},
        })
        -- Refer to the spawned clone.
        _JOINT_GUID = instance.guid
      end, 0.5)
    end
  })

  -- Avoid an infinite loop (e.g. our copy should not copy).
  copy.setLuaScript('')
end
