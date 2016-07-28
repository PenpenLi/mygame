--
-- ui/buildingDef.lua
-- 建筑缺省界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_buildingDef = class("UI_buildingDef", UI)


--init
function UI_buildingDef:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
end
