--
-- ui/mail/occupyMail.lua
-- 主建筑更多信息
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_occupyMail = class("UI_occupyMail", UI)


--init
function UI_occupyMail:init(Info,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "occupyMail.json")
	
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7701))
	
	
	local Panel_cont_0 = Panel_item:getChildByName("Panel_cont_0")
	Panel_cont_0:getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7702))
	
	Panel_cont_0:getChildByName("Label_PosFrom"):setString(
		string.format( hp.lang.getStrByID(7703),Info.from,"K：" .. Info.fromK .. " X：" .. Info.fromX  .. " Y：" .. Info.fromY) 
	)
	Panel_cont_0:getChildByName("Label_PosFrom_1"):setString("")
	Panel_cont_0:getChildByName("Label_PosFrom_2"):setString("")
	
	Panel_cont_0:getChildByName("Label_PosTo"):setString( 
		string.format( hp.lang.getStrByID(7704),"K：" .. Info.toK .. " X：" .. Info.toX .. " Y：" .. Info.toY) 
	)
	Panel_cont_0:getChildByName("Label_PosTo_1"):setString("")
	Panel_cont_0:getChildByName("Label_PosTo_2"):setString("")
	
	
	
	
	
	
	
	local Panel_cont_1 = Panel_item:getChildByName("Panel_cont_1")
	Panel_cont_1:getChildByName("Label_troops"):setString(hp.lang.getStrByID(7705))
	Panel_cont_1:getChildByName("Label_amount"):setString(hp.lang.getStrByID(7706))
	           
	
	local function getSoldNum(id,n)
	
		for i,v in ipairs(Info.soldTp) do
			if v == hp.lang.getStrByID(id) then
				return Info.soldNum[i]
			end
		end
	
		return "0"
		
	end
	
	
	
	
	Panel_item:getChildByName("Panel_contItem1"):getChildByName("Label_name"):setString(hp.lang.getStrByID(1001))
	Panel_item:getChildByName("Panel_contItem1"):getChildByName("Label_col"):setString(getSoldNum(1001,1))
	
	
	Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_name"):setString(hp.lang.getStrByID(1002))
	Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_col"):setString(getSoldNum(1002,2))
	
	
	
	Panel_item:getChildByName("Panel_contItem3"):getChildByName("Label_name"):setString(hp.lang.getStrByID(1003))
	Panel_item:getChildByName("Panel_contItem3"):getChildByName("Label_col"):setString(getSoldNum(1003,3))
	
	
	
	Panel_item:getChildByName("Panel_contItem4"):getChildByName("Label_name"):setString(hp.lang.getStrByID(1004))
	Panel_item:getChildByName("Panel_contItem4"):getChildByName("Label_col"):setString(getSoldNum(1004,4))
	
	
	
	
	
	--del
	Panel_item:getChildByName("Panel_delCont"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_delCont"):getChildByName("ImageView_delete")
	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			hp.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	delBtn:addTouchEventListener(delBtnOnTouched)
	
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
