--
-- ui/bigMap/source/sourceInformation.lua
-- 资源信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_sourceInformation = class("UI_sourceInformation", UI)

--init
function UI_sourceInformation:init(tileInfo_)
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5182))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_sourceInformation:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "resouceInfo.json")
	local content = self.wigetRoot:getChildByName("Panel_1")

	-- 描述
	content:getChildByName("Label_2"):setString(hp.lang.getStrByID(5181))
end