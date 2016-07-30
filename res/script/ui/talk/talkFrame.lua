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
			oper.type = self.text:getString()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onClearTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.text.setString("")
		end
	end

	local function onSecretTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/goldShop/goldShop"
			local ui_ = UI_goldShop.new()
			self:addUI(ui_)
		end
	end

	self.onClearTouched = onClearTouched
	self.onConfirmTouched = onConfirmTouched
	self.onSecretTouched = onSecretTouched
end

function UI_talkFrame:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "talkFrame.json")
	local content = self.widgetRoot:getChildByName("Panel_23431")

	content:getChildByName("ImageView_23433"):addTouchEventListener(self.onClearTouched)
	content:getChildByName("ImageView_23434"):addTouchEventListener(self.onConfirmTouched)
	content:getChildByName("Image_32"):addTouchEventListener(self.onSecretTouched)

	self.loadingBar = content:getChildByName("ProgressBar_4")

	local label_ = content:getChildByName("Label_15")
	self.text = hp.uiHelper.labelBind2EditBox(label_)

	-- 体力
	local energe_ = player.getEnerge()
	if energe_ == nil then
		energe_ = 0
	end
	content:getChildByName("Label_16"):setString("体力:"..energe_)
end