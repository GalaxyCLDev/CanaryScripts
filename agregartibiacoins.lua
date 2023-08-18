local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)

    player:addTibiaCoins(1000)
    player:addTransferableCoins(1000)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Obtuviste 1000 tibia coins Gracias por jugar VAGOSCLUB, Siguenos en Instagram : @w3.vagosclub.cl")
    item:remove()

end

action:id(37317)
action:register()
