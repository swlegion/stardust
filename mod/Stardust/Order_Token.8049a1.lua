function onLoad(state)
  if state != '' then
    PERSIST = JSON.decode(state)
  else
    PERSIST = self.getTable('PERSIST')
  end
  if PERSIST != nil then
    _setObjectDetails()
  end
end

function onSave(state)
  if PERSIST != nil then
    return JSON.encode(PERSIST)
  end
end

function _setObjectDetails()
  if PERSIST.color == 'Blue' then
    self.setCustomObject({
      diffuse = 'https://assets.swlegion.dev/tools/orders/empire.corps.jpg'
    })
  else
    self.setCustomObject({
      diffuse = 'https://assets.swlegion.dev/tools/orders/rebels.corps.jpg'
    })
  end
  self.setName(PERSIST.color .. ' ' .. PERSIST.rank)
  self.reload()
end
