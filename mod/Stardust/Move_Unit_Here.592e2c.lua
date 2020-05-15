--- A model that projects a ghost miniature to move another miniature to.
--
-- Projects UI that, when interacted with, moves the provided model (by GUID).
--
-- Expects a GUID to be provided via the field 'setupUnitProxy`:
--
-- @see Move_Unit_Here:setupUnitProxy
--
-- @module Move_Unit_Here

_PERSIST = {
  MOVE_GUID = nil,
}

--- A GUID that is expected to be setup in order to display relevant UI.
--
-- @usage
--   token.setTable('setupUnitProxy', 'abc123')
setUpUnitProxy = nil

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