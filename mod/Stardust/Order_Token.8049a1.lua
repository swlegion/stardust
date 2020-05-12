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
      diffuse = 'http://cloud-3.steamusercontent.com/ugc/1018319581181469578/56191D081421C02B875AC944DCEFE2063F1D7FC1/'
    })
  else
    self.setCustomObject({
      diffuse = 'http://cloud-3.steamusercontent.com/ugc/1018319581181607230/299FF1E61697FFCBB40A74AAC189D11B4EAFBA3B/'
    })
  end
  self.setName(PERSIST.color .. ' ' .. PERSIST.rank)
  self.reload()
end