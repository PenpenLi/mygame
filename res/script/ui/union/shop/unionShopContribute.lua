--
-- ui/union/shop/unionShopContribute.lua
-- 联盟商店贡献说明
--===================================
require "ui/frame/popFrame"

UI_unionShopContribute = class("UI_unionShopContribute", UI)

--init
function UI_unionShopContribute:init()
	-- data
	-- ===============================

	-- call back

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5110))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_unionShopContribute:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopContribute.json")
	local content_ = self.wigetRoot:getChildByName("Panel_4")
	content_:getChildByName("Label_5"):setString(hp.lang.getStrByID(5412))

	content_:getChildByName("Label_5_0"):setString(hp.lang.getStrByID(5413))

	content_:getChildByName("Label_10"):setString(hp.lang.getStrByID(5128))
end