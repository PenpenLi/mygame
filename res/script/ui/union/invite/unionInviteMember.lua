--
-- ui/union/unionInviteMember.lua
-- 邀请成员
--===================================
require "ui/fullScreenFrame"

UI_unionInviteMember = class("UI_unionInviteMember", UI)

--init
function UI_unionInviteMember:init(page_)
	-- data
	-- ===============================
	self.pageInit = {false, false, false}
	self.tab = 1
	if page_ == nil then
		self.defaultPage = 1
	else
		self.defaultPage = page_
	end
	self.chooseID = 0	-- 选择的成员本地id
	self.idMap = {}
	self.index = 1
	self.itemMap = {}

	-- ui data
	self.uiTab = {}
	self.uiTabText = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUIBase()

	local uiFrame = UI_fullScreenFrame.new()
	self.uiFrame = uiFrame
	uiFrame:hideTopBackground()
	uiFrame:setTitle(hp.lang.getStrByID(5133))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	self.sizeSelected = self.uiTab[1]:getScale()
	self.sizeUnselected = self.uiTab[2]:getScale()

	self:tabPage(self.defaultPage)
end

function UI_unionInviteMember:initUIBase()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionInviteMember.json")
	local content_ = self.wigetRoot:getChildByName("Panel_17")
	local idList_ = {1828, 1843, 1847}
	for i = 1, 3 do
		self.uiTab[i] = content_:getChildByName("ImageView_801"..(i + 2))
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		self.uiTabText[i] = self.uiTab[i]:getChildByName("Label_29877")
		self.uiTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
	end

	self.colorSelected = self.uiTab[1]:getColor()
	self.colorUnselected = self.uiTab[2]:getColor()
end

function UI_unionInviteMember:initPage(id_)
	if id_ == 1 then
		self:initPage1()
	elseif id_ == 2 then
		self:initPage2()
	elseif id_ == 3 then
		self:initPage3()
	end
end

function UI_unionInviteMember:tabPage(id_)
	if self.pageInit[id_] == false then
		self:initPage(id_)
	end

	local zorder_ = {0, 0, 0}
	local visible_ = {false, false, false}
	local scale_ = {self.sizeUnselected, self.sizeUnselected, self.sizeUnselected}
	local color_ = {self.colorUnselected, self.colorUnselected, self.colorUnselected}
	zorder_[id_] = 1
	visible_[id_] = true
	scale_[id_] = self.sizeSelected
	color_[id_] = self.colorSelected

	if self.pageInit[1] == true then
		self.content:setLocalZOrder(zorder_[1])
		self.listView1:setLocalZOrder(zorder_[1])
		self.content:setVisible(visible_[1])
		self.listView1:setVisible(visible_[1])
		self.back1:setVisible(visible_[1])
	end

	if self.pageInit[2] == true then
		self.listView2:setLocalZOrder(zorder_[2])
		self.listView2:setVisible(visible_[2])
	end

	if self.pageInit[3] == true then
		self.listView3:setLocalZOrder(zorder_[3])
		self.listView3:setVisible(visible_[3])
	end

	for i = 1, 3 do
		self.uiTab[i]:setColor(color_[i])
		self.uiTab[i]:setScale(scale_[i])
		self.uiTabText[i]:setColor(color_[i])
	end

	self.tab = id_
	if id_ == 1 then
		self.uiFrame:setTopShadePosY(740)
	elseif id_ == 2 then
		self:requestApplicant()
		self.uiFrame:setTopShadePosY(830)
	elseif id_ == 3 then
		self:requestSentInvites()
		self.uiFrame:setTopShadePosY(830)
	end
end

function UI_unionInviteMember:requestApplicant()
	local function onApplicantResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:refreshPage2(data.member)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 30
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onApplicantResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionInviteMember:requestSentInvites()
	local function onInviteResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:refreshPage3(data.member)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 29
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onInviteResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionInviteMember:initPage1()
	self.back1 = self.wigetRoot:getChildByName("Panel_33413")
	local content_ = self.wigetRoot:getChildByName("Panel_33443")
	self.content = content_
	self.search = content_:getChildByName("ImageView_32844_Copy0")
	self.search:getChildByName("Label_32845"):setString(hp.lang.getStrByID(1846))
	self.search:addTouchEventListener(self.onSearchTouched)
	local inputLabel_ = content_:getChildByName("TextField_32843_Copy0")
	self.searchText = hp.uiHelper.labelBind2EditBox(inputLabel_)
	content_:getChildByName("Label_79"):setString(hp.lang.getStrByID(5403))

	self.listView1 = self.wigetRoot:getChildByName("ListView_30172")
	self.item1 = self.listView1:getChildByName("Panel_30177"):clone()
	self.item1:retain()
	self.listView1:removeAllItems()

	self.pageInit[1] = true
end

function UI_unionInviteMember:initPage2()
	self.listView2 = self.wigetRoot:getChildByName("ListView_30172_Copy0")
	self.item2 = self.listView2:getChildByName("Panel_30177"):clone()
	self.item2:retain()
	self.listView2:removeAllItems()
	self.pageInit[2] = true
end

function UI_unionInviteMember:initPage3()
	self.listView3 = self.wigetRoot:getChildByName("ListView_30172_Copy1")
	self.item3 = self.listView3:getChildByName("Panel_30177"):clone()
	self.item3:retain()
	self.listView3:removeAllItems()
	self.pageInit[3] = true
end

function UI_unionInviteMember:initCallBack()
	-- 查看玩家信息
	local function onViewTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	-- 切换标签
	local function onTabTouched(sender, eventType)
		if self.tab == sender:getTag() then
			return
		end
		
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.uiTabText[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabPage(sender:getTag())
		end
	end

	-- 搜索玩家
	local function onSearchResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:refreshPage1(data)
		else
			self:refreshPage1(nil)
		end
	end

	local function onSearchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 23
			oper.name = self.searchText:getString()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onSearchResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	-- 邀请玩家
	local function onInviteResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			local item_ = self.listView1:getItem(0)
			local button_ = item_:getChildByName("Panel_30185"):getChildByName("ImageView_30186")
			button_:loadTexture(config.dirUI.common.."button_gray.png")
			button_:setTouchEnabled(false)
			Scene.showMsg({1011})
		end
	end

	local function onInviteTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 17
			oper.id = self.idMap[sender:getTag()]
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onInviteResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	-- 同意加入
	local function onAgreeResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			cclog_("player joined")
			self:removeItem(2)
		end
	end

	local function onAgreeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 3
			oper.id = self.idMap[sender:getTag()]
			self.chooseID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onAgreeResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	-- 拒绝加入
	local function onRefuseResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			cclog_("player refuse")
			self:removeItem(2)
		end
	end

	local function onRefuseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 33
			oper.id = self.idMap[sender:getTag()]
			self.chooseID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onRefuseResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	-- 删除邀请
	local function onDeleteResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			cclog_("inviete delete")
			self:removeItem(3)
		end
	end

	local function onDeleteTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 34
			oper.id = self.idMap[sender:getTag()]
			self.chooseID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onDeleteResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	local function onPlayerHeadTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.idMap[sender:getTag()])
			self:addUI(ui_)
		end
	end

	self.onTabTouched = onTabTouched
	self.onChangePageTouched = onChangePageTouched
	self.onSearchTouched = onSearchTouched
	self.onInviteTouched = onInviteTouched
	self.onAgreeTouched = onAgreeTouched
	self.onRefuseTouched = onRefuseTouched
	self.onDeleteTouched = onDeleteTouched
	self.onPlayerHeadTouched = onPlayerHeadTouched
end

function UI_unionInviteMember:removeItem(type_)
	local listView_ = nil
	if type_ == 1 then
		listView_ = self.listView1
	elseif type_ == 2 then
		listView_ = self.listView2
	elseif type_ == 3 then
		listView_ = self.listView3
	end

	listView_:removeChild(self.itemMap[self.chooseID])
end

function UI_unionInviteMember:onMsg(msg_, param_)
end

function UI_unionInviteMember:onRemove()
	if self.pageInit[1] == true then
		self.item1:release()
	elseif self.pageInit[2] == true then
		self.item2:release()
	elseif self.pageInit[3] == true then
		self.item3:release()
	end
	self.super.onRemove(self)
end

function UI_unionInviteMember:refreshPage1(info_)
	self.listView1:removeAllItems()
	if info_ == nil then
		return
	end

	self.idMap = {}
	self.itemMap = {}
	self.index = 1
	local item_ = self.item1:clone()
	self.listView1:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_30185")

	self.idMap = {string.format("%.0f", info_.id)}
	self.itemMap = {item_}
	-- 邀请
	local invite_ = content_:getChildByName("ImageView_30186")
	invite_:getChildByName("Label_33412"):setString(hp.lang.getStrByID(1828))
	if info_.league ~= nil then
		invite_:setTouchEnabled(false)
		invite_:loadTexture(config.dirUI.common.."button_gray.png")
	else		
		invite_:addTouchEventListener(self.onInviteTouched)
		invite_:setTag(self.index)
	end

	-- 名称
	content_:getChildByName("Label_30190"):setString(info_.name)
	-- 头像
	local head_ = content_:getChildByName("ImageView_9383")
	head_:setTag(self.index)
	head_:addTouchEventListener(self.onPlayerHeadTouched)
	head_:loadTexture(config.dirUI.heroHeadpic..info_.img..".png")
	-- 签名
	content_:getChildByName("ImageView_30191"):getChildByName("Label_30192"):setString(info_.msg)
	-- 战力
	content_:getChildByName("Label_30194"):setString(info_.power)
	-- 杀敌
	content_:getChildByName("Label_30195"):setString(string.format(hp.lang.getStrByID(1842),info_.num))
end

function UI_unionInviteMember:refreshPage2(info_)
	self.listView2:removeAllItems()
	if info_ == nil then
		return
	end

	self.idMap = {}
	self.itemMap = {}
	self.index = 1
	for i, v in ipairs(info_) do
		local item_ = self.item2:clone()
		self.listView2:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_30185")
		local member_ = Alliance.parsePlayerInfo(v)
		-- 名称
		content_:getChildByName("Label_30190"):setString(member_.name)
		-- 头像
		local head_ = content_:getChildByName("ImageView_9383")
		head_:setTag(self.index)
		head_:addTouchEventListener(self.onPlayerHeadTouched)
		head_:loadTexture(config.dirUI.heroHeadpic..member_.icon..".png")
		-- 签名
		content_:getChildByName("ImageView_30191"):getChildByName("Label_30192"):setString(member_.sign)
		-- 战力
		content_:getChildByName("Label_30194"):setString(member_.power)
		-- 杀敌
		content_:getChildByName("Label_30195"):setString(string.format(hp.lang.getStrByID(1842),member_.kill))
		-- 拒绝
		local view_ = content_:getChildByName("ImageView_30186")
		view_:getChildByName("Label_33412"):setString(hp.lang.getStrByID(1851))
		view_:addTouchEventListener(self.onRefuseTouched)
		view_:setTag(self.index)
		-- 同意
		local agree_ = content_:getChildByName("ImageView_30186_Copy0")
		agree_:getChildByName("Label_33412"):setString(hp.lang.getStrByID(1852))
		agree_:addTouchEventListener(self.onAgreeTouched)		
		agree_:setTag(self.index)
		self.idMap[self.index] = member_.id
		self.itemMap[self.index] = item_
		self.index = self.index + 1
	end	
end

function UI_unionInviteMember:refreshPage3(info_)
	self.listView3:removeAllItems()
	if info_ == nil then
		return
	end

	self.idMap = {}
	self.itemMap = {}
	self.index = 1
	for i, v in ipairs(info_) do
		local item_ = self.item3:clone()
		self.listView3:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_30185")
		local member_ = Alliance.parsePlayerInfo(v)
		-- 名称
		content_:getChildByName("Label_30190"):setString(member_.name)
		-- 头像
		local head_ = content_:getChildByName("ImageView_9383")
		head_:setTag(self.index)
		head_:addTouchEventListener(self.onPlayerHeadTouched)
		head_:loadTexture(config.dirUI.heroHeadpic..member_.icon..".png")
		-- 签名
		content_:getChildByName("ImageView_30191"):getChildByName("Label_30192"):setString(member_.sign)
		-- 战力
		content_:getChildByName("Label_30194"):setString(member_.power)
		-- 杀敌
		content_:getChildByName("Label_30195"):setString(string.format(hp.lang.getStrByID(1842),member_.kill))
		-- 删除
		local delete_ = content_:getChildByName("ImageView_30186")
		delete_:getChildByName("Label_33412"):setString(hp.lang.getStrByID(1848))
		delete_:addTouchEventListener(self.onDeleteTouched)
		delete_:setTag(self.index)

		self.idMap[self.index] = member_.id
		self.itemMap[self.index] = item_
		self.index = self.index + 1
	end
end