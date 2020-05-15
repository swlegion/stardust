--- Represnts a miniature of a unit.
--
-- Expects the table "spawnWithData" to be set to initialize the miniature.
-- @usage
-- someMini.setTable('spawnWithData', {
--   -- Data table.
--   data: { ... },
--
--   -- Whether to be considered a unit leader.
--   isUnitLeader: true,
-- })
--
-- @module Miniature
--
-- @see Data_Controller

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

--- Used by the targeting sub-system to determine what models are targetable.
--
-- Defaults to true.
IS_TARGETABLE = true

--- Used by various sub-systems to determine what models represent unit leaders.
--
-- Defaults to false.
IS_UNIT_LEADER = false

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

--- Returns whether the `guid` of the provided table is part of the unit.
--
-- @param args A table with a 'guid' property.
--
-- @usage
-- unitLeaderMini.call('isPartOfUnit', {
--   guid: 'abc123',
-- })
--
-- @return True if the mini is part of the unit.
function isPartOfUnit(args)
  return _isPartOfUnit(args.guid)
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

--- Toggle silouhettes showing up for the miniature.
--
-- If this unit is a unit leader, then this automatically calls the
-- `toggleSilouhettes` method for all miniatures attached to the unit.
--
-- @usage
-- unitLeaderMini.call('toggleSilouhettes')
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

--- Associate this model with another minis.
--
-- @param minis A list of other model objects.
--
-- If you are a unit leader, this method associates itself with miniatures
-- that are considered "part" of your unit (including things like counterparts).
--
-- If you are a non-leader, this method links to your unit leader.
--
-- @usage
-- unitLeaderMini.call('connectTo', {mini1, mini2, mini3})
function connectTo(minis)
  for _, mini in ipairs(minis) do
    _connectTo(mini)
  end
end

function _connectTo(otherMini)
  if otherMini.guid == self.guid then
    return
  end
  table.insert(_PERSIST.CONNECTED_MINIS, otherMini.guid)
end
