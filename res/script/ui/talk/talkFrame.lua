--
-- ui/talk/talkFrame.lua
-- 聊天
--===================================
require "ui/frame/popFrame"

UI_talkFrame = class("UI_talkFrame", UI)

local costMap = {5, 4, 6, 3, 2}
local timeOffset = 1800
local costOffSet = 0.4
local unitGoldCost = 5
local interval = 0

--init
function UI_talkFrame:init()
	-- data
	-- ===============================
	self.building = building_

	-- ui
	-- ===============================
	self:initCallBack()

	self:initUI()
	local popFrame = UI_popFrame.new(self.widgetRoot, "kzddd")

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.widgetRoot)
end

function UI_talkFrame:initCallBack()
	local function onResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result==0 then

		end
	end

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 99
			oper.type = self.text:getStringValue()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onClearTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.text:setText("")
		end
	end

	self.onClearTouched = onClearTouched
	self.onConfirmTouched = onConfirmTouched
end

function UI_talkFrame:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "talkFrame.json")
	local content = self.widgetRoot:getChildByName("Panel_23431")

	content:getChildByName("ImageView_23433"):addTouchEventListener(self.onClearTouched)
	content:getChildByName("ImageView_23434"):addTouchEventListener(self.onConfirmTouched)

	self.text = content:getChildByName("TextField_23435")
end