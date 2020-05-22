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

-- Used by the local UI to track the tokens this unit owns.
local tokenNames = {
  aim = { state = false, quantity = 0},
  dodge = { state = false, quantity = 0},
  surge = { state = false, quantity = 0},
  suppression = { state = false, quantity = 0}
}

function onLoad(state)
  -- Define UI assets
  local uiAssets = {
    { name = 'surge', url = 'https://assets.swlegion.dev/ui/surge.png' },
    { name = 'aim', url = 'https://assets.swlegion.dev/ui/aim.png' },
    { name = 'dodge', url = 'https://assets.swlegion.dev/ui/dodge.png' },
    { name = 'suppression', url = 'https://assets.swlegion.dev/ui/suppression.png' },
    { name = 'activate', url = 'https://assets.swlegion.dev/ui/activate.png' },
    { name = 'threat', url = 'https://assets.swlegion.dev/ui/threat.png' }
  }

  Global.UI.setCustomAssets(uiAssets)

  -- Keep the previously configured state.
  if state != '' then
    _PERSIST = JSON.decode(state)
    if _PERSIST.SETUP.leader then
      initializeAsLeader()
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
    ACTIVE_RANGE_FINDER = false,
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

--- Toggle range finder for the unit leader.
--
-- @usage
-- unitLeaderMini.call('toggleRange')
function toggleRange()
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
  controller.call('clearFloatingNumbers')
end

function _showRange()
  local controller = getObjectFromGUID(
    Global.getTable('GUIDS').controllers.Target
  )
  local object = controller.call('spawnRangeFinder', {
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

function onCollisionEnter(collision_info)
  local obj = collision_info.collision_object
  local newTokenName = obj.getName()
  if tokenNames[newTokenName] != nil then
    addToken(newTokenName)
    if IS_UNIT_LEADER then
      obj.destruct()
    end
  end
end

-- Event handler for clicking tokens in the unit's UI
function _onTokenClick(player, value, id)
  removeToken(id)
end

-- Adds a token to the unit leader's UI
--
-- @param tokenName A string specifying the token to add
-- @usage
-- object.call('addToken', 'aim')
function addToken(tokenName)
  if tokenNames[tokenName] != nil and IS_UNIT_LEADER then
    tokenNames[tokenName].state = true
    tokenNames[tokenName].quantity = tokenNames[tokenName].quantity + 1
    Wait.frames(function() _updateTokenDisplay(tokenName) end, 1)
  end
end

-- Removes a token from the unit leader's UI
--
-- @param tokenName A string specifying the token to remove
-- @usage
-- object.call('removeToken', 'aim')
function removeToken(tokenName)
  tokenNames[tokenName].quantity = tokenNames[tokenName].quantity - 1
  _updateTokenDisplay(tokenName)
end

-- Updates the unit's UI to display the current token count
--
-- @local
-- @param tokenName A string specifying the name of the token
--
-- If the count falls below 1, it hides the associated UI element
function _updateTokenDisplay(tokenName)
  local count = tokenNames[tokenName].quantity
  if count <= 0 then
    tokenNames[tokenName].state = false
    self.UI.setAttribute(tokenName, 'active', false)
    self.UI.setAttribute(tokenName .. '_label', 'active', false)
  else
    tokenNames[tokenName].state = true
    self.UI.setAttribute(tokenName, 'active', true)
    self.UI.setAttribute(tokenName .. '_label', 'active', true)
    self.UI.setAttribute(tokenName .. '_label', 'text', tokenNames[tokenName].quantity)
  end
end
