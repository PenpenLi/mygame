--
-- ui/chat/chatOper.lua
-- 聊天点击操作
--===================================
require "ui/frame/popFrame"


UI_chatOper = class("UI_chatOper", UI)


--init
function UI_chatOper:init(chatInfo_)
	-- data
	-- ===============================

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "chatOper.json")
	local uiFrame = UI_popFrame.new(wigetRoot)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	-- logic
	-- ===============================
	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btnCopy = contNode:getChildByName("Image_copy")
	local btnMore = contNode:getChildByName("Image_more")
	local btnCancle = contNode:getChildByName("Image_cancle")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnCopy then
			elseif sender==btnMore then
				require("ui/chat/chatOperMore")
				local ui = UI_chatOperMore.new(chatInfo_)
				self:close()
				self:addModalUI(ui)
			elseif sender==btnCancle then
				self:close()
			end
		end
	end
	btnCopy:addTouchEventListener(onBtnTouched)
	btnMore:addTouchEventListener(onBtnTouched)
	btnCancle:addTouchEventListener(onBtnTouched)

	btnCopy:getChildByName("Label_text"):setString(hp.lang.getStrByID(3602))
	btnMore:getChildByName("Label_text"):setString(chatInfo_.srcName)
	btnMore:getChildByName("Image_headIcon"):loadTexture(config.dirUI.heroHeadpic .. chatInfo_.srcIcon .. ".png")
	btnCancle:getChildByName("Label_text"):setString(hp.lang.getStrByID(2412))
end
