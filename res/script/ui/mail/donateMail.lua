--
-- ui/mail/donateMail.lua
-- 联盟捐赠
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_donateMail = class("UI_donateMail", UI)


--init
function UI_donateMail:init(mailInfo)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "donateMail.json")
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--mailInfo
	--"联盟资助|【过得很是】y2玩家名向您捐赠了一批资源。","【过得很是】y2玩家名向您捐赠了一批资源。",[88,319,958,1490,2769],1406625391,0]]

	Info = {}
	
	Info.silver = mailInfo.annex[1]
	Info.food = mailInfo.annex[2]
	Info.wood = mailInfo.annex[3]
	Info.stone = mailInfo.annex[4]
	Info.ore = mailInfo.annex[5]
	
	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(hp.lang.getStrByID(8201))
	
	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(mailInfo.content)
	
	
	local itemCont = Panel_item:getChildByName("Panel_cont_1")
	itemCont:getChildByName("Label_tittleL"):setString(hp.lang.getStrByID(2804))
	itemCont:getChildByName("Label_tittleR"):setString(hp.lang.getStrByID(5106))

	itemCont:getChildByName("Label_info1"):setString(hp.lang.getStrByID(6305))
	itemCont:getChildByName("Label_info1_1"):setString( Info.food)
	
	itemCont:getChildByName("Label_info2"):setString(hp.lang.getStrByID(6303))
	itemCont:getChildByName("Label_info2_1"):setString(Info.wood)
	
	itemCont:getChildByName("Label_info3"):setString( hp.lang.getStrByID(6302) )
	itemCont:getChildByName("Label_info3_1"):setString(Info.stone)
	
	itemCont:getChildByName("Label_info4"):setString( hp.lang.getStrByID(6304) )
	itemCont:getChildByName("Label_info4_1"):setString(Info.ore)
	
	itemCont:getChildByName("Label_info5"):setString( hp.lang.getStrByID(7603) )
	itemCont:getChildByName("Label_info5_1"):setString(Info.silver)
	

	--del
	Panel_item:getChildByName("Panel_delCont"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_delCont"):getChildByName("ImageView_delete")
	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	delBtn:addTouchEventListener(delBtnOnTouched)

	
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
