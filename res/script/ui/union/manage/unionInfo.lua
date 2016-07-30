--
-- ui/union/manage/unionInfo.lua
-- 公会信息
--===================================
require "ui/fullScreenFrame"

UI_unionInfo = class("UI_unionInfo", UI)

--init
function UI_unionInfo:init(id_, url_)
	-- data
	-- ===============================
	self.id = id_
	self.url = url_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5407))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)	

	self:requestDataFromOtherServer()
end

function UI_unionInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionInfo.json")
	local back_ = self.wigetRoot:getChildByName("Panel_2")
	back_:getChildByName("Image_47"):addTouchEventListener(self.onMemberTouched)
	back_:getChildByName("Image_47_0"):addTouchEventListener(self.onPropertyTouched)
	back_:getChildByName("Image_47_1"):addTouchEventListener(self.onChairmanTouched)

	local content_ = self.wigetRoot:getChildByName("Panel_30")

	-- 公会基本信息
	-- 会长
	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(1812))
	self.leaderName = content_:getChildByName("Label_31_0")

	-- 公会力量
	content_:getChildByName("Label_31_1"):setString(hp.lang.getStrByID(1813))
	self.power = content_:getChildByName("Label_31_0_1")

	-- 成员数量
	content_:getChildByName("Label_31_2"):setString(hp.lang.getStrByID(1814))
	self.memberNum = content_:getChildByName("Label_31_0_2")

	-- 工会图标
	self.unionIcon = content_:getChildByName("Image_40")

	-- 公会名
	self.unionName = content_:getChildByName("Label_43")

	-- 公会留言
	self.msgParent = back_:getChildByName("Image_51")
	self.unionMessage = content_:getChildByName("Label_43_0")
	content_:removeChild(self.unionMessage)

	self.rollLabel = hp.uiHelper.bindRollLabel(self.unionMessage, content_, self.msgParent)

	-- 礼包等级
	self.giftLevel = content_:getChildByName("Label_46")

	content_:getChildByName("Label_52"):setString(hp.lang.getStrByID(5408))

	content_:getChildByName("Label_52_0"):setString(hp.lang.getStrByID(5409))

	content_:getChildByName("Label_52_1"):setString(hp.lang.getStrByID(5410))

	-- 公告信息
	content_:getChildByName("Label_56"):setString(hp.lang.getStrByID(5411))

	self.notice = content_:getChildByName("Label_57")

	-- 编辑
	local editBtn_ = content_:getChildByName("Image_15")
	editBtn_:addTouchEventListener(self.onEditAnnounceTouched)

	-- 权限判断
	if player.getAlliance():haveAuthority("changeAnnounce") then
		editBtn_:setVisible(true)
		editBtn_:setTouchEnabled(true)
	end
end

function UI_unionInfo:refreshShow()
	self.leaderName:setString(self.unionInfo.chairman)
	self.power:setString(self.unionInfo.power)
	self.memberNum:setString(self.unionInfo.number)
	self.unionIcon:loadTexture(config.dirUI.icon..self.unionInfo.icon..".png")
	self.unionName:setString(self.unionInfo.name)
	self.unionMessage:setString(self.unionInfo.notice)
	self.giftLevel:setString(string.format(hp.lang.getStrByID(1826), self.unionInfo.giftLevel))
	self.notice:setString(self.unionInfo.announce)
end

function UI_unionInfo:requestDataFromOtherServer()
	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.members = Alliance.parseMemberList(data.member)
			self.unionInfo = Alliance.parseUnionInfo(data.league[1])
			self:refreshShow()
		end
	end

	local cmdData={}
	cmdData.type = 8
	cmdData.id = self.id
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, self.url)
	self:showLoading(cmdSender)
end

function UI_unionInfo:requestMemList()
	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.members = Alliance.parseMemberList(data.member)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 57
	oper.id = self.id
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionInfo:requestData()
	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.unionInfo = Alliance.parseUnionInfo(data.league[1])
			self:refreshShow()
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 26
	oper.id = self.id
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionInfo:initCallBack()
	local function onMemberTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.members ~= nil then
				require "ui/union/manage/normalMemberList"
				ui_ = UI_normalMemberList.new(self.members)
				self:addUI(ui_)
			end
		end
	end	

	local function onPropertyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.members ~= nil then
				require "ui/union/manage/unionInfoProp"
				local ui_ = UI_unionInfoProp.new(self.id, self.members, self.url)
				self:addUI(ui_)
			end
		end
	end	

	local function onChairmanTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mail/writeMail"
			local ui_ = UI_writeMail.new(self.unionInfo.chairman)
			self:addUI(ui_)
		end
	end

	local function onEditAnnounceTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function callBack(text_)
				self.unionInfo.announce = text_
				self.notice:setString(text_)
			end

			require "ui/union/manage/changeUnionAnnounce"
			local ui_ = UI_changeUnionAnnounce.new(self.unionInfo.announce, callBack)
			self:addModalUI(ui_)
		end
	end

	self.onMemberTouched = onMemberTouched
	self.onPropertyTouched = onPropertyTouched
	self.onChairmanTouched = onChairmanTouched
	self.onEditAnnounceTouched = onEditAnnounceTouched
end

function UI_unionInfo:onMsg(msg_, param_)
end