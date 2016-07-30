--
-- ui/mainBuildingInfo.lua
-- 主建筑更多信息
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_mainBuildingInfo = class("UI_mainBuildingInfo", UI)


--init
function UI_mainBuildingInfo:init(building_)
	
	local bInfo = building_.bInfo
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainBuildingInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, bInfo.name)

	
	
	local ListView_info = wigetRoot:getChildByName("ListView_info")
	
	local moreInfo = ListView_info:getChildByName("Panel_desc"):getChildByName("Panel_cont"):getChildByName("Label_moreInfo")
	moreInfo:setString(bInfo.moreDesc)
	
	
	--
	
	local head = ListView_info:getChildByName("Panel_tittle")
	local item1 = ListView_info:getChildByName("Panel_item1")
	local item2 = ListView_info:getChildByName("Panel_item2")
	local itemTittle = ListView_info:getChildByName("Panel_itemTittle")
	local selected = ListView_info:getChildByName("Panel_selected"):clone()
	
	local tittleCont = head:getChildByName("Panel_cont")
	local item1Cont = item1:getChildByName("Panel_cont")
	local itemTittleCont = itemTittle:getChildByName("Panel_cont")
	
	--tittle
	tittleCont:getChildByName("Label_head"):setString(string.format(hp.lang.getStrByID(6101) , hp.lang.getStrByID(6801)))
	
	--head
	itemTittleCont:getChildByName("Label_level"):setString( hp.lang.getStrByID(1039) )
	itemTittleCont:getChildByName("Label_col"):setString( hp.lang.getStrByID(6802) )
	itemTittleCont:getChildByName("Label_col_0"):setString( hp.lang.getStrByID(6803) )
	itemTittleCont:getChildByName("Label_col_1"):setString( hp.lang.getStrByID(6804) )
	
	
	
	--remove selected item
	ListView_info:removeItem(5)
	
	local ContItemSize = 3
	
	local firstUseItem1 = true
	local firstUseItem2 = true
	
	
	--避免第一个和第二个未clone的直接赋值而意外改变顺序
	local tmp = 1
	
	
	--item
	for i,info in ipairs(game.data.main) do
		
		
		local item = nil
		
		if building_.build.lv == i  then
			item = selected
			if building_.build.lv % 2 == 1 then 
				tmp = 0
			else
				tmp = 1
			end
			
		elseif i % 2 == tmp then
			
			
			if firstUseItem1 then
				item = item1
				firstUseItem1 = false
			else
				item = item1:clone()
			end
		
		
		else
		
			if firstUseItem2 then
				item = item2
				firstUseItem2 = false
				
			else
				item = item2:clone()
			end
			
			
		end
		
		local itemCont = item:getChildByName("Panel_cont")
		
		itemCont:getChildByName("Label_level"):setString(info.level)
		
		itemCont:getChildByName("Label_col"):setString(info.soldierMax)
		itemCont:getChildByName("Label_col_0"):setString(info.troopMax)
		itemCont:getChildByName("Label_col_1"):setString(info.helpMeCount)
		
		if item ~= item1 and item ~= item2 then
			ListView_info:insertCustomItem(item,ContItemSize)
		end
		
		ContItemSize = ContItemSize + 1
		
	
		
	end
	
	
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
