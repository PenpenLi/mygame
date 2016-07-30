--
-- ui/smith/gemEmbed.lua
-- 宝石镶嵌界面
--===================================
require "ui/fullScreenFrame"

UI_gemEmbed = class("UI_gemEmbed", UI)

--init
function UI_gemEmbed:init(equip_, bagUI_)
	-- data
	-- ===============================
	local maxGemNum = 3
	local equip = equip_
	local equipInfo = hp.gameDataLoader.getInfoBySid("equip", equip.sid)
	local equipAttrNum = 0
	local equipMaxAttr = 4

	local selectPos = 0
	local gemCallback

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(3501))
	uiFrame:setTopShadePosY(888)
	uiFrame:setBottomShadePosY(224)
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "gemEmbed.json")
	

	-- addCCNode
	self:addChildUI(uiFrame)
	-- ===============================
	self:addCCNode(widgetRoot)


	local listNode = widgetRoot:getChildByName("ListView_material")
	local basePanel = listNode:getChildByName("Panel_baseInfo"):getChildByName("Panel_cont")
	
	--desc
	local descNode = basePanel:getChildByName("Label_desc")
	descNode:setString(hp.lang.getStrByID(3502))
	--equip
	local equipBg = basePanel:getChildByName("Image_equipBg")
	local equipImg = equipBg:getChildByName("Image_equip")
	local equipName = equipBg:getChildByName("Label_name")
	local equipLv = equipBg:getChildByName("Label_lv")
	equipBg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, equip.lv))
	equipImg:loadTexture(string.format("%s%d.png", config.dirUI.equip, equip.sid))
	equipName:setString(equipInfo.name)
	equipLv:setString(string.format(hp.lang.getStrByID(3503), equipInfo.mustLv))

	--gem

	local function onGemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local index=sender:getTag()
			local gemInfo = hp.gameDataLoader.getInfoBySid("gem", equip.gems[index])
			require("ui/smith/gemMaterialInfo")
			local ui = UI_gemMaterialInfo.new(1,gemInfo)
			self:addModalUI(ui)
		end
	end
	local gem1 = basePanel:getChildByName("Image_gem1"):getChildByName("Image_gem")
	local gem2 = basePanel:getChildByName("Image_gem2"):getChildByName("Image_gem")
	local gem3 = basePanel:getChildByName("Image_gem3"):getChildByName("Image_gem")
	gem1:addTouchEventListener(onGemTouched)
	gem2:addTouchEventListener(onGemTouched)
	gem3:addTouchEventListener(onGemTouched)


	local function onEmbedTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			selectPos = sender:getTag()
			require("ui/smith/gemSelect")
			local ui = UI_gemSelect.new(equip, selectPos, gemCallback)
			self:addModalUI(ui)
		end
	end
	local function onUnembedTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			selectPos = sender:getTag()
			require("ui/item/removeGemItem")
			local ui = UI_removeGemItem.new(equip, selectPos, gemCallback)
			self:addUI(ui)
		end
	end
	local function setGemInfo(index_)
		local gemBg = basePanel:getChildByName("Image_gem" .. index_)
		local gemImg = gemBg:getChildByName("Image_gem")
		local gemLvBg = gemBg:getChildByName("Image_lvbg")
		local gemLv = gemBg:getChildByName("Label_lv")
		local gemNoEmbed = gemBg:getChildByName("Label_notEmbed")
		local operImg = gemBg:getChildByName("Image_oper")
		local operText = gemBg:getChildByName("Label_oper")
		operImg:setTag(index_)
		gemImg:setTag(index_)

		if equip.gems[index_]<=0 then
			--未镶嵌
			gemBg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, 1))
			gemNoEmbed:setVisible(true)
			gemNoEmbed:setString(hp.lang.getStrByID(3504))
			gemImg:setVisible(false)
			gemLvBg:setVisible(false)
			gemLv:setVisible(false)
			operImg:loadTexture(config.dirUI.common .. "button_green.png")
			operImg:addTouchEventListener(onEmbedTouched)
			operText:setString(hp.lang.getStrByID(3505))
		else
			local gemInfo = hp.gameDataLoader.getInfoBySid("gem", equip.gems[index_])
			gemBg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, gemInfo.level))
			gemNoEmbed:setVisible(false)
			gemImg:setVisible(true)
			gemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, gemInfo.type))
			gemLvBg:setVisible(true)
			gemLv:setVisible(true)
			gemLv:setString(gemInfo.level)
			operImg:loadTexture(config.dirUI.common .. "button_red.png")
			operImg:addTouchEventListener(onUnembedTouched)
			operText:setString(hp.lang.getStrByID(3506))
		end
	end
	for i=1,maxGemNum do
		setGemInfo(i)
	end

	-- attr lv
	local attrNodeDemo = listNode:getItem(1)
	local attrCont = attrNodeDemo:getChildByName("Panel_cont")
	local attrNameNode = attrCont:getChildByName("Label_type")
	local attrNumNode = attrCont:getChildByName("Label_num")
	attrNameNode:setString(hp.lang.getStrByID(3507))
	attrNumNode:setString(equip.lv)

	-- attr
	local function setAttrInfo()
		for i=1, equipAttrNum do
			listNode:removeLastItem()
		end
		equipAttrNum = 0

		for i=1, equipMaxAttr do
			local attrType = equipInfo["type"..i]
			if attrType~=-1 then
				local attrNum = equipInfo["value"..i][equip.lv]
				local attrInfo = hp.gameDataLoader.getInfoBySid("attr", attrType)

				local attrNode = attrNodeDemo:clone()
				attrCont = attrNode:getChildByName("Panel_cont")
				attrNameNode = attrCont:getChildByName("Label_type")
				attrNumNode = attrCont:getChildByName("Label_num")
				attrNameNode:setString(attrInfo.desc)
				attrNumNode:setString("+"..(attrNum/100).."%")

				listNode:pushBackCustomItem(attrNode)
				equipAttrNum = equipAttrNum+1
			end
		end

		for i,gsid in ipairs(equip.gems) do
			if gsid>0 then
				local gemInfo = hp.gameDataLoader.getInfoBySid("gem", gsid)
				for j,v in ipairs(gemInfo.key) do
					local attrInfo = hp.gameDataLoader.getInfoBySid("attr", v)
					local attrNum = gemInfo.value[j]

					local attrNode = attrNodeDemo:clone()
					attrCont = attrNode:getChildByName("Panel_cont")
					attrNameNode = attrCont:getChildByName("Label_type")
					attrNumNode = attrCont:getChildByName("Label_num")
					attrNameNode:setString(attrInfo.desc)
					attrNumNode:setString("+"..(attrNum/100).."%")

					listNode:pushBackCustomItem(attrNode)
					equipAttrNum = equipAttrNum+1
				end
			end
		end
	end
	setAttrInfo()

	function gemCallback()
		setGemInfo(selectPos)
		setAttrInfo()
		bagUI_:refreshSelectedEquip()
	end


	--btn
	local contPanle = widgetRoot:getChildByName("Panel_cont")
	local btnBreak = contPanle:getChildByName("Image_break")
	local btnGetGem = contPanle:getChildByName("Image_get")
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--摧毁成功
				equip:destory()
				bagUI_:refreshSelectedEquip()
				self:close()
				player.addItem(data.sid, 1)
			end
		end
	end
	--
	local function breakEquip()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 7
		oper.type = 3
		oper.id = equip_.id
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
		self:showLoading(cmdSender, btnBreak)
	end
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnGetGem then
				require("ui/item/boxItem")
				local ui = UI_boxItem.new(1, nil)
				self:addUI(ui)
			else
				require("ui/msgBox/warningMsgBox")
				local ui = UI_warningMsgBox.new(hp.lang.getStrByID(3516),
					hp.lang.getStrByID(3517),
					hp.lang.getStrByID(2401),
					hp.lang.getStrByID(2412),
					breakEquip)
				self:addModalUI(ui)
			end
		end
	end
	btnBreak:addTouchEventListener(onBtnTouched)
	btnBreak:getChildByName("Label_text"):setString(hp.lang.getStrByID(3516))
	btnGetGem:addTouchEventListener(onBtnTouched)
	btnGetGem:getChildByName("Label_text"):setString(hp.lang.getStrByID(3305))
end
