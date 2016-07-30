--
-- ui/march/viewArmy.lua
-- 部队信息查看
--===================================
require "ui/UI"
require "ui/frame/popFrame"


UI_viewArmy = class("UI_viewArmy", UI)


--init
function UI_viewArmy:init(armyInfo_)
	-- data
	-- ===============================
	self.armyInfo = armyInfo_

	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1408))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_viewArmy:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "viewArmy.json")

	local listView = self.wigetRoot:getChildByName("ListView_5193")

	-- 总兵力 消耗
	local Panel_5946 = listView:getChildByName("Panel_1344"):getChildByName("Panel_5946")
	Panel_5946:getChildByName("Label_5947"):setString(hp.lang.getStrByID(5104))
	Panel_5946:getChildByName("Label_5968"):setString(self.armyInfo.number)

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
	panelTemp:getChildByName("Label_5957"):setString(hp.lang.getStrByID(5105))
	panelTemp:getChildByName("Label_5958"):setString(hp.lang.getStrByID(5106))

	local army = player.soldierManager.getTotalArmy()
	local oneArmyInfo = armyListView:getChildByName("Panel_5883")
	armyListView:removeLastItem()

	for i, v in ipairs(self.armyInfo.soldier) do
		local info_ = player.soldierManager.getArmyInfoByType(i)
		local cloneInfo = oneArmyInfo:clone()
		cloneInfo:getChildByName("Panel_5960"):getChildByName("Label_5957"):setString(info_.name)
		cloneInfo:getChildByName("Panel_5960"):getChildByName("Label_5958"):setString(v)
		armyListView:pushBackCustomItem(cloneInfo)
	end
	adjustHeight(Panel_5194, {armyPanel, PanelContent}, armyListView, globalData.TOTAL_LEVEL)
end
