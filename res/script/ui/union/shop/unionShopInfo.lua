--
-- ui/union/shop/unionShopInfo.lua
-- 公会商店更多信息
--===================================
require "ui/frame/popFrame"


UI_unionShopInfo = class("UI_unionShopInfo", UI)


--init
function UI_unionShopInfo:init()
	
	

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(7001))

	
	
	local ListView_info = wigetRoot:getChildByName("ListView_info")
	
	ListView_info:getChildByName("Panel_contU1"):
		getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(6403))
	
	ListView_info:getChildByName("Panel_contU2"):
		getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(6403))
	
	ListView_info:getChildByName("Panel_Tittle"):
		getChildByName("Panel_cont"):getChildByName("Label_name"):setString(hp.lang.getStrByID(7002))
	
	ListView_info:getChildByName("Panel_contD1"):
		getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(6403))
	
	ListView_info:getChildByName("Panel_contD2"):
		getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(6403))
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
