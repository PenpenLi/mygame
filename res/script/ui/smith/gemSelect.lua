--
-- ui/smith/gemSelect.lua
-- 宝石选择界面
--===================================
require "ui/frame/popFrame"

UI_gemSelect = class("UI_gemSelect", UI)

--init
function UI_gemSelect:init(equip_, pos_, embedGemCallback_)
	-- data
	-- ===============================
	local equip = equip_
	local pos = pos_
	local selectNode = nil
	local selectGemSid = 0

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "gemSelect.json")
	local uiFrame = UI_popFrame.new(widgetRoot, hp.lang.getStrByID(3508))
	

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)

	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--镶嵌成功
				equip.gems[pos_] = selectGemSid
				player.expendItem(selectGemSid, 1)
				if embedGemCallback_~=nil then
					embedGemCallback_()
				end
				self:close()
			end
		end
	end
	--
	local isEmbeding = false
	local function embed()
		isEmbeding = true
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 7
		oper.type = 6
		oper.id = equip_.id
		oper.loc = pos-1
		oper.sid = selectGemSid
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
	end
	-- desc
	local contNode = widgetRoot:getChildByName("Panel_cont")
	local attrText = contNode:getChildByName("Label_attr")
	local btnEmbed = contNode:getChildByName("Image_embed")
	local txtEmbed = contNode:getChildByName("Label_embed")
	local btnClose = contNode:getChildByName("Image_close")
	local txtClose = contNode:getChildByName("Label_close")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnClose then
				self:close()
			elseif sender==btnEmbed then
				--
				sender:setTouchEnabled(false)
				embed()
			end
		end
	end
	btnEmbed:addTouchEventListener(onBtnTouched)
	btnClose:addTouchEventListener(onBtnTouched)
	attrText:setString(hp.lang.getStrByID(3510))
	txtEmbed:setString(hp.lang.getStrByID(3505))
	txtClose:setString(hp.lang.getStrByID(3509))

	local function setGemInfo()
		if selectGemSid>0 then
			local gemInfo = hp.gameDataLoader.getInfoBySid("gem", selectGemSid)
			local infoText = gemInfo.name
			for i,v in ipairs(gemInfo.key) do
				local attrInfo = hp.gameDataLoader.getInfoBySid("attr", v)
				infoText = infoText .. "\n" .. attrInfo.desc .. ": +"..(gemInfo.value[i]/100).."%"
			end
			attrText:setString(infoText)
		end
	end

	--list
	local function selectGem(nodeBg)
		if selectNode~=nil then
			selectNode:setVisible(false)
		else
			btnEmbed:loadTexture(config.dirUI.common .. "button_green.png")
			btnEmbed:setTouchEnabled(true)
		end
		selectNode = nodeBg:getParent():getChildByName("Image_check")
		selectNode:setVisible(true)
		selectGemSid = nodeBg:getTag()
		setGemInfo()
	end
	local function onGemTouched(sender, eventType)
		if isEmbeding then
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			selectGem(sender)
		end
	end
	local listNode = widgetRoot:getChildByName("ListView_gem")
	local lineNode = listNode:getChildByName("Panel_line")
	local lineModel = lineNode:clone()
	local itemBgModel = widgetRoot:getChildByName("Panel_itemFrame")
	local itemModel = widgetRoot:getChildByName("Panel_itemCont")
	local itemNum = 0
	local lineNum = 5
	local maxColorLv = 6
	local itemSz = itemBgModel:getSize()
	for i=maxColorLv, 1, -1 do
		for j, gemInfo in ipairs(game.data.gem) do
			if i==gemInfo.level then
				local gemNum = player.getItemNum(gemInfo.sid)
				if gemNum>0 then
					local lineIndex = itemNum%lineNum
					if lineIndex==0 and itemNum>0 then
						lineNode = lineModel:clone()
						listNode:pushBackCustomItem(lineNode)
					end
					itemNum = itemNum+1

					local px = lineIndex*itemSz.width
					local itemNode = itemModel:clone()
					local itemBg = itemBgModel:clone()
					lineNode:addChild(itemBg)
					itemBg:setPosition(px, 0)
					lineNode:addChild(itemNode)
					itemNode:setPosition(px, 0)

					local gemBg = itemBg:getChildByName("Image_bg")
					local gemImg = itemNode:getChildByName("Image_gem")
					gemBg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, gemInfo.level))
					gemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, gemInfo.sid))
					itemNode:getChildByName("Label_num"):setString(gemNum)
					gemBg:setTag(gemInfo.sid)
					gemBg:addTouchEventListener(onGemTouched)
				end
			end
		end
	end
end
