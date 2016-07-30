--
-- ui/march/goldMarchHint.lua
-- 采集资源提示
--===================================
require "ui/UI"

UI_goldMarchHint = class("UI_goldMarchHint", UI)

--init
function UI_goldMarchHint:init()
	-- data
	-- ===============================

	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	-- addCCNode
	-- ===============================
	self:addCCNode(self.widgetRoot)
end

function UI_goldMarchHint:initCallBack()
	local function onProceedTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function onNeverPopTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			player.setGatherGoldHint(1)
			self:close()
		end
	end

	self.onNeverPopTouched = onNeverPopTouched
	self.onProceedTouched = onProceedTouched
end

function UI_goldMarchHint:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "goldMarchHint.json")
	local content_ = self.widgetRoot:getChildByName("Panel_3")

	-- 说明
	content_:getChildByName("Label_6"):setString(hp.lang.getStrByID(5503))

	local proceed_ = content_:getChildByName("Image_7_0")
	proceed_:getChildByName("Label_8"):setString(hp.lang.getStrByID(5504))
	proceed_:addTouchEventListener(self.onProceedTouched)

	local neverPop_ = content_:getChildByName("Image_7")
	neverPop_:getChildByName("Label_8"):setString(hp.lang.getStrByID(5505))
	neverPop_:addTouchEventListener(self.onNeverPopTouched)
end