--
-- ui/mainBuilding.lua
-- 主基地界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_mainBuilding = class("UI_mainBuilding", UI)

local tabID = 1
local titleID_ = {5240, 5278, 5239}

--init
function UI_mainBuilding:init(building_)
	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo
	local imgPath = building_.imgPath
	local helper = player.helper

	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mainBuilding/mainBuildLevel2"
			local ui_ = UI_mainBuildLevel2.new(sender:getTag())
			self:addUI(ui_)
		end
	end

	self.uiTab = {}
	self.label = {}

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	uiFrame:setTopShadePosY(666)
	local uiHeader = UI_buildingHeader.new(building_)

	self:registMsg(hp.MSG.CHANGE_CITYNAME)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainBuilding.json")
	local content_ = wigetRoot:getChildByName("Panel_headCont")
	local listView = wigetRoot:getChildByName("ListView_info")
	local cityNode = listView:getItem(0)
	local armyNode = listView:getItem(1)
	local foodNode = listView:getItem(2)
	local resNode = listView:getItem(3)
	local moreNode = listView:getItem(4)

	-- city
	local itemCont = cityNode:getChildByName("Panel_cont")
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.building .. "fudi_icon.png")
	self.cityName = itemCont:getChildByName("Label_2")
	self.cityName:setString(string.format(hp.lang.getStrByID(1903), player.getName()))
	itemCont:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(5494) .. "：%s", player.serverMgr.getMyCountry()))
	local pos = player.serverMgr.getMyPosition()
	itemCont:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(5101), player.serverMgr.getMyServer().name, pos.x, pos.y))
	local changeName_ = itemCont:getChildByName("ImageView_rename")
	changeName_:getChildByName("Label_443"):setString(hp.lang.getStrByID(5246))
	-- 战斗力
	itemCont = armyNode:getChildByName("Panel_cont")
	armyNode:setTag(1)
	armyNode:addTouchEventListener(onItemTouched)
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(hp.lang.getStrByID(1907))
	infoNode = itemCont:getChildByName("Panel_info")
	local numPerTroop_ = player.helper.getNumPerTroop()
	local troopNum_ = helper.getTroopNum()
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1908), player.soldierManager.getTotalArmy():getSoldierTotalNumber()))
	infoNode:getChildByName("Label_4_0"):setString(string.format(hp.lang.getStrByID(5238), numPerTroop_ * troopNum_))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1909), troopNum_))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1910), numPerTroop_))
	infoNode:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(1911), player.soldierManager.getTotalArmy():getArmyLoaded()))
	-- 粮食
	local iIndex = 3
	itemCont = foodNode:getChildByName("Panel_cont")
	foodNode:addTouchEventListener(onItemTouched)
	foodNode:setTag(2)
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(game.data.resType[iIndex][2])
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1912), helper.getResOutput(2)))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1913), player.soldierManager.getTotalArmy():getCharge()))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1914), player.getResource(game.data.resType[iIndex][1])))
	infoNode:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(1915), helper.getResCapacity(2)))
	-- 银币
	iIndex = 2
	itemCont = resNode:getChildByName("Panel_cont")
	resNode:addTouchEventListener(onItemTouched)
	resNode:setTag(3)
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(game.data.resType[iIndex][2])
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. game.data.resType[iIndex][1] .. "_big.png")
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1912), helper.getResOutput(1)))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1914), player.getResource(game.data.resType[iIndex][1])))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1915), helper.getResCapacity(1)))
	-- 木材
	iIndex = 4
	local nodeTmp = resNode:clone()
	listView:insertCustomItem(nodeTmp, iIndex)
	itemCont = nodeTmp:getChildByName("Panel_cont")
	nodeTmp:addTouchEventListener(onItemTouched)
	nodeTmp:setTag(4)
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(game.data.resType[iIndex][2])
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. game.data.resType[iIndex][1] .. "_big.png")
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1912), helper.getResOutput(3)))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1914), player.getResource(game.data.resType[iIndex][1])))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1915), helper.getResCapacity(3)))
	-- 石头
	local iIndex = 5
	local nodeTmp = resNode:clone()
	listView:insertCustomItem(nodeTmp, iIndex)
	itemCont = nodeTmp:getChildByName("Panel_cont")
	nodeTmp:addTouchEventListener(onItemTouched)
	nodeTmp:setTag(5)
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(game.data.resType[iIndex][2])
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. game.data.resType[iIndex][1] .. "_big.png")
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1912), helper.getResOutput(4)))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1914), player.getResource(game.data.resType[iIndex][1])))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1915), helper.getResCapacity(4)))
	-- 矿石
	local iIndex = 6
	local nodeTmp = resNode:clone()
	listView:insertCustomItem(nodeTmp, iIndex)
	itemCont = nodeTmp:getChildByName("Panel_cont")
	nodeTmp:addTouchEventListener(onItemTouched)
	nodeTmp:setTag(6)
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(game.data.resType[iIndex][2])
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. game.data.resType[iIndex][1] .. "_big.png")
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1912), helper.getResOutput(5)))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1914), player.getResource(game.data.resType[iIndex][1])))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1915), helper.getResCapacity(5)))
	--更多信息
	local imgBtnMore = moreNode:getChildByName("Panel_cont"):getChildByName("ImageView_titleBg")
	imgBtnMore:getChildByName("Label_title"):setString(hp.lang.getStrByID(2033))
	local function onBtnMoreTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mainBuildingInfo"
			local moreInfoBox = UI_mainBuildingInfo.new(building_)
			self:addModalUI(moreInfoBox)
		end
	end
	imgBtnMore:addTouchEventListener(onBtnMoreTouched)

	local function onChangeNameTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/mainBuilding/cityChangeName"
			local moreInfoBox = UI_cityChangeName.new()
			self:addUI(moreInfoBox)
		end
	end
	changeName_:addTouchEventListener(onChangeNameTouched)

	local function onTabTouched(sender, eventType)
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.label[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.label[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.label[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			require "ui/mainBuilding/mainBuildInfo"
			local ui_ = UI_mainBuildingProfile.new(building_, sender:getTag())
			self:addUI(ui_)
			self:close()
		end
	end

	--======================================
	for i = 1, 3 do
		self.uiTab[i] = content_:getChildByName("ImageView_"..i)
		self.label[i] = content_:getChildByName("Label_"..i)
		self.label[i]:setString(hp.lang.getStrByID(titleID_[i]))
		if tabID ~= i then
			self.uiTab[i]:setTag(i)
			self.uiTab[i]:addTouchEventListener(onTabTouched)
		end
	end
	self.colorSelected = self.label[1]:getColor()
	self.colorUnselected = self.label[2]:getColor()
	--======================================

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)
end

function UI_mainBuilding:onMsg(msg_, param_)
	if msg_ == hp.MSG.CHANGE_CITYNAME then
		self.cityName:setString(string.format(hp.lang.getStrByID(1903), player.getName()))
	end
end