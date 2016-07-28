--
-- ui/productionBuilding.lua
-- 生产建筑界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_productionBuilding = class("UI_productionBuilding", UI)


--init
function UI_productionBuilding:init(building_)
	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo
	local helper = player.helper
	local resInfo = nil
	local resType = nil
	local resTypeNum = 1
	
	if 14==bInfo.showtype then
		--钱庄
		for i,v in ipairs(game.data.villa) do
			if b.lv==v.level then
				resInfo = v
				break
			end
		end
		resTypeNum = 1
		resType = game.data.resType[2]
	else
		for i,v in ipairs(game.data.res) do
			if b.sid==v.buildsid and b.lv==v.level then
				resInfo = v
				break
			end
		end
		resTypeNum = resInfo.type
		resType = game.data.resType[resTypeNum+1]
	end
	local addn = helper.getAttrAddn(100+resTypeNum)


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "productionBuilding.json")
	local listView = wigetRoot:getChildByName("ListView_info")
	local itemDesc = listView:getItem(0)
	local item1 = listView:getItem(1)
	local item2 = listView:getItem(2)
	local itemMore = listView:getItem(3)
	-- desc
	local itemCont = itemDesc:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_desc"):setString(bInfo.desc)
	-- 每小时收入
	local resPath = string.format("%s%s_big.png", config.dirUI.common, resType[1])
	local itemTmp = item1
	itemCont = itemTmp:getChildByName("Panel_cont")
	local itemBg = itemCont:getChildByName("ImageView_bg")
	itemBg:getChildByName("ImageView_res"):loadTexture(resPath)
	itemBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(2034))
	itemBg:getChildByName("Label_num"):setString(math.floor(resInfo.resCount*(1+addn/10000)))
	-- 
	local iIndex = 2
	-- 每小时消耗
	if b.sid==1002 then
		itemTmp = item2
		itemCont = itemTmp:getChildByName("Panel_cont")
		itemBg = itemCont:getChildByName("ImageView_bg")
		itemBg:getChildByName("ImageView_res"):loadTexture(resPath)
		itemBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(2035))
		itemBg:getChildByName("Label_num"):setString("100")
		iIndex = iIndex+1
	else
		listView:removeItem(iIndex)
	end
	-- 库存量
	itemTmp = item1:clone()
	listView:insertCustomItem(itemTmp, iIndex)
	itemCont = itemTmp:getChildByName("Panel_cont")
	itemBg = itemCont:getChildByName("ImageView_bg")
	itemBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(2036))
	itemBg:getChildByName("Label_num"):setString(player.getResource(resType[1]))
	-- 每小时总收入
	iIndex = iIndex+1
	itemTmp = item1:clone()
	listView:insertCustomItem(itemTmp, iIndex)
	itemCont = itemTmp:getChildByName("Panel_cont")
	itemBg = itemCont:getChildByName("ImageView_bg")
	itemBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(2037))
	itemBg:getChildByName("Label_num"):setString(helper.getResOutput(resTypeNum))

	-- 更多操作
	itemCont = itemMore:getChildByName("Panel_cont")
	local btnMore = itemCont:getChildByName("ImageView_moreInfo")
	local btnGet = itemCont:getChildByName("ImageView_getRes")
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnMore then
				if 14==bInfo.showtype then
					require "ui/villa/villaInfo"
					local moreInfoBox = UI_villaInfo.new(building_)
					self:addModalUI(moreInfoBox)
				else
					require "ui/productionBuildingInfo.lua"
					local moreInfoBox = UI_productionBuildingInfo.new(building_)
					self:addModalUI(moreInfoBox)
				end
			elseif sender==btnGet then
				require "ui/item/resourceItem"
				local ui = UI_resourceItem.new(resTypeNum)
				self:addUI(ui)
			end
		end
	end
	btnMore:getChildByName("Label_moreInfo"):setString(hp.lang.getStrByID(2033))
	btnGet:getChildByName("Label_getRes"):setString(hp.lang.getStrByID(2038))
	btnMore:addTouchEventListener(onBtnTouched)
	btnGet:addTouchEventListener(onBtnTouched)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)
end
