--
-- ui/bigMap/tips.lua
-- 规则信息
--===================================
require "ui/UI"


UI_tips = class("UI_tips", UI)


--init
function UI_tips:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "tips.json")

	-- 初始化界面
	self.wigetRoot:getChildByName("Label_8007"):setString("sjdfihqoiwehroiqjwerij")

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1214))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end
