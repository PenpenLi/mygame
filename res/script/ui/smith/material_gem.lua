--
-- ui/smith/material_gem.lua
-- 材料和宝石界面
--===================================
require "ui/fullScreenFrame"


UI_material_gem = class("UI_material_gem", UI)


--init
function UI_material_gem:init(type_)
	-- data
	-- ===============================
	local headerType = 1
	if type_~=nil then
		headerType = type_
	end
	local maxColorLv = 6
	local minColorLv = 1
	local lvE = 0
	local materialList = nil

	-- functions
	local refreshMaterialList

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(3304))
	uiFrame:setTopShadePosY(808)
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "material_gem.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)

	-- tab
	-----------------------------
	local tabPanel = widgetRoot:getChildByName("Panel_headTab")
	local tabGem = tabPanel:getChildByName("ImageView_gem")
	local gemIcon = tabGem:getChildByName("Image_icon")
	tabGem:getChildByName("Label_name"):setString(hp.lang.getStrByID(3308))
	local tabMaterial = tabPanel:getChildByName("ImageView_material")
	local materialIcon = tabMaterial:getChildByName("Image_icon")
	tabMaterial:getChildByName("Label_name"):setString(hp.lang.getStrByID(3309))
	local typeSelected = tabGem
	local scaleSelected = tabGem:getScale()
	local colorSelected = tabGem:getColor()
	local scaleUnselected = tabMaterial:getScale()
	local colorUnselected = tabMaterial:getColor()
	local function tabType(tabNode)
		typeSelected:setScale(scaleUnselected)
		typeSelected:setColor(colorUnselected)
		typeSelected:getChildByName("Image_icon"):setColor(colorUnselected)
		typeSelected:getChildByName("Label_name"):setColor(colorUnselected)
		typeSelected = tabNode
		typeSelected:setScale(scaleSelected)
		typeSelected:setColor(colorSelected)
		typeSelected:getChildByName("Image_icon"):setColor(colorSelected)
		typeSelected:getChildByName("Label_name"):setColor(colorSelected)

		headerType = typeSelected:getTag()
		if headerType==1 then
			maxColorLv = 6
			minColorLv = 1
			lvE = 0
		else
			maxColorLv = 5
			minColorLv = 0
			lvE = 1
		end
	end
	local function onTabTouched(sender, eventType)
		if sender==typeSelected then
			return
		end

		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(colorSelected)
			sender:getChildByName("Image_icon"):setColor(colorSelected)
			sender:getChildByName("Label_name"):setColor(colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(colorSelected)
				sender:getChildByName("Image_icon"):setColor(colorSelected)
				sender:getChildByName("Label_name"):setColor(colorSelected)
			else
				sender:setColor(colorUnselected)
				sender:getChildByName("Image_icon"):setColor(colorUnselected)
				sender:getChildByName("Label_name"):setColor(colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			tabType(sender)
			refreshMaterialList()
		end
	end
	tabGem:addTouchEventListener(onTabTouched)
	tabMaterial:addTouchEventListener(onTabTouched)
	if typeSelected:getTag()~=headerType then
	--切换tab
		tabType(tabPanel:getChildByTag(headerType))
	end

	-- 材料列表
	----------------------------------
	local materialListNode = widgetRoot:getChildByName("ListView_material")
	local materialLine = materialListNode:getItem(0)
	local materialDemo = materialLine:clone()
	self.materialDemo = materialDemo
	materialDemo:retain()
	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if headerType==1 then
				local sid=sender:getTag()
				local gemInfo = hp.gameDataLoader.getInfoBySid("gem", sid)
				require("ui/smith/gemMaterialInfo")
				local ui = UI_gemMaterialInfo.new(1,gemInfo)
				self:addModalUI(ui)
			elseif headerType==2 then
				local sid=sender:getTag()
				local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", sid)
				require("ui/smith/gemMaterialInfo")
				local ui = UI_gemMaterialInfo.new(2,materialInfo)
				self:addModalUI(ui)
			end
		end
	end
	local function setMaterialInfo(lineNode, lineIndex, materialInfo)
		local mframe = lineNode:getChildByName("Panel_frame1"):getChildByTag(lineIndex)
		local textBg = lineNode:getChildByName("Panel_frame2"):getChildByTag(lineIndex)
		local itemImg = lineNode:getChildByName("Panel_cont1"):getChildByTag(lineIndex)
		local itemName = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_name" .. lineIndex)
		local itemNum = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_num" .. lineIndex)

		mframe:setVisible(true)
		textBg:setVisible(true)
		itemImg:setVisible(true)
		itemName:setVisible(true)
		itemNum:setVisible(true)

		mframe:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+lvE))
		if headerType==1 then
			itemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, materialInfo.type))
		else
			itemImg:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
		end
		itemImg:setTag(materialInfo.sid)
		itemImg:addTouchEventListener(onItemTouched)
		itemName:setString(materialInfo.name)
		itemNum:setString(materialList[materialInfo.sid])
	end

	-- 设置材料列表
	function refreshMaterialList()
		local lineNode = nil
		local mNum = 0
		local lineIndex = 0
		local items = nil
		if headerType==1 then
			items = game.data.gem
		else
			items = game.data.equipMaterial
		end
		materialList = clone(player.getItemList())
		materialListNode:removeAllItems()
		for i=maxColorLv, minColorLv, -1 do
			for j, v in ipairs(items) do
				if v.level==i then
				-- 等级排序
					if materialList[v.sid]~=nil and materialList[v.sid]>0 then
					-- 只显示拥有的材料
						mNum = mNum+1
						lineIndex = mNum%3
						if lineIndex==1 then
							lineNode = materialDemo:clone()
							materialListNode:pushBackCustomItem(lineNode)
							lineNode:setTag(math.ceil(mNum/3))
						end
						if lineIndex==0 then
							lineIndex = 3
						end

						setMaterialInfo(lineNode, lineIndex, v)
					end
				end
			end
		end
	end
	refreshMaterialList()
end

--onRemove
function UI_material_gem:onRemove()
	-- must release
	self.materialDemo:release()

	self.super.onRemove(self)
end

