--
-- ui/talk/talkBtn.lua
-- 聊天按钮
--===================================
require "ui/UI"


UI_talkBtn = class("UI_talkBtn", UI)


--init
function UI_talkBtn:init(ui_, title_, tileInfo_)
	-- data
	-- ===============================

	local function onButtonTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/talk/talkFrame"
			local ui_ = UI_talkFrame.new()
			self:addModalUI(ui_)
		end
	end

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "talkBtn.json")
	wigetRoot:getChildByName("Panel_23428"):getChildByName("ImageView_23429"):addTouchEventListener(onButtonTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end