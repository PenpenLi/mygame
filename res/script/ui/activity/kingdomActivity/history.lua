--
-- ui/activity/kindomActivity/history.lua
-- 历史记录
--=============================================

UI_history = class("UI_history", UI)

function UI_history:init()
	self:initTouchEvent()
	self:initUI()
end

function UI_history:initTouchEvent()
	-- 点击查看联盟奖励
	local function checkUnionRankTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			-- 解析
			local data = self.history[math.floor(sender:getTag()/100)]
			local data2 = data.unionRank
			local data3 = data2[sender:getTag()%100]

			require "ui/activity/unionActivity/historyReward"
			local ui = UI_histroyReward.new(data3[3], data3[1], sender:getTag()%100)
			self:addModalUI(ui)
		end
	end
	self.checkUnionRankTouched = checkUnionRankTouched
	-- 点击查看个人奖励
	local function checkPersonRankTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			-- 解析
			local data = self.history[math.floor(sender:getTag()/100)]
			local data2 = data.personRank
			local data3 = data2[sender:getTag()%100]

			local player = {}
			player.reward = data3[4]
			player.unionName = data3[1]
			player.name = data3[2]
			player.kingdom = data3[3]
			player.rank = sender:getTag()%100

			cclog_(player.reward, player.unionName, player.name, player.kingdom, player.rank)

			require "ui/activity/activityHistoryReward"
			local ui = UI_activityHistoryReward.new(player)
			self:addModalUI(ui)
		end
	end
	self.checkPersonRankTouched = checkPersonRankTouched
end

function UI_history:initUI()
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "kingdomAct_history.json")
	self:addCCNode(widget)

	local list = widget:getChildByName("ListView_history")
	local title_content = list:getItem(0):getChildByName("Panel_content")
	title_content:getChildByName("Label_text"):setString(hp.lang.getStrByID(11151))

	local baseServerItem = list:getItem(1):clone()
	local baseUnionItem = list:getItem(2):clone()
	local basePersonItem = list:getItem(3):clone()
	list:removeItem(3)
	list:removeItem(2)
	list:removeItem(1)

	local history = player.kingdomActivityMgr.getHistory()
	for i = 1, #history do
		-- 冒泡排序
		for j = #history - 1, i, -1 do
			if history[j].beginTime < history[j + 1].beginTime then
				local temp = history[j]
				history[j] = history[j + 1]
				history[j + 1] = temp
			end
		end
	end
	
	self.history = history
	-- 无历史数据
	if #history ~= 0 then
		-- {"RANK":    
		-- [  [1414214580,1414383780,2,1,0,0,[],[]]  ,  [1414401600,1414570800,2,1,0,0,[],[]]  ],
		-- "result":0},"heart":{}}

		for j = 1, #history do
			info = history[j]
			local serverItem = baseServerItem:clone()
			local personItem = basePersonItem:clone()
			local unionItem = baseUnionItem:clone()

			-- 服务器信息
			--=================================
			serverItem:getChildByName("Panel_titleContent"):getChildByName("Label_act"):setString(hp.lang.getStrByID(11101))
			-- 活动时间
			local beginTime = os.date("%Y-%m-%d %H:%M", info.beginTime)
			local endTime = os.date("%Y-%m-%d %H:%M", info.endTime)
			serverItem:getChildByName("Panel_titleContent"):getChildByName("Label_time"):setString(string.format("%s - %s", beginTime, endTime))
			-- 服务器名称
			local server1 = hp.gameDataLoader.getInfoBySid("serverList", info.serverID1).name
			local server2 = hp.gameDataLoader.getInfoBySid("serverList", info.serverID2).name
			
			if info.result == 0 then
				serverItem:getChildByName("Panel_titleContent"):getChildByName("Label_title"):setString(hp.lang.getStrByID(11173))
				serverItem:getChildByName("Panel_content"):getChildByName("Label_win"):setString(hp.lang.getStrByID(11177))
				serverItem:getChildByName("Panel_content2"):getChildByName("Label_win"):setString(hp.lang.getStrByID(11177))
				serverItem:getChildByName("Panel_content"):getChildByName("Label_kingdom"):setString(server1)
				serverItem:getChildByName("Panel_content2"):getChildByName("Label_kingdom"):setString(server2)
				serverItem:getChildByName("Panel_content"):getChildByName("Image_ranking"):setVisible(false)
				serverItem:getChildByName("Panel_content2"):getChildByName("Image_ranking"):setVisible(false)
			else
				serverItem:getChildByName("Panel_titleContent"):getChildByName("Label_title"):setString(hp.lang.getStrByID(11174))
				serverItem:getChildByName("Panel_content"):getChildByName("Label_win"):setString(hp.lang.getStrByID(11175))
				serverItem:getChildByName("Panel_content2"):getChildByName("Label_win"):setString(hp.lang.getStrByID(11176))
				
				if info.result == 1 then
					serverItem:getChildByName("Panel_content"):getChildByName("Label_kingdom"):setString(server1)
					serverItem:getChildByName("Panel_content2"):getChildByName("Label_kingdom"):setString(server2)
				else
					serverItem:getChildByName("Panel_content"):getChildByName("Label_kingdom"):setString(server2)
					serverItem:getChildByName("Panel_content2"):getChildByName("Label_kingdom"):setString(server1)
				end
			end
			list:pushBackCustomItem(serverItem)

			-- 联盟排行信息
			--=================================
			local title = unionItem:getChildByName("Panel_titleContent"):getChildByName("Label_title")
			title:setString(hp.lang.getStrByID(11178))
			local list_unionRank = unionItem:getChildByName("ListView_ranking")
			local baseItem = list_unionRank:getItem(0):clone()
			local itemHeight = baseItem:getSize().height

			for i,v in ipairs(info.unionRank) do
				
				local item
				if i == 1 then
					item = list_unionRank:getItem(0)
				elseif i == #info.unionRank then
					item = baseItem
					list_unionRank:pushBackCustomItem(item)
				else
					item = baseItem:clone()
					list_unionRank:pushBackCustomItem(item)
				end

				-- ["1103",1,1001]
				local content = item:getChildByName("Panel_content")
				local image_ranking = content:getChildByName("Image_ranking")
				local label_ranking = content:getChildByName("Label_rangking")
				-- 名次
				if i < 4 then
					label_ranking:setVisible(false)
					image_ranking:loadTexture(config.dirUI.common .. string.format("activity_%d.png", i))
				else
					image_ranking:setVisible(false)
					label_ranking:setString(i)
				end
				-- 联盟名
				content:getChildByName("Label_name"):setString(v[1])
				-- 服务器名
				content:getChildByName("Label_kingdom"):setString(hp.gameDataLoader.getInfoBySid("serverList", v[2]).name)
				-- 点击查看
				content:getChildByName("Label_check"):setString(hp.lang.getStrByID(11179))
				local check = item:getChildByName("Panel_frame"):getChildByName("5")
				check:setTag(j * 100 + i)
				check:addTouchEventListener(self.checkUnionRankTouched)
			end

			local addHeight = (#list_unionRank:getItems() - 1) * itemHeight
			if #info.unionRank == 0 then
				list_unionRank:setVisible(false)
			else
				local size = list_unionRank:getSize()
				size.height = size.height + addHeight
				list_unionRank:setSize(size)
				local size = unionItem:getSize()
				size.height = size.height + addHeight
				unionItem:setSize(size)
				title:setPositionY(title:getPositionY() + addHeight)
			end
			list:pushBackCustomItem(unionItem)

			-- 个人排行信息
			--=================================
			local title = personItem:getChildByName("Panel_titleContent"):getChildByName("Label_title")
			title:setString(hp.lang.getStrByID(11180))
			local list_personRank = personItem:getChildByName("ListView_ranking")
			local baseItem = list_personRank:getItem(0):clone()
			local itemHeight = baseItem:getSize().height

			for i,v in ipairs(info.personRank) do
				
				local item
				if i == 1 then
					item = list_personRank:getItem(0)
				elseif i == #info.unionRank then
					item = baseItem
					list_personRank:pushBackCustomItem(item)
				else
					item = baseItem:clone()
					list_personRank:pushBackCustomItem(item)
				end

				local content = item:getChildByName("Panel_content")
				local image_ranking = content:getChildByName("Image_ranking")
				local label_ranking = content:getChildByName("Label_rangking")
				-- 名次
				if i < 4 then
					label_ranking:setVisible(false)
					image_ranking:loadTexture(config.dirUI.common .. string.format("activity_%d.png", i))
				else
					image_ranking:setVisible(false)
					label_ranking:setString(i)
				end
				-- 联盟名
				if v[2] ~= nil and #v[2] > 0 then
					content:getChildByName("Label_name"):setString(string.format(hp.lang.getStrByID(8010), v[2]) .. v[1])
				else
					content:getChildByName("Label_name"):setString(v[1])
				end
				-- 服务器名
				content:getChildByName("Label_kingdom"):setString(hp.gameDataLoader.getInfoBySid("serverList", v[3]).name)
				-- 点击查看
				content:getChildByName("Label_check"):setString(hp.lang.getStrByID(11179))
				local check = item:getChildByName("Panel_frame"):getChildByName("5")
				check:setTag(j * 100 + i)
				check:addTouchEventListener(self.checkPersonRankTouched)
			end

			local addHeight = (#list_personRank:getItems() - 1) * itemHeight
			if #info.personRank == 0 then
				list_personRank:setVisible(false)
			else
				local size = list_personRank:getSize()
				size.height = size.height + addHeight
				list_personRank:setSize(size)
				local size = personItem:getSize()
				size.height = size.height + addHeight
				personItem:setSize(size)
				title:setPositionY(title:getPositionY() + addHeight)
			end
			list:pushBackCustomItem(personItem)
		end
	end
end