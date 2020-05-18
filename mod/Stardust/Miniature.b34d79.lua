--- Represnts a miniature of a unit.
--
-- Expects the table "spawnSetup" to be set to initialize the miniature.
--
-- @usage
-- someMini.setTable('spawnSetup', {
--   -- Data table.
--   name = '...',
--
--   -- Whether to be considered a unit leader. Omit if not a leader.
--   leader: {
--     color = 'Red',
--     rank  = 'Corps',
--   },
-- })
--
-- @module Miniature
--
-- @see Data_Controller

_PERSIST = {
  CONNECTED_MINIS = {},
  ACTIVE_MOVEMENT = nil,
  ACTIVE_SILOUHETTE = nil,
  ACTIVE_RANGE_FINDER = nil,
  SETUP = nil,
}

--- Used by the targeting sub-system to determine what models are targetable.
--
-- Defaults to true.
IS_TARGETABLE = true

--- Used by various sub-systems to determine what models represent unit leaders.
--
-- Defaults to false.
IS_UNIT_LEADER = false

--- Whether this unit is currently selected by a player (color).
--
-- This value should always be `nil` for a non-leader miniature.
--
-- @local
_SELECTED_BY_COLOR = nil

function onLoad(state)
  -- Keep the previously configured state.
  if state != '' then
    _PERSIST = JSON.decode(state)
    if _PERSIST.SETUP.leader then
      _initializeAsLeader()
    end
    return
  end

  -- Load the data provided to the model, if any. Otherwise bail out.
  local spawnSetup = self.getTable('spawnSetup')
  if spawnSetup == nil then
    _disableSelectable()
    return
  end

  _PERSIST = {
    CONNECTED_MINIS = {},
    ACTIVE_SILOUHETTE = nil,
    ACTIVE_MOVEMENT = nil,
    ACTIVE_RANGE_FINDER = nil,
    SETUP = {
      name = spawnSetup.name,
    }
  }

  -- Are we a unit leader?
  if spawnSetup.leader then
    _PERSIST.SETUP.leader = spawnSetup.leader
    _initializeAsLeader()
    self.setName(_PERSIST.SETUP.name .. ' (Unit Leader)')
  else
    _initializeAsFollower()
    self.setName(_PERSIST.SETUP.name)
  end

  -- Override defaults.
  self.setLock(false)
  self.setScale({1, 1, 1})
end

function onSave()
  if _PERSIST.SETUP != nil then
    return JSON.encode(_PERSIST)
  end
end

--- Initialize as a Unit Leader.
--
-- Assigns @see Miniature:IS_UNIT_LEADER and sets up UI.
--
-- @local
function _initializeAsLeader()
  -- Expose to other objects we are a unit leader.
  IS_UNIT_LEADER = true
end

--- Select button (i.e. the base) is clicked.
--
-- @param player Player that selected the miniature.
--
-- @see Miniature:_selectUnit
-- @local
function _onSelect(player)
  assert(IS_UNIT_LEADER == true)
  local color = player.color
  if color != 'Red' and color != 'Blue' then
    color = _PERSIST.SETUP.leader.color
  end
  _selectUnit(color)
end

--- Initialize as a "Follower" (not a Unit Leader).
--
-- @local
function _initializeAsFollower()
  _disableSelectable()
end

--- Disables the ability to select this model.
--
-- @local
function _disableSelectable()
  Wait.frames(function()
    self.UI.hide('baseButton')
  end, 1)
end

--- Toggles selection of the unit.
--
-- @param color Player color.
--
-- @local
function _selectUnit(color)
  assert(color != nil)

  -- Toggle on.
  if _SELECTED_BY_COLOR == nil then
    _SELECTED_BY_COLOR = color
    self.highlightOn(color)
    self.UI.show('unitActions')
    return;
  end

  -- Toggle off.
  if _SELECTED_BY_COLOR == color then
    _SELECTED_BY_COLOR = nil
    self.highlightOff()
    self.UI.hide('unitActions')
    return
  end
end

--- Destroys any attachments that the provided guid.
--
-- @param checkGuid GUID to search for.
--
-- @local
-- @usage
-- _destroyAttachment(rangeFinderGuid)
function _destroyAttachment(checkGuid)
  for i, object in ipairs(self.getAttachments()) do
    if object.guid == checkGuid then
      local attachment = self.removeAttachment(i - 1)
      attachment.destruct()
      return
    end
  end
end

--- Shows a floating number above the miniature's head.
--
-- @param args Table: `number` and `color` to show.
function showFloatingNumber(args)
  local number = args.number
  local color = args.color
  if not color then
    color = getOwner()
  end
  self.UI.setAttribute('floatingNumber', 'color', color)
  self.UI.setValue('floatingNumberText', tostring(number))
  self.UI.show('floatingNumber')
end

--- Hides any visible floating number above the miniature's head.
function hideFloatingNumber()
  self.UI.hide('floatingNumber')
end

--- Toggle threats-mode for the unit leader.
--
-- @usage
-- unitLeaderMini.call('toggleThreats')
function toggleThreats()
  assert(IS_UNIT_LEADER)
  if _PERSIST.ACTIVE_RANGE_FINDER then
    _hideRange()
  else
    _showRange()
  end
end

function _hideRange()
  local controller = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Target
  )
  _destroyAttachment(_PERSIST.ACTIVE_RANGE_FINDER)
  _PERSIST.ACTIVE_RANGE_FINDER = nil
  -- TODO: This could accidentally clear other numbers. We probably want to
  -- automatically turn off "threat-mode" (?) when another unit is interacted
  -- with, to some extent.
  controller.call('clearFloatingNumbers')
end

function _showRange()
  local controller = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Target
  )
  local object = controller.call('spawnRangeFinder', {
    -- TODO: Pass in base size.
    position = self.getPosition(),
    rotation = self.getRotation(),
  })
  -- Wait a frame for the range finder to generate a GUID.
  Wait.frames(function()
    self.addAttachment(object)
    assert(object.guid != nil)
    _PERSIST.ACTIVE_RANGE_FINDER = object.guid
  end, 1)
  controller.call('showRangeOfEnemyMinis', {
    origin = self
  })
end

function toggleMovement()
  assert(IS_UNIT_LEADER)
  if _PERSIST.ACTIVE_MOVEMENT != nil then
    _hideMovement()
  else
    _showMovement()
  end
end

function _moveDone()
  _hideMovement()
end

function _moveCancelBack()
  self.setPositionSmooth(_PERSIST.ACTIVE_MOVEMENT.origin, false, true)
  _hideMovement()
end

function _moveChangeSpeed()
  local speed = _PERSIST.ACTIVE_MOVEMENT.speed
  speed = speed + 1
  if speed > 3 then
    speed = 1
  end
  local controller = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Movement
  )
  controller.call('setProjectedMovementSpeed', {
    finder = getObjectFromGUID(_PERSIST.ACTIVE_MOVEMENT.finder),
    speed = speed,
  })
  -- TODO: Update radius for coroutine locking.
  _PERSIST.ACTIVE_MOVEMENT.speed = speed
  self.UI.setValue('activeSpeed', 'Speed ' .. tostring(speed))
end

function _hideMovement()
  getObjectFromGUID(_PERSIST.ACTIVE_MOVEMENT.finder).destruct()
  _PERSIST.ACTIVE_MOVEMENT = nil
  self.UI.hide('moveActions')
end

function _showMovement()
  local controller = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Movement
  )
  local objects = controller.call('spawnMoveFinder', {
    -- TODO: Pass in base size.
    initialSpeed = 2,
    origin = self,
  })
  -- Wait a frames for the returned objects to generate a GUID.
  Wait.frames(function()
    assert(objects.finder.guid != nil)
    _PERSIST.ACTIVE_MOVEMENT = {
      origin = self.getPosition(),
      speed = 2,
      finder = objects.finder.guid,
    }
  end, 1)
  self.UI.setValue('activeSpeed', 'Speed 2')
  self.UI.show('moveActions')
  -- TODO: Also show locked tool for cohesion range.
  -- TODO: Start coroutine to prevent the leader from moving out of bounds.
  -- TODO: Unlock once all minis are forced locked.
  -- TODO: Disable all other minis in unit/ghost them.
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
  if _PERSIST.ACTIVE_SILOUHETTE then
    _hideSilouhette()
  else
    _showSilouhette()
  end
  if _IS_UNIT_LEADER and #_PERSIST.CONNECTED_MINIS then
    for _, mini in ipairs(_PERSIST.CONNECTED_MINIS) do
      mini.call('toggleSilouhettes')
    end
  end
end

function _hideSilouhette()
  _destroyAttachment(_PERSIST.ACTIVE_SILOUHETTE)
  _PERSIST.ACTIVE_SILOUHETTE = nil
end

function _showSilouhette()
  local controller = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Spawn
  )
  local silouhette = controller.call('spawnSilouhette', {
    position = self.getPosition(),
    rotation = self.getRotation(),
  })
  self.addAttachment(silouhette)
  _PERSIST.ACTIVE_SILOUHETTE = silouhette.guid
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

--- Returns the miniature for this unit that is the unit leader.
--
-- @return Miniature
function getUnitLeader()
  if IS_UNIT_LEADER then
    return self
  elseif #_PERSIST.CONNECTED_MINIS then
    return getObjectFromGUID(_PERSIST.CONNECTED_MINIS[1])
  end
end

--- Returns the owner of the mini.
--
-- @return Color, such as "Red" or "Blue".
function getOwner()
  return _getLeaderSetup().leader.color
end

--- Returns the `_PERSIST.SETUP` value for the leader of this unit.
--
-- @local
-- @return table {color, rank}
-- @usage
-- local setup = _getLeaderSetup()
-- print(setup.color, setup.rank)
function _getLeaderSetup()
  local leader = getUnitLeader()
  local persist = leader.getTable('_PERSIST')
  return persist.SETUP
end
