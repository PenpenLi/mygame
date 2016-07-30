--
-- ui/productionBuildingInfo.lua
-- 生成建筑更多信息界面
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_productionBuildingInfo = class("UI_productionBuildingInfo", UI)


--init
function UI_productionBuildingInfo:init(building_)
	
	local b = building_.build
	local bInfo = building_.bInfo
	local upInfo = building_.upInfo
	local resInfo = nil
	local resType = nil
	for i,v in ipairs(game.data.res) do
		if b.sid==v.buildsid and b.lv==v.level then
			resInfo = v
			break
		end
	end
	resType = game.data.resType[resInfo.type+1]

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "ziyuanInfo.json")
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
	tittleCont:getChildByName("Label_head"):setString(string.format(hp.lang.getStrByID(6101) , bInfo.name))
	
	--head
	itemTittleCont:getChildByName("Label_level"):setString( hp.lang.getStrByID(1039) )
	itemTittleCont:getChildByName("Label_col"):setString( hp.lang.getStrByID(6601) )
	itemTittleCont:getChildByName("Label_col_0"):setString( hp.lang.getStrByID(6602) )
	
	local img = hp.gameDataLoader.getInfoBySid("resInfo", resInfo.type+1).image
	--cclog_(img)
	itemTittleCont:getChildByName("Image_1"):loadTexture(config.dirUI.common .. img)
	itemTittleCont:getChildByName("Image_2"):loadTexture(config.dirUI.common .. img)
	
	
	--remove selected item
	ListView_info:removeItem(5)
	
	local ContItemSize = 3
	
	local firstUseItem1 = true
	local firstUseItem2 = true
	
	
	--避免第一个和第二个未clone的直接赋值而意外改变顺序
	local tmp = 1
	
	
	--item
	for i,info in ipairs(game.data.res) do
		
		if b.sid==info.buildsid then
		
			
			local item = nil
			
			if b.lv==info.level then
				item = selected
				if b.lv % 2 == 1 then 
					tmp = 0
				else
					tmp = 1
				end
				
			elseif info.level % 2 == tmp then
				
				
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
			
			itemCont:getChildByName("Label_col"):setString(info.resCount)
			itemCont:getChildByName("Label_col_0"):setString(info.max)
			
			if item ~= item1 and item ~= item2 then
				ListView_info:insertCustomItem(item,ContItemSize)
				--cclog_(info.level .. " " .. ContItemSize .. "---------xxxxxxxx---------")
			end
			
			--cclog_(info.level .. " " .. ContItemSize .. "------------------")
			
			ContItemSize = ContItemSize + 1
			
		end	
		
	end
	
	
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
