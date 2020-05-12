_GUIDS = {
  PLAY_AREA = '9be545',
  DEMO_GAME = '7fedf3',
}

function loadList(_, _, type)
  if type == 'lDemo' then
    loadTable(nil, nil, 't3x3')
    getObjectFromGUID(_GUIDS.DEMO_GAME).call('callLoadDemo')
  elseif type == 'lBuild' then
    print('Not yet supported')
  elseif type == 'lLoad' then
    print('Not yet supported')
  end
end

function loadTable(_, _, size)
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