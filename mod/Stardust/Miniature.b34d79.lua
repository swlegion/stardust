_GUIDS = {
  SPAWN_CONTROLLER = '525d68',
}

_DATA = nil
_CONNECTED_MINIS = {}
_IS_TARGETABLE = true
_IS_UNIT_LEADER = false
_HAS_ATTACHED_SILOUHETTE = false

function onLoad()
  -- Load the data provided to the model, if any. Otherwise bail out.
  _DATA = self.getTable('data')
  if _DATA == nil then
    return
  end

  -- Are we a unit leader?
  _IS_UNIT_LEADER = self.getVar('is_unit_leader')
  if _IS_UNIT_LEADER then
    initializeAsLeader()
  else
    initializeAsFollower()
  end

  -- Override defaults.
  self.setLock(false)
  self.setScale({1, 1, 1})
end

-- Initialize as a Unit Leader.
function initializeAsLeader()
  self.setName(_DATA.name .. ' (Unit Leader)')
end

-- Initialize as a "Follower" (not a Unit Leader).
function initializeAsFollower()
  self.setName(_DATA.name)
end

function callIsPartOfUnit(args)
  _isPartOfUnit(args[1])
end

function _isPartOfUnit(guid)
  if self.guid == guid then
    return true
  end
  for _, mini in ipairs(_CONNECTED_MINIS) do
    if mini.guid == guid then
      return true
    end
  end
  return false
end

-- Toggle silouhettes showing up.
function toggleSilouhettes()
  if _HAS_ATTACHED_SILOUHETTE then
    _hideSilouhette()
  else
    _showSilouhette()
  end
  if _IS_UNIT_LEADER and #_CONNECTED_MINIS then
    for _, mini in ipairs(_CONNECTED_MINIS) do
      mini.call('toggleSilouhettes')
    end
  end
end

function _hideSilouhette()
  local silouhette = self.removeAttachment()[1]
  silouhette.destruct()
  _HAS_ATTACHED_SILOUHETTE = false
end

function _showSilouhette()
  local controller = getObjectFromGUID(_GUIDS.SPAWN_CONTROLLER)
  local silouhette = controller.call('callSpawnSilouhette', {
    self.getPosition(),
    self.getRotation(),
  })
  self.addAttachment(silouhette)
  _HAS_ATTACHED_SILOUHETTE = true
end

-- Associate this model with another models.
--
-- If you are a unit leader, this method associates itself with miniatures
-- that are considered "part" of your unit (including things like counterparts).
--
-- If you are a non-leader, this method links to your unit leader.
function connectTo(otherMini)
  if otherMini.guid == self.guid then
    return
  end
  table.insert(_CONNECTED_MINIS, otherMini)
end

function callConnectTo(args)
  connectTo(args[1])
end