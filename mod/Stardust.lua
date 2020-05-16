--- Global module.

--- Reference of GUIDs, by name, that might be utilized by parts of the mod.
--
-- In general, all GUIDS should be only stored and referenced from this table
-- (assuming the GUID is for a global object). The exception might be objects
-- that are tightly bound to one-another.
--
-- @usage
-- local guids = Global.getVar('GUIDS')
-- local data = getObjectFromGUID(guids.controllers.Data)
-- data.call('...', { ... })
GUIDS = {
  controllers = {
    Data            = '093685',
    Demo            = '7f3df3',
    Formation       = '53afc7',
    Movement        = '0d6e64',
    Spawn           = '525d68',
    Target          = '4205cc',
  },

  clone = {
    Silouhette      = '767062',
    Miniature       = 'b34d79',
  },

  objects = {
    Barricade       = '96cf71',
    Order           = '8049a1',
    Table           = '9be545',
  }
}

--- Loads a new 3x table and a default army list for all players.
--
-- @param player Player that clicked to load a list.
--
-- Clears the table, load a new `3x3` one, and loads default armies.
function loadListByDemo(player)
  -- TODO: Add a check that the player is seated.
  loadTable(player, '3x3')
  getObjectFromGUID(GUIDS.controllers.Demo).call('loadDemo')
end

--- Opens a list builder for the current player.
--
-- @param player Player that clicked to load a list.
function loadListByBuilding(player)
  -- TODO: Add a check that the player is seated.
  error('Not yet supported')
end

--- Opens an import dialog to import/upload a list.
--
-- @param player Player that clicekd to import a list.
function loadListByImporting(player)
  -- TODO: Add a check that the player is seated.
  error('Not yet supported')
end

--- Clears (destroys) the current table.
function clearTable()
  getObjectFromGUID(GUIDS.objects.Table).call('resize', {0, 0})
end

--- Loads a new table based on the parameter passed by the UI.
--
-- @param player Player that clicked the button.
-- @param size Size of the table as expressed by a string, i.e. `3x3`.
function loadTable(player, size)
  -- TODO: Assert that size is valid.
  -- "Create" (summon) the play area.
  getObjectFromGUID(GUIDS.objects.Table).call('resize', {
    tonumber(string.sub(size, 1, 1)) * 12,
    tonumber(string.sub(size, 3, 4)) * 12,
  })
end
