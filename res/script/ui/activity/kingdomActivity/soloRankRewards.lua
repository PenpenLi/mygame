--
-- ui/activity/kingdomActivity/soloRankRewards.lua
-- 单人排名奖励详情
--=============================================

require "ui/frame/popFrame"
require "ui/UI"

UI_soloRankRewards = class("UI_soloRankRewards", UI)

local rewards
local index

-- 初始化
function UI_soloRankRewards:init()
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_unionRankRewards.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(5655))
	
	wigetRoot:getChildByName("Panel_title"):getChildByName("Label_text"):setString(hp.lang.getStrByID(5347))

	self.list1 = wigetRoot:getChildByName("ListView_detail")
	self.baseItem = self.list1:getItem(0):clone()
	self.baseItem:retain()
	self.list1:removeAllItems()

	self.wigetRoot = wigetRoot

	-- 准备数据
	index = 1
	rewards = {}
	for i = 1001, 1100 do
		local reward_info = hp.gameDataLoader.getInfoBySid("k_eventRank_e", i)
		local reward = {}
		reward.gold = reward_info.gold
		reward.item = reward_info.item
		table.insert(rewards, reward)
	end
	self.rewards = rewards

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	self:pushItem(5)

	local function onScrollEvent(t1, t2, t3)
		if t2 == ccui.ScrollviewEventType.scrollToBottom then
			if index <= 95 then
				self:pushItem(5)
			else
				self:pushItem(100 - index)
			end
		end
	end
	self.list1:addEventListenerScrollView(onScrollEvent)
end

-- 添加子项
function UI_soloRankRewards:pushItem(count)
	if count == 0 then
		return
	end

	for i = index, index + count do
		local item1 = self.baseItem:clone()
		self.list1:pushBackCustomItem(item1)

		local list2 = item1:getChildByName("ListView_rewards")
		list2:getItem(0):getChildByName("Panel_content"):getChildByName("Label_title"):setString(string.format(hp.lang.getStrByID(5342), i))

		local baseItem2 = list2:getItem(1):clone()
		for j = 1, #self.rewards[i].item + 1 do
			local item2
			if j == 1 then
				item2 = list2:getItem(1)
				item2:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(config.dirUI.common .. "gold2.png")
				item2:getChildByName("Panel_content"):getChildByName("Label_desc"):setString(hp.lang.getStrByID(6018))
				item2:getChildByName("Panel_content"):getChildByName("Label_num"):setString(self.rewards[i].gold)
			elseif j == #self.rewards[i].item + 1 then
				item2 = baseItem2
				list2:pushBackCustomItem(item2)
			else
				item2 = baseItem2:clone()
				list2:pushBackCustomItem(item2)
			end
			if j ~= 1 then
				local reward_info = hp.gameDataLoader.getInfoBySid("item", self.rewards[i].item[j-1])
				item2:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(config.dirUI.item .. self.rewards[i].item[j-1] .. ".png")
				item2:getChildByName("Panel_content"):getChildByName("Label_desc"):setString(reward_info.name)
				item2:getChildByName("Panel_content"):getChildByName("Label_num"):setString(1)
			end
		end
		-- change size
		local addHeight = baseItem2:getSize().height * #self.rewards[i].item
		local size = list2:getSize()
		size.height = size.height + addHeight
		list2:setSize(size)
		local size = item1:getSize()
		size.height = size.height + addHeight
		item1:setSize(size) 
	end
	index = index + count + 1
end

function UI_soloRankRewards:onRemove()
	self.baseItem:release()
	self.super.onRemove(self)
end