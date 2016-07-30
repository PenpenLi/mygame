--
-- ui/activity/activityHistoryReward.lua
-- 单人活动
--===================================
require "ui/frame/popFrame"

UI_activityHistoryReward = class("UI_activityHistoryReward", UI)

local interval = 0

--init
function UI_activityHistoryReward:init(player_)
	-- data
	-- ===============================
	self.player = player_

	-- call back

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5346))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	self:initShow()
end

function UI_activityHistoryReward:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "activityHistoryReward.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")
	-- 恭喜
	content_:getChildByName("Label_63"):setString(hp.lang.getStrByID(5349))
	-- 玩家名
	local name_ = self.player.name
	if self.player.unionName ~= "" then
		name_ = hp.lang.getStrByID(21)..self.player.unionName..hp.lang.getStrByID(22)..name_
	end
	content_:getChildByName("Label_63_0"):setString(name_)
	-- 描述
	content_:getChildByName("Label_63_1"):setString(hp.lang.getStrByID(5352))

	self.listView = self.wigetRoot:getChildByName("ListView_122")
end

function UI_activityHistoryReward:initShow()
	local info_ = hp.gameDataLoader.getInfoBySid("eventRank", self.player.reward)
	if info_ == nil then
		return
	end

	-- 头
	local content_ = self.listView:getChildByName("Panel_136"):getChildByName("Panel_121")
	content_:getChildByName("Label_127"):setString(string.format(hp.lang.getStrByID(5342), self.player.rank))

	-- 奖励内容
	-- 金币
	local innerItem_ = self.listView:getChildByName("Panel_140")
	innerItem_:getChildByName("Panel_141"):getChildByName("Image_143"):setVisible(false)
	local content_ = innerItem_:getChildByName("Panel_142")
	local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", 1)
	-- 图标
	content_:getChildByName("Image_146"):loadTexture(config.dirUI.common.."gold2.png")
	-- 名称
	content_:getChildByName("Label_147"):setString(info_.gold..resInfo_.name)
	-- 数量
	content_:getChildByName("Label_147_0"):setString(1)

	-- 道具
	for i, v in ipairs(info_.item) do
		local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", v)
		local item_ = innerItem_:clone()
		if i%2 == 1 then
			item_:getChildByName("Panel_141"):getChildByName("Image_143"):setVisible(true)
		end
		content_ = item_:getChildByName("Panel_142")
		self.listView:insertCustomItem(item_, i + 1)
		if itemInfo_ ~= nil then
			-- 图标
			content_:getChildByName("Image_146"):loadTexture(config.dirUI.item..v..".png")
			-- 名称
			content_:getChildByName("Label_147"):setString(itemInfo_.name)
			-- 数量
			content_:getChildByName("Label_147_0"):setString(1)
		end
	end

	local num_ = table.getn(info_.item)
	local deltaHeight_ = num_ * innerItem_:getSize().height
	local size_ = self.listView:getSize()
	size_.height = size_.height + deltaHeight_
	self.listView:setSize(size_)
	local x_, y_ = self.listView:getPosition()
	self.listView:setPosition(x_, y_ - deltaHeight_)
end