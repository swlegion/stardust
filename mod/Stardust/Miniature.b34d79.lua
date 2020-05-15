--- Represnts a miniature of a unit.
--
-- @module Miniature

_GUIDS = {
  SPAWN_CONTROLLER = '525d68',
}

_PERSIST = {
  DATA = nil,
  CONNECTED_MINIS = {},
  IS_UNIT_LEADER = false,
  HAS_ATTACHED_SILOUHETTE = false,
  HAS_ATTACHED_MOVEMENT_TOOL = false,
}

-- Used by the targeting sub-system.
IS_TARGETABLE = true

function onLoad(state)
  -- Keep the previously configured state.
  if state != '' then
    _PERSIST = JSON.decode(state)
    IS_UNIT_LEADER = _PERSIST.IS_UNIT_LEADER
    return
  end

  -- Load the data provided to the model, if any. Otherwise bail out.
  local spawnWithData = self.getTable('spawnWithData')
  if spawnWithData == nil then
    return
  end

  _PERSIST = {
    DATA = spawnWithData.data,
    CONNECTED_MINIS = {},
    IS_UNIT_LEADER = spawnWithData.isUnitLeader,
    HAS_ATTACHED_SILOUHETTE = false,
    HAS_ATTACHED_MOVEMENT_TOOL = false,
  }

  -- Are we a unit leader?
  if _PERSIST.IS_UNIT_LEADER then
    initializeAsLeader()
  else
    initializeAsFollower()
  end

  -- Override defaults.
  self.setLock(false)
  self.setScale({1, 1, 1})
end

function onSave()
  if _PERSIST.DATA != nil then
    return JSON.encode(_PERSIST)
  end
end

-- Initialize as a Unit Leader.
function initializeAsLeader()
  self.setName(_PERSIST.DATA.name .. ' (Unit Leader)')
  IS_UNIT_LEADER = true
end

-- Initialize as a "Follower" (not a Unit Leader).
function initializeAsFollower()
  self.setName(_PERSIST.DATA.name)
end

function callIsPartOfUnit(args)
  _isPartOfUnit(args[1])
end

function _isPartOfUnit(guid)
  if self.guid == guid then
    return true
  end
  for _, miniGuid in ipairs(_PERSIST.CONNECTED_MINIS) do
    if miniGuid == guid then
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
  table.insert(_PERSIST.CONNECTED_MINIS, otherMini.guid)
end

function callConnectTo(args)
  connectTo(args[1])
end
