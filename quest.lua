local faraonquest = Action()

function faraonquest.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(59000) == 1 then -- revisamos si el jugador ya abrio el cofre o el objeto que se asigno como quest.
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Esta estatua ya fue revisada...")
		return true
	end

	player:addItem(3043, 300) -- item que se le dara al jugador
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Obtuviste 300 Crystal Coin y Acceso al boss Gran Faraon...")
	player:setStorageValue(59000, 1) -- storage que se le agrega al jugador
	return true
end

faraonquest:uid(59000) -- id que se pone en uniqueid en el mapa editor.
faraonquest:register()
