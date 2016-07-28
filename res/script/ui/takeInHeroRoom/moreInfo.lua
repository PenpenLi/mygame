--
-- ui/msgBox/msgBox.lua
-- ÏûÏ¢¿ò
--===================================
require "ui/frame/popFrame"


UI_moreInfoBox = class("UI_moreInfoBox", UI)


--init
function UI_moreInfoBox:init(bInfo)
	

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "moreInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, bInfo.name)

	local contNode = wigetRoot:getChildByName("Panel_cont")
	local moreInfo = contNode:getChildByName("Label_moreInfo")
	moreInfo:setString(bInfo.moreDesc)
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
