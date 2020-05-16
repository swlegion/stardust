--- Order Tokens.
--
-- Expects a table of properties to provided via the field 'setupOrderToken`:
--
-- @usage
-- token.setTable('setupOrderToken', {
--   color = 'Blue',
--   rank  = 'Corps',
-- })
--
-- @module Order_Token

_PERSIST = {
  color = nil,
  rank  = nil,
}

function onLoad(state)
  if state != '' then
    _PERSIST = JSON.decode(state)
  else
    _PERSIST = self.getTable('setupOrderToken')
  end
  if _PERSIST != nil then
    _setObjectDetails()
  end
end

function onSave(state)
  if _PERSIST != nil then
    return JSON.encode(PERSIST)
  end
end

function _setObjectDetails()
  if _PERSIST.color == 'Blue' then
    self.setCustomObject({
      diffuse = 'https://assets.swlegion.dev/tools/orders/empire.corps.jpg'
    })
  else
    self.setCustomObject({
      diffuse = 'http://localhost:8080/tools/orders/rebels.corps.jpg'
    })
  end
  self.setName(_PERSIST.color .. ' ' .. _PERSIST.rank)
  self.reload()
end
