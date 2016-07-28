--
-- ui/bigMap/warning.lua
-- 警告
--===================================
require "ui/UI"


UI_warning = class("UI_warning", UI)


--init
function UI_warning:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================

	-- 初始化界面
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "warning.json")

	require "ui/frame/popFrame"
	local popFrame = UI_popFrame.new(self.wigetRoot, "提示")

	self.wigetRoot:getChildByName("Label_13933"):setString("你必须选择一支部队")

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end
