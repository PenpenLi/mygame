--
-- ui/activity/unionActivity/rewards.lua
-- 联盟活动_奖励
--=============================================

UI_rewards = class("UI_rewards", UI)

local data

function UI_rewards:init(data_)

	data = data_

	self:initUI()
end

function UI_rewards:initUI()
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_rewards.json")
	local list = widget:getChildByName("ListView_rewards")

	-- activity info
	local activity_info = hp.gameDataLoader.getInfoBySid("allienceEvent", data.sid)

	-- panel title
	local panel_title = list:getChildByName("Panel_title")
	local content_title = panel_title:getChildByName("Panel_content")

	content_title:getChildByName("Label_text1"):setString(hp.lang.getStrByID(5616))
	content_title:getChildByName("Label_text2"):setString(hp.lang.getStrByID(5617))

	-- panel rewards
	local item = list:getChildByName("Panel_item")
	local content = item:getChildByName("Panel_content")
	content:getChildByName("Label_nameText"):setString(hp.lang.getStrByID(5640))
	content:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(5641))
	content:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(5642))

	list:pushBackCustomItem(list:getChildByName("Panel_item"):clone())
	list:pushBackCustomItem(list:getChildByName("Panel_item"):clone())

	local rewards = {}
	rewards[1] = activity_info.reward1
	rewards[2] = activity_info.reward2
	rewards[3] = activity_info.reward3

	for i = 1, 3 do
		local temp_item = list:getItem(i)
		local temp_content = temp_item:getChildByName("Panel_content")

		temp_content:getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.unionGift, rewards[i]))
		if data.score > activity_info.points[i] then
			temp_content:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right1.png")
		end

		temp_content:getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(5643), 
			hp.gameDataLoader.getInfoBySid("unionGift", rewards[i] * 1000 + 1).name))
		temp_content:getChildByName("Label_score"):setString(activity_info.points[i])
	end

	self:addCCNode(widget)
end