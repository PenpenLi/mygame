--
-- ui/hero/dressEquip.lua
-- 穿戴装备
--===================================
require "ui/fullScreenFrame"


UI_dressEquip = class("UI_dressEquip", UI)


--init
function UI_dressEquip:init(sender_,index,type_)
	-- data
	-- ===============================
	local sender = sender_
	local equipType = 1
	local equipIndex = 0
	if index~=nil then
		equipIndex = index
	end
	if type_~=nil then
		equipType = type_
	end

	local lineNum = 4
	local equipMaxAttr = 4
	local equip = nil
	local equipNode = nil
	local equipInfo = nil
	local onflag =nil
	local selectImg = nil
	local selectBagNode = nil
	local equipBag = player.equipBag

	-- functions
	local refreshMaterialList
	local refreshSelectedEquip

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(4100+equipType))
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(890)
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "dress_equip.json")


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)

	

	-- 显示装备列表
	local infoPanel = widgetRoot:getChildByName("Panel_info_bg")
	local attrListNode = widgetRoot:getChildByName("ListView_attrs")
	attrListNode:setItemModel(attrListNode:getItem(0))
    --local attrNodeDemo = widgetRoot:getChildByName("Panel_attr")

    -- 装备、卸下按钮
	local upBtn=infoPanel:getChildByName("ImageView_dress")
	upBtn:getChildByName("Label_dress"):setString(hp.lang.getStrByID(2910))
	local downBtn=infoPanel:getChildByName("ImageView_unfix")
	downBtn:getChildByName("Label_unfix"):setString(hp.lang.getStrByID(2911))
	local gemBtn=infoPanel:getChildByName("ImageView_gem")
	gemBtn:getChildByName("Label_gem"):setString(hp.lang.getStrByID(3501))
	local smithBtn=infoPanel:getChildByName("ImageView_smith")
	smithBtn:getChildByName("Label_smith"):setString(hp.lang.getStrByID(2912))
	local listNode = widgetRoot:getChildByName("ListView_equip")
	local lineDemo = listNode:getChildByName("Panel_itemLine"):clone()
	self.lineDemo = lineDemo
	lineDemo:retain()
	local bagDemo = widgetRoot:getChildByName("Panel_bag")
	local bagEmptyDemo = widgetRoot:getChildByName("Panel_bag_empty")
	local equipDemo = widgetRoot:getChildByName("Panel_equip")
	local bagSize = bagDemo:getSize()
	bagSize.width = bagSize.width*bagDemo:getScale()

	

	-- 装备按钮点击事件
	local function onEquipTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local equipid_sed = sender:getTag()
			local bgimg_sed = sender:getParent()
			local bagNode_sed = bgimg_sed:getParent()
			equip = equipBag.getEquipById(equipid_sed)
			selectBagNode=bagNode_sed
			setSelectedEquip()

			--require("ui/smith/gemEmbed")
			--local ui = UI_gemEmbed.new( equipBag.getEquipById(equipid_sed), self)
			--self:addUI(ui)
		end
	end

	-- 设置装备信息
	local function setEquipInfo(bagNode, equip_)
		local colorBg = bagNode:getChildByName("Image_bg")
		local equipNode = colorBg:getChildByName("Panel_equip")
		local equipImg = colorBg:getChildByName("Image_equip")
		local selectedImg = colorBg:getChildByName("Image_selected")
		selectedImg : setVisible(false)
		colorBg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, equip_.lv))
		equipImg:loadTexture(string.format("%s%d.png", config.dirUI.equip, equip_.sid))
		equipImg:setTag(equip_.id)
		bagNode:setTag(equip_.id)
		equipImg:addTouchEventListener(onEquipTouched)

		for i,v in ipairs(equip_.gems) do
			if v>0 then
				local gemImg = equipNode:getChildByName("Image_gem" .. i)
				gemImg:setVisible(true)
				local gemInfo = hp.gameDataLoader.getInfoBySid("gem", v)
				gemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, gemInfo.type))
			else
				equipNode:getChildByName("Image_gem" .. i):setVisible(false)
			end
		end

		if equip_:isEquiped() then
			local flag = equipNode:getChildByName("Image_onFlag")
			flag:setVisible(true)
			onflag=flag
			if equip_.id == player.equipBag.getEquips_equiped()[equipIndex].id then
				onflag=flag
			end
		end
		-- 限时装备隐藏宝石框
		local equipInfo = hp.gameDataLoader.getInfoBySid("equip", equip_.sid)
		if equipInfo~=nil and equipInfo.overTime[1]>0 then
			colorBg:getChildByName("Image_cell"):setVisible(false)
		end
	end
	-- 设置装备属性
	local function setAttrInfo()
		
		attrListNode:removeAllItems()
		local equipAttrNum = 0

		for i=1, equipMaxAttr do
			local attrType = equipInfo["type"..i]
			if attrType~=-1 then
				attrListNode:pushBackDefaultItem()
				local attrNode = attrListNode:getItem(equipAttrNum):getChildByName("Panel_cont")
				local attrNum = equipInfo["value"..i][equip.lv]
				local attrInfo = hp.gameDataLoader.getInfoBySid("attr", attrType)
				attrNameNode = attrNode:getChildByName("Label_attr_name")
				attrNumNode = attrNode:getChildByName("Label_attr_value")
				attrNameNode:setString(attrInfo.desc)
				if attrNum/100 >= 0 then
					attrNumNode:setString(string.format("+%0.2f%%", attrNum/100))
				else
					--显示红色
					attrNumNode:setColor(cc.c3b(235, 94, 107))
					attrNumNode:setString(string.format("%0.2f%%", attrNum/100))
				end
				equipAttrNum = equipAttrNum+1
			end
		end

		for i,gsid in ipairs(equip.gems) do
			if gsid>0 then
				local gemInfo = hp.gameDataLoader.getInfoBySid("gem", gsid)
				for j,v in ipairs(gemInfo.key) do
					local attrInfo = hp.gameDataLoader.getInfoBySid("attr", v)
					local attrNum = gemInfo.value[j]
					attrListNode:pushBackDefaultItem()
					local attrNode = attrListNode:getItem(equipAttrNum):getChildByName("Panel_cont")
					attrNameNode = attrNode:getChildByName("Label_attr_name")
					attrNumNode = attrNode:getChildByName("Label_attr_value")
					attrNameNode:setString(attrInfo.desc)
					if attrNum/100 >= 0 then
						attrNumNode:setString(string.format("+%0.2f%%", attrNum/100))
					else
						--显示红色
						attrNumNode:setColor(cc.c3b(235, 94, 107))
						attrNumNode:setString(string.format("%0.2f%%", attrNum/100))
					end
					equipAttrNum = equipAttrNum+1
				end
			end
		end
	end

	-- 刷新装备、卸下按钮状态
	local function flushEquipBtn()
		if equip:isEquiped() then
			upBtn:setTouchEnabled(false)
			upBtn:setVisible(false)
			--upBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			downBtn:setTouchEnabled(true)
			downBtn:loadTexture(config.dirUI.common .. "button_red.png")
			downBtn:setVisible(true)
		else
			upBtn:setTouchEnabled(true)
			upBtn:loadTexture(config.dirUI.common .. "button_green.png")
			upBtn:setVisible(true)
			downBtn:setTouchEnabled(false)
			--downBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			downBtn:setVisible(false)
		end
	end


	-- 设置选中装备的信息
	function refreshSelectedEquip()
		equip=player.equipBag.getEquipById(equip.id)
		equipNode = nil
		equipInfo = nil
		onflag =nil
		selectImg = nil
		selectBagNode = nil
		showEquipList()
		setSelectedEquip()
		if selectBagNode ~= nil then
			setEquipInfo(selectBagNode,equip)
		end
		if sender ~=nil then
			sender.refreshEquipInfo(equipIndex)
		end
	end

	-- 设置选中装备的信息
	function setSelectedEquip()
		if selectBagNode==nil then
			infoPanel:setVisible(false)
			attrListNode:setVisible(false)
			local framePanel = widgetRoot:getChildByName("Panel_frame")
			framePanel:setVisible(false)
		else
			local bgImg = selectBagNode:getChildByName("Image_bg")
			equipNode = bgImg:getChildByName("Panel_equip")
			equipInfo = hp.gameDataLoader.getInfoBySid("equip", equip.sid)
			if selectImg ~= nil then
					selectImg:setVisible(false)
			end
			selectImg = bgImg:getChildByName("Image_selected")
			selectImg : setVisible(true)
			infoPanel:getChildByName("Label_name"):setString(equipInfo.name)
			infoPanel:getChildByName("Label_need_level"):setString(string.format(hp.lang.getStrByID(3503), equipInfo.mustLv))
			setAttrInfo()	
			flushEquipBtn()
		end
	end


	self.refreshSelectedEquip=refreshSelectedEquip


	--  通讯返回处理
	local function onHttpResponseUpEquip(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--装备成功
				if onflag ~= nil then 
					onflag:setVisible(false)
				end	
				onflag = equipNode:getChildByName("Image_onFlag")
				onflag:setVisible(true)
				--player.equipBag.getEquips_equiped()[equipIndex]=equip.id
				player.equipBag.equipEquip(equipIndex, equip.id)
				if sender ~=nil then
					sender.upEquip(equipIndex,equip)
				end
				flushEquipBtn()
			end
		end
	end
	local function onHttpResponseDownEquip(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--卸下装备成功
				if onflag ~= nil then 
					onflag:setVisible(false)
				end	
				--player.equipBag.getEquips_equiped()[equipIndex]=nil
				player.equipBag.unequipEquip(equipIndex)
				if sender ~=nil then
					sender.downEquip(equipIndex)
				end
				flushEquipBtn()
			end
		end
	end
	-- 通讯
	local function sendUpEquip()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 7
		oper.type = 1
		oper.index = equipIndex-1
		oper.id = equip.id
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponseUpEquip)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
	end
	local function sendDownEquip()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 7
		oper.type = 1	
		oper.index = equipIndex-1
		oper.id = 0
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponseDownEquip)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
	end

	--穿装备
	local function upEquip()
		if equip:isEquiped()==false then
			if player.getLv()< equipInfo.mustLv then
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(1191), 
					string.format(hp.lang.getStrByID(4108), equipInfo.mustLv),
					hp.lang.getStrByID(1209)
					)
				self:addModalUI(msgBox)
			else
				sendUpEquip()
			end
		end
	end

	--卸下装备
	local function downEquip()
		if equip:isEquiped() then	
			sendDownEquip()
		end
	end

	-- 设置装备、卸下按钮点击事件

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==upBtn then
				upEquip()
			elseif sender==downBtn then				
				downEquip()
			elseif sender==gemBtn then				
				require("ui/smith/gemEmbed")
				local ui = UI_gemEmbed.new(equip, self)
				self:addUI(ui)
			elseif sender==smithBtn then				
				local building=player.buildingMgr.getBuildingObjBySid(1011)
				if building ~= nil then
					building:onClicked()
				else
					require "ui/common/noBuildingNotice"
   					local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(2913), 1011, 1)
   					self:addModalUI(ui_)
				end
			end
		end
	end

	upBtn:addTouchEventListener(onBtnTouched)
	downBtn:addTouchEventListener(onBtnTouched)
	gemBtn:addTouchEventListener(onBtnTouched)
	smithBtn:addTouchEventListener(onBtnTouched)

	-- 显示装备列表
	function showEquipList()
		listNode:removeAllItems()
		local equips = equipBag.getEquipsByType(equipType)
		local size = #equips
		if size == 0 then
			infoPanel:setVisible(false)
			attrListNode:setVisible(false)
			local framePanel = widgetRoot:getChildByName("Panel_frame")
			framePanel:setVisible(false)
		else
			
			local lineNode = nil
			local bagNode = nil
			local equipNode = nil
			local k = 1
			local equipedEq = player.equipBag.getEquips_equiped()[equipIndex]
			-- 当前穿戴的装备
			if equipedEq~=nil then
				lineNode = lineDemo:clone()
				listNode:pushBackCustomItem(lineNode)
				bagNode = bagDemo:clone()
				bagNode:setPosition(0, 0)
				lineNode:addChild(bagNode)
				setEquipInfo(bagNode, equipedEq)

				equip = equipedEq
				selectBagNode=bagNode
				k = k+1
			end
			-- 其他的装备

			for i=1, size do
				local linePos = k%lineNum
				local px = 0
				if linePos==0 then
					px = (lineNum-1)*bagSize.width
				else
					px = (linePos-1)*bagSize.width
				end
				if equips[i]~=nil then
					if equips[i]:isEquiped()==false then
						if linePos==1 then
							lineNode = lineDemo:clone()
							listNode:pushBackCustomItem(lineNode)
						end
						bagNode = bagDemo:clone()
						bagNode:setPosition(px, 0)
						lineNode:addChild(bagNode)
						setEquipInfo(bagNode, equips[i])
						if k==1 then
							equip = equips[i]
							selectBagNode=bagNode
						end	
						k = k+1
					end
				end	
			end	
		end
	end
	showEquipList()
	setSelectedEquip()
end
