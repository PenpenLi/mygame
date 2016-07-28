--
-- ui/altar/altar.lua
-- 祭坛
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_altar = class("UI_altar", UI)

--init
function UI_altar:init(building_)
		-- data
	-- ===============================
	local building = building_
	local bInfo = building_.bInfo
	local dataInfo = nil
	
	for i, v in ipairs(game.data.altar) do
		if building_.build.lv==v.level then
			dataInfo = v
		end
	end

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "altar.json")
	local listView = widgetRoot:getChildByName("ListView_info")
	local itemDesc = listView:getItem(0)
	local itemAtt = listView:getItem(1)
	local itemDef = listView:getItem(2)
	local itemLife = listView:getItem(3)
	local itemSpeed = listView:getItem(4)
	local itemBtn = listView:getItem(5)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(widgetRoot)


	-- desc
	local itemCont = itemDesc:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_desc"):setString(bInfo.desc)

	-- 攻击加成
	itemCont = itemAtt:getChildByName("Panel_cont")
	itemNum = itemCont:getChildByName("ImageView_bg"):getChildByName("Label_num")
	itemNum:setString(dataInfo.attackRate.."%")

	-- 防御加成
	itemCont = itemDef:getChildByName("Panel_cont")
	itemNum = itemCont:getChildByName("ImageView_bg"):getChildByName("Label_num")
	itemNum:setString(dataInfo.defanceRate.."%")

	-- 生命加成
	itemCont = itemLife:getChildByName("Panel_cont")
	itemNum = itemCont:getChildByName("ImageView_bg"):getChildByName("Label_num")
	itemNum:setString(dataInfo.lifeRate.."%")

	-- 行军速度加成
	itemCont = itemSpeed:getChildByName("Panel_cont")
	itemNum = itemCont:getChildByName("ImageView_bg"):getChildByName("Label_num")
	itemNum:setString(dataInfo.speedRate.."%")



	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/altar/alterInfo")
			local ui = UI_altarInfo.new(building)
			self:addUI(ui)
		end
	end

	local itemCont = itemBtn:getChildByName("Panel_cont")
	local moreInfoImg = itemCont:getChildByName("ImageView_moreInfo")

	moreInfoImg:addTouchEventListener(onMoreInfoTouched)


end