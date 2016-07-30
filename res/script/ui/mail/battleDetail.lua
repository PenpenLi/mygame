--
-- ui/mail/battleDetail.lua
-- 战报详情
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_battleDetail = class("UI_battleDetail", UI)


--init
function UI_battleDetail:init(Info)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "battleDetail.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(7622))
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView_info")
	
	
	
	
	Panel_item:getChildByName("Panel_atter"):getChildByName("Panel_cont"):
		getChildByName("Label_head"):setString( hp.lang.getStrByID(7631))
	
	
	Panel_item:getChildByName("Panel_atterName"):getChildByName("Panel_cont"):
		getChildByName("Label_atterName"):setString( Info.atterName)
	
	
	
	
	local item0 = Panel_item:getChildByName("Panel_item0"):getChildByName("Panel_cont")
	item0:getChildByName("Label_name"):setString( hp.lang.getStrByID(7633))
	item0:getChildByName("Label_col"):setString( hp.lang.getStrByID(7615))
	item0:getChildByName("Label_col_0"):setString( hp.lang.getStrByID(7634))
		
	
	
	local item1 = Panel_item:getChildByName("Panel_item1"):getChildByName("Panel_cont")
	item1:getChildByName("Label_name"):setString( hp.lang.getStrByID(1001))
	item1:getChildByName("Label_col"):setString( Info.atterSolds[1])
	item1:getChildByName("Label_col_0"):setString( Info.atterSolds[2])
		
		
	
	local item2 = Panel_item:getChildByName("Panel_item2"):getChildByName("Panel_cont")
	item2:getChildByName("Label_name"):setString( hp.lang.getStrByID(1002))
	item2:getChildByName("Label_col"):setString( Info.atterSolds[3])
	item2:getChildByName("Label_col_0"):setString( Info.atterSolds[4])
		
	
	
	
	local item3 = Panel_item:getChildByName("Panel_item3"):getChildByName("Panel_cont")
	item3:getChildByName("Label_name"):setString( hp.lang.getStrByID(1003))
	item3:getChildByName("Label_col"):setString( Info.atterSolds[5])
	item3:getChildByName("Label_col_0"):setString( Info.atterSolds[6])
		
		
	
	local item4 = Panel_item:getChildByName("Panel_item4"):getChildByName("Panel_cont")
	item4:getChildByName("Label_name"):setString( hp.lang.getStrByID(1004))
	item4:getChildByName("Label_col"):setString( Info.atterSolds[7])
	item4:getChildByName("Label_col_0"):setString( Info.atterSolds[8])
		
	
	
	
	local troop = Panel_item:getChildByName("Panel_troop"):getChildByName("Panel_cont")
	troop:getChildByName("Label_troop"):setString( string.format( hp.lang.getStrByID(7635),Info.atterName,Info.atterkillCount))
	
	
	local trap = Panel_item:getChildByName("Panel_trap"):getChildByName("Panel_cont")
	trap:getChildByName("Label_trap"):setString( string.format( hp.lang.getStrByID(7636),Info.atterName,Info.atterDestroyTraps))
	
	
	
	
	
	
	
	--def
	
	
	Panel_item:getChildByName("Panel_defer"):getChildByName("Panel_cont"):
		getChildByName("Label_head"):setString( hp.lang.getStrByID(7632))
	
	
	Panel_item:getChildByName("Panel_deferName"):getChildByName("Panel_cont"):
		getChildByName("Label_deferName"):setString( Info.deferName)
	
	
	
	
	local item0_1 = Panel_item:getChildByName("Panel_item0_1"):getChildByName("Panel_cont")
	item0_1:getChildByName("Label_name"):setString( hp.lang.getStrByID(7633))
	item0_1:getChildByName("Label_col"):setString( hp.lang.getStrByID(7615))
	item0_1:getChildByName("Label_col_0"):setString( hp.lang.getStrByID(7634))
		
	
	
	local item1_1 = Panel_item:getChildByName("Panel_item1_1"):getChildByName("Panel_cont")
	item1_1:getChildByName("Label_name"):setString( hp.lang.getStrByID(1001))
	item1_1:getChildByName("Label_col"):setString( Info.deferSolds[1])
	item1_1:getChildByName("Label_col_0"):setString( Info.deferSolds[2])
		
		
	
	local item2_1 = Panel_item:getChildByName("Panel_item2_1"):getChildByName("Panel_cont")
	item2_1:getChildByName("Label_name"):setString( hp.lang.getStrByID(1002))
	item2_1:getChildByName("Label_col"):setString( Info.deferSolds[3])
	item2_1:getChildByName("Label_col_0"):setString( Info.deferSolds[4])
		
	
	
	
	local item3_1 = Panel_item:getChildByName("Panel_item3_1"):getChildByName("Panel_cont")
	item3_1:getChildByName("Label_name"):setString( hp.lang.getStrByID(1003))
	item3_1:getChildByName("Label_col"):setString( Info.deferSolds[5])
	item3_1:getChildByName("Label_col_0"):setString( Info.deferSolds[6])
		
		
	
	local item4_1 = Panel_item:getChildByName("Panel_item4_1"):getChildByName("Panel_cont")
	item4_1:getChildByName("Label_name"):setString( hp.lang.getStrByID(1004))
	item4_1:getChildByName("Label_col"):setString( Info.deferSolds[7])
	item4_1:getChildByName("Label_col_0"):setString( Info.deferSolds[8])
		
	
	
	
	local troop_1 = Panel_item:getChildByName("Panel_troop_1"):getChildByName("Panel_cont")
	troop_1:getChildByName("Label_troop"):setString( string.format( hp.lang.getStrByID(7635),Info.deferName,Info.deferkillCount))
	
	
	
	
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
