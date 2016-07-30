--
-- ui/union/disbandUnion.lua
-- 解散工会
--===================================
require "ui/frame/popFrame"
require "ui/frame/popFrameRed"

UI_disbandUnion = class("UI_disbandUnion", UI)

--init
function UI_disbandUnion:init(tab_)
	-- data
	-- ===============================

	-- ui data

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrameRed.new(self.wigetRoot, hp.lang.getStrByID(1884))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_disbandUnion:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "leaveUnion.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")

	content_:getChildByName("Label_1"):setString(hp.lang.getStrByID(1890))
	content_:getChildByName("Label_1_0"):setString(hp.lang.getStrByID(1891))
	content_:getChildByName("Label_1_0_1"):setString(hp.lang.getStrByID(1892))

	local leave_ = content_:getChildByName("Image_10")
	leave_:getChildByName("Label_11"):setString(hp.lang.getStrByID(1840))
	leave_:addTouchEventListener(self.onDisbandTouched)
end

function UI_disbandUnion:initCallBack()
	local function onDisbandResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.getAlliance():setUnionID(0)
			self:closeAll()
			require "ui/common/successBox"
			local ui_ = UI_successBox.new(hp.lang.getStrByID(5019), hp.lang.getStrByID(1895))
			game.curScene:addModalUI(ui_)
		end
	end

	local function onConfirm2Touched(sender, eventType)
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 16
		oper.type = 5
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onDisbandResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender, sender)
	end

	local function onConfirm1Touched(sender, eventType)
		require "ui/msgBox/msgBox"
		local ui_ = UI_msgBox.new(hp.lang.getStrByID(5019), hp.lang.getStrByID(1894), hp.lang.getStrByID(1209),
			hp.lang.getStrByID(2412), onConfirm2Touched, nil, "red")
		self:addModalUI(ui_)
	end

	-- 离开
	local function onDisbandTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/msgBox/msgBox"
			local ui_ = UI_msgBox.new(hp.lang.getStrByID(5019), hp.lang.getStrByID(1893), hp.lang.getStrByID(1209),
				hp.lang.getStrByID(2412), onConfirm1Touched, nil, "red")
			self:addModalUI(ui_)
		end
	end	

	self.onDisbandTouched = onDisbandTouched
end

function UI_disbandUnion:onRemove()
	self.super.onRemove(self)
end