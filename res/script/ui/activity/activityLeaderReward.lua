--
-- ui/activity/activityLeaderReward.lua
-- 单人活动
--===================================
require "ui/frame/popFrame"

UI_activityLeaderReward = class("UI_activityLeaderReward", UI)

local interval = 0

--init
function UI_activityLeaderReward:init(activity_)
	-- data
	-- ===============================
	self.activity = activity_
	self.leaderReward = self.activity.info.leaderReward

	-- call back

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5346))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item)

	self:initShow()
end

function UI_activityLeaderReward:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "activityLeaderReward.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")
	content_:getChildByName("Label_63"):setString(hp.lang.getStrByID(5347))

	self.listView = self.wigetRoot:getChildByName("ListView_64")
	self.item = self.listView:getChildByName("Panel_119"):clone()
	self.item:retain()
	self.listView:removeLastItem()
end

function UI_activityLeaderReward:initShow()
	local function createItemByindex(index_)
		local info_ = hp.gameDataLoader.getInfoBySid("eventRank", index_ + self.leaderReward - 1)
		cclog_("index_",index_,info_)
		if info_ == nil then
			return nil
		end

		local item_ = self.item:clone()
		local listView_ = item_:getChildByName("ListView_122")
		-- 头
		local content_ = listView_:getChildByName("Panel_136"):getChildByName("Panel_121")
		content_:getChildByName("Label_127"):setString(string.format(hp.lang.getStrByID(5342), index_))

		-- 奖励内容
		-- 金币
		local innerItem_ = listView_:getChildByName("Panel_140")
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
			listView_:insertCustomItem(item_, i + 1)
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
		local size_ = item_:getSize()
		size_.height = size_.height + deltaHeight_
		item_:setSize(size_)
		listView_:setSize(size_)
		return item_
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.item:getSize().height, 2)
	end
	self.listViewHelper.initShow(2)
end

function UI_activityLeaderReward:onRemove()
	self.item:release()
	self.super.onRemove(self)
end