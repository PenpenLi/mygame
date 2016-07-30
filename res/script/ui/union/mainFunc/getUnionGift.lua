--
-- ui/union/mainFunc/getUnionGift.lua
-- 获取联盟礼包
--===================================
require "ui/fullScreenFrame"

-- 清除过期或已领取礼包
-- channel = 60
-- @type = 16
-- id = 0 全部清除
--===================================

UI_getUnionGift = class("UI_getUnionGift", UI)

local interval = 0

--init
function UI_getUnionGift:init()
	-- data
	-- ===============================
	self.receiveID = 0

	-- ui data
	self.uiItem = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(762)
	uiFrame:setTitle(hp.lang.getStrByID(5127))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	self:registMsg(hp.MSG.UNION_RECEIVE_GIFT)

	player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_getUnionGift")

	self:updateBaseInfo()
end

function UI_getUnionGift:initCallBack()
	local function onClearAllTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function onBaseInfoResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_getUnionGift")
					self:refreshShow()
				end
			end
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 60
			oper.id = 0
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	local function onReceiveTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function onBaseInfoResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					-- player.getAlliance():receiveGift(self.receiveID)
					player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_getUnionGift")
					self:updateBaseInfo()
					self:refreshShow()

					-- 弹框提示
					local str = "%s × %d "
					local info
					-- 奖励类型
					if data.type == 1 then
						-- 联盟积分
						info = string.format(str, hp.lang.getStrByID(5110), data.num)
					elseif data.type == 2 then
						-- 金币
						info = string.format(str, hp.lang.getStrByID(6018), data.num)
					elseif data.type == 3 then
						-- 道具
						info = string.format(str, hp.gameDataLoader.getInfoBySid("item", data.sid).name, data.num)
					end
					Scene.showMsg({4001, info})
				end
			end
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 54
			oper.id = sender:getTag()
			self.receiveID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	local function onClearTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then

			local function onBaseInfoResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					-- player.getAlliance():receiveGift(self.receiveID)
					player.getAlliance():prepareData(dirtyType.UNIONGIFT, "UI_getUnionGift")
					self:refreshShow()
				end
			end
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 60
			oper.id = sender:getTag()
			self.receiveID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	self.onReceiveTouched = onReceiveTouched
	self.onClearTouched = onClearTouched
	self.onClearAllTouched = onClearAllTouched
end

function UI_getUnionGift:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "getUnionGift.json")
	local content_ = self.widgetRoot:getChildByName("Panel_12")

	-- 礼包等级
	self.loadingBar = content_:getChildByName("ImageView_1644_0_0"):getChildByName("LoadingBar_1640")

	self.uiExp = content_:getChildByName("Label_1643")

	self.level = content_:getChildByName("Label_24")
	content_:getChildByName("Label_23"):setString(hp.lang.getStrByID(5080)..":")

	content_:getChildByName("Label_23_0"):setString(hp.lang.getStrByID(5077))

	self.listView = self.widgetRoot:getChildByName("ListView_26")
	self.item1 = self.listView:getItem(0):clone()
	self.item1:retain()
	self.item2 = self.listView:getItem(1):clone()
	self.item2:retain()
	self.listView:removeAllItems()
end

function UI_getUnionGift:refreshShow()
	self.listView:removeAllItems()
	self.uiItem = {}

	local gifts_ = player.getAlliance():getUnionGift()
	for i, v in pairs(gifts_) do
		local item_ = self.item1:clone()
		self.uiItem[i] = item_
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_35")
		-- 礼包信息
		local giftInfo_ = hp.gameDataLoader.getInfoBySid("unionGift", v.sid)
		-- 图片
		content_:getChildByName("Image_36"):loadTexture(string.format("%s%d.png", config.dirUI.unionGift, giftInfo_.type))
		-- 名称
		content_:getChildByName("Label_37"):setString(giftInfo_.name)
		-- 发放人
		content_:getChildByName("Label_nameText"):setString(hp.lang.getStrByID(8129))
		content_:getChildByName("Label_name"):setString(v.name)
		-- 领取按钮
		local get_ = content_:getChildByName("Image_40")
		get_:setTag(v.id)
		-- 不可领取
		if v.state == 0 or v.endTime < player.getServerTime() then
			get_:loadTexture(config.dirUI.common .. "button_red1.png")
			get_:getChildByName("Label_41"):setString(hp.lang.getStrByID(1218))
			get_:addTouchEventListener(self.onClearTouched)
			content_:getChildByName("Label_37_0"):setString(hp.lang.getStrByID(5215))
			if v.state == 0 then
				content_:getChildByName("Label_44"):setString(hp.lang.getStrByID(5464))
			else
				content_:getChildByName("Label_44"):setString(hp.lang.getStrByID(5463))
			end 
		else
			get_:getChildByName("Label_41"):setString(hp.lang.getStrByID(5079))
			get_:addTouchEventListener(self.onReceiveTouched)
			content_:getChildByName("Label_37_0"):setString(hp.lang.getStrByID(5083))
			local time = v.endTime - player.getServerTime()
			if time < 0 then
				time = 0
			end
			content_:getChildByName("Label_44"):setString(hp.datetime.strTime(time))
		end
	end
	local desc_ = self.item2:clone()
	content_ = desc_:getChildByName("Panel_43")
	content_:getChildByName("Label_45"):setString(hp.lang.getStrByID(5081))
	clearAll_ = desc_:getChildByName("Panel_47"):getChildByName("Image_44")
	content_:getChildByName("Label_46"):setString(hp.lang.getStrByID(5082))
	clearAll_:addTouchEventListener(self.onClearAllTouched)
	self.listView:pushBackCustomItem(desc_)
end

function UI_getUnionGift:updateBaseInfo()
	local unionBaseInfo_ = player.getAlliance():getBaseInfo()
	local levelInfo_ = hp.gameDataLoader.getInfoBySid("unionGiftlv", unionBaseInfo_.giftLevel)
	self.level:setString(unionBaseInfo_.giftLevel)
	self.uiExp:setString(string.format("%d/%d", unionBaseInfo_.giftCurLvExp, unionBaseInfo_.levelUpExp))
	local percent_ = unionBaseInfo_.giftCurLvExp / unionBaseInfo_.levelUpExp * 100
	self.loadingBar:setPercent(percent_)
end

function UI_getUnionGift:onRemove()
	self.item1:release()
	self.item2:release()
	player.getAlliance():unPrepareData(dirtyType.UNIONGIFT, "UI_getUnionGift")
	self.super.onRemove(self)
end

function UI_getUnionGift:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.UNIONGIFT then
			self:refreshShow()
		end
	elseif msg_ == hp.MSG.UNION_RECEIVE_GIFT then
		local index_ = self.listView:getIndex(self.uiItem[param_])
		self.listView:removeItem(index_)
		self.uiItem[param_] = nil
		self:updateBaseInfo()
	end
end

function UI_getUnionGift:tickTimeUpdate()
	local gifts_ = player.getAlliance():getUnionGift()
	for i, v in pairs(self.uiItem) do
		local content_ = v:getChildByName("Panel_35")
		local info_ = gifts_[i]
		if info_.state == 1 and info_.endTime > player.getServerTime() then
			local time = info_.endTime - player.getServerTime()
			if time < 0 then
				time = 0
			end
			content_:getChildByName("Label_44"):setString( hp.datetime.strTime(time))
		end
	end
end

function UI_getUnionGift:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:tickTimeUpdate()
end