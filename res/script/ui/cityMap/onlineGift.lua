--
-- ui/cityMap/onlineGift.lua
-- 在线礼包界面
--===================================


UI_onlineGift = class("UI_onlineGift", UI)


--init
function UI_onlineGift:init()
	-- data
	-- ===============================
	local onlineGift = player.onlineGift

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "onlineGift.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)


	--	logic
	-- ===============================
	local panelCont = widgetRoot:getChildByName("Panel_cont")
	local labelTitle = panelCont:getChildByName("BitmapLabel_text")
	local labelDesc = panelCont:getChildByName("Label_desc")
	local imgBox = panelCont:getChildByName("Image_box")
	local itemBg = imgBox:getChildByName("Image_itemBg")
	local itemIcon = itemBg:getChildByName("Image_item")
	local cdNode = panelCont:getChildByName("Image_cdBg")
	local labelCD = cdNode:getChildByName("Label_time")
	local labelItemInfo = panelCont:getChildByName("Label_itemInfo")
	local btnOper = panelCont:getChildByName("Image_oper")
	local labelOper = btnOper:getChildByName("Label_text")

	local function setInfo()
		local cd = onlineGift.getCD()
		if cd>0 then
			labelItemInfo:setVisible(false)
			itemBg:setVisible(false)
			cdNode:setVisible(true)
			labelTitle:setString(hp.lang.getStrByID(3801))
			labelDesc:setString(hp.lang.getStrByID(3802))
			labelOper:setString(hp.lang.getStrByID(1209))
			labelCD:setString(hp.datetime.strTime(cd))
			imgBox:loadTexture(config.dirUI.common .. "box_golden.png")
		else
			local sid = onlineGift.getItemSid()
			if sid>0 then
				local itemInfo = hp.gameDataLoader.getInfoBySid("item", sid)
				if itemInfo then
					cdNode:setVisible(false)
					labelItemInfo:setVisible(true)
					itemBg:setVisible(true)
					labelTitle:setString(hp.lang.getStrByID(3803))
					labelDesc:setString(hp.lang.getStrByID(3804))
					labelOper:setString(hp.lang.getStrByID(3805))
					labelItemInfo:setString(itemInfo.name .. " × 1")
					itemIcon:loadTexture(config.dirUI.item .. sid .. ".png")
					imgBox:loadTexture(config.dirUI.common .. "box_golden_opened.png")
				end
			end
		end
	end
	local function refreshCD()
		local cd = onlineGift.getCD()
		if cd>0 then
			labelCD:setString(hp.datetime.strTime(cd))
		end
	end
	setInfo()
	self.setInfo = setInfo
	self.refreshCD = refreshCD

	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				player.addItem(onlineGift.getItemSid(), 1)
				onlineGift.initByData(data.onlineGift)
			end
		end
		self:close()
	end
	local function onOperTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			sender:setTouchEnabled(false)
			if onlineGift.getCD()>0 then
				self:close()
			else
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 19
				oper.type = 1
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end
		end
	end
	btnOper:addTouchEventListener(onOperTouched)

	--
	-- registMsg
	self:registMsg(hp.MSG.ONLINE_GIFT)
end

-- onMsg
function UI_onlineGift:onMsg(msg_, param_)
	if msg_==hp.MSG.ONLINE_GIFT then
		self.setInfo()
	end
end

function UI_onlineGift:heartbeat(dt)
	self.refreshCD()
end