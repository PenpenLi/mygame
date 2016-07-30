--
-- ui/activity/unionActivity/history.lua
-- 联盟活动_历史记录
--=============================================

UI_history = class("UI_history", UI)

local data

function UI_history:init(data_)
	
	data = data_.history

	self:initTouchEvent()
	self:initUI()
end

function UI_history:initTouchEvent()
	-- 点击查看
	local function checkTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			-- 解析
			local data = self.history[math.floor(sender:getTag()/100)]
			local data2 = data.list
			local data3 = data2[sender:getTag()%100]

			require "ui/activity/unionActivity/historyReward"
			local ui = UI_histroyReward.new(data3[3], data3[1], sender:getTag()%100)
			self:addModalUI(ui)
		end
	end
	self.checkTouched = checkTouched
end

function UI_history:initUI()

	-- RANK":[  [1412510400,1412593200,[]]  ,  [1412596800,1412679600,[["1103",1,1001]]]         ]
	
	-- data prepare
	local history = {}

	for i = 1, #data do
		-- 冒泡排序
		for j = #data - 1, i, -1 do
			if data[j][1] < data[j + 1][1] then
				local temp = data[j]
				data[j] = data[j + 1]
				data[j + 1] = temp
			end
		end
		local history_ = {}
		history_.beginTime = data[i][1]
		history_.endTime = data[i][2]
		history_.list = data[i][3]
		table.insert(history, history_)
	end

	self.history = history

	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_history.json")
	local list = widget:getChildByName("ListView_history")
	local item = list:getItem(1):clone()

	list:getItem(0):getChildByName("Panel_content"):getChildByName("Label_text"):setString(hp.lang.getStrByID(5656))

	if #data == 0 or data == nil then
		list:removeItem(1)
	else
		for i,v in ipairs(history) do
			local temp_item

			if i == 1 then
				temp_item = list:getItem(1)
			elseif i == #history then
				temp_item = item
				list:pushBackCustomItem(temp_item)
			else
				temp_item = item:clone()
				list:pushBackCustomItem(temp_item)
			end

			local beginTime = os.date("%Y-%m-%d %H:%M", v.beginTime)
			local endTime = os.date("%Y-%m-%d %H:%M", v.endTime)

			local temp_content = temp_item:getChildByName("Panel_titleContent")
			local temp_frame = temp_item:getChildByName("Panel_titleFrame")
			temp_content:getChildByName("Label_act"):setString(hp.lang.getStrByID(5651))
			temp_content:getChildByName("Label_time"):setString(string.format("%s - %s", beginTime, endTime))
			temp_content:getChildByName("Label_title"):setString(hp.lang.getStrByID(5652))

			local item_list = temp_item:getChildByName("ListView_ranking")
			local item_ = item_list:getItem(0):clone()

			if #v.list == 0 or v.list == nil then
				local size = temp_item:getSize()
				size.height = size.height - item_list:getSize().height
				temp_item:setSize(size)
				temp_item:removeChild(item_list)
				temp_content:setPositionY(temp_content:getPositionY() - item_list:getSize().height)
				temp_frame:setPositionY(temp_frame:getPositionY() - item_list:getSize().height)
				temp_content:getChildByName("Label_title"):setVisible(false)
			else
				for k,l in ipairs(v.list) do
					local temp_item_

					if k == 1 then
						temp_item_ = item_list:getItem(0)
					elseif k == #v.list then
						temp_item_ = item_
						item_list:pushBackCustomItem(temp_item_)
					else
						temp_item_ = item_:clone()
						item_list:pushBackCustomItem(temp_item_)
					end

					local temp_content_ = temp_item_:getChildByName("Panel_content")
					local image_ranking = temp_content_:getChildByName("Image_ranking")
					local label_ranking = temp_content_:getChildByName("Label_rangking")
	
					-- local image_detail = temp_content_:getChildByName("Image_detail")
					-- image_detail:setTag(i * 100 + k)
					-- image_detail:addTouchEventListener(self.checkTouched)

					local touch_panel = temp_item_:getChildByName("Panel_frame"):getChildByName("5")
					touch_panel:setTag(i * 100 + k)
					touch_panel:addTouchEventListener(self.checkTouched)

					if k <= 3 then
						label_ranking:setVisible(false)
						image_ranking:loadTexture(config.dirUI.common .. string.format("activity_%d.png", k))
					else
						image_ranking:setVisible(false)
						label_ranking:setString(k)
					end

					temp_content_:getChildByName("Label_name"):setString(l[1])
					temp_content_:getChildByName("Label_kingdom"):setString(hp.gameDataLoader.getInfoBySid("serverList", l[2]).name)
					temp_content_:getChildByName("Label_check"):setString(hp.lang.getStrByID(5654))
				end

				-- change size
				local addHeight = item_:getSize().height * (#item_list:getItems() - 1)
				local size1 = item_list:getSize()
				size1.height = size1.height + addHeight
				item_list:setSize(size1)
				local size2 = temp_item:getSize()
				size2.height = size2.height + addHeight
				temp_item:setSize(size2)
				temp_content:setPositionY(temp_content:getPositionY() + addHeight)
				temp_frame:setPositionY(temp_frame:getPositionY() + addHeight)
			end
		end
	end
	
	self:addCCNode(widget)
end