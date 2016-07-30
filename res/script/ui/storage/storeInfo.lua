--
-- ui/storage/storeInfo
-- 仓库更多信息
--===================================
require "ui/frame/popFrame"


UI_storeInfo = class("UI_storeInfo", UI)


--init
function UI_storeInfo:init(building_)
	
	local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "storeHouseInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, bInfo.name)

	
	
	local ListView_info = wigetRoot:getChildByName("ListView_info")
	
	local moreInfo = ListView_info:getChildByName("Panel_desc"):getChildByName("Panel_cont"):getChildByName("Label_moreInfo")
	moreInfo:setString(bInfo.moreDesc)
	
	
	--第一部分
	
	local head = ListView_info:getChildByName("Panel_tittle")
	local item1 = ListView_info:getChildByName("Panel_item1")
	local item2 = ListView_info:getChildByName("Panel_item2")
	local selected = ListView_info:getChildByName("Panel_selected"):clone()
	
	local tittleCont = head:getChildByName("Panel_cont")
	local item1Cont = item1:getChildByName("Panel_cont")
	--local item2Cont = item2:getChildByName("Panel_cont")
	--local selectedCont = selected:getChildByName("Panel_cont")
	
	--tittle
	tittleCont:getChildByName("Label_head"):setString(string.format( hp.lang.getStrByID(6101),hp.lang.getStrByID(6301) ))
	
	--head
	item1Cont:getChildByName("Label_level"):setString(hp.lang.getStrByID(1039))
	item1Cont:getChildByName("Label_col"):setString(hp.lang.getStrByID(6302))
	item1Cont:getChildByName("Label_col_0"):setString(hp.lang.getStrByID(6303))
	item1Cont:getChildByName("Label_col_1"):setString(hp.lang.getStrByID(6304))
	item1Cont:getChildByName("Label_col_2"):setString(hp.lang.getStrByID(6305))
	
	--remove selected item
	ListView_info:removeItem(4)
	
	local ContItemSize = 3
	
	local firstUseItem2 = true
	
	--item
	for i,info in ipairs(game.data.storehouse) do
		
		
		local item = nil
		
		if building_.build.lv == i then
			item = selected
		elseif i % 2 == 0 then
			item = item1:clone()
		else
			if firstUseItem2 then
				item = item2
				firstUseItem2 = false
				
			else
				item = item2:clone()
			end
		end
		
		local itemCont = item:getChildByName("Panel_cont")
		
		itemCont:getChildByName("Label_level"):setString(info.level .. "")
		num = info.protectResMax
		itemCont:getChildByName("Label_col"):setString(num)
		itemCont:getChildByName("Label_col_0"):setString(num)
		itemCont:getChildByName("Label_col_1"):setString(num)
		itemCont:getChildByName("Label_col_2"):setString(num)
		
		if item ~= item2 then
			ListView_info:insertCustomItem(item,ContItemSize)
		end
		
		
		
		ContItemSize = ContItemSize + 1
		
	end
	
	
	
	
	
	local addHead = head:clone()
	addHead:getChildByName("Panel_cont"):getChildByName("Label_head"):setString(hp.lang.getStrByID(6203))
	
	ListView_info:insertCustomItem(addHead,ContItemSize)
	
	local panelInfo = ListView_info:getChildByName("Panel_info")

	panelInfo:getChildByName("Panel_cont"):getChildByName("Label_info"):
		setString(hp.lang.getStrByID(6306))

	if building_.build.lv == 21 then

		panelInfo:getChildByName("Panel_fram"):
			getChildByName("Image_bg"):loadTexture(config.dirUI.common .. "ui_barrack_current.png")
		
	end
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
