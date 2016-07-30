--
-- ui/activity/unionActivity/ranking.lua
-- 联盟活动_排名
--=============================================

UI_ranking = class("UI_ranking", UI)

local data

function UI_ranking:init(data_)
	
	data = data_

	self:initUI()
end

function UI_ranking:initTouchEvent()
	
	-- 查看全部
	local function checkAllRewards(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/activity/unionActivity/rankingDetail"
			local ui = UI_rankingDetail.new()
			self:addModalUI(ui)
		end
	end
	self.checkAllRewards = checkAllRewards
end

function UI_ranking:initUI()
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_ranking.json")
	local list = widget:getChildByName("ListView_ranking")

	self:initTouchEvent()

	-- rewads info
	local rewads_id = hp.gameDataLoader.getInfoBySid("allienceEvent", data.sid).leaderReward
	local rewards_info = hp.gameDataLoader.getInfoBySid("unionActRank", rewads_id)

	-- panel title
	local panel_title = list:getItem(0)
	panel_title:getChildByName("Panel_content"):getChildByName("Label_text"):setString(hp.lang.getStrByID(5644))

	-- panel ending
	local panel_ending = list:getItem(2)
	panel_ending:getChildByName("Panel_content"):getChildByName("Label_text"):setString(hp.lang.getStrByID(5645))

	-- panel rewards
	local panel_rewards = list:getItem(1)
	local content_rewards = panel_rewards:getChildByName("Panel_content")

	content_rewards:getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.unionGift, rewards_info.award))
	content_rewards:getChildByName("Label_title"):setString(hp.lang.getStrByID(5646))
	content_rewards:getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(5643), 
		hp.gameDataLoader.getInfoBySid("unionGift", rewards_info.award * 1000 + 1).name))
	content_rewards:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(5647))

	content_rewards:getChildByName("Image_btn"):addTouchEventListener(self.checkAllRewards)

	self:addCCNode(widget)
end