--
-- ui/union/manageFellow.lua
-- 管理公会成员
--===================================
require "ui/frame/popFrame"

UI_manageFellow = class("UI_manageFellow", UI)

local interval = 0
local totalItem = 50

--init
function UI_manageFellow:init(id_)
	-- data
	-- ===============================
	self.id = id_
	self.member = player.getAlliance():getMemberByLocalID(self.id)

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5130))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	self:initAutority()
end

function UI_manageFellow:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "manageMember.json")

	local content_ = self.wigetRoot:getChildByName("Panel_2")
	-- 职位
	local rank_ = self.member:getRank()
	local info_ = hp.gameDataLoader.getInfoBySid("unionRank", rank_)
	content_:getChildByName("Image_11"):loadTexture(config.dirUI.common..info_.image)
	-- 名字
	content_:getChildByName("Label_3"):setString(self.member:getName())

	local gift_ = content_:getChildByName("Image_4")
	gift_:addTouchEventListener(self.onGiftTouched)
	gift_:getChildByName("Label_9"):setString(hp.lang.getStrByID(1869))

	local message_ = content_:getChildByName("Image_4_0")
	message_:addTouchEventListener(self.onMessageTouched)
	message_:getChildByName("Label_10"):setString(hp.lang.getStrByID(1870))

	local promote_ = content_:getChildByName("Image_4_1")
	promote_:addTouchEventListener(self.onPromoteTouched)
	promote_:getChildByName("Label_11"):setString(hp.lang.getStrByID(1871))
	self.promote = promote_

	local kick_ = content_:getChildByName("Image_4_2")
	kick_:addTouchEventListener(self.onKickTouched)
	kick_:getChildByName("Label_12"):setString(hp.lang.getStrByID(1872))
	self.kick = kick_
end

function UI_manageFellow:initAutority()
	local myRank_ = player.getAlliance():getMyUnionInfo():getRank()
	cclog_(self.member:getRank())
	cclog_(myRank_)
	local authority_ = hp.gameDataLoader.getInfoBySid("allienceRank", myRank_)
	if authority_.promote == 1 then
		if myRank_ > self.member:getRank() then
			self.promote:setTouchEnabled(true)
			self.promote:loadTexture(config.dirUI.common.."button_blue.png")
		end
	end

	if authority_.kick == 1 then
		if myRank_ > self.member:getRank() then
			self.kick:setTouchEnabled(true)
			self.kick:loadTexture(config.dirUI.common.."button_red.png")
		end
	end
end

function UI_manageFellow:initCallBack()
	-- 送礼
	local function onGiftTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.member:getID())
			self:addUI(ui_)
			self:close()
		end
	end

	-- 消息
	local function onMessageTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mail/writeMail"
			ui_ = UI_writeMail.new(self.member:getName())
			self:addUI(ui_)
			self:close()
		end
	end

	-- 升级
	local function onPromoteTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/member/memberPromote"
			cclog_("++++++++++++++_--")
			local ui_ = UI_memberPromote.new(self.member:getID())
			self:addModalUI(ui_)
		end
	end

	local function onKickConfirmTouched(sender, eventType)
		local function onKickResponse(status, response, tag)
			if status ~= 200 then
				return
			end

			local data = hp.httpParse(response)
			if data.result == 0 then
				Scene.showMsg({1012})
				self:close()
			end
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 16
		oper.type = 6
		oper.id = self.member:getID()
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onKickResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender, sender)
	end

	-- 踢出
	local function onKickTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/msgBox/msgBox"
			ui_ = UI_msgBox.new(hp.lang.getStrByID(5210), string.format(hp.lang.getStrByID(1179), self.member:getName()), hp.lang.getStrByID(1209),
				hp.lang.getStrByID(2412), onKickConfirmTouched)
			self:addModalUI(ui_)
		end
	end

	self.onGiftTouched = onGiftTouched
	self.onMessageTouched = onMessageTouched
	self.onPromoteTouched = onPromoteTouched
	self.onKickTouched = onKickTouched
end