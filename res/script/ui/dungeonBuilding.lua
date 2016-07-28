--
-- ui/dungeonBuilding.lua
-- 地牢界面
--===================================

require "ui/UI"
require "ui/fullScreenFrame"
require "ui/buildingHeader"
require "obj/capture"

UI_dungeonBuilding = class("UI_dungeonBuilding", UI)



--init
function UI_dungeonBuilding:init(building_)


	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
	end


	-- data
	-- ===============================
	-- local b = building_.build
	-- local bInfo = building_.bInfo
	-- local imgPath = building_.imgPath



	-- 无伤兵界面
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	--uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "dungeonBuilding.json")

	local Panel_page = wigetRoot:getChildByName("Panel_page")
	local Panel_all = wigetRoot:getChildByName("Panel_all")

	local ListView_hero = Panel_all:getChildByName("ListView_hero")
	--local Panel_heros = ListView_hero:getChildByName("ListView_hero")
	local Panel_more = ListView_hero:getChildByName("Panel_more")



	ListView_hero:removeLastItem()

	for i,v in ipairs(Capture.getCaptureList().captureList) do

		local Panel_heros = ListView_hero:getChildByName("Panel_heros")
		local ImageView_hero = Panel_heros:getChildByName("ImageView_hero")
		local Label_hero = Panel_heros:getChildByName("Label_hero")
		local Label_level = Panel_heros:getChildByName("Label_level")
		local Label_lord = Panel_heros:getChildByName("Label_lord")
		local Label_alliance = Panel_heros:getChildByName("Label_alliance")
		local ImageView_release = Panel_heros:getChildByName("ImageView_release")
		local ImageView_hero = Panel_heros:getChildByName("ImageView_execute")


		--ImageView_hero:loadTexture(string.format("%s/%s", config.dirUI.soldier, game.data.army[i].image))
		Label_hero:setString(hp.lang.getStrByID(4001)..":"..hp.lang.getStrByID(v.sid))
		Label_level:setString(hp.lang.getStrByID(1039)..":"..hp.lang.getStrByID(v.level))

		Panel_heros = Panel_heros:clone()
		listView:pushBackCustomItem(Panel_heros)	
		--adampt = container:getChildByName("Panel_adampt")		
		--end
	end

	Panel_more:getChildByName("Button_more"):getChildByName("Label_more"):setString(hp.lang.getStrByID(2033))
	listView:pushBackCustomItem(Panel_more)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)

end
