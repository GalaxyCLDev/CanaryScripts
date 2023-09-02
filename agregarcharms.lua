local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)

    player:addCharmPoints(5) -- cantidad de charms a agregar
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Ganaste 5 Charms")
    item:remove()

end

action:id(37317) --- id del objeto que usaras para que funcione
action:register()
