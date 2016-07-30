--
-- ui/common/foodUseDlg.lua
-- 消息框
--===================================
require "ui/frame/popFrame"


UI_foodUseDlg = class("UI_foodUseDlg", UI)


--init
function UI_foodUseDlg:init()
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "foodUseDlg.json")
	local popFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(10501))

	wigetRoot:getChildByName("Panel_cont"):getChildByName("Label_desc"):setString(hp.lang.getStrByID(10502))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(wigetRoot)
end
