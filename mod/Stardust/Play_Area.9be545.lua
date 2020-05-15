PERSIST = {}

function onLoad(saveState)
  -- Make the play area not clickable.
  self.interactable = false

  if saveState != "" then
    PERSIST = JSON.decode(saveState)
  end

  if (PERSIST.unscaledBounds == nil) then
    onInitBounds()
  end
end

function onInitBounds()
  -- Get an initial bounds check
  self.setScale({1, 1, 1})
  PERSIST.unscaledBounds = self.getBounds().size

  -- Hide the object
  self.setScale({0, 0, 0})
end

function onSave()
    return JSON.encode(PERSIST);
end

--- Clears and then resizes the table to provided {width, height}.
--
-- If {0, 0} is passed in the table is cleared/destroyed only.
--
-- @param size A table of an X and Y value, in inches.
--
-- @usage
-- playArea.call('resize', {36, 36})
function resize(size)
  -- Read size arguments.
  local width = size[1] / 6
  local height = size[2] / 6

  -- Given the initial bounds, determine how much to scale to hit 6 inches.
  --
  -- For example, if START_BOUNDS.x was 4.5, we would scale by 1.5x in order
  -- to represent 6 inches, so our `ratioX` would be 1.5.
  local ratioX = 6 / PERSIST.unscaledBounds.x
  local ratioZ =  6 / PERSIST.unscaledBounds.z

  -- Scale up appropriately.
  --
  -- If we wanted to show a 36" board, we would scale X by 36 * ratioX.
  local scaleTo = {
    x = width * ratioX,
    y = 1,
    z = height * ratioZ
  }

  -- Clear table (remove all minis, etc) before scaling.
  clearTable()

  -- Size the table. Create a new zone.
  self.setScale(scaleTo)

  -- Do we need to create a zone?
  if PERSIST.zoneGuid == nil then
    createZone(size[1], size[2])
  end
end

--- If there is a visible play area, destroys it.
--
-- @local
function clearTable()
  if PERSIST.zoneGuid == nil then
    return
  end
  local zoneCheck = getObjectFromGUID(PERSIST.zoneGuid)
  local allObjects = zoneCheck.getObjects()
  for _, object in ipairs(allObjects) do
    if object.getGUID() != self.getGUID() then
      object.destruct()
    end
  end
  zoneCheck.destruct()
  PERSIST.zoneGuid = nil
end

--- Creates a new scripting zone on top of the table to watch for minis.
--
-- @param width Width in inches.
-- @param height Height in inches.
--
-- @local
function createZone(width, height)
  local zone = {
    position = self.getPosition(),
    scale = {width, 1, height},
    type = 'ScriptingTrigger',
    rotation = self.getRotation(),
    callback = 'onZoneCreated',
    callback_owner = self
  }
  spawnObject(zone)
end

function onZoneCreated(zone)
  PERSIST.zoneGuid = zone.guid
end

--- Returns all unit leaders that are currently in the play area.
--
-- @usage
-- local unitLeaders = playArea.call('getAllUnitLeaders')
-- for _, unitLeader in ipairs(unitLeaders) do
--   -- ...
-- end
function getAllUnitLeaders()
  local results = {}
  local zoneCheck = getObjectFromGUID(PERSIST.zoneGuid)
  if zoneCheck != nil then
    for _, object in ipairs(zoneCheck.getObjects()) do
      if object.getVar('IS_UNIT_LEADER') then
        table.insert(results, object)
      end
    end
  end
  return results
end

--- Returns all targetable units that are currently in the play area.
--
-- In practice, this is all unit leaders plus all non-unit leader minis.
--
-- @usage
-- local targets = playArea.call('getAllTargets')
-- for _, target in ipairs(targets) do
--   -- ...
-- end
function getAllTargets()
  local results = {}
  local zoneCheck = getObjectFromGUID(PERSIST.zoneGuid)
  if zoneCheck != nil then
    for _, object in ipairs(zoneCheck.getObjects()) do
      if object.getVar('IS_TARGETABLE') then
        table.insert(results, object)
      end
    end
  end
  return results
end