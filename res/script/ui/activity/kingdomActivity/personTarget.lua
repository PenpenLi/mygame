--
-- ui/activity/kindomActivity/personTarget.lua
-- 个人目标
--=============================================

UI_personTarget = class("UI_personTarget", UI)

-- 初始化
function UI_personTarget:init()
	self:initUI()
end

-- 初始化UI
function UI_personTarget:initUI()
	-- ui
	-- ===========
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_personTarget.json")

	-- 设置静态数据
	local list = widget:getChildByName("ListView_root")

	local activity = player.kingdomActivityMgr.getActivity()
	local activity_id = activity.sid
	local activity_info = hp.gameDataLoader.getInfoBySid("kingEvent", activity_id)

	local frame_score = list:getItem(0):getChildByName("Panel_frame")
	local content_score = list:getItem(0):getChildByName("Panel_content")
	content_score:getChildByName("Label_title"):setString(hp.lang.getStrByID(11131))
	content_score:getChildByName("Label_time"):setString(hp.lang.getStrByID(11132))
	content_score:getChildByName("Label_score"):setString(hp.lang.getStrByID(11131))

	content_score:getChildByName("Label_score2"):setString(activity.perScore)
	local progress = frame_score:getChildByName("Image_proBg"):getChildByName("ProgressBar_score")

	if activity.perScore < activity_info.soloTarget[1] then
		progress:setPercent(33 * activity.perScore / activity_info.soloTarget[1])
	elseif activity.perScore < activity_info.soloTarget[2] then
		local score = activity.perScore - activity_info.soloTarget[1]
		local scoreMax = activity_info.soloTarget[2] - activity_info.soloTarget[1]
		progress:setPercent(33 + 33 * score / scoreMax)
	elseif activity.perScore < activity_info.soloTarget[3] then
		local score = activity.perScore - activity_info.soloTarget[2]
		local scoreMax = activity_info.soloTarget[3] - activity_info.soloTarget[2]
		progress:setPercent(67 + 33 * score / scoreMax)
	else
		progress:setPercent(100)
	end

	self.label_time = content_score:getChildByName("Label_time2")

	content_score:getChildByName("Label_target1"):setString(string.format(hp.lang.getStrByID(11133), activity_info.soloTarget[1]))
	content_score:getChildByName("Label_target2"):setString(string.format(hp.lang.getStrByID(11133), activity_info.soloTarget[2]))
	content_score:getChildByName("Label_target3"):setString(string.format(hp.lang.getStrByID(11133), activity_info.soloTarget[3]))

	local content_rewards = list:getItem(1):getChildByName("Panel_content")
	content_rewards:getChildByName("Label_title"):setString(hp.lang.getStrByID(11134))

	local content_rewards1 = list:getItem(1):getChildByName("Panel_content1")
	local content_rewards2 = list:getItem(1):getChildByName("Panel_content2")
	local content_rewards3 = list:getItem(1):getChildByName("Panel_content3")

	-- panel 1
	-- ================
	content_rewards1:getChildByName("Label_nameText"):setString(string.format(hp.lang.getStrByID(11135), 1))
	content_rewards1:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(11136))
	content_rewards1:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(11137))
	content_rewards1:getChildByName("Label_valueText"):setString(hp.lang.getStrByID(11145))
	if activity.perScore > activity_info.soloTarget[1] then
		content_rewards1:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right.png")
	end

	local reward1_id = activity_info.soloReward1[1]
	local reward1_info = hp.gameDataLoader.getInfoBySid("item", reward1_id)
	content_rewards1:getChildByName("BitmapLabel_num"):setString(activity_info.soloReward1[2])
	content_rewards1:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. reward1_id .. ".png")
	content_rewards1:getChildByName("Label_desc"):setString(reward1_info.name)
	content_rewards1:getChildByName("Label_score"):setString(activity_info.soloTarget[1])
	content_rewards1:getChildByName("Label_value"):setString(activity_info.soloReward1[2] * reward1_info.sale)

	-- panel 2
	-- ================
	content_rewards2:getChildByName("Label_nameText"):setString(string.format(hp.lang.getStrByID(11135), 2))
	content_rewards2:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(11136))
	content_rewards2:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(11137))
	content_rewards2:getChildByName("Label_valueText"):setString(hp.lang.getStrByID(11145))
	if activity.perScore > activity_info.soloTarget[2] then
		content_rewards2:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right.png")
	end

	local reward2_id = activity_info.soloReward2[1]
	local reward2_info = hp.gameDataLoader.getInfoBySid("item", reward2_id)
	content_rewards2:getChildByName("BitmapLabel_num"):setString(activity_info.soloReward2[2])
	content_rewards2:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. reward2_id .. ".png")
	content_rewards2:getChildByName("Label_desc"):setString(reward2_info.name)
	content_rewards2:getChildByName("Label_score"):setString(activity_info.soloTarget[2])
	content_rewards2:getChildByName("Label_value"):setString(activity_info.soloReward2[2] * reward2_info.sale)

	-- panel 3
	-- ================
	content_rewards3:getChildByName("Label_nameText"):setString(string.format(hp.lang.getStrByID(11135), 3))
	content_rewards3:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(11136))
	content_rewards3:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(11137))
	content_rewards3:getChildByName("Label_valueText"):setString(hp.lang.getStrByID(11145))
	if activity.perScore > activity_info.soloTarget[3] then
		content_rewards3:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right.png")
	end

	local reward3_id = activity_info.soloReward3[1]
	local reward3_info = hp.gameDataLoader.getInfoBySid("item", reward3_id)
	content_rewards3:getChildByName("BitmapLabel_num"):setString(activity_info.soloReward3[2])
	content_rewards3:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. reward3_id .. ".png")
	content_rewards3:getChildByName("Label_desc"):setString(reward3_info.name)
	content_rewards3:getChildByName("Label_score"):setString(activity_info.soloTarget[3])
	content_rewards3:getChildByName("Label_value"):setString(activity_info.soloReward3[2] * reward3_info.sale)

	local content_rank = list:getItem(2):getChildByName("Panel_content")
	content_rank:getChildByName("Label_title"):setString(hp.lang.getStrByID(11138))
	content_rank:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11139))

	-- 个人奖励
	local reward_ids = hp.gameDataLoader.getInfoBySid("k_eventRank_e", activity_info.soloRank).item
	local reward_gold = hp.gameDataLoader.getInfoBySid("k_eventRank_e", activity_info.soloRank).gold

	local panel_rank2 = list:getItem(3)
	local frame_rewards = panel_rank2:getChildByName("Panel_frame")
	local list_rewards = panel_rank2:getChildByName("ListView_content")
	local baseItem = list_rewards:getItem(1):clone()
	local itemHeight = baseItem:getSize().height

	for i = 1, #reward_ids + 1 do
		local item
		if i == 1 then
			item = list_rewards:getItem(1)
			item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(hp.lang.getStrByID(6018))
			item:getChildByName("Panel_content"):getChildByName("Label_num"):setString(reward_gold)
			item:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(config.dirUI.common .. "gold2.png")
		elseif i == #reward_ids + 1 then
			item = baseItem
			list_rewards:insertCustomItem(item, #list_rewards:getItems() - 1)
		else
			item = baseItem:clone()
			list_rewards:insertCustomItem(item, #list_rewards:getItems() - 1)
		end
		if i ~= 1 then
			local reward_info = hp.gameDataLoader.getInfoBySid("item", reward_ids[i-1])
			item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(reward_info.name)
			item:getChildByName("Panel_content"):getChildByName("Label_num"):setString(1)
			item:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(config.dirUI.item .. reward_ids[i-1] .. ".png")
		end
	end

	-- 改变大小
	local addHeight = #reward_ids * itemHeight
	local size = list_rewards:getSize()
	size.height = size.height + addHeight
	list_rewards:setSize(size)
	local size = panel_rank2:getSize()
	size.height = size.height + addHeight
	panel_rank2:setSize(size)

	local s1 = frame_rewards:getChildByName("1")
	local s2 = frame_rewards:getChildByName("2")
	local s3 = frame_rewards:getChildByName("3")
	s1:setPositionY(s1:getPositionY() + addHeight)
	s2:setPositionY(s1:getPositionY())
	s3:setPositionY(s1:getPositionY())
	local s4 = frame_rewards:getChildByName("4")
	local s5 = frame_rewards:getChildByName("5")
	local s6 = frame_rewards:getChildByName("6")
	s4:setPositionY(s4:getPositionY() + addHeight / 2)
	s5:setPositionY(s4:getPositionY())
	s6:setPositionY(s4:getPositionY())
	local size = s4:getSize()
	size.height = size.height + addHeight
	s4:setSize(size)
	s6:setSize(size)
	local size = s5:getSize()
	size.height = size.height + addHeight
	s5:setSize(size)

	-- 显示更多奖励
	local function onShowMoreTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/activity/kingdomActivity/soloRankRewards"
			local ui = UI_soloRankRewards.new()
			self:addModalUI(ui)
		end
	end
	local content_oper = list_rewards:getItem(#list_rewards:getItems() - 1):getChildByName("Panel_content")
	content_oper:getChildByName("Image_btn"):addTouchEventListener(onShowMoreTouched)
	content_oper:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(11142))

	-- add ui
	-- ===========
	self:addCCNode(widget)
end

-- 心跳
function UI_personTarget:heartbeat(dt)
	self.label_time:setString(hp.datetime.strTime(player.kingdomActivityMgr.getTime()))
end