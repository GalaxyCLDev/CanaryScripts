local config = {
    storageid = 59000, -- Storage para verificar si ya ha usado la estatua.
    itemid = 3043, count = 300, -- ITEM ID y la Cantidad.
    uid_use = 59000 -- AID O UID.
}

local faraonquest = Action()

function faraonquest.onUse(player, item, frompos, item2, topos)
   if player:getStorageValue(config.storageid) == 1 then -- revisamos si el jugador ya abrio el cofre o el objeto que se asigno como quest.
      player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Esta estatua ya fue revisada...")
      return true
   end

   player:addItem(config.itemid, config.count) -- item que se le dara al jugador
   player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Obtuviste 300 Crystal Coin y Acceso al boss Gran Faraon...")
   player:setStorageValue(config.storageid, 1) -- storage que se le agrega al jugador
   return true
end

faraonquest:uid(config.uid_use) -- id que se pone en uniqueid en el mapa editor.
faraonquest:register()
