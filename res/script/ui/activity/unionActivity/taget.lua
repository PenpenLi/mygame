--
-- ui/activity/unionActivity/target.lua
-- 联盟活动_目标
--=============================================

UI_target = class("UI_target", UI)

local data

function UI_target:init(data_, firstTime)

	data = data_
	
	self:registMsg(hp.MSG.UNION_ACTIVITY)

	-- 消息未遍历结束，导致本页面注册时仍会收到这个消息，所以第一次不调用 initUI
	if firstTime == nil then
		self:initUI()
	end
end

function UI_target:initUI()

	if self.widget then
		self:removeCCNode(self.widget)
	end

	self.widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_target.json")
	self:addCCNode(self.widget)
	local list = self.widget:getChildByName("ListView_activity")

	if data.status == UNION_ACTIVITY_STATUS.OPEN then
		-- activity info
		local activity_info = hp.gameDataLoader.getInfoBySid("allienceEvent", data.sid)

		-- panel title
		local panel_title = list:getChildByName("Panel_title")
		local content_title = panel_title:getChildByName("Panel_content")

		content_title:getChildByName("Label_timeText"):setString(hp.lang.getStrByID(5608))
		content_title:getChildByName("Label_scoreText"):setString(hp.lang.getStrByID(5609))

		self.time =  data.endTime - player.getServerTime()
		self.timeLabel = content_title:getChildByName("Label_time")
		self.timeLabel:setString(hp.datetime.strTime(self.time))
		self.scoreLabel = content_title:getChildByName("Label_score")
		self.scoreLabel:setString(data.score)

		-- panel desc
		local panel_desc = list:getChildByName("Panel_desc")
		local content_des = panel_desc:getChildByName("Panel_content")

		content_des:getChildByName("Label_text1"):setString(hp.lang.getStrByID(5610))
		content_des:getChildByName("Label_text2"):setString(hp.lang.getStrByID(5611))
		content_des:getChildByName("Label_text3"):setString(hp.lang.getStrByID(5612))
		content_des:getChildByName("Label_text4"):setString(hp.lang.getStrByID(5613))

		content_des:getChildByName("Label_score1"):setString(string.format(hp.lang.getStrByID(5614), activity_info.points[1]))
		content_des:getChildByName("Label_score2"):setString(string.format(hp.lang.getStrByID(5614), activity_info.points[2]))
		content_des:getChildByName("Label_score3"):setString(string.format(hp.lang.getStrByID(5614), activity_info.points[3]))

		self.progress = panel_desc:getChildByName("Panel_frame"):getChildByName("ProgressBar_score")

		-- progress
		if data.score < activity_info.points[1] then
			self.progress:setPercent(33 * data.score / activity_info.points[1])
		elseif data.score < activity_info.points[2] then
			local score = data.score - activity_info.points[1]
			local scoreMax = activity_info.points[2] - activity_info.points[1]
			self.progress:setPercent(33 + 33 * score / scoreMax)
		elseif data.score < activity_info.points[3] then
			local score = data.score - activity_info.points[2]
			local scoreMax = activity_info.points[3] - activity_info.points[2]
			self.progress:setPercent(67 + 33 * score / scoreMax)
		else
			self.progress:setPercent(100)
		end

		-- panel detail
		local panel_detail = list:getChildByName("Panel_detail")
		local list_detail = panel_detail:getChildByName("ListView_detail")

		-- prepare data
		local data_detail = {}
		for i = 1, #activity_info.param1 do
			local temp_info = {}
			temp_info.text = string.format(hp.lang.getStrByID(5620 + activity_info.type1), activity_info.param1[i])
			temp_info.score = activity_info.point1[i]
			data_detail[#data_detail + 1] = temp_info
		end

		if activity_info.type2 ~= -1 then
			for i = 1, #activity_info.param2 do
				local temp_info = {}
				temp_info.text = string.format(hp.lang.getStrByID(5620 + activity_info.type2), activity_info.param2[i])
				temp_info.score = activity_info.point2[i]
				data_detail[#data_detail + 1] = temp_info
			end
		end
		-- insert list
		local item = list_detail:getItem(0):clone()
		for i,v in ipairs(data_detail) do
			local temp_item
			if i == 1 then
				temp_item = list_detail:getItem(0)
			elseif i == #data_detail then
				temp_item = item
				list_detail:pushBackCustomItem(temp_item)
			else
				temp_item = item:clone()
				list_detail:pushBackCustomItem(temp_item)
			end

			local content_item = temp_item:getChildByName("Panel_content")
			content_item:getChildByName("Label_text1"):setString(v.text)
			content_item:getChildByName("Label_text2"):setString(string.format(hp.lang.getStrByID(5615), v.score))
		end
		-- change size
		local size = list_detail:getSize()
		size.height = #list_detail:getItems() * item:getSize().height
		list_detail:setSize(size)
		panel_detail:setSize(size)
	-- 活动未开启
	else
		list:setVisible(false)
		self.widget:getChildByName("Panel_noActivity"):setVisible(true)
	end
end

function UI_target:heartbeat(dt)
	if self.timeLabel then
		self.time = self.time - dt
		self.timeLabel:setString(hp.datetime.strTime(self.time))
		if self.time <= 0 then
			self.time = 0
			self.timeLabel = nil
			player.unionActivityMgr.updateActivity(self)
		end
	end
end

function UI_target:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_ACTIVITY then
		if param_ == 1 then
			data = player.unionActivityMgr.getActivity()
			self:initUI()
		end
	end
end