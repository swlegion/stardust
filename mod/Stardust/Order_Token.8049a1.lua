--- Order Tokens.
--
-- @module Order_Token
--
-- Expects a table of properties to provided via the field 'setupOrderToken`:
--
-- @usage
--   token.setTable('setupOrderToken', {
--     color = 'Blue',
--     rank  = 'Corps',
--   })

function onLoad(state)
  if state != '' then
    PERSIST = JSON.decode(state)
  else
    PERSIST = self.getTable('setupOrderToken')
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
      diffuse = 'http://localhost:8080/tools/orders/rebels.corps.jpg'
    })
  end
  self.setName(PERSIST.color .. ' ' .. PERSIST.rank)
  self.reload()
end