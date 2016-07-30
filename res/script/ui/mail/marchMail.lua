--
-- ui/mail/marchMail.lua
-- 采集邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_marchMail = class("UI_marchMail", UI)


--init
function UI_marchMail:init(Info,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "marchMail.json")
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7711))
	
	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(Info.content)
	
	
	
	local Panel_cont_1 = Panel_item:getChildByName("Panel_cont_1")
	Panel_cont_1:getChildByName("Label_res"):setString(hp.lang.getStrByID(7713))
	Panel_cont_1:getChildByName("Label_amount"):setString(hp.lang.getStrByID(7706))
	
	
	local Panel_cont_2 = Panel_item:getChildByName("Panel_cont_2")
	Panel_cont_2:getChildByName("Label_materials"):setString(hp.lang.getStrByID(7714))
	Panel_cont_2:getChildByName("Label_amount"):setString(hp.lang.getStrByID(7706))
	
	
	
	local img = hp.gameDataLoader.getInfoBySid("resInfo", Info.resTp + 1).image
	local resTpName = hp.gameDataLoader.getInfoBySid("resInfo", Info.resTp + 1).name
	
	
	Panel_item:getChildByName("Panel_contItem1"):getChildByName("Image_icon"):
		loadTexture(config.dirUI.common .. img)
	
	Panel_item:getChildByName("Panel_contItem1"):getChildByName("Label_name"):setString( resTpName)
	Panel_item:getChildByName("Panel_contItem1"):getChildByName("Label_col"):setString( Info.resNum)
	
	if Info.materials > 0 then
		local materials = hp.gameDataLoader.getInfoBySid("equipMaterial", Info.materials)
		if materials == ni then
			materials = hp.gameDataLoader.getInfoBySid("gem", Info.materials)
		end
		Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_name"):setString(materials.name)
		Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_col"):setString("1")
		
	else
		Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_noFnd"):setString(hp.lang.getStrByID(7715))
		Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_name"):setString( "")
		Panel_item:getChildByName("Panel_contItem2"):getChildByName("Label_col"):setString( "")
	end
	
	
	
	
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
