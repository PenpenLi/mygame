--
-- ui/mainBuilding.lua
-- 主基地界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_mainBuilding = class("UI_mainBuilding", UI)


--init
function UI_mainBuilding:init(building_)
	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo
	local imgPath = building_.imgPath
	local helper = player.helper


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainBuilding.json")
	local listView = wigetRoot:getChildByName("ListView_info")
	local cityNode = listView:getItem(0)
	local armyNode = listView:getItem(1)
	local foodNode = listView:getItem(2)
	local resNode = listView:getItem(3)
	local moreNode = listView:getItem(4)
	-- city
	local itemCont = cityNode:getChildByName("Panel_cont")
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.building .. "fudi_icon.png")
	local infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_t1"):setString(hp.lang.getStrByID(1902))
	infoNode:getChildByName("Label_1"):setString(player.getName())
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1903), player.getName()))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1904), player.getName()))
	infoNode:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(1905), player.getName()))
	-- 战斗力
	itemCont = armyNode:getChildByName("Panel_cont")
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(hp.lang.getStrByID(1907))
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1908), 100))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1909), 2))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1910), 200))
	infoNode:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(1911), 3000))
	-- 粮食
	local iIndex = 3
	itemCont = foodNode:getChildByName("Panel_cont")
	itemCont:getChildByName("ImageView_titleBg"):getChildByName("Label_title"):setString(game.data.resType[iIndex][2])
	infoNode = itemCont:getChildByName("Panel_info")
	infoNode:getChildByName("Label_1"):setString(string.format(hp.lang.getStrByID(1912), helper.getResOutput(2)))
	infoNode:getChildByName("Label_2"):setString(string.format(hp.lang.getStrByID(1913), 2))
	infoNode:getChildByName("Label_3"):setString(string.format(hp.lang.getStrByID(1914), player.getResource(game.data.resType[iIndex][1])))
	infoNode:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(1915), helper.getResCapacity(2)))
	-- 银币
	iIndex = 2
	itemCont = resNode:getChildByName("Panel_cont")
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

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)
end
