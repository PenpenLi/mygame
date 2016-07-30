--
-- ui/union/shop/unionShopFunds.lua
-- 联盟商店基金说明
--===================================
require "ui/frame/popFrame"

UI_unionShopFunds = class("UI_unionShopFunds", UI)

--init
function UI_unionShopFunds:init()
	-- data
	-- ===============================

	-- call back

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5120))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_unionShopFunds:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopFunds.json")
	local content_ = self.wigetRoot:getChildByName("Panel_4")
	content_:getChildByName("Label_5"):setString(hp.lang.getStrByID(5414))
end