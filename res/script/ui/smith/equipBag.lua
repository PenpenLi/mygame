--
-- ui/smith/equipBag.lua
-- 背包界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_equipBag = class("UI_equipBag", UI)


--init
function UI_equipBag:init()
	-- data
	-- ===============================
	local lineNum = 4
	local equipBag = player.equipBag
	local maxSize = equipBag.getMaxSize()
	local size = equipBag.getSize()
	local equips = equipBag.getEquips()
	local line_unlock = math.ceil(size/lineNum)
	local line_lock = math.ceil((maxSize-size)/lineNum)



	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(3303))
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipBag.json")
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	--
	local listNode = wigetRoot:getChildByName("ListView_equipList")
	local lineDemo = listNode:getChildByName("Panel_itemLine"):clone()
	local lineDemoLock = listNode:getChildByName("Panel_itemLine_lock"):clone()
	self.lineDemo = lineDemo
	lineDemo:retain()
	local bagDemo = wigetRoot:getChildByName("Panel_bag")
	local bagEmptyDemo = wigetRoot:getChildByName("Panel_bag_empty")
	local equipDemo = wigetRoot:getChildByName("Panel_equip")
	local equipCellDemo = wigetRoot:getChildByName("Panel_cell")
	local bagSize = bagDemo:getSize()

	listNode:removeAllItems()

	--设置装备信息
	local lineNode_sed = nil
	local bagNode_sed = nil
	local equipNode_sed = nil
	local equipid_sed = nil
	local function onEquipTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			equipid_sed = sender:getTag()
			equipNode_sed = sender:getParent()
			lineNode_sed = equipNode_sed:getParent()
			bagNode_sed = lineNode_sed:getChildByTag(equipid_sed)

			require("ui/smith/gemEmbed")
			local ui = UI_gemEmbed.new( equipBag.getEquipById(equipid_sed), self)
			self:addUI(ui)
		end
	end
	local function setEquipInfo(bagNode, equipNode, equip)
		local colorBg = bagNode:getChildByName("Image_bg")
		local equipImg = equipNode:getChildByName("Image_equip")
		colorBg:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, equip.lv))
		equipImg:loadTexture(string.format("%s%d.png", config.dirUI.equip, equip.sid))
		equipImg:setTag(equip.id)
		bagNode:setTag(equip.id)
		equipImg:addTouchEventListener(onEquipTouched)

		for i,v in ipairs(equip.gems) do
			if v>0 then
				local gemImg = equipNode:getChildByName("Image_gem" .. i)
				gemImg:setVisible(true)
				gemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, v))
			else
				equipNode:getChildByName("Image_gem" .. i):setVisible(false)
			end
		end

		if equip:isEquiped() then
			equipNode:getChildByName("Image_onFlag"):setVisible(true)
		end
	end
	local function refreshSelectedEquip()
		local equip_sed = equipBag.getEquipById(equipid_sed)
		if equip_sed==nil then
		--装备消失
			local bagNode = bagEmptyDemo:clone()
			bagNode:setPosition(bagNode_sed:getPosition())
			lineNode_sed:removeChild(bagNode_sed)
			lineNode_sed:removeChild(equipNode_sed)
			lineNode_sed:addChild(bagNode)
		else
			setEquipInfo(bagNode_sed, equipNode_sed, equip_sed)
		end
	end
	self.refreshSelectedEquip = refreshSelectedEquip

	local lineNode = nil
	local bagNode = nil
	local equipNode = nil
	local cellNode = nil
	for i=1, size do
		local linePos = i%lineNum
		local px = 0
		if linePos==0 then
			px = (lineNum-1)*bagSize.width
		else
			px = (linePos-1)*bagSize.width
		end

		if linePos==1 then
			lineNode = lineDemo:clone()
			listNode:pushBackCustomItem(lineNode)
		end

		if equips[i]==nil then
			bagNode = bagEmptyDemo:clone()
			bagNode:setPosition(px, 0)
			lineNode:addChild(bagNode)
		else
			bagNode = bagDemo:clone()
			bagNode:setPosition(px, 0)
			lineNode:addChild(bagNode)
			cellNode = equipCellDemo:clone()
			cellNode:setPosition(px, 0)
			lineNode:addChild(cellNode)
			equipNode = equipDemo:clone()
			equipNode:setPosition(px, 0)
			lineNode:addChild(equipNode)	
			setEquipInfo(bagNode, equipNode, equips[i])
		end
	end

	-- 扩充背包
	local function onExtendBag()
		listNode:removeItem(line_unlock)
		lineNode = lineDemo:clone()
		listNode:insertCustomItem(lineNode, line_unlock)
		for i=1, lineNum do
			px = (i-1)*bagSize.width
			bagNode = bagEmptyDemo:clone()
			bagNode:setPosition(px, 0)
			lineNode:addChild(bagNode)
		end

		line_unlock = line_unlock+1
		line_lock = line_lock-1
		equipBag.extendSize(lineNum)
	end
	local function canExtend()
		print(equipBag.getSize(), equipBag.getMaxSize() )
		if equipBag.getSize()<equipBag.getMaxSize() then
			return true
		end

		-- 金币不够
		require("ui/msgBox/msgBox")
		local msgBox = UI_msgBox.new(hp.lang.getStrByID(3402), 
			hp.lang.getStrByID(3403), 
			hp.lang.getStrByID(1209)
			)
		self:addModalUI(msgBox)
		return false
	end
	local function onLockImgTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/commonItem")
			local ui = UI_commonItem.new(20550, hp.lang.getStrByID(3401), canExtend, onExtendBag)
			self:addUI(ui)
		end
	end
	for i=1, line_lock do
		lineNode = lineDemoLock:clone()
		listNode:pushBackCustomItem(lineNode)
		lineNode:getChildByName("Panel_frame"):getChildByName("Image_lock"):addTouchEventListener(onLockImgTouched)
	end
end


--onRemove
function UI_equipBag:onRemove()
	-- must release
	self.lineDemo:release()

	self.super.onRemove(self)
end
