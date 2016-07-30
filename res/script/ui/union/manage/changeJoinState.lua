--
-- ui/union/changeJoinState.lua
-- 工会图标选择
--===================================
require "ui/fullScreenFrame"

UI_changeJoinState = class("UI_changeJoinState", UI)

--init
function UI_changeJoinState:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()
	self:changeSwitchState()
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5139))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	
end

function UI_changeJoinState:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "changeJoinState.json")
	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	local content_ = self.listView:getChildByName("Panel_29886"):getChildByName("Panel_29900")
	content_:getChildByName("Label_29901"):setText(hp.lang.getStrByID(1836))
	content_:getChildByName("Label_30030"):setText(hp.lang.getStrByID(1850))
	local bottom_ = content_:getChildByName("ImageView_33689")
	self.bottom_ = bottom_
	bottom_:addTouchEventListener(self.onSwitchTouched)
	self.button = bottom_:getChildByName("ImageView_33690")
end

function UI_changeJoinState:initCallBack()
	local function onSwitchResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if player.getAlliance():getBaseInfo().joinState == 1 then
				player.getAlliance():getBaseInfo().joinState = 0
			else
				player.getAlliance():getBaseInfo().joinState = 1
			end
			self:changeSwitchState()
		end
	end

	local function onSwitchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 11
			oper.param = player.getAlliance():getBaseInfo().joinState
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onSwitchResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	self.onSwitchTouched = onSwitchTouched
end

function UI_changeJoinState:changeSwitchState()
	local state_ = player.getAlliance():getBaseInfo().joinState
	local x_, y_ = 0
	if state_ == 0 then
		x_, y_ = self.bottom_:getChildByName("Panel_3"):getPosition()
	else
		x_, y_ = self.bottom_:getChildByName("Panel_2"):getPosition()		
	end
	self.button:setPosition(x_, y_)
end