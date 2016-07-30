--
-- ui/union/leaveUnion.lua
-- 离开工会
--===================================
require "ui/frame/popFrame"
require "ui/frame/popFrameRed"

UI_leaveUnion = class("UI_leaveUnion", UI)

--init
function UI_leaveUnion:init(tab_)
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

function UI_leaveUnion:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "leaveUnion.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")

	content_:getChildByName("Label_1"):setString(hp.lang.getStrByID(1880))
	content_:getChildByName("Label_1_0"):setString(hp.lang.getStrByID(1881))
	content_:getChildByName("Label_1_0_1"):setString(hp.lang.getStrByID(1882))

	local leave_ = content_:getChildByName("Image_10")
	leave_:getChildByName("Label_11"):setString(hp.lang.getStrByID(1841))
	leave_:addTouchEventListener(self.onLeaveTouched)
end

function UI_leaveUnion:initCallBack()
	local function onExitResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:closeAll()
			player.getAlliance():setUnionID(0)
			require "ui/common/successBox"
			local ui_ = UI_successBox.new(hp.lang.getStrByID(1841), hp.lang.getStrByID(1889))
			game.curScene:addModalUI(ui_)
		end
	end

	local function onConfirm2Touched(sender, eventType)
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 16
		oper.type = 4
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onExitResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender, sender)
	end

	local function onConfirm1Touched(sender, eventType)
		require "ui/msgBox/msgBox"
		local ui_ = UI_msgBox.new(hp.lang.getStrByID(1841), hp.lang.getStrByID(1887), hp.lang.getStrByID(1841),
			hp.lang.getStrByID(2412), onConfirm2Touched, nil, "red")
		self:addModalUI(ui_)
	end

	-- 离开
	local function onLeaveTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/msgBox/msgBox"
			local ui_ = UI_msgBox.new(hp.lang.getStrByID(1841), hp.lang.getStrByID(1886), hp.lang.getStrByID(1841),
				hp.lang.getStrByID(2412), onConfirm1Touched, nil, "red")
			self:addModalUI(ui_)
		end
	end	

	self.onLeaveTouched = onLeaveTouched
end

function UI_leaveUnion:onRemove()
	self.super.onRemove(self)
end