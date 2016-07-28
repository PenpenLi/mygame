--
-- ui/smith/craftingInfo
-- 合成更多信息
--===================================
require "ui/frame/popFrame"


UI_craftingInfo = class("UI_craftingInfo", UI)


--init
function UI_craftingInfo:init(building_)
	
	--local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "craftingInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(6901))

	
	
	local ListView_info = wigetRoot:getChildByName("ListView_info")
	
	local contNode = ListView_info:getChildByName("Panel_cont")
	local moreInfo = contNode:getChildByName("Panel_cont"):getChildByName("Label_moreInfo")
	moreInfo:setString(hp.lang.getStrByID(6902))
	
	
	
	
	ListView_info:getChildByName("Panel_coloritem"):getChildByName("Panel_cont"):
		getChildByName("Label_name"):setString(hp.lang.getStrByID(6903))
	
	ListView_info:getChildByName("Panel_coloritem_1"):getChildByName("Panel_cont"):
		getChildByName("Label_name"):setString(hp.lang.getStrByID(6904))
	
	ListView_info:getChildByName("Panel_coloritem_2"):getChildByName("Panel_cont"):
		getChildByName("Label_name"):setString(hp.lang.getStrByID(6905))
	
	ListView_info:getChildByName("Panel_coloritem_3"):getChildByName("Panel_cont"):
		getChildByName("Label_name"):setString(hp.lang.getStrByID(6906))
	
	ListView_info:getChildByName("Panel_coloritem_4"):getChildByName("Panel_cont"):
		getChildByName("Label_name"):setString(hp.lang.getStrByID(6907))
	
	ListView_info:getChildByName("Panel_coloritem_5"):getChildByName("Panel_cont"):
		getChildByName("Label_name"):setString(hp.lang.getStrByID(6908))
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
