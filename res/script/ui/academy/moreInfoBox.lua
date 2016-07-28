--
-- ui/academy/moreInfoBox
-- ��Ժ������Ϣ
--===================================
require "ui/frame/popFrame"


UI_moreInfoBox = class("UI_moreInfoBox", UI)


--init
function UI_moreInfoBox:init(building_)
	
	local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "academyInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, bInfo.name)

	local contNode = wigetRoot:getChildByName("ListView_info"):getChildByName("Panel_cont")
	local moreInfo = contNode:getChildByName("Label_moreInfo")
	moreInfo:setString(bInfo.moreDesc)
	
	local ListView_info = wigetRoot:getChildByName("ListView_info")
	
	
	local tittleCont = ListView_info:getChildByName("Panel_tittle"):getChildByName("Panel_cont")
	local item1Cont = ListView_info:getChildByName("Panel_item1"):getChildByName("Panel_cont")
	local item2Cont = ListView_info:getChildByName("Panel_item2"):getChildByName("Panel_cont")
	local selectedCont = ListView_info:getChildByName("Panel_selected"):getChildByName("Panel_cont")
	
	tittleCont:getChildByName("Label_head"):setString(string.format( hp.lang.getStrByID(6101),hp.lang.getStrByID(1161) ))
	item1Cont:getChildByName("Label_level"):setString(hp.lang.getStrByID(1039))
	item1Cont:getChildByName("Label_speed"):setString(hp.lang.getStrByID(6102))
	
	
	local item2 = ListView_info:getChildByName("Panel_item2"):clone()
	local selected = ListView_info:getChildByName("Panel_selected"):clone()
	
	ListView_info:removeLastItem()
	ListView_info:removeLastItem()
	
	
	
	for i,info in ipairs(game.data.academy) do
	
		-- info.level
		-- info.speedRate
		
		local item = nil
		
		if building_.build.lv == i then
			item = selected:clone()
		elseif i % 2 == 0 then
			item = ListView_info:getChildByName("Panel_item1"):clone()
		else
			item = item2:clone()
		end
		
		local itemCont = item:getChildByName("Panel_cont")
		
		itemCont:getChildByName("Label_level"):setString(info.level .. "")
		itemCont:getChildByName("Label_speed"):setString(info.speedRate .. "%")
		
		ListView_info:pushBackCustomItem(item)
		
	end
	
	
	
	
	
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end