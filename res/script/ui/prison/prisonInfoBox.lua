--
-- ui/prison/prisonMoreInfoBox
-- 地牢更多信息
--===================================
require "ui/frame/popFrame"


UI_prisonInfo = class("UI_prisonInfo", UI)


--init
function UI_prisonInfo:init(building_)
	
	local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "prisonInfo.json")
	local uiFrame = UI_popFrame.new(wigetRoot, bInfo.name)

	
	
	local ListView_info = wigetRoot:getChildByName("ListView_info")
	
	local contNode = ListView_info:getChildByName("Panel_cont"):getChildByName("Panel_info")
	local moreInfo = contNode:getChildByName("Label_moreInfo")
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
	tittleCont:getChildByName("Label_head"):setString(string.format( hp.lang.getStrByID(6101),hp.lang.getStrByID(6201) ))
	
	--head
	item1Cont:getChildByName("Label_level"):setString(hp.lang.getStrByID(1039))
	item1Cont:getChildByName("Label_time"):setString(hp.lang.getStrByID(6202))
	item1Cont:getChildByName("Label_num"):setString(hp.lang.getStrByID(6206))
	--remove selected item
	ListView_info:removeItem(4)
	
	local ContItemSize = 3
	
	local firstUseItem2 = true
	
	--item
	for i,info in ipairs(game.data.prison) do
		
		
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
		itemCont:getChildByName("Label_time"):setString(info.earlierseGuillotine .. "h")
		itemCont:getChildByName("Label_num"):setString(info.imprisonHero)
		if item ~= item2 then
			ListView_info:insertCustomItem(item,ContItemSize)
		end
		
		
		
		ContItemSize = ContItemSize + 1
		
	end
	
	
	
	--第二部分
	
	head = ListView_info:getChildByName("Panel_tittle"):clone()
	local addItem1 = ListView_info:getChildByName("Panel_addItem1")
	local addItem2 = ListView_info:getChildByName("Panel_addItem2")
	
	tittleCont = head:getChildByName("Panel_cont")
	local addItem1Cont = addItem1:getChildByName("Panel_cont")
	
	--tittle
	tittleCont:getChildByName("Label_head"):setString(hp.lang.getStrByID(6203))
	
	--head
	addItem1Cont:getChildByName("Label_level"):setString(hp.lang.getStrByID(6204))
	addItem1Cont:getChildByName("Label_benefits"):setString(hp.lang.getStrByID(6205))
	
	ListView_info:insertCustomItem(head,ContItemSize)
	ContItemSize = ContItemSize + 1
	
	-- addItem1Cont has in list
	ContItemSize = ContItemSize + 1
	
	--关押的英雄等级	攻击增加
	local AddititonalBenefits = {
		{"1~19"	 ,"1%"},
		{"20~24" ,"2%"},
		{"25~29" ,"4%"},
		{"30~34" ,"7%"},
		{"35~39" ,"11%"},
		{"40~44" ,"16%"},
		{"45~49" ,"22%"},
		{"50"	 ,"30%"}	}
	
	
	for i,info in ipairs(AddititonalBenefits) do
	
		
		local item = nil
		
		
		if i % 2 == 0 then
			
			item = addItem1:clone()
			
		else
		
			if i > 1 then
				item = addItem2:clone()
			else
				item = addItem2
			end
		end
		
		local itemCont = item:getChildByName("Panel_cont")
		
		itemCont:getChildByName("Label_level"):setString(info[1] .. "")
		itemCont:getChildByName("Label_benefits"):setString(info[2] .. "")
		
		if i > 1 then
			ListView_info:insertCustomItem(item,ContItemSize)
		end
		
		ContItemSize = ContItemSize + 1
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
