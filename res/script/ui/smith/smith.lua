--
-- ui/smith/smith.lua
-- 铁匠铺主界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_smith = class("UI_smith", UI)

--init
function UI_smith:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "smith.json")
	local listNode = widgetRoot:getChildByName("ListView_research")
	local contMake = listNode:getChildByName("Panel_itemMake"):getChildByName("Panel_cont")
	local contCom = listNode:getChildByName("Panel_itemCom"):getChildByName("Panel_cont")
	local contBag = listNode:getChildByName("Panel_itemBag"):getChildByName("Panel_cont")
	local contMaterial = listNode:getChildByName("Panel_itemMaterial"):getChildByName("Panel_cont")
	local contMore = listNode:getChildByName("Panel_moreInfo"):getChildByName("Panel_cont")

	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==contMake then
				require("ui/smith/equipForge")
				local ui = UI_equipForge.new()
				self:addUI(ui)
			elseif sender==contCom then
				require("ui/smith/combine")
				local ui = UI_combine.new()
				self:addUI(ui)
			elseif sender==contBag then
				require("ui/smith/equipBag")
				local ui = UI_equipBag.new()
				self:addUI(ui)
			elseif sender==contMaterial then
				require("ui/smith/material_gem")
				local ui = UI_material_gem.new()
				self:addUI(ui)
			end
		end
	end
	contMake:addTouchEventListener(onItemTouched)
	contCom:addTouchEventListener(onItemTouched)
	contBag:addTouchEventListener(onItemTouched)
	contMaterial:addTouchEventListener(onItemTouched)

	contMake:getChildByName("Label_name"):setString(hp.lang.getStrByID(3301))
	contCom:getChildByName("Label_name"):setString(hp.lang.getStrByID(3302))
	contBag:getChildByName("Label_name"):setString(hp.lang.getStrByID(3303))
	contMaterial:getChildByName("Label_name"):setString(hp.lang.getStrByID(3304))
	contMore:getChildByName("ImageView_more"):getChildByName("Label_more"):setString(hp.lang.getStrByID(1030))
	
	

	
	local MoreBtn = contMore:getChildByName("ImageView_more")
	
	
	
	
	local function MoreBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/smith/smithInfo"
			local moreInfoBox = UI_smithInfo.new(building_)
			self:addModalUI(moreInfoBox)
		end
	end
	
	
	MoreBtn:addTouchEventListener(MoreBtnTouched)
	
	
	
	
	
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(widgetRoot)
end
