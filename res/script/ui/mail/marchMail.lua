--
-- ui/mail/marchMail.lua
-- 采集邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_marchMail = class("UI_marchMail", UI)


--init
function UI_marchMail:init(Info_,mailType_,mailIndex)

	-- data
	local annex = Info_.annex
	content = Info_.content .. "\n\n"
	content = content .. string.format(hp.lang.getStrByID(7716), annex[2])
	content = content .. string.format(hp.lang.getStrByID(7717), annex[3])
	
	local Info = {}
	Info.content = Info_.content
	Info.resTp	= annex[1]
	Info.resNum	= annex[2]
	Info.materials	= annex[3]
	Info.server = annex[4]
	Info.x = annex[5]
	Info.y = annex[6]

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "marchMail.json")
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7711))
	
	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(Info.content)
	
	local posText = string.format(hp.lang.getStrByID(7718), hp.gameDataLoader.getInfoBySid("serverList", Info.server).name, Info.x, Info.y)
	local label_pos = Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info_0")
	label_pos:setString(posText)

	local image_line = Panel_item:getChildByName("Panel_cont_0"):getChildByName("Image_line")
	local width = label_pos:getContentSize().width
	local size = image_line:getSize()
	size.width = width
	image_line:setSize(size)

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
	
	--goto
	local function goto(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if game.curScene.mapLevel == 2 then
				self:closeAll()
    			game.curScene:gotoPosition(cc.p(Info.x, Info.y), "", Info.server)
    		else
    			self:close()
				require("scene/kingdomMap")
				local map = kingdomMap.new()
				map:enter()
				map:gotoPosition(cc.p(Info.x, Info.y), "", Info.server)
			end
		end
	end
	label_pos:addTouchEventListener(goto)
	
	--del
	Panel_item:getChildByName("Panel_delCont"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_delCont"):getChildByName("ImageView_delete")
	local function delBtnOnTouched(sender, eventType)
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
