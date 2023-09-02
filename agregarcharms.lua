local action = Action()

function action.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not player or not item or item:getId() ~= 37317 then
        return false
    end

    local charmAmountToAdd = 5

    -- Verifica si el objeto es apilable y tiene más de 1 en la pila
    if item:isStackable() and item:getCount() > 1 then
        player:addCharmPoints(charmAmountToAdd)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Ganaste " .. charmAmountToAdd .. " Charms")
        item:remove(1)  -- Elimina solo 1 objeto del montón
    else
        -- Si no es apilable o solo queda 1 en la pila, elimina todo el montón
        player:addCharmPoints(charmAmountToAdd * item:getCount())
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Ganaste " .. charmAmountToAdd * item:getCount() .. " Charms")
        item:remove()
    end

    return true
end

action:id(37317)
action:register()
