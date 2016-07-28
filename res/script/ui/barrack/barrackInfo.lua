--
-- ui/barrack/barrackInfo.lua
-- 兵营更多信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"


UI_barrackInfo = class("UI_barrackInfo", UI)

local extralReward = {{5,5160},{10,5161},{15,5162},{20,5163},{21,5164}}

--init
function UI_barrackInfo:init(building_)
	-- data
	-- ===============================
	self.building = building_

	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, building_.bInfo.name)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_barrackInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "barrackInfo.json")

	local listView = self.wigetRoot:getChildByName("ListView_5193")

	self.uiItem = listView:getChildByName("Panel_5200"):clone()
	self.uiItem:retain()
	listView:removeLastItem()
	self.uiSubTitle = listView:getChildByName("Panel_5199"):clone()
	listView:removeLastItem()
	self.uiSubTitle:retain()
	self.uiTitle = listView:getChildByName("Panel_5198"):clone()
	listView:removeLastItem()
	self.uiTitle:retain()

	-- 描述
	self.wigetRoot:getChildByName("Panel_1277"):getChildByName("Label_1278"):setString(hp.lang.getStrByID(1031))

	-- 总兵力 消耗
	local Panel_5946 = listView:getChildByName("Panel_1344"):getChildByName("Panel_5946")
	Panel_5946:getChildByName("Label_5947"):setString(hp.lang.getStrByID(1032))
	Panel_5946:getChildByName("Label_5968"):setString(string.format(hp.lang.getStrByID(1011), player.getTotalArmy():getSoldierTotalNumber()))
	Panel_5946:getChildByName("Label_5969"):setString(string.format(hp.lang.getStrByID(1033), player.getTotalArmy():getCharge()))

	local function adjustHeight(parent_, panelList_, listView_, num_)
		local deltaHeight = 31 * num_
		local size_ = parent_:getSize()
		size_.height = size_.height + deltaHeight
		parent_:setSize(size_)

		for i,v in ipairs(panelList_) do
			for i,v in ipairs(v:getChildren()) do
				local x_, y_ = v:getPosition()
				v:setPosition(x_, y_ + deltaHeight)
			end
		end
		size_ = listView_:getSize()
		size_.height = size_.height + deltaHeight
		listView_:setSize(size_)
	end

	-- 我的军队
	local Panel_5194 = listView:getChildByName("Panel_5194")
	local PanelContent = Panel_5194:getChildByName("Panel_5946")
	local armyPanel = Panel_5194:getChildByName("Panel_5876")
	local armyListView = Panel_5194:getChildByName("ListView_5881")
	PanelContent:getChildByName("Label_5947"):setString(hp.lang.getStrByID(1034))
	local panelTemp = armyListView:getChildByName("Panel_5882"):getChildByName("Panel_5956")
	panelTemp:getChildByName("Label_5957"):setString(hp.lang.getStrByID(1040))
	panelTemp:getChildByName("Label_5958"):setString(hp.lang.getStrByID(1041))

	local army = player.getTotalArmy()
	local oneArmyInfo = armyListView:getChildByName("Panel_5883")
	armyListView:removeLastItem()

	for i = 1, player.getSoldierType() do
		local name = army:getSoldierByType(i):getSoldierInfo().name
		local num = army:getSoldierByType(i):getNumber()
		local cloneInfo = oneArmyInfo:clone()
		cloneInfo:getChildByName("Panel_5960"):getChildByName("Label_5957"):setString(name)
		cloneInfo:getChildByName("Panel_5960"):getChildByName("Label_5958"):setString(num)
		armyListView:pushBackCustomItem(cloneInfo)
	end
	adjustHeight(Panel_5194, {armyPanel, PanelContent}, armyListView, player.getSoldierType())

	-- 兵营信息
	local Panel_5196 = listView:getChildByName("Panel_5196")
	local Panel_5877 = Panel_5196:getChildByName("Panel_5877")
	local ListView_5908 = Panel_5196:getChildByName("ListView_5908")
	local oneBuildInfo = ListView_5908:getChildByName("Panel_5883")
	PanelContent = Panel_5196:getChildByName("Panel_5946")
	PanelContent:getChildByName("Label_5947"):setString(hp.lang.getStrByID(1035))
	local panelTemp = ListView_5908:getChildByName("Panel_5882"):getChildByName("Panel_5956")
	panelTemp:getChildByName("Label_5957"):setString(hp.lang.getStrByID(1039))
	panelTemp:getChildByName("Label_5958"):setString(hp.lang.getStrByID(1038))
	ListView_5908:removeLastItem()

	local totalLevel = table.getn(game.data.barrack)
	for i = 1, totalLevel do
		local cloneInfo = oneBuildInfo:clone()
		local level = game.data.barrack[i].level
		cloneInfo:getChildByName("Panel_5960"):getChildByName("Label_5957"):setString(level)
		cloneInfo:getChildByName("Panel_5960"):getChildByName("Label_5958"):setString(game.data.barrack[i].soldierMax)
		ListView_5908:pushBackCustomItem(cloneInfo)
		-- 当前选中效果
		if self.building.build.lv == level then
			local bgImage = ccui.ImageView:create()
			bgImage:loadTexture(config.dirUI.common.."ui_barrack_current.png")
			bgImage:setPosition(cc.p(320, 15))			
			cloneInfo:getChildByName("Panel_5883"):addChild(bgImage)
		end
	end
	adjustHeight(Panel_5196, {Panel_5877, PanelContent}, ListView_5908, totalLevel)

	-- 总兵营奖励
	local panelBarrackAward = listView:getChildByName("Panel_5197"):getChildByName("Panel_5946")
	panelBarrackAward:getChildByName("Label_5947"):setString(hp.lang.getStrByID(1036))
	panelBarrackAward:getChildByName("Label_5970"):setString(string.format(hp.lang.getStrByID(1045), "0"))
	panelBarrackAward:getChildByName("Label_6145"):setString(string.format(hp.lang.getStrByID(1044), "0"))
	panelBarrackAward:getChildByName("Label_6146"):setString(string.format(hp.lang.getStrByID(1043), "0"))

	-- 额外福利
	local title_ = self.uiTitle:clone()
	title_:getChildByName("Panel_5946"):getChildByName("Label_5947"):setString(hp.lang.getStrByID(1037))
	listView:pushBackCustomItem(title_)

	local subTitle_ = self.uiSubTitle:clone()
	local content_ = subTitle_:getChildByName("Panel_5956")
	content_:getChildByName("Label_5957"):setString(hp.lang.getStrByID(1039))
	content_:getChildByName("Label_5958"):setString(hp.lang.getStrByID(5158))
	listView:pushBackCustomItem(subTitle_)

	for i, v in ipairs(extralReward) do
		local item_ = self.uiItem:clone()
		local content_ = item_:getChildByName("Panel_5960")
		content_:getChildByName("Label_5957"):setString(v[1])
		content_:getChildByName("Label_5958"):setString(hp.lang.getStrByID(v[2]))
		listView:pushBackCustomItem(item_)
	end
end

function UI_barrackInfo:close()
	self.uiItem:release()
	self.uiSubTitle:release()
	self.uiTitle:release()
	self.super.close(self)
end