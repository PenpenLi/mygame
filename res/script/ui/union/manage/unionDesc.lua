--
-- ui/union/unionDesc.lua
-- 公会战细节
--===================================
require "ui/fullScreenFrame"

UI_unionDesc = class("UI_unionDesc", UI)

--init
function UI_unionDesc:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5138))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_unionDesc:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionDesc.json")

	local content_ = self.wigetRoot:getChildByName("Panel_29")
	content_:getChildByName("Label_30"):setString(hp.lang.getStrByID(1189))
	-- 字数
	self.wordNum = content_:getChildByName("Label_30_0")
	-- 输入框
	local desc_ = content_:getChildByName("Label_30_1")
	desc_:setString(player.getAlliance():getBaseInfo().message)
	self.descEdit = hp.uiHelper.labelBind2EditBox(desc_)

	self.wigetRoot:getChildByName("Panel_15291_0"):getChildByName("Image_26"):addTouchEventListener(self.onCancelTouched)
	self.wigetRoot:getChildByName("Panel_15291_0"):getChildByName("Image_26_0"):addTouchEventListener(self.onUpdateTouched)
	content_:getChildByName("Label_37"):setString(hp.lang.getStrByID(2412))

	content_:getChildByName("Label_37_0"):setString(hp.lang.getStrByID(1190))
end

function UI_unionDesc:initCallBack()
	-- 切换到城市
	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function onUpdateResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			-- 发通知
			self:close()
		end
	end

	-- 查看玩家信息
	local function onUpdateTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 12
			oper.msg = self.descEdit.getString()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onUpdateResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	self.onCancelTouched = onCancelTouched
	self.onUpdateTouched = onUpdateTouched
end