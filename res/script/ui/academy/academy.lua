--
-- ui/academy/academy.lua
-- 学院信息
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_academy = class("UI_academy", UI)

--init
function UI_academy:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "academy.json")
	local listNode = widgetRoot:getChildByName("ListView_research")
	local contCombat = listNode:getChildByName("Panel_itemCombat"):getChildByName("Panel_cont")
	local contTrap = listNode:getChildByName("Panel_itemTrap"):getChildByName("Panel_cont")
	local contEconomics = listNode:getChildByName("Panel_itemEconomics"):getChildByName("Panel_cont")
	local contMore = listNode:getChildByName("Panel_moreInfo"):getChildByName("Panel_cont")
	local btnMore = contMore:getChildByName("ImageView_more")
	
	contCombat:getChildByName("BitmapLabel_name"):setString(hp.lang.getStrByID(9101))
	contTrap:getChildByName("BitmapLabel_name"):setString(hp.lang.getStrByID(9102))
	contEconomics:getChildByName("BitmapLabel_name"):setString(hp.lang.getStrByID(9103))
	btnMore:getChildByName("Label_more"):setString(hp.lang.getStrByID(1030))
	
	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==contCombat then
				require("ui/academy/fightTree")
				local ui = UI_fightTree.new()
				self:addUI(ui)
			elseif sender==contTrap then
				require("ui/academy/trapTree")
				local ui = UI_trapTree.new()
				self:addUI(ui)
			elseif sender==contEconomics then
				require("ui/academy/economicsTree")
				local ui = UI_economicsTree.new()
				self:addUI(ui)
			end
		end
	end
	contCombat:addTouchEventListener(onItemTouched)
	contTrap:addTouchEventListener(onItemTouched)
	contEconomics:addTouchEventListener(onItemTouched)
	
	
	local function onbtnMoreTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			require "ui/academy/moreInfoBox"
			local moreInfoBox = UI_moreInfoBox.new(building_)
			self:addModalUI(moreInfoBox)
			
		end
	end
	
	btnMore:addTouchEventListener(onbtnMoreTouched)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(widgetRoot)
end