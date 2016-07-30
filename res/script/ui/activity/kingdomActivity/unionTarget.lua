--
-- ui/activity/kindomActivity/unionTarget.lua
-- 联盟目标
--=============================================

UI_unionTarget = class("UI_unionTarget", UI)

function UI_unionTarget:init()
	-- 注册加入联盟消息
	self:registMsg(hp.MSG.UNION_JOIN_SUCCESS)

	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_unionTarget.json")
	self:addCCNode(widget)
	self.widget = widget

	self:initUI()
end

function UI_unionTarget:initUI()
	local list = self.widget:getChildByName("ListView_root")
	local noUnion = self.widget:getChildByName("Panel_noUnion")

	if player.getAlliance():getUnionID() == 0 then
		local function joinUnion(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then
				-- 未加入联盟
				require "ui/union/invite/unionJoin.lua"
				local ui = UI_unionJoin.new()
				self:addUI(ui)
			end
		end

		list:setVisible(false)
		noUnion:setVisible(true)

		noUnion:getChildByName("Label_text"):setString(hp.lang.getStrByID(11181))
		noUnion:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(11182))
		noUnion:getChildByName("Image_button"):addTouchEventListener(joinUnion)
	else

		list:setVisible(true)
		noUnion:setVisible(false)

		local activity = player.kingdomActivityMgr.getActivity()
		local activity_id = activity.sid
		local activity_info = hp.gameDataLoader.getInfoBySid("kingEvent", activity_id)

		-- 设置静态数据
		local frame_score = list:getItem(0):getChildByName("Panel_frame")
		local content_score = list:getItem(0):getChildByName("Panel_content")
		content_score:getChildByName("Label_title"):setString(hp.lang.getStrByID(11143))
		content_score:getChildByName("Label_time"):setString(hp.lang.getStrByID(11132))
		content_score:getChildByName("Label_score"):setString(hp.lang.getStrByID(11143))

		content_score:getChildByName("Label_score2"):setString(activity.unionScore)
		local progress = frame_score:getChildByName("Image_proBg"):getChildByName("ProgressBar_score")

		if activity.unionScore < activity_info.unionTarget[1] then
			progress:setPercent(33 * activity.unionScore / activity_info.unionTarget[1])
		elseif activity.unionScore < activity_info.unionTarget[2] then
			local score = activity.unionScore - activity_info.unionTarget[1]
			local scoreMax = activity_info.unionTarget[2] - activity_info.unionTarget[1]
			progress:setPercent(33 + 33 * score / scoreMax)
		elseif activity.unionScore < activity_info.unionTarget[3] then
			local score = activity.unionScore - activity_info.unionTarget[2]
			local scoreMax = activity_info.unionTarget[3] - activity_info.unionTarget[2]
			progress:setPercent(67 + 33 * score / scoreMax)
		else
			progress:setPercent(100)
		end

		self.label_time = content_score:getChildByName("Label_time2")

		content_score:getChildByName("Label_target1"):setString(string.format(hp.lang.getStrByID(11133), activity_info.unionTarget[1]))
		content_score:getChildByName("Label_target2"):setString(string.format(hp.lang.getStrByID(11133), activity_info.unionTarget[2]))
		content_score:getChildByName("Label_target3"):setString(string.format(hp.lang.getStrByID(11133), activity_info.unionTarget[3]))

		local content_rewards = list:getItem(1):getChildByName("Panel_content")
		content_rewards:getChildByName("Label_title"):setString(hp.lang.getStrByID(11144))

		local content_rewards1 = list:getItem(1):getChildByName("Panel_content1")
		local content_rewards2 = list:getItem(1):getChildByName("Panel_content2")
		local content_rewards3 = list:getItem(1):getChildByName("Panel_content3")

		-- panel 1
		-- ===============
		content_rewards1:getChildByName("Label_nameText"):setString(string.format(hp.lang.getStrByID(11135), 1))
		content_rewards1:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(11136))
		content_rewards1:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(11137))
		if activity.unionScore > activity_info.unionTarget[1] then
			content_rewards1:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right.png")
		end

		local reward1_id = activity_info.unionReward1
		local reward1_info = hp.gameDataLoader.getInfoBySid("unionGift", reward1_id * 1000 + 1)
		content_rewards1:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. reward1_info.type .. ".png")
		content_rewards1:getChildByName("Label_desc"):setString(reward1_info.name)
		content_rewards1:getChildByName("Label_score"):setString(activity_info.unionTarget[1])

		-- panel 2
		-- ===============
		content_rewards2:getChildByName("Label_nameText"):setString(string.format(hp.lang.getStrByID(11135), 2))
		content_rewards2:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(11136))
		content_rewards2:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(11137))
		if activity.unionScore > activity_info.unionTarget[2] then
			content_rewards2:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right.png")
		end

		local reward2_id = activity_info.unionReward2
		local reward2_info = hp.gameDataLoader.getInfoBySid("unionGift", reward2_id * 1000 + 1)
		content_rewards2:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. reward2_info.type .. ".png")
		content_rewards2:getChildByName("Label_desc"):setString(reward2_info.name)
		content_rewards2:getChildByName("Label_score"):setString(activity_info.unionTarget[2])

		-- panel 3
		-- ===============
		content_rewards3:getChildByName("Label_nameText"):setString(string.format(hp.lang.getStrByID(11135), 3))
		content_rewards3:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(11136))
		content_rewards3:getChildByName("Label_stateText"):setString(hp.lang.getStrByID(11137))
		if activity.unionScore > activity_info.unionTarget[3] then
			content_rewards3:getChildByName("Image_state"):loadTexture(config.dirUI.common .. "right.png")
		end

		local reward3_id = activity_info.unionReward3
		local reward3_info = hp.gameDataLoader.getInfoBySid("unionGift", reward3_id * 1000 + 1)
		content_rewards3:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. reward3_info.type .. ".png")
		content_rewards3:getChildByName("Label_desc"):setString(reward3_info.name)
		content_rewards3:getChildByName("Label_score"):setString(activity_info.unionTarget[3])

		local content_rank = list:getItem(2):getChildByName("Panel_content")
		content_rank:getChildByName("Label_title"):setString(hp.lang.getStrByID(11138))
		content_rank:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11146))

		local list_rewards = list:getItem(3):getChildByName("ListView_content")
		local content_title = list_rewards:getItem(0):getChildByName("Panel_content")
		content_title:getChildByName("Label_title"):setString(hp.lang.getStrByID(11140))
		content_title:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11141))

		local content_reward = list_rewards:getItem(1):getChildByName("Panel_content")

		local reward_id = hp.gameDataLoader.getInfoBySid("k_eventRank_a", activity_info.unionRank).award
		local reward_info = hp.gameDataLoader.getInfoBySid("unionGift", reward_id * 1000 + 1)

		content_reward:getChildByName("Label_desc"):setString(reward_info.name)
		content_reward:getChildByName("Image_icon"):loadTexture(config.dirUI.unionGift .. reward_info.type .. ".png")

		-- 显示更多奖励
		local function onShowMoreTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then
				require "ui/activity/unionActivity/rankingDetail"
				local ui = UI_rankingDetail.new(1)
				self:addModalUI(ui)
			end
		end
		local content_oper = list_rewards:getItem(2):getChildByName("Panel_content")
		content_oper:getChildByName("Image_btn"):addTouchEventListener(onShowMoreTouched)
		content_oper:getChildByName("Label_btnText"):setString(hp.lang.getStrByID(11142))
	end
end

-- 接收消息
function UI_unionTarget:onMsg(msg, param)
	if msg == hp.MSG.UNION_JOIN_SUCCESS then
		self:initUI()
	end
end

-- 心跳
function UI_unionTarget:heartbeat(dt)
	if self.label_time then
		self.label_time:setString(hp.datetime.strTime(player.kingdomActivityMgr.getTime()))
	elseif player.getAlliance():getUnionID() ~= 0 then
		self:initUI()
	end
end