--
-- ui/mail/equipMail.lua
-- 主建筑更多信息
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_equipMail = class("UI_equipMail", UI)


--init
function UI_equipMail:init(Info,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipMail.json")
	
	
	
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	

	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(Info.content)
	
	
	local Panel_cont_1 = Panel_item:getChildByName("Panel_cont_1")
	Panel_cont_1:getChildByName("Label_equipInfo"):setString(hp.gameDataLoader.getInfoBySid("equip", Info.equipSid).name)
	Panel_cont_1:getChildByName("Label_equipDesc"):setString(hp.gameDataLoader.getInfoBySid("equip", Info.equipSid).desc)
	Panel_cont_1:getChildByName("Image_equip"):loadTexture(config.dirUI.equip .. Info.equipSid .. ".png")
	

	local Panel_cont_2 = Panel_item:getChildByName("Panel_cont_2")
	Panel_cont_2:getChildByName("Label_attri"):setString(hp.lang.getStrByID(7911))
	Panel_cont_2:getChildByName("Label_value"):setString(hp.lang.getStrByID(7912))
	

	local Panel_cont_3 = Panel_item:getChildByName("Panel_cont_3")
	Panel_cont_3:getChildByName("Label_reward"):setString(hp.lang.getStrByID(7913))
	Panel_cont_3:getChildByName("Label_heroXP"):setString(hp.lang.getStrByID(7914))
	Panel_cont_3:getChildByName("Label_heroXPNum"):setString("+" .. hp.gameDataLoader.getInfoBySid("equip", Info.equipSid).exp)
	





	function movePos(parent, name ,dh)
		local Panel_cont = parent:getChildByName(name)
		local posx,posy = Panel_cont:getPosition()
		posy = posy - dh
		Panel_cont:setPosition(posx,posy)
	end

	function movePos1(Panel_cont,dh)
		local posx,posy = Panel_cont:getPosition()
		posy = posy - dh
		Panel_cont:setPosition(posx,posy)
	end


	function addHeight(parent, name ,dh)
		local Image_bg = parent:getChildByName(name)
		local size = Image_bg:getSize()
		size.height = size.height + dh
		Image_bg:setSize(size)
	end


	local equipInfo = hp.gameDataLoader.getInfoBySid("equip", Info.equipSid)

	

	local equipFunc = {}
	local ch = 0
	
	
	if equipInfo.type1 > 0 then
		equipFunc[1] = {}
		equipFunc[1].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type1).desc
		equipFunc[1].value = "+" .. equipInfo.value1[Info.quality] / 100 .. "%"
		ch = ch + 1
	end


	if equipInfo.type2 > 0 then
		equipFunc[2] = {}
		equipFunc[2].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type2).desc
		equipFunc[2].value = "+" .. equipInfo.value2[Info.quality] / 100 .. "%"
		ch = ch + 1
	end



	if equipInfo.type3 > 0 then
		equipFunc[3] = {}
		equipFunc[3].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type3).desc
		equipFunc[3].value = "+" .. equipInfo.value3[Info.quality] / 100 .. "%"
		ch = ch + 1
	end


	if equipInfo.type4 > 0 then
		equipFunc[4] = {}
		equipFunc[4].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type4).desc
		equipFunc[4].value = "+" .. equipInfo.value4[Info.quality] / 100 .. "%"
		ch = ch + 1
	end



	local dd = 40
	local dh = dd * (ch-1)
	
	if dh < 0 then 
		dh = 0
	end

	--panel 
	local Panel_framBg1 = Panel_item:getChildByName("Panel_framBg_1")

	


	addHeight(Panel_framBg1,"Image_bg_2",dh)
	addHeight(Panel_framBg1,"Image_bg_3",dh)
	addHeight(Panel_framBg1,"Image_bg_4",dh)




	movePos(Panel_framBg1,"Image_bg_2",dh)
	movePos(Panel_framBg1,"Image_bg_3",dh)
	movePos(Panel_framBg1,"Image_bg_4",dh)
	movePos(Panel_framBg1,"Image_bg_5",dh)
	movePos(Panel_framBg1,"Image_bg_6",dh)
	movePos(Panel_framBg1,"Image_bg_7",dh)





	movePos(Panel_item,"Panel_framBg_2",dh)
	movePos(Panel_item,"Panel_cont_3",dh)






	local size = Panel_item:getSize()
	size.height = size.height + dh
	Panel_item:setSize(size)





	dh = -dh



	
	movePos(Panel_item,"Panel_framBg",dh)
	movePos(Panel_item,"Panel_framBg_0",dh)
	movePos(Panel_item,"Panel_framBg_1",dh)
	movePos(Panel_item,"Panel_framBg_2",dh)
	
	movePos(Panel_item,"Panel_cont_0",dh)
	movePos(Panel_item,"Panel_cont_1",dh)
	movePos(Panel_item,"Panel_cont_2",dh)
	movePos(Panel_item,"Panel_cont_3",dh)

	
	movePos(Panel_item,"Panel_framHd2_0",dh)
	movePos(Panel_item,"Panel_framHd2_1",dh)
	
	movePos(Panel_item,"Panel_framItem2",dh)
	movePos(Panel_item,"Panel_contItem2",dh)


	


	for i=1,ch do
		if equipFunc[i] ~= nil then
			
			local itemf1 
			local itemc1
			if i ~= 1 then
				itemf1 = Panel_item:getChildByName("Panel_framItem2"):clone()
				itemc1 = Panel_item:getChildByName("Panel_contItem2"):clone()
				Panel_item:addChild(itemf1)
				Panel_item:addChild(itemc1)
				movePos1(itemf1, (i - 1)*dd)
				movePos1(itemc1, (i - 1)*dd)
			else
				itemf1 = Panel_item:getChildByName("Panel_framItem2")
				itemc1 = Panel_item:getChildByName("Panel_contItem2")
			end

			itemc1:getChildByName("Label_name"):setString(equipFunc[i].type)
			itemc1:getChildByName("Label_col"):setString(equipFunc[i].value)
			

		end
	end



	--view
	Panel_item:getChildByName("Panel_cont_3"):getChildByName("Label_viewItem"):setString( hp.lang.getStrByID(7915))
		
	local viewBtn = Panel_item:getChildByName("Panel_cont_3"):getChildByName("Image_viewItem")
	function viewBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local equipBag = player.equipBag
			local equip = equipBag.getEquipById(Info.equipId) 
			if equip ~= nil then
				require("ui/hero/dressEquip")
				local ui = UI_dressEquip.new(nil,equip,nil)
				self:addUI(ui)
			else
				require "ui/msgBox/msgBox"
				self:addModalUI(UI_msgBox.new(
					hp.lang.getStrByID(6034),
					hp.lang.getStrByID(7916),
					hp.lang.getStrByID(6035)))
			
			end
		end
	end
	
	viewBtn:addTouchEventListener(viewBtnOnTouched)
	


	
	--del
	Panel_item:getChildByName("Panel_cont_3"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))
		
	local delBtn = Panel_item:getChildByName("Panel_cont_3"):getChildByName("ImageView_delete")
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
