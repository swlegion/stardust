--- # Stardust, An experimental Tabletop Simulator mod for a popular miniatures game.

_GUIDS = {
  PLAY_AREA = '9be545',
  DEMO_GAME = '7fedf3',
}

--- Loads an army list based on the parameter passed by the UI.
--
-- @param player Player that clicked the button.
-- @param _ Unused (value).
-- @param type Name of the button that invoked this function.
function loadList(player, _, id)
  if type == 'lDemo' then
    loadTable(nil, nil, 't3x3')
    getObjectFromGUID(_GUIDS.DEMO_GAME).call('callLoadDemo')
  elseif type == 'lBuild' then
    print('Not yet supported')
  elseif type == 'lLoad' then
    print('Not yet supported')
  end
end

--- Loads a new table based on the parameter passed by the UI.
--
-- @param player Player that clicked the button.
-- @param _ Unused (value).
-- @param size Size of the table (e.g. `t3x3`) to load.
function loadTable(player, _, id)
  local sizeToScale = {
    t0x0 = {0, 0},
    t3x3 = {36, 36},
    t6x3 = {72, 36},
    t6x4 = {72, 48}
  }

  -- Determine dimensions.
  local scaleTo = sizeToScale[size]

  -- "Create" (summon) the play area.
  getObjectFromGUID(_GUIDS.PLAY_AREA).call('resize', scaleTo)
end
