--- # Stardust, An experimental Tabletop Simulator mod for a popular miniatures game.

_GUIDS = {
  PLAY_AREA = '9be545',
  DEMO_GAME = '7fedf3',
}

--- Loads a new 3x table and a default army list for all players.
--
-- @param player Player that clicked to load a list.
--
-- Clears the table, load a new `3x3` one, and loads default armies.
function loadListByDemo(player)
  -- TODO: Add a check that the player is seated.
  loadTable(player, '3x3')
  getObjectFromGUID(_GUIDS.DEMO_GAME).call('loadDemo')
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
  getObjectFromGUID(_GUIDS.PLAY_AREA).call('resize', {0, 0})
end

--- Loads a new table based on the parameter passed by the UI.
--
-- @param player Player that clicked the button.
-- @param size Size of the table as expressed by a string, i.e. `3x3`.
function loadTable(player, size)
  -- TODO: Assert that size is valid.
  -- "Create" (summon) the play area.
  getObjectFromGUID(_GUIDS.PLAY_AREA).call('resize', {
    tonumber(string.sub(size, 1, 1)) * 12,
    tonumber(string.sub(size, 3, 4)) * 12,
  })
end