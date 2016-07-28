--
-- ui/union/unionJoin.lua
-- 加入公会
--===================================
require "ui/fullScreenFrame"
require "obj/alliance/unionManager"

UI_unionJoin = class("unionJoin", UI)

local resNumber = 10
local showNumber = 3
local tabID = 2
local titleID_ = {1806, 1827, 1828}
local imageList_ = {"3", "4", "5"}

--init
function UI_unionJoin:init()
	-- data
	-- ===============================
	self.label = {}
	self.tabIcon = {}
	self.type = 1	-- 获取数据类型，0-开头十个，1-前十个，2-后十个
	self.dataType = 1 -- 1-所有联盟信息 2-搜索的联盟信息
	self.showType = 1
	self.dataManager = {}
	self.dataManager[1] = UnionManager.new()
	self.dataManager[2] = UnionManager.new()
	self.dataManager[1]:setInterval(showNumber)
	self.dataManager[2]:setInterval(showNumber)

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

	hp.uiHelper.uiAdaption(self.uiItem)

	self:requestData(0)
end

function UI_unionJoin:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionJoin.json")

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
	self.colorSelected = self.label[2]:getColor()
	self.colorUnselected = self.label[1]:getColor()

	content_:getChildByName("ImageView_32950"):addTouchEventListener(self.onChangePageTouched)
	content_:getChildByName("ImageView_32950_Copy0"):addTouchEventListener(self.onChangePageTouched)
	content_:getChildByName("ImageView_32950_Copy1"):addTouchEventListener(self.onChangePageTouched)
	content_:getChildByName("ImageView_32950_Copy2"):addTouchEventListener(self.onChangePageTouched)

	self.inputText = hp.uiHelper.labelBind2EditBox(content_:getChildByName("Label_8"))
	self.inputText.setDefaultText(hp.lang.getStrByID(1255))
	self.inputText.setOnChangedHandle(self.onSearchTextChange)

	self.uiSearch = content_:getChildByName("ImageView_32844")
	self.uiSearch:getChildByName("Label_32845"):setString(hp.lang.getStrByID(1846))
	self.uiSearch:addTouchEventListener(self.onSearchTouched)

	self.uiPage = content_:getChildByName("Label_32958")

	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	self.uiItem = self.listView:getChildByName("Panel_30322_Copy1"):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
	self.listView:setClippingType(1)
end

-- 添加一个公会到列表
function UI_unionJoin:addOneUnion(v, index_)
	local item_ = self.uiItem:clone()
	local content_ = item_:getChildByName("Panel_30331")
	-- 头像
	content_:getChildByName("ImageView_30335"):getChildByName("ImageView_30336"):loadTexture(string.format("%s%s.png", config.dirUI.icon, v.icon))
	-- 会长
	content_:getChildByName("Label_30337"):setString(hp.lang.getStrByID(1812)..":"..v.chairMan)
	-- 联盟名称
	content_:getChildByName("Label_30334"):setString(v.name)
	-- 公告
	local labelBg_ = item_:getChildByName("Panel_30324"):getChildByName("ImageView_30332")
	local label_ = content_:getChildByName("Label_30338")
	content_:removeChild(label_)
	label_:setString(v.notice)
	self.rollLabel[index_] = hp.uiHelper.bindRollLabel(label_, content_, labelBg_)

	-- 成员
	content_:getChildByName("Label_30341"):setString(string.format("%d/100", v.number))
	-- 战力
	content_:getChildByName("Label_30341_Copy0"):setString(tostring(v.power))
	-- 礼物等级
	content_:getChildByName("Label_30341_Copy1"):setString(string.format(hp.lang.getStrByID(1826), v.giftLevel))
	-- 杀敌
	content_:getChildByName("Label_30341_Copy2"):setString(string.format(hp.lang.getStrByID(1842), v.kill))
	-- 查看
	local view_ = content_:getChildByName("ImageView_30345")
	view_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1316))
	view_:addTouchEventListener(self.onViewTouched)
	view_:setTag(v.index)
	-- 加入
	local join_ = content_:getChildByName("ImageView_30345_Copy0")
	join_:setTag(v.index)
	join_:addTouchEventListener(self.onJoinTouched)
	if v.join == 0 then
		join_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1827))
	else
		join_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1843))
	end
	self.listView:pushBackCustomItem(item_)
end

function UI_unionJoin:refreshShow()
	self.listView:removeAllItems()
	local list_ = self.dataManager[self.showType]:getData(self.type)
	if list_ == nil then
		if self.showType == 1 then
			self:requestData(self.dataManager[1]:getLastID())
			return
		end
	end
	
	self.rollLabel = {}
	for i, v in ipairs(list_) do
		self:addOneUnion(v, i)
	end
	self.uiPage:setString(self.dataManager[self.showType]:getCurPage())
end

function UI_unionJoin:dealUnionData(data_)
	for i, v in ipairs(data_) do
		local data_ = Alliance.parseUnionInfo(v)
		self.dataManager[self.dataType]:insertUnion(data_)
	end

	if table.getn(data_) < resNumber then
		self.dataManager[self.dataType]:setAllData(true)
	end
end

function UI_unionJoin:requestData(id_)
	local function onDataResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.dataType = 1
			
			self:dealUnionData(data.league)

			self:refreshShow()
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 25
	oper.id = string.format("%.0f", id_)
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onDataResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_unionJoin:initCallBack()
	local function onChangePageTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.type = sender:getTag()
			self:refreshShow()
			print(sender:getTag())
		end
	end

	local function onJoinResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if data.id ~= nil then
				player.getAlliance():setUnionID(data.id)
			end

			if tag == 0 then
				require "ui/union/unionMain"
				local uiMain_ = UI_unionMain.new()
				self:addUI(uiMain_)
				require "ui/union/invite/joinSuccess"
				local ui_ = UI_joinSuccess.new()
				self:addModalUI(ui_)
				player.clearFristLeague()
				hp.msgCenter.sendMsg(hp.MSG.UNION_JOIN_SUCCESS)
				self:close()
			elseif tag == 1 then
				require "ui/common/successBox"
				ui_ = UI_successBox.new(hp.lang.getStrByID(1888), hp.lang.getStrByID(5116))
				self:addModalUI(ui_)
			end			
		end
	end 

	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local union_ = self.dataManager[self.showType]:getUnionInfoByIndex(sender:getTag())
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 2
			oper.id = string.format("%.0f", union_.id)
			self.id = union_.id
			cmdData.operation[1] = oper
			local tag_ = 1
			if union_.join == 0 then
				tag_ = 0
			end
			local cmdSender = hp.httpCmdSender.new(onJoinResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
		end
	end
	
	local function onViewTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	local function onSearchTextChange(string_)
		if string_ == "" then
			self.showType = 1
			self.type = 1
			self:refreshShow()
		end
	end	
	
	local function onSearchResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.dataType = 2
			self.type = 1
			
			self:dealUnionData(data.league)			
		end
		self:refreshShow()
	end 

	local function onSearchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.inputText.getString() == "" then
				return
			end
			self.showType = 2
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 24
			oper.name = self.inputText.getString()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onSearchResponse)
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
			elseif sender:getTag() == 3 then
				require "ui/union/invite/unionInvites"
				ui_ = UI_unionInvites.new()
				self:addUI(ui_)
				self:close()
			end
		end
	end

	self.onTabTouched = onTabTouched
	self.onChangePageTouched = onChangePageTouched
	self.onJoinTouched = onJoinTouched
	self.onViewTouched = onViewTouched
	self.onSearchTouched = onSearchTouched
	self.onSearchTextChange = onSearchTextChange
end

function UI_unionJoin:onMsg(msg_, param_)
end

function UI_unionJoin:close()
	self.uiItem:release()
	self.super.close(self)
end

function UI_unionJoin:heartbeat(dt_)
	for i, v in ipairs(self.rollLabel) do
		v.labelRoll(dt_)
	end
end