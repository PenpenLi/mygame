--
-- ui/mail/alarmMail.lua
-- 战争预警
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_alarmMail = class("UI_alarmMail", UI)


--init
function UI_alarmMail:init(mailInfo,mailType_,mailIndex)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "alarmMail.json")
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	--[[16,11,0,"null","战争预警","主公请注意，有人向您发起战争。",
	--[21,"个人攻击","y1","",1405418442,"8300",[1,2,3,4],[3922,1840,1800,738],"司马懿",9,[1,1,11,1,12,1,21,1]]

	local annex = mailInfo.annex
	local Info = {}

	if annex[2] ~= "" then
		Info.warType = annex[2]
	else
		Info.warType = hp.lang.getStrByID(7956)
	end

	if annex[3] ~= "" then
		if annex[4] ~= "" then
			Info.atkName = hp.lang.getStrByID(21) .. annex[4] .. hp.lang.getStrByID(22) .. annex[3]
		else
			Info.atkName = annex[3]
		end
	else
		Info.atkName = hp.lang.getStrByID(7956)
	end

	if annex[5] ~= 0 then
		Info.time = os.date("%c", annex[5])
	else
		Info.time = hp.lang.getStrByID(7956)
	end

	if annex[6] ~= "" then
		Info.soldCount = annex[6] 
	else
		Info.soldCount = hp.lang.getStrByID(7956)
	end


	Info.solds = {}
	Info.solds[1] = hp.lang.getStrByID(7956)
	Info.solds[2] = hp.lang.getStrByID(7956)
	Info.solds[3] = hp.lang.getStrByID(7956)
	Info.solds[4] = hp.lang.getStrByID(7956)

	-- if #annex[7] > 0 then
	-- 	for i,v in ipairs(annex[7]) do
	-- 		if i == annex[7][i] then
	-- 			Info.solds[i] = hp.lang.getStrByID(7956)
	-- 		end
	-- 	end
	-- else
	-- 	for i=1,4 do
	-- 		Info.solds[i] = hp.lang.getStrByID(7956)
	-- 	end
	-- end

	if #annex[8] > 0 then
		for i,v in ipairs(annex[8]) do
			Info.solds[i] = annex[8][i]
		end
	end

	if annex[9] ~= "" then
		Info.heroName = annex[9]
	else
		Info.heroName = hp.lang.getStrByID(7956)
	end

	if annex[10] > 0 then
		Info.heroLv = annex[10]
	else
		Info.heroLv = hp.lang.getStrByID(7956)
	end

 	Info.buff = {}
	for i=1,#annex[11],2 do
		local buf = {}
		buf.id = annex[11][i]
		buf.value = annex[11][i+1]
		table.insert(Info.buff,buf)
	end



	--head
	Panel_item:getChildByName("Panel_cont"):getChildByName("Label_succeed"):setString(hp.lang.getStrByID(7971))
	
	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(hp.lang.getStrByID(7972))
	

	local panelLabelCont = Panel_item:getChildByName("Panel_cont_1")
	panelLabelCont:getChildByName("Label_tittleC"):setString(hp.lang.getStrByID(7973))
	panelLabelCont:getChildByName("Label_info1"):setString(hp.lang.getStrByID(7974))
	panelLabelCont:getChildByName("Label_info2"):setString(hp.lang.getStrByID(7975))
	panelLabelCont:getChildByName("Label_info3"):setString(hp.lang.getStrByID(7976))

	panelLabelCont:getChildByName("Label_info1_1"):setString(Info.atkName)
	panelLabelCont:getChildByName("Label_info2_1"):setString(Info.warType)
	panelLabelCont:getChildByName("Label_info3_1"):setString(Info.time)



	local panelLabelCont1 = Panel_item:getChildByName("Panel_cont_2")
	panelLabelCont1:getChildByName("Label_tittleL"):setString(hp.lang.getStrByID(7977))
	panelLabelCont1:getChildByName("Label_info1"):setString(hp.lang.getStrByID(6001) .. "：")
	panelLabelCont1:getChildByName("Label_info2"):setString(hp.lang.getStrByID(5250))
	-- panelLabelCont1:getChildByName("Label_info3"):setString(hp.lang.getStrByID(1001) .. "：")
	-- panelLabelCont1:getChildByName("Label_info4"):setString(hp.lang.getStrByID(1002) .. "：")
	-- panelLabelCont1:getChildByName("Label_info5"):setString(hp.lang.getStrByID(1003) .. "：")
	-- panelLabelCont1:getChildByName("Label_info6"):setString(hp.lang.getStrByID(1004) .. "：")

	-- 兵种
	local labelTbl = {}
	labelTbl[1] = panelLabelCont1:getChildByName("Label_info3")
	labelTbl[2] = panelLabelCont1:getChildByName("Label_info4")
	labelTbl[3] = panelLabelCont1:getChildByName("Label_info5")
	labelTbl[4] = panelLabelCont1:getChildByName("Label_info6")

	for i,v in ipairs(annex[7]) do
		local tblName = ""
		if v <= 5 then
			tblName = "armyType"
		else
			tblName = "army"
		end
		labelInfo = hp.gameDataLoader.getInfoBySid(tblName, v).name
		labelTbl[i]:setString(labelInfo .. "：")
	end

	panelLabelCont1:getChildByName("Label_info1_1"):setString(Info.heroName .. " Lv." .. Info.heroLv)
	panelLabelCont1:getChildByName("Label_info2_1"):setString(Info.soldCount)
	-- panelLabelCont1:getChildByName("Label_info3_1"):setString(Info.solds[1])
	-- panelLabelCont1:getChildByName("Label_info4_1"):setString(Info.solds[2])
	-- panelLabelCont1:getChildByName("Label_info5_1"):setString(Info.solds[3])
	-- panelLabelCont1:getChildByName("Label_info6_1"):setString(Info.solds[4])

	-- 兵力
	local labelTbl2 = {}
	labelTbl2[1] = panelLabelCont1:getChildByName("Label_info3_1")
	labelTbl2[2] = panelLabelCont1:getChildByName("Label_info4_1")
	labelTbl2[3] = panelLabelCont1:getChildByName("Label_info5_1")
	labelTbl2[4] = panelLabelCont1:getChildByName("Label_info6_1")

	for i,v in ipairs(Info.solds) do
		if labelTbl[i]:getString() ~= "" then
			labelTbl2[i]:setString(Info.solds[i])
		end
	end
	
	local panelLabelCont2 = Panel_item:getChildByName("Panel_cont_3")
	panelLabelCont2:getChildByName("Label_tittleR"):setString(hp.lang.getStrByID(7978))
	
	local panelLabelContTmp = Panel_item:getChildByName("Panel_cont_Temp")
	panelLabelContTmp:getChildByName("Label_info1"):setString(hp.lang.getStrByID(7979))
	panelLabelContTmp:getChildByName("Label_info1_1"):setString("+" .. "gfgdf")
	
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

	
	local panelLabelContTmp = Panel_item:getChildByName("Panel_cont_Temp")

	local ch = #Info.buff

	if ch == 0 then

		panelLabelContTmp:getChildByName("Label_info1"):setString("")
		panelLabelContTmp:getChildByName("Label_info1_1"):setString("")

		if annex[1] >= 19 then
			panelLabelCont2:getChildByName("Label_null"):setString(hp.lang.getStrByID(7958))
		else
			panelLabelCont2:getChildByName("Label_null"):setString(hp.lang.getStrByID(7956))
		end

		self:addCCNode(wigetRoot)
		return nil
	end

	local dd = 40
	local dh = dd * (ch - 1)

	for i,v in ipairs(Info.buff) do
		local tmp = nil

		if i == 1 then 
			tmp = panelLabelContTmp
		else
			tmp = panelLabelContTmp:clone()
		end

		local attrName = hp.gameDataLoader.getInfoBySid("attr", v.id)
		tmp:getChildByName("Label_info1"):setString(attrName.desc)
		tmp:getChildByName("Label_info1_1"):setString("+" .. v.value .. "%")
		
		if i > 1 then 
			movePos1(tmp,dd*(i-1))
			Panel_item:addChild(tmp)
		end
		
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

	if ch <= 6 then
		self:addCCNode(wigetRoot)
		return nil
	else
		dh = dh - dd * 5
	end

	--move down del
	movePos1(Panel_item:getChildByName("Panel_delFrame") ,dh)
	movePos1(Panel_item:getChildByName("Panel_delCont") ,dh)

	--resize item panel
	local size = Panel_item:getSize()
	size.height = size.height + dh
	Panel_item:setSize(size)

	--move up all item
	local allChild = Panel_item:getChildren()
	for i,v in ipairs(allChild) do
		movePos1(v,-dh)
	end

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
