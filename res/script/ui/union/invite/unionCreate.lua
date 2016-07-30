--
-- ui/union/unionCreate.lua
-- 创建工会
--===================================
require "ui/fullScreenFrame"

UI_unionCreate = class("UI_unionCreate", UI)

local tabID = 1
local titleID_ = {1806, 1827, 1828}
local imageList_ = {"3", "4", "5"}
local NAME_LEN = 8

--init
function UI_unionCreate:init()
	-- data
	-- ===============================
	self.image = 1
	self.label = {}
	self.tabIcon = {}

	self.uiTab = {}
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
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	self:addCCNode(self.wigetRoot)

	self:registMsg(hp.MSG.UNION_CHOOSE_ICON)

	self:setUnionIcon(self.image)
end

function UI_unionCreate:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "allianceCreate.json")
	local content_ = self.wigetRoot:getChildByName("Panel_5")
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
	self.colorSelected = self.label[1]:getColor()
	self.colorUnselected = self.label[2]:getColor()

	self.listView = self.wigetRoot:getChildByName("ListView_29885")

	-- 公会名称
	local content_ = self.listView:getChildByName("Panel_29886"):getChildByName("Panel_29900")
	-- 标题
	content_:getChildByName("Label_29901"):setString(hp.lang.getStrByID(1803))
	content_:getChildByName("Label_30030"):setString(hp.lang.getStrByID(1807))
	content_:getChildByName("Label_29921"):setString(hp.lang.getStrByID(1808))
	local searchingUnionName_ = content_:getChildByName("Label_7")
	self.inputText = hp.uiHelper.labelBind2EditBox(searchingUnionName_)
	self.inputText.setDefaultText(hp.lang.getStrByID(1255))
	self.inputText.setMaxLength(NAME_LEN)

	-- 选择工会图标
	local content_ = self.listView:getChildByName("Panel_29886_Copy0"):getChildByName("Panel_29900")
	-- 图标
	self.icon = content_:getChildByName("ImageView_29941"):getChildByName("ImageView_29942")
	self.icon:addTouchEventListener(self.onIconChooseTouched)
	-- 按钮
	local chooseIcon_ = content_:getChildByName("ImageView_29943")
	chooseIcon_:addTouchEventListener(self.onIconChooseTouched)
	chooseIcon_:getChildByName("Label_29944"):setString(hp.lang.getStrByID(1801))
	-- 标题
	content_:getChildByName("Label_29963"):setString(hp.lang.getStrByID(1804))

	-- 创建完成
	local content_ = self.listView:getChildByName("Panel_29886_Copy1"):getChildByName("Panel_29900")
	-- 标题
	content_:getChildByName("Label_29901"):setString(hp.lang.getStrByID(1805))
	-- 创建
	local confirm_ = content_:getChildByName("ImageView_29964")
	confirm_:getChildByName("Label_29965"):setString(hp.lang.getStrByID(1806))
	confirm_:addTouchEventListener(self.onCreateBtnTouched)
	-- 说明
	content_:getChildByName("Label_29921"):setString(hp.lang.getStrByID(1809))

	-- 签名	
	local content_ = self.listView:getChildByName("Panel_29886_Copy1_0"):getChildByName("Panel_29900")
	content_:getChildByName("Label_29901"):setString(hp.lang.getStrByID(5187))

	content_:getChildByName("Label_29921_0"):setString(hp.lang.getStrByID(5188))

	local label_ = content_:getChildByName("Label_29921")
	label_:setString(hp.lang.getStrByID(5121))
	self.desc = hp.uiHelper.labelBind2EditBox(label_)
	self.desc.setString(hp.lang.getStrByID(5121))
end

function UI_unionCreate:initCallBack()
	local function onIconChooseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/invite/unionIcon"
			local ui_ = UI_unionIcon:new()
			self:addUI(ui_)
		end
	end

	local function onCreateResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			local frist_ = player.getFristLeague()
			player.getAlliance():setUnionID(data.id)
			require "ui/union/unionMain"
			local ui_ = UI_unionMain.new()
			self:addUI(ui_)
			if frist_ == 0 then
				require "ui/union/invite/joinSuccess"
				local ui_ = UI_joinSuccess.new(frist_, true)
				self:addModalUI(ui_)
			else
				require "ui/common/successBox"
				local title_ = hp.lang.getStrByID(1810)
				local text_ = string.format(hp.lang.getStrByID(1811), self.inputText:getString())
				local box_ = UI_successBox.new(title_, text_)
				self:addModalUI(box_)
			end
			self:close()
		end
	end

	local function onCreateBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local name_ = self.inputText:getString()
			cclog_("string.len(name_)", string.len(name_), name_)
			if name_ == "" then
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5211), hp.lang.getStrByID(5212))
				self:addModalUI(box_)
			else
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 16
				oper.type = 1
				oper.img = tostring(self.image)
				oper.name = self.inputText:getString()
				oper.notice = self.desc.getString()
				cclog_("oper.noticeoper.noticeoper.noticeoper.notice",oper.notice)
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onCreateResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end
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
			if sender:getTag() == 2 then
				require "ui/union/invite/unionJoin"
				local ui_ = UI_unionJoin.new()
				cclog_("UI_unionJoin")
				self:addUI(ui_)
				self:close()
			elseif sender:getTag() == 3 then
				require "ui/union/invite/unionInvites"
				local ui_ = UI_unionInvites.new()
				self:addUI(ui_)
				self:close()
			end
		end
	end

	self.onIconChooseTouched = onIconChooseTouched
	self.onCreateBtnTouched = onCreateBtnTouched
	self.onTabTouched = onTabTouched
end

function UI_unionCreate:setUnionIcon(tag_)
	self.image = tag_
	self.icon:loadTexture(string.format("%s%d.png", config.dirUI.icon, tag_))
end

function UI_unionCreate:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_CHOOSE_ICON then
		self:setUnionIcon(param_)
	end
end