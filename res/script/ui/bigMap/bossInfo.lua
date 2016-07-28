--
-- ui/bigMap/bossInfo.lua
-- boss信息界面 
--===================================
require "ui/UI"

UI_bossInfo = class("UI_bossInfo", UI)

--init
function UI_bossInfo:init(bossInfo_)
	-- data
	-- ===============================
	self.bossInfo = bossInfo_

	-- ui
	-- ===============================
	self:initUI()

	-- call back
	local function onCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	self.closeBtn:addTouchEventListener(onCloseTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)
end

function UI_bossInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bossInfo.json")
	local content_ = self.wigetRoot:getChildByName("Panel_4")
	self.closeBtn = content_:getChildByName("Image_16")
end