--
-- ui/union/unionInvites.lua
-- 工会邀请和请求
--===================================
require "ui/fullScreenFrame"

UI_unionInvites = class("UI_unionInvites", UI)

local tabID = 3
local titleID_ = {1806, 1827, 1828}
local imageList_ = {"3", "4", "5"}

--init
function UI_unionInvites:init()
	-- data
	-- ===============================
	self.defaultPage = 1
	self.label = {}
	self.tabIcon = {}
	self.tab = {}

	self.chooseID = 0
	self.index = 1
	self.idMap = {}
	self.itemMap = {}

	self.uiTab = {}
	self.rollLabel = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(1800))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.top)
	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self:tabPage(self.defaultPage)
end

function UI_unionInvites:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionInvites.json")

	local content_ = self.wigetRoot:getChildByName("Panel_29874")
	for i = 1, 3 do
		self.uiTab[i] = content_:getChildByName("ImageView_801"..imageList_[i])
		self.label[i] = self.uiTab[i]:getChildByName("Label_"..tostring(i))
		self.label[i]:setString(hp.lang.getStrByID(titleID_[i]))
		self.tabIcon[i] = self.uiTab[i]:getChildByName("ImageView_"..tostring(i))		
		if tabID ~= i then
			self.uiTab[i]:setTag(i)
			self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		end
	end
	self.colorSelected = self.label[3]:getColor()
	self.colorUnselected = self.label[1]:getColor()

	self.tab[1] = content_:getChildByName("ImageView_30314")
	self.tab[1]:setTag(1)
	self.tab[1]:getChildByName("Label_30316"):setString(hp.lang.getStrByID(1843))
	self.tab[1]:addTouchEventListener(self.onSmallTabTouched)
	self.tab[2] = content_:getChildByName("ImageView_30314_Copy0")
	self.tab[2]:setTag(2)
	self.tab[2]:getChildByName("Label_30316"):setString(hp.lang.getStrByID(1828))
	self.tab[2]:addTouchEventListener(self.onSmallTabTouched)

	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	self.top = self.listView:getItem(0):clone()
	self.top:retain()
	self.item1 = self.listView:getItem(1):clone()
	self.item1:retain()
	self.item2 = self.listView:getItem(2):clone()
	self.item2:retain()
	self.listView:removeAllItems()
	self.listView:setClippingType(1)
end

function UI_unionInvites:tabPage(id_)
	self.rollLabel = {}
	self.listView:removeAllItems()

	if id_ == 1 then
		self.tab[1]:setColor(self.colorSelected)
		self.tab[1]:getChildByName("Label_30316"):setColor(self.colorSelected)
		self.tab[2]:setColor(self.colorUnselected)
		self.tab[2]:getChildByName("Label_30316"):setColor(self.colorUnselected)
		self:requestSent()
	else
		self.tab[1]:setColor(self.colorUnselected)
		self.tab[1]:getChildByName("Label_30316"):setColor(self.colorUnselected)
		self.tab[2]:setColor(self.colorSelected)
		self.tab[2]:getChildByName("Label_30316"):setColor(self.colorSelected)
		self:requestInvites()
	end
end

function UI_unionInvites:requestSent()
	local function onApplyResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:refreshPage1(data.member)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 21
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onApplyResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_unionInvites:requestInvites()
	local function onInvitesResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:refreshPage2(data.league)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 22
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onInvitesResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_unionInvites:refreshPage1(info_)
	if info_ == nil then
		return
	end

	if table.getn(info_) ~= 0 then
		local top_ = self.top:clone()
		self.listView:pushBackCustomItem(top_)
	end

	self.index = 1
	self.idMap = {}
	self.itemMap = {}

	self.rollLabel = {}
	for i, v in ipairs(info_) do
		local item_ = self.item1:clone()
		local content_ = item_:getChildByName("Panel_30331")
		local union_ = Alliance.parseUnionInfo(v)
		content_:getChildByName("Label_30334"):setString(v.name)
		content_:getChildByName("ImageView_30335"):getChildByName("ImageView_30336"):loadTexture(string.format("%s%s.png", config.dirUI.icon, union_.icon))
		content_:getChildByName("Label_30337"):setString(union_.chairMan)

		-- notice
		local labelBg_ = item_:getChildByName("Panel_30324"):getChildByName("ImageView_30332")
		local label_ = content_:getChildByName("Label_30338")
		content_:removeChild(label_)
		label_:setString(union_.notice)
		self.rollLabel[i] = hp.uiHelper.bindRollLabel(label_, content_, labelBg_)

		content_:getChildByName("Label_30341"):setString(string.format("%d/100", union_.number))
		content_:getChildByName("Label_30341_Copy0"):setString(union_.power)
		content_:getChildByName("Label_30341_Copy1"):setString(string.format(hp.lang.getStrByID(1826), union_.giftLevel))
		content_:getChildByName("Label_30341_Copy2"):setString(tostring(union_.kill))
		-- 查看
		local view_ = content_:getChildByName("ImageView_30345")
		view_:addTouchEventListener(self.onViewTouched)
		view_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1316))
		view_:setTag(self.index)
		-- 删除
		local delete_ = content_:getChildByName("ImageView_30345_Copy0")
		delete_:addTouchEventListener(self.onDeleteTouched)
		delete_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1848))
		delete_:setTag(self.index)
		self.listView:pushBackCustomItem(item_)

		self.idMap[self.index] = union_.id
		self.itemMap[self.index] = item_
		self.index = self.index + 1
	end
end

function UI_unionInvites:refreshPage2(info_)
	if info_ == nil then
		return
	end

	if table.getn(info_) ~= 0 then
		local top_ = self.top:clone()
		self.listView:pushBackCustomItem(top_)
	end

	self.index = 1
	self.idMap = {}
	self.itemMap = {}

	self.rollLabel = {}
	for i, v in ipairs(info_) do
		local item_ = self.item2:clone()
		local content_ = item_:getChildByName("Panel_30331")
		local union_ = Alliance.parseUnionInfo(v)
		content_:getChildByName("Label_30334"):setString(v.name)
		content_:getChildByName("ImageView_30335"):getChildByName("ImageView_30336"):loadTexture(string.format("%s%s.png", config.dirUI.icon, union_.icon))
		content_:getChildByName("Label_30337"):setString(union_.chairMan)

		-- notice
		local labelBg_ = item_:getChildByName("Panel_30324"):getChildByName("ImageView_30332")
		local label_ = content_:getChildByName("Label_30338")
		content_:removeChild(label_)
		label_:setString(union_.notice)
		self.rollLabel[i] = hp.uiHelper.bindRollLabel(label_, content_, labelBg_)

		content_:getChildByName("Label_30341"):setString(string.format("%d/100", union_.number))
		content_:getChildByName("Label_30341_Copy0"):setString(union_.power)
		content_:getChildByName("Label_30341_Copy1"):setString(string.format(hp.lang.getStrByID(1826), union_.giftLevel))
		content_:getChildByName("Label_30341_Copy2"):setString(tostring(union_.kill))
		-- 查看
		local view_ = content_:getChildByName("ImageView_30345")
		view_:addTouchEventListener(self.onViewTouched)
		view_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1316))
		view_:setTag(self.index)
		-- 加入
		local join_ = content_:getChildByName("ImageView_30345_Copy1")
		join_:addTouchEventListener(self.onJoinTouched)
		join_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1827))
		join_:setTag(self.index)
		-- 拒绝
		local delete_ = content_:getChildByName("ImageView_30345_Copy0")
		delete_:addTouchEventListener(self.onRefuseTouched)
		delete_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1851))
		delete_:setTag(self.index)
		self.listView:pushBackCustomItem(item_)

		self.idMap[self.index] = union_.id
		self.itemMap[self.index] = item_
		self.index = self.index + 1
	end
end

function UI_unionInvites:removeItem()
	self.listView:removeChild(self.itemMap[self.chooseID])
end

function UI_unionInvites:initCallBack()
	-- 查看公会
	local function onViewTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
		end
	end

	-- 加入
	local function onAgreeResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if data.id ~= nil then
				player.getAlliance():setUnionID(data.id)
			end
			require "ui/union/unionMain"
			local uiMain_ = UI_unionMain.new()
			self:addUI(uiMain_)
			require "ui/union/invite/joinSuccess"
			local ui_ = UI_joinSuccess.new()
			self:addModalUI(ui_)
			player.clearFristLeague()
			hp.msgCenter.sendMsg(hp.MSG.UNION_JOIN_SUCCESS)
			self:close()
		end
	end

	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 18
			oper.id = self.idMap[sender:getTag()]
			self.chooseID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onAgreeResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	-- 删除
	local function onDeleteResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:removeItem()
		end
	end

	local function onDeleteTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 36
			oper.id = self.idMap[sender:getTag()]
			self.chooseID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onDeleteResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	-- 拒绝
	local function onRefuseResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:removeItem()
		end
	end

	local function onRefuseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 35
			oper.id = self.idMap[sender:getTag()]
			self.chooseID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onRefuseResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onTabTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.label[sender:getTag()]:setColor(self.colorSelected)
			self.tabIcon[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.label[sender:getTag()]:setColor(self.colorSelected)
				self.tabIcon[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.label[sender:getTag()]:setColor(self.colorUnselected)
				self.tabIcon[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			if sender:getTag() == 1 then
				require "ui/union/invite/unionCreate"
				ui_ = UI_unionCreate.new()
				self:addUI(ui_)
				self:close()
			elseif sender:getTag() == 2 then
				require "ui/union/invite/unionJoin"
				ui_ = UI_unionJoin.new()
				self:addUI(ui_)
				self:close()
			end
		end
	end

	local function onSmallTabTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.tab[sender:getTag()]:getChildByName("Label_30316"):setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.tab[sender:getTag()]:getChildByName("Label_30316"):setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.tab[sender:getTag()]:getChildByName("Label_30316"):setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabPage(sender:getTag())
		end
	end

	self.onTabTouched = onTabTouched
	self.onSmallTabTouched = onSmallTabTouched
	self.onViewTouched = onViewTouched
	self.onJoinTouched = onJoinTouched
	self.onDeleteTouched = onDeleteTouched
	self.onRefuseTouched = onRefuseTouched
end

function UI_unionInvites:onMsg(msg_, param_)
end

function UI_unionInvites:close()
	self.top:release()
	self.item1:release()
	self.item2:release()
	self.super.close(self)
end

function UI_unionInvites:heartbeat(dt_)
	for i, v in ipairs(self.rollLabel) do
		v.labelRoll(dt_)
	end
end