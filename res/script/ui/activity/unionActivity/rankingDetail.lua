--
-- ui/activity/unionActivity/rankingDetail.lua
-- 联盟活动_排名奖励详情
--=============================================

require "ui/frame/popFrame"
require "ui/UI"

UI_rankingDetail = class("UI_rankingDetail", UI)


function UI_rankingDetail:init(flag)
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_rankingDetail.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(5655))
	
	wigetRoot:getChildByName("Panel_title"):getChildByName("Label_text"):setString(hp.lang.getStrByID(5648))

	local list = wigetRoot:getChildByName("ListView_detail")
	local item = list:getItem(0):clone()

	-- prepare data
	local rankRewards = {}

	for i = 1001, 1010 do
		local reward = {}
		if flag then
			reward.id = hp.gameDataLoader.getInfoBySid("k_eventRank_a", i).award
			reward.desc = hp.gameDataLoader.getInfoBySid("unionGift", reward.id * 1000 + 1).name
		else
			reward.id = hp.gameDataLoader.getInfoBySid("unionActRank", i).award
			reward.desc = hp.gameDataLoader.getInfoBySid("unionGift", reward.id * 1000 + 1).name
		end
		rankRewards[#rankRewards + 1] = reward
	end

	-- insert list
	for i = 1, #rankRewards do
		local temp_item
		if i == 1 then
			temp_item = list:getItem(0)
		elseif i == #rankRewards then
			temp_item = item
			list:pushBackCustomItem(temp_item)
		else
			temp_item = item:clone()
			list:pushBackCustomItem(temp_item)
		end
		local temp_content = temp_item:getChildByName("Panel_content")
		temp_content:getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.unionGift, rankRewards[i].id))
		temp_content:getChildByName("Label_title"):setString(string.format(hp.lang.getStrByID(5649), i))
		temp_content:getChildByName("Label_desc"):setString(rankRewards[i].desc)
	end

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
