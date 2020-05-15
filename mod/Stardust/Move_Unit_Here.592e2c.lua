--- A model that projects a ghost miniature to move another miniature to.
--
-- Expects a GUID to be provided via the field 'setupUnitProxy`:
--
-- @usage
--   token.setTable('setupUnitProxy', 'abc123')
--
-- Projects UI that, when interacted with, moves the provided model (by GUID).
--
-- @module Move_Unit_Here

_PERSIST = {
  MOVE_GUID = nil,
}

function onLoad(state)
  if state != '' then
    _PERSIST = JSON.decode(state)
  else
    local moveGuid = self.getVar('setupUnitProxy')
    if moveGuid == nil then
      self.UI.hide('Button')
      return
    end
    _PERSIST.MOVE_GUID = moveGuid
  end
end

function onSave()
  if _PERSIST.MOVE_GUID then
    return JSON.encode(_PERSIST)
  end
end

function onClick()
  local origin = getObjectFromGUID(_PERSIST.MOVE_GUID)
  self.destruct()
  origin.setPosition(self.getPosition())
  origin.setRotation(self.getRotation())
end
