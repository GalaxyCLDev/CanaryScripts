marketWindow = nil
marketButton = nil
buyTab = nil
sellTab = nil
offerTab = nil
histTab = nil
tradeTab = nil

itemSellPanel = nil
itemsPanel = nil
tradeButton = nil
buyPanel = nil
histPanel = nil
offerPanel = nil
sellPanel = nil
selecSellPanel = nil
offerPanel = nil
offer2Panel = nil
tradePanel = nil
trade2Panel = nil

buttonSearch = nil
buttonsearchOk = nil
buttonofferOk = nil
buttonobuyNow = nil
buttonocater = nil
buttonomenuCater = nil

labelPag = nil


sellCancel = nil


selectedItem = nil
selectedItemSell = nil


mouseGrabberWidget = nil


miniWindow = nil

price = nil


itemList = {}
itemSellList = {}


confimarWindow = nil

pag = 1
pagLast = 1
pagNext = nil
pagNextL = nil
pagPrev = nil
pagPrevL = nil
pagnot = false

itemIdFirst = nil

itemIdLast = nil

vendWindow = nil


searchTxt = ""

categorias = {"All", "Pokemons",
"Helds",
"Utilitários",
"Mobilias",
"Addons",
"Itens",
"Stones",
"Outros",
"Cards","Diamonds", "Pokeballs"}


function init()
	marketButton = modules.client_topmenu.addRightGameToggleButton('marketButton', tr('Market') .. ' (Ctrl+U)', '/images/topbuttons/market', toggle)

    marketButton:setOn(false)
    marketWindow = g_ui.displayUI('pokemakert',  modules.game_interface.getRightPanel())
	marketWindow:setVisible(false)
    
	vendWindow = g_ui.displayUI('confvend')
	vendWindow:setVisible(false)
  
    itemsPanel = marketWindow:recursiveGetChildById('itemsPanel')
	buyPanel = marketWindow:recursiveGetChildById('buyPanel')
	histPanel = marketWindow:recursiveGetChildById('histPanel')
	sellPanel = marketWindow:recursiveGetChildById('sellPanel')
	selecSellPanel = marketWindow:recursiveGetChildById('selecSellPanel')
	offerPanel = marketWindow:recursiveGetChildById('offerPanel')
	offer2Panel = marketWindow:recursiveGetChildById('offer2Panel')
	sellCancel = marketWindow:recursiveGetChildById('sellCancel')
	tradePanel = marketWindow:recursiveGetChildById('tradePanel')
	trade2Panel = marketWindow:recursiveGetChildById('trade2Panel')
	histPanel:setVisible(false)
	offerPanel:setVisible(false)
	offer2Panel:setVisible(false)
	sellPanel:setVisible(false)
	selecSellPanel:setVisible(false)
	sellCancel:setVisible(false)
	tradePanel:setVisible(false)
	trade2Panel:setVisible(false)
	
	itemSellPanel = marketWindow:recursiveGetChildById('sellItemPanel')

    buyTab = marketWindow:getChildById('buyTab')
    sellTab = marketWindow:getChildById('sellTab')
	offerTab = marketWindow:getChildById('offerTab')
    histTab = marketWindow:getChildById('histTab')
	tradeTab = marketWindow:getChildById('tradeTab')
	
	buttonSearch = marketWindow:getChildById('search')
	buttonsearchOk = marketWindow:getChildById('searchOk')
	buttonofferOk = marketWindow:getChildById('offerOk')
	buttonofferOk:setEnabled(false)
	buttonofferOk:setVisible(false)
	buttonobuyNow = marketWindow:getChildById('buyNow')
	buttonobuyNow:setEnabled(false)
	buttonocater = marketWindow:getChildById('cater')
	buttonomenuCater = marketWindow:getChildById('menuCater')
	for _, proto in ipairs(categorias) do
        buttonomenuCater:addOption(proto) 
    end
	connect(buttonomenuCater, { onOptionChange = categoria })
	
	labelPag = marketWindow:getChildById('pag')
	pagNext = marketWindow:getChildById('next')
	pagNextL = marketWindow:getChildById('nextL')
	pagPrev = marketWindow:getChildById('prev')
	pagPrevL = marketWindow:getChildById('prevL')
	
	offerTab:setEnabled(false)
	histTab:setEnabled(false)
	offerTab:setVisible(false)
	histTab:setVisible(false)
	tradeTab:setVisible(false)
	
    radioTabs = UIRadioGroup.create()
    radioTabs:addWidget(buyTab)
	radioTabs:addWidget(sellTab)
	radioTabs:addWidget(offerTab)
	radioTabs:addWidget(histTab)
	radioTabs:addWidget(tradeTab)
	radioTabs:selectWidget(buyTab)
    radioTabs.onSelectionChange = onTradeTypeChange
	
	
	mouseGrabberWidget = g_ui.createWidget('UIWidget')
 	mouseGrabberWidget:setVisible(false)
	mouseGrabberWidget:setFocusable(false)
	mouseGrabberWidget.onMouseRelease = onChooseItemMouseRelease
	
	ProtocolGame.registerOpcode(0xF3, newOpcodes)
	ProtocolGame.registerExtendedOpcode(155, textErro)
	
	connect(g_game, { onGameStart = onGameStart })
	connect(g_game, { onGameEnd = hide })
end

function newOpcodes(protocol, msg)
    local recvbyte = msg:getU8()
    if recvbyte == 0x1 then
	    showConfVend(protocol, msg)
	    return
	elseif recvbyte == 0x2 then
		refreshSellItems1(protocol, msg)
	elseif recvbyte == 0x4 then
	    refreshBuyItems1(protocol, msg)
	    return
	end
end

function showPontos(protocol, opcode, buffer)
    local msg = InputMessage.create()
    msg:setBuffer(buffer)
    local ty = msg:getU8()
    if ty == 2 then
        balance = tostring(msg:getU64())
        balance1 = tostring(msg:getU64())
        marketWindow:recursiveGetChildById('ldol'):setText("Market Dollar Balance:"..tostring(balance))
        marketWindow:recursiveGetChildById('ldd'):setText("Market Diamond Balance:"..tostring(balance1))
    elseif ty == 4 or ty == 1 then
        balance = tostring(msg:getU64())
        marketWindow:recursiveGetChildById('ldd'):setText("Market Diamond Balance:"..balance)
    else
        balance = tostring(msg:getU64())
        marketWindow:recursiveGetChildById('ldol'):setText("Market Dollar Balance:"..balance)
    end


end

function changer(value)
    local protocol = g_game.getProtocolGame()
    if protocol then
        local msg = OutputMessage.create()
		msg:addU8(value)
		msg:addU64(tonumber(marketWindow:recursiveGetChildById('troca'..value):getText()))
        protocol:sendExtendedOpcode(151, msg:getBuffer())
		
    end
end
function changerConvert(value)
    local protocol = g_game.getProtocolGame()
    if protocol then
        local msg = OutputMessage.create()
		msg:addU8(value)
		msg:addU64(tonumber(marketWindow:recursiveGetChildById('convert'..value):getText()))
        protocol:sendExtendedOpcode(151, msg:getBuffer())
		
    end
end

function setTrade(txt, dia)


    if dia then
        local pe = marketWindow:recursiveGetChildById('tradeTdia')
        pe:setText("Total: "..tostring(math.floor(tonumber(txt))))
    else
        local pe = marketWindow:recursiveGetChildById('tradeTdol')
        pe:setText("Total: "..tostring(math.floor(tonumber(txt)*0.95)))
    end
end

function setConvert(txt, dia)

    if dia then
        local pe = marketWindow:recursiveGetChildById('tradeCdia')
        pe:setText("Total: "..txt)
    else
        local pe = marketWindow:recursiveGetChildById('tradeCdol')
        pe:setText("Total: "..txt)
    end
end

function revert()
    local protocol = g_game.getProtocolGame()
    if protocol then
        local msg = OutputMessage.create()
		if marketWindow:recursiveGetChildById('someoferta'):isChecked() then
       		msg:addU8(4)
		else
			msg:addU8(3)
		end
		msg:addU64(tonumber(marketWindow:recursiveGetChildById('trocaDi'):getText()))
        protocol:sendExtendedOpcode(151, msg:getBuffer())
		
    end
end


function categoria(comboBox, text, data)
    local protocol = g_game.getProtocolGame()
    if protocol then
        local msg = OutputMessage.create()
        msg:addString("categoria")
		msg:addString(text)
		msg:addString("")
		msg:addU16(0)
        protocol:sendExtendedOpcode(156, msg:getBuffer())
    end
	buttonSearch:setText("")
	pag = 1
end

function page(pagNow, pagLast)

    pag = pagNow
    pagLast = pagLast

    if pagLast < 1 then
        pagLast = 1
    end

    labelPag:setText(pag.."/"..pagLast)

end

function setSearch(txt)
    buttonSearch:setText(txt)
    searchTxt = txt
end

function pagClickDown()--pagina anterior
    if pag == 1 then
	    return
	end
    pag = pag-1 
	local protocol = g_game.getProtocolGame()
    if protocol then
		local msg = OutputMessage.create()
   		msg:addU8(0xF3)
    	msg:addU8(0x4)
	
		if searchTxt == "" and marketWindow:getChildById('menuCater'):getCurrentOption().text == "All" then
			msg:addString("categoria")
			msg:addString("")
			msg:addU8(pag)
		elseif searchTxt ~= "" then
			msg:addString("categoria")
			msg:addString("")
			msg:addU8(pag)
		else
			msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
			msg:addString("")
			msg:addU8(pag)
		end
		
        protocol:send(msg)
    end
	labelPag:setText(pag.."/"..pagLast)
end

function pagClickUp()
    if pag == pagLast then
	    return
	end
    pag = pag+1
	
	local protocol = g_game.getProtocolGame()
    if protocol then
	    local msg = OutputMessage.create()
	    if searchTxt == "" and marketWindow:getChildById('menuCater'):getCurrentOption().text == "All" then
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		elseif searchTxt ~= "" then
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		else
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		end
	    protocol:send(msg)
    end
    labelPag:setText(pag.."/"..pagLast)

end

function pagClickFirst()
    if pag == 1 then
	    return
	end
    pag = 1
	local protocol = g_game.getProtocolGame()
    if protocol then
        local msg = OutputMessage.create()
		if searchTxt == "" and marketWindow:getChildById('menuCater'):getCurrentOption().text == "All" then
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		elseif searchTxt ~= "" then
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		else
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		end
        protocol:send(msg)
    end
	labelPag:setText(pag.."/"..pagLast)
end

function pagClickLast()
    if pag == pagLast then
	    return
	end
	
    pag = pagLast
	local protocol = g_game.getProtocolGame()
    if protocol then
        local msg = OutputMessage.create()
        if searchTxt == "" and marketWindow:getChildById('menuCater'):getCurrentOption().text == "All" then
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		elseif searchTxt ~= "" then
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		else
		    msg:addString("categoria")--marketWindow:getChildById('menuCater'):getCurrentOption().text
		    msg:addString("")
			msg:addU8(pag)
		end
		protocol:send(msg)
    end


	labelPag:setText(pag.."/"..pagLast)
	    
end

function search()
	local protocol = g_game.getProtocolGame()
    if protocol then
		local msg = OutputMessage.create()
   		msg:addU8(0xF3)
    	msg:addU8(0x4)
		
		if marketWindow:getChildById('menuCater'):getCurrentOption().text == "All" then
			msg:addString("search")
			msg:addString(searchTxt)
			msg:addU8(1)
        	protocol:send(msg)
		else
			msg:addString("categoria")
			--msg:addString(marketWindow:getChildById('menuCater'):getCurrentOption().text)
			--msg:addString("search")
			msg:addString(searchTxt)
			msg:addU8(1)
       		protocol:send(msg)
		end
    end
end

function onGameStart()
    atualizar()
end



function onTradeTypeChange(radioTabs, selected, deselected)
	tradeButton = selected:getId()--selected:getText()

    selected:setOn(true)
    deselected:setOn(false)

	if tradeButton == tr("buyTab") then
	    refreshBuyItems()
    elseif tradeButton == tr("sellTab") then
	    refreshSellItems()
	elseif tradeButton == tr("offerTab") then
        refreshOfferItems()
	elseif tradeButton == tr("histTab") then
	    refreshHistItems()
	else
	    refreshTradeItems()
    end
end


function refreshBuyItems() 
    
	sellPanel:setVisible(false)
	selecSellPanel:setVisible(false)
	offerPanel:setVisible(false)
	offer2Panel:setVisible(false)
    histPanel:setVisible(false)
	sellCancel:setVisible(false)
	tradePanel:setVisible(false)
	trade2Panel:setVisible(false)
	
	buyPanel:setVisible(true)
	buttonBuy(true)
end

function textErro(protocol, opcode, buffer)
    if buffer == "OpenMarkert" then
	    if not marketWindow:isOn() then
			buttonomenuCater:setCurrentOption("All")
			show()
			
			return
        end
    end
    showMiniWindowDone(buffer)
end

function onTimerExpired(time_value)
    local value_time = (time_value - os.time()) / 60
	local hour = math.floor((value_time/60))
	local minute = math.floor(value_time-(hour*60)) --2879,9765
	
	if os.time() <= time_value then
		return hour..":"..minute
	end
	
	return "expired"
end

function refreshSellItems1(protocol, msg)
    selectedItemSell = nil
    itemSellPanel:destroyChildren()
	  
	local PAGITEM_SIZE = msg:getU8()
	if PAGITEM_SIZE > 50 then
	    PAGITEM_SIZE = 50
	end
	
	for i=1, PAGITEM_SIZE do
	    
	    local market_id = msg:getU32()
        local item_id = msg:getU16()
        local item_name = msg:getString()
        local item_count = msg:getU16()
        local item_price = msg:getU32()--/100
		local item_description = msg:getString()
		local item_time = msg:getU64()
		local type_money = msg:getU8()
		local type_price_all = msg:getU8()
		
		if type_money == 0 then
		    item_price = item_price/100
		end

	    local itemBox = g_ui.createWidget('MarketItemSellBox', itemSellPanel)
        local itemWidget = itemBox:getChildById('itemSell')
		local itemP = itemBox:getChildById('itemP')
		itemBox:setId(market_id)
		
		if i%2 == 0 then
			itemBox:setImageSource("/images/ui/pxg1")
		else
			itemBox:setImageSource("/images/ui/pxg0")
		end
		
		local nid = g_ui.createWidget('MakertLabel', itemBox)
    	nid:setMarginTop(10)
    	nid:setMarginLeft(5)
    	nid:setText(i)
		itemWidget:setItemId(item_id)
		itemWidget:setText(tostring(item_count))
		itemWidget:setTooltip(tr(item_description))
		
		local Nome = g_ui.createWidget('MakertLabel', itemBox)
     	Nome:setMarginTop(10)
     	Nome:setMarginLeft(115)
     	Nome:setText(item_name)
		
		local Tempo = g_ui.createWidget('MakertLabel', itemBox)
     	Tempo:setMarginTop(10)
     	Tempo:setMarginLeft(320)
     	Tempo:setText(onTimerExpired(item_time))
		
     	local Quant = g_ui.createWidget('MakertLabel', itemBox)
     	Quant:setMarginTop(10)
     	Quant:setMarginLeft(440)
     	Quant:setText(item_count)
		
     	local Prec = g_ui.createWidget('MakertLabel', itemBox)
     	Prec:setMarginTop(10)
     	Prec:setText(pricek(item_price))
		Prec:setMarginLeft(590-Prec:getTextSize().width)
		
		if type_money > 0 then
			itemP:setItemId(3042)
		else
			itemP:setItemId(3035)
		end
		
		if type_price_all > 0 then
			itemP:setTooltip(tr(" price:"..item_price).." (X"..item_count..")")
		else
			itemP:setTooltip(tr(" price:"..item_price).." (X".."1)")
		end
		
		itemSellList["i"..market_id] = {inu = i, n = market_id, item = item_id, nome = item_name, tempo = item_time, count = item_count, price = item_price, money = type_money, stack = type_price_all}
	end

end

function onItemSellBoxChecked(widget)
    local item = widget.item
	if selectedItemSell then
	    selectedItemSell:setText("")
		if itemSellList["i"..selectedItemSell:getId()].inu % 2 == 0 then
			selectedItemSell:setImageSource("/images/ui/pxg1")
		else
			selectedItemSell:setImageSource("/images/ui/pxg0")
		end
	end
    
	widget:setImageSource("/images/ui/pxg")
	selectedItemSell = widget

end

function itemSellCancel() --//BR
	if selectedItemSell then
	   local protocol = g_game.getProtocolGame()
        if protocol then 
		    local msg = OutputMessage.create()
		    msg:addU8(0xF3)
		    msg:addU8(0x3)
		    msg:addU16(selectedItemSell:getId())
            protocol:send(msg)
            itemSellPanel:destroyChildren()			
        end
	end
end

function pricek(price)
    if price >= 1000000 then
        return (math.floor(price/1000000)).."kk"
    elseif price >= 1000 then
        return (math.floor(price/1000)).."k"
    else
        return math.floor(price)
    end
end

function refreshBuyItems1(protocol, msg)
    selectedItem = nil
    buttonobuyNow:setEnabled(false)
    itemsPanel:destroyChildren()
	  
	local PAG_SIZE_NOW = msg:getU8()
	local PAG_SIZE_LAST = msg:getU8()
	if PAG_SIZE_LAST == 0 then
	PAG_SIZE_LAST = 1
    end
	
	page(PAG_SIZE_NOW, PAG_SIZE_LAST)
	local PAGITEM_SIZE = msg:getU8()
	if PAGITEM_SIZE > 50 then
	    PAGITEM_SIZE = 50
	end
	
	for i=1, PAGITEM_SIZE do
	    local market_id = msg:getU32()
        local item_id = msg:getU16()
        local item_name = msg:getString()
		local selling_name = msg:getString()
        local item_count = msg:getU16()
        local item_price = msg:getU32()--/100
		local item_description = msg:getString()
		local type_money = msg:getU8()
		local type_price_all = msg:getU8()
		
		if type_money == 0 then
		    item_price = item_price/100
		end
	
	    if i == 1 then
		    itemIdLast = market_id
		end
		
		if i == PAGITEM_SIZE then
		    itemIdFirst = market_id
		end
		
		
	
	    local itemBox = g_ui.createWidget('MarketItemBox', itemsPanel)
        local itemWidget = itemBox:getChildById('item')
		local itemP = itemBox:getChildById('itemP')
		
		
		itemBox:setId(market_id)
		if i%2 == 0 then
		    itemBox:setImageSource("/images/ui/pxg1")
		else
		    itemBox:setImageSource("/images/ui/pxg0")
		end
		local nid = g_ui.createWidget('MakertLabel', itemBox)
    	nid:setMarginTop(10)
    	nid:setMarginLeft(5)
    	nid:setText(i+((50*pag)-50))
		itemWidget:setItemId(item_id)
		itemWidget:setText(tostring(item_count))
		itemBox:setTooltip(tr(item_description))
		local Nome = g_ui.createWidget('MakertLabel', itemBox)
     	Nome:setMarginTop(10)
     	Nome:setMarginLeft(115)
     	Nome:setText(item_name)
     	local Vend = g_ui.createWidget('MakertLabel', itemBox)
    	Vend:setMarginTop(10)
     	Vend:setMarginLeft(310)
     	Vend:setText(selling_name)
     	local Quant = g_ui.createWidget('MakertLabel', itemBox)
     	Quant:setMarginTop(10)
     	Quant:setMarginLeft(440)
     	Quant:setText(item_count)
     	local Prec = g_ui.createWidget('MakertLabel', itemBox)
		
     	Prec:setMarginTop(10)
		buttonobuyNow:setTooltip(tr('You are paralysed'))
     	Prec:setText(pricek(item_price))
		Prec:setMarginLeft(590-Prec:getTextSize().width)
		
		if type_money > 0 then
		    itemP:setItemId(3028)
		else
		    itemP:setItemId(3031)
		end
		itemP:setItemCount(1)
		if type_price_all > 0 then
		    itemP:setTooltip(tr(" price:"..item_price).." (X"..item_count..")")
		else
		    itemP:setTooltip(tr(" price:"..item_price).." (X".."1)")
		end
		
		
		itemList["i"..market_id] = {inu = i, n = market_id, item = item_id, nome = item_name, vend = selling_name, count = item_count, price = item_price, stack = type_price_all}
		itemList["i"..i] = {inu = i, n = market_id, item = item_id, nome = item_name, vend = selling_name, count = item_count, price = item_price, stack = type_price_all}
	end
		
end
function refreshSellItems()
    buyPanel:setVisible(false)
	sellPanel:setVisible(true)
	selecSellPanel:setVisible(true)
	sellCancel:setVisible(true)
	offerPanel:setVisible(false)
	offer2Panel:setVisible(false)
	histPanel:setVisible(false)
	tradePanel:setVisible(false)
	trade2Panel:setVisible(false)
	
	buttonBuy(false)
end
function refreshOfferItems()
    buyPanel:setVisible(false)
	sellPanel:setVisible(false)
	selecSellPanel:setVisible(false)
	offerPanel:setVisible(true)
	offer2Panel:setVisible(true)
	histPanel:setVisible(false)
	sellCancel:setVisible(false)
	tradePanel:setVisible(false)
	trade2Panel:setVisible(false)
	buttonBuy(false)
end
function refreshHistItems()
    buyPanel:setVisible(false)
	sellPanel:setVisible(false)
	selecSellPanel:setVisible(false)
	offerPanel:setVisible(false)
	offer2Panel:setVisible(false)
	tradePanel:setVisible(false)
	histPanel:setVisible(true)
	sellCancel:setVisible(false)
	trade2Panel:setVisible(false)
	buttonBuy(false)
end

function refreshTradeItems()
    buyPanel:setVisible(false)
	sellPanel:setVisible(false)
	selecSellPanel:setVisible(false)
	offerPanel:setVisible(false)
	offer2Panel:setVisible(false)
	tradePanel:setVisible(true)
	trade2Panel:setVisible(true)
	sellCancel:setVisible(false)
	buttonBuy(false)
end

function buttonBuy(value)
    buttonSearch:setVisible(value)
	buttonsearchOk:setVisible(value)
	buttonofferOk:setVisible(false)
	buttonobuyNow:setVisible(value)
	buttonocater:setVisible(value)
    buttonomenuCater:setVisible(value)
	labelPag:setVisible(value)
	pagNext:setVisible(value)
	pagNextL:setVisible(value)
	pagPrev:setVisible(value)
	pagPrevL:setVisible(value)
end

function terminate()
    disconnect(g_game, { onGameEnd = hide })
	ProtocolGame.unregisterOpcode(0xF3)
	ProtocolGame.unregisterExtendedOpcode(155)
    marketWindow:destroy()
end

function toggle()
    if marketButton:isOn() then
        hide()
        marketButton:setOn(false)
		
    else
        show()
       --[[ marketButton:setOn(true)
		  local ids = 268440432
		  gameMapPanel = modules.game_interface.getMapPanel()]]
    end
end

function show()
    marketWindow:setVisible(true)
	if vendWindow:isVisible() then
		    vendWindow:setVisible(false)
			marketWindow:recursiveGetChildById('slotved'):clearItem()
		marketWindow:recursiveGetChildById('countText'):setText("")
		
		marketWindow:recursiveGetChildById('countScrollBar'):setMinimum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setMaximum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setValue(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setText("")
		end
end

function hide()
    marketWindow:setVisible(false)
end

function atualizar()
    local protocol = g_game.getProtocolGame()
    if protocol then  
		local msg = OutputMessage.create()
   		msg:addU8(0xF3)
    	msg:addU8(0x4)
	
		if marketWindow:getChildById('menuCater'):getCurrentOption().text == "All" then
        	msg:addString("atualizar")
			msg:addString("")
		    msg:addU8(1)
		else
			msg:addString(marketWindow:getChildById('menuCater'):getCurrentOption().text)
			msg:addString("")
			msg:addU8(1)
		end
		buttonobuyNow:setEnabled(false)
    	itemSellPanel:destroyChildren()

    	protocol:send(msg)
    end
end

function showConfVend(protocol, msg)--//BR sendMarketItemRequest()
    
	local spriteId = msg:getU16()
	local item_count = msg:getU16()
	local item_name = msg:getString()
	
	local slot_item = marketWindow:recursiveGetChildById('slotved')
    slot_item:setItemId(spriteId)
	slot_item:setText(tostring(item_count))
	
    marketWindow:recursiveGetChildById('countScrollBar'):setMinimum(1)
    marketWindow:recursiveGetChildById('countScrollBar'):setMaximum(item_count)
    marketWindow:recursiveGetChildById('countScrollBar'):setValue(item_count)
    marketWindow:recursiveGetChildById('countScrollBar'):setText(tostring(item_count))
	
	vendWindow:recursiveGetChildById('slotconf'):setItemId(spriteId)
	vendWindow:recursiveGetChildById('name'):setText(item_name)
end

function ConfVend()--confirmar vendar
    local protocol = g_game.getProtocolGame()
    if protocol then 
        if tonumber(marketWindow:recursiveGetChildById('countText'):getText()) and tonumber(marketWindow:recursiveGetChildById('countText'):getText()) > 0 then	
	        local msg = OutputMessage.create()
			msg:addU8(0xF3)
            msg:addU8(0x2)
		    msg:addU16(tonumber(vendWindow:recursiveGetChildById('slotconf'):getText()))
			msg:addU32(tonumber(marketWindow:recursiveGetChildById('countText'):getText()))
			local type_money = marketWindow:recursiveGetChildById('someoferta'):isChecked() and 1 or 0
	        local type_unity = marketWindow:recursiveGetChildById('stack'):isChecked() and 1 or 0
			msg:addU8(tonumber(type_money))
			msg:addU8(tonumber(type_unity))
            protocol:send(msg)
        else
		    showMiniWindowDone("O preço do item deve ser acima de 0")
        end
		
		marketWindow:recursiveGetChildById('slotved'):clearItem()
		marketWindow:recursiveGetChildById('slotved'):setText("")
		marketWindow:recursiveGetChildById('countText'):setText("")
		vendWindow:setVisible(false)
		marketWindow:setVisible(true)
    end
end

function CancelVend()
    local protocol = g_game.getProtocolGame()
    if protocol then 
		local msg = OutputMessage.create()
        msg:addString("cancel")
		
		marketWindow:recursiveGetChildById('slotved'):clearItem()
		marketWindow:recursiveGetChildById('slotved'):setText("")
		marketWindow:recursiveGetChildById('countText'):setText("")
		
		marketWindow:recursiveGetChildById('countScrollBar'):setMinimum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setMaximum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setValue(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setText("")
		
		vendWindow:setVisible(false)
		marketWindow:setVisible(true)
		
    end
end

--opcodes
function venda()
        if tonumber(marketWindow:recursiveGetChildById('countText'):getText()) and tonumber(marketWindow:recursiveGetChildById('countText'):getText()) > 0 then	
		   local preco = tonumber(marketWindow:recursiveGetChildById('countText'):getText())
		   local count = tonumber(marketWindow:recursiveGetChildById('slotved'):getText())--getItemCount()
		   vendWindow:recursiveGetChildById('slotconf'):setText(tostring(count))
		   vendWindow:recursiveGetChildById('precou'):setText("Preço unitário: "..tonumber(marketWindow:recursiveGetChildById('countText'):getText()).." dólares")
		   
	        marketWindow:setVisible(false)
		    vendWindow:setVisible(true)
			
			marketWindow:recursiveGetChildById('countScrollBar'):setMinimum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setMaximum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setValue(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setText("")
		
		if marketWindow:recursiveGetChildById('stack'):isChecked() then
		
		    if marketWindow:recursiveGetChildById('someoferta'):isChecked() then
			    vendWindow:recursiveGetChildById('precou'):setText("Preço unitário: "..tonumber(marketWindow:recursiveGetChildById('countText'):getText()).." diamonds")
			    vendWindow:recursiveGetChildById('precot'):setText("Preço total: "..preco.." diamonds")
			    vendWindow:recursiveGetChildById('lucro'):setText("Lucro esperado: "..math.floor((preco)).." diamonds")
				vendWindow:recursiveGetChildById('imposto'):setText("Imposto: ".."10.000 dólares")
			else
			    vendWindow:recursiveGetChildById('precot'):setText("Preço total: "..preco.." dólares")
			    vendWindow:recursiveGetChildById('lucro'):setText("Lucro esperado: "..math.floor((preco)*0.95).." dólares")
				vendWindow:recursiveGetChildById('imposto'):setText("Imposto: "..(preco-math.floor((preco)*0.95)).." dólares")
			end
		else
		    if marketWindow:recursiveGetChildById('someoferta'):isChecked() then
			    vendWindow:recursiveGetChildById('precou'):setText("Preço unitário: "..tonumber(marketWindow:recursiveGetChildById('countText'):getText()).." diamonds")
			    vendWindow:recursiveGetChildById('precot'):setText("Preço total: "..preco*count.." diamonds")
			    vendWindow:recursiveGetChildById('lucro'):setText("Lucro esperado: "..math.floor((preco*count)).." diamonds")
				vendWindow:recursiveGetChildById('imposto'):setText("Imposto: ".."10.000 dólares")
			else
			    vendWindow:recursiveGetChildById('precot'):setText("Preço total: "..preco*count.." dólares")
			    vendWindow:recursiveGetChildById('lucro'):setText("Lucro esperado: "..math.floor((preco*count)*0.95).." dólares")
				vendWindow:recursiveGetChildById('imposto'):setText("Imposto: "..((preco*count)-math.floor((preco*count)*0.95)).." dólares")
			end
		
		end
			
        else
		    showMiniWindowDone("O preço do item deve ser acima de 0")
        end
end

function senditem(pos, stackpos, item, count)--enviar RequestSellMarket //BR
   local protocol = g_game.getProtocolGame()
   if protocol then  
        local msg = OutputMessage.create()
		msg:addU8(0xF3)
    	msg:addU8(0x1)
		msg:addPosition(pos)
		msg:addU16(item)
		msg:addU16(stackpos)
		protocol:send(msg)
   end
end


function onItemBoxChecked(widget)
    local item = widget.item
	if selectedItem then
	    selectedItem:setText("")
		
		if itemList["i"..selectedItem:getId()].inu % 2 == 0 then
		selectedItem:setImageSource("/images/ui/pxg1")
		else
		selectedItem:setImageSource("/images/ui/pxg0")
		end
	end
    
	widget:setImageSource("/images/ui/pxg")
	selectedItem = widget

	buttonobuyNow:setEnabled(true)
end

function buy()
   
	local item = selectedItem:getChildById('item')

	showConfimarWindowDone(tonumber(item:getItemId()), tonumber(item:getText()))
end





function setCount(value)
	marketWindow:recursiveGetChildById('slotved'):setText(tostring(value))
	marketWindow:recursiveGetChildById('countScrollBar'):setText(tostring(value))
end

function setPrice(text)
    if tonumber(text) and tonumber(text) > 0 then
		marketWindow:recursiveGetChildById('countText'):setText(tonumber(text))
		price = text
	end
	
    
    if text == "" then
        price = text
        marketWindow:recursiveGetChildById('countText'):setText("")
    else
        marketWindow:recursiveGetChildById('countText'):setText(price)
    end

   return
end

function onChooseItemMouseRelease(self, mousePosition, mouseButton)
    local item = nil
    if mouseButton == MouseLeftButton then
        local clickedWidget = modules.game_interface.getRootPanel():recursiveGetChildByPos(mousePosition, false)
        if clickedWidget then
            if clickedWidget:getClassName() == 'UIMap' then
                local tile = clickedWidget:getTile(mousePosition)
                if tile then
                    local thing = tile:getTopMoveThing()
                    if thing and thing:isItem() then
                        item = thing
			         
						
                    end
					show()

					g_mouse.popCursor('target')
					self:ungrabMouse()
					return
                end
            elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
                item = clickedWidget:getItem()
            end
        end
    end
  
    if item then	
        senditem(item:getPosition(), item:getStackPos(), item:getId(), item:getCount())
    end

    show()

    g_mouse.popCursor('target')
    self:ungrabMouse()
end

function startChooseItem()
  if g_ui.isMouseGrabbed() then return end
  mouseGrabberWidget:grabMouse()
  g_mouse.pushCursor('target')
  hide()
  marketWindow:recursiveGetChildById('slotved'):clearItem()
		marketWindow:recursiveGetChildById('countText'):setText("")
		
		marketWindow:recursiveGetChildById('countScrollBar'):setMinimum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setMaximum(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setValue(1)
        marketWindow:recursiveGetChildById('countScrollBar'):setText("")
end

function setCountConf(value)

	confimarWindow:recursiveGetChildById('slotconf'):setText(tostring(value))
	confimarWindow:recursiveGetChildById('countConfScrollBar'):setValue(tonumber(value))
    confimarWindow:recursiveGetChildById('countConfScrollBar'):setText(tostring(value)) -- tostring(tonumber(itemList["i"..selectedItem:getId()].price) * tonumber(value))
	if itemList["i"..selectedItem:getId()].stack == 1 then
	confimarWindow:recursiveGetChildById('textConf'):setText("Preço total: "..tostring(tonumber(itemList["i"..selectedItem:getId()].price)))
	else
	confimarWindow:recursiveGetChildById('textConf'):setText("Preço total: "..tostring(tonumber(itemList["i"..selectedItem:getId()].price) * tonumber(value)))
	end
	
end

function confimar()--//br comprar item
    local protocol = g_game.getProtocolGame()
    if protocol then  
        local msg = OutputMessage.create()
		msg:addU8(0xF3)
		msg:addU8(0x5)
		msg:addU16(selectedItem:getId())
		msg:addU16(confimarWindow:recursiveGetChildById('slotconf'):getText())
		
        protocol:send(msg)
   end
   hideConfimarWindowDone()
end

function showConfimarWindowDone(item, count)
    if confimarWindow == nil then
        confimarWindow = g_ui.displayUI('confimar')
    end
    confimarWindow:recursiveGetChildById('slotconf'):setItemId(tonumber(item))
	confimarWindow:recursiveGetChildById('slotconf'):setText(tostring(count))
    
    confimarWindow:recursiveGetChildById('countConfScrollBar'):setMaximum(count)
    
    confimarWindow:recursiveGetChildById('countConfScrollBar'):setText(tostring(1))
	if itemList["i"..selectedItem:getId()].stack == 1 then
	confimarWindow:recursiveGetChildById('textConf'):setText("Preço Total: "..itemList["i"..selectedItem:getId()].price)
	confimarWindow:recursiveGetChildById('countConfScrollBar'):setMinimum(count)
	confimarWindow:recursiveGetChildById('countConfScrollBar'):setEnabled(false)
	else
	confimarWindow:recursiveGetChildById('textConf'):setText("Preço Total: "..itemList["i"..selectedItem:getId()].price * 1)
	confimarWindow:recursiveGetChildById('slotconf'):setText(tostring(1))
	confimarWindow:recursiveGetChildById('countConfScrollBar'):setMinimum(1)
	confimarWindow:recursiveGetChildById('countConfScrollBar'):setValue(1)
	confimarWindow:recursiveGetChildById('countConfScrollBar'):setEnabled(true)
	end
    confimarWindow:setVisible(true)
    hide()
end

function hideConfimarWindowDone()
    confimarWindow:setVisible(false)
    show()
end

function showMiniWindowDone(text)
    if miniWindow ~= nil then
        miniWindow:destroy()
    end
        miniWindow = g_ui.displayUI('erro')
        miniWindow:recursiveGetChildById('textErro'):setText(text)
        miniWindow:setVisible(true)
end

function hideMiniWindowDone()
    miniWindow:recursiveGetChildById('textErro'):setText("")
    miniWindow:setVisible(false)
    miniWindow:destroy()
end
