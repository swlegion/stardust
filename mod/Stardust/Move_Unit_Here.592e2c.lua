_PERSIST = {
  MOVE_GUID = nil,
}

function onLoad(state)
  if state != '' then
    _PERSIST = JSON.decode(state)
  else
    local moveGuid = self.getVar('moveGuid')
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