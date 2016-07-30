--
-- ui/mansion/giftItem/noviceGiftItem.lua
-- 新手奖励
--===================================

-- 19 2 领取奖励
--===================================

-- 类
--===================================
NoviceGiftItem = class("NoviceGiftItem")

-- 初始化
function NoviceGiftItem:ctor(item_, parent_)
	self.item = item_
	self.parent = parent_
	self:initTouchEvent()
	self:initUI()
end

-- 初始化事件
function NoviceGiftItem:initTouchEvent()
	-- 领取
	local function getNoviceGift(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function onBaseInfoResponse(status, response, tag)
				if status == 200 then
					local res = hp.httpParse(response)
					if res.result ~= nil and res.result == 0 then
						player.noviceGiftMgr.receive()
						local str = "%s × %d"
						local info = string.format(str, self.rewards.name, self.rewards.num)
						Scene.showMsg({4001, info})
						self:initUI()
					end
				end
			end
			local cmdData = {operation = {}}
			local oper = {}
			oper.channel = 19
			oper.type = 2
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self.parent:showLoading(cmdSender, sender)
		end
	end
	self.getNoviceGift = getNoviceGift
end

-- 初始化界面
function NoviceGiftItem:initUI()
	local content_rewards = self.item:getChildByName("Panel_content")
	
	content_rewards:getChildByName("Label_title"):setString(hp.lang.getStrByID(11301))
	content_rewards:getChildByName("Label_desc"):setString(hp.lang.getStrByID(11302))
	
	-- 数据准备
	local day = player.noviceGiftMgr.getDay()
	local isSign = player.noviceGiftMgr.isSign()
	local days = player.noviceGiftMgr.getDays()
	local startTime = 1
	local endTime = 7

	if day == -1 then
		self.priority = 4
		return
	elseif isSign then
		self.priority = 3
	else
		self.priority = 1
	end

	if day > 7 or (day == 7 and isSign) then
		startTime = 8
		endTime = 14
	end
	
	self.rewards = {}
	local index = 1
	for i = startTime, endTime do
		-- 设置初始状态
		content_rewards:getChildByName("Label_day" .. index):setString(string.format(hp.lang.getStrByID(11303), i))
		content_rewards:getChildByName("Image_btn" .. index):loadTexture(config.dirUI.common .. "button_gray.png")
		content_rewards:getChildByName("Image_btn" .. index):setTouchEnabled(false)
		content_rewards:getChildByName("Image_btn" .. index):setVisible(true)
		content_rewards:getChildByName("Label_btnText" .. index):setColor(cc.c3b(255, 255, 255))
		content_rewards:getChildByName("Label_btnText" .. index):setString(hp.lang.getStrByID(11305))

		local info = game.data.noviceGift[i]

		-- 道具奖励
		if info.sid ~= -1 then
			local itemInfo = hp.gameDataLoader.getInfoBySid("item", info.sid)
			content_rewards:getChildByName("Image_reward" .. index):loadTexture(string.format("%s%d.png", config.dirUI.item, info.sid))
			content_rewards:getChildByName("Label_desc" .. index):setString(itemInfo.name)
			content_rewards:getChildByName("Label_num" .. index):setString(1)
		-- 金币奖励
		else
			content_rewards:getChildByName("Image_reward" .. index):loadTexture(config.dirUI.common .. "gold2.png")
			content_rewards:getChildByName("Label_desc" .. index):setString(hp.lang.getStrByID(11306))
			content_rewards:getChildByName("Label_num" .. index):setString(info.gold)
		end
		-- 今天未领取
		if i == day and not isSign then
			content_rewards:getChildByName("Image_btn" .. index):loadTexture(config.dirUI.common .. "button_blue.png")
			content_rewards:getChildByName("Image_btn" .. index):setTouchEnabled(true)
			content_rewards:getChildByName("Image_btn" .. index):addTouchEventListener(self.getNoviceGift)
			-- 记录奖励
			if info.sid ~= -1 then
				self.rewards.name = hp.gameDataLoader.getInfoBySid("item", info.sid).name
				self.rewards.num = 1
			else
				self.rewards.name = hp.lang.getStrByID(11306)
				self.rewards.num = info.gold
			end
		elseif i <= day then
			-- 错过
			if days[i] == 0 then
				content_rewards:getChildByName("Label_btnText" .. index):setColor(cc.c3b(244, 66, 66))
				content_rewards:getChildByName("Label_btnText" .. index):setString(hp.lang.getStrByID(11307))
			else
				content_rewards:getChildByName("Label_btnText" .. index):setString(hp.lang.getStrByID(11304))
			end
			content_rewards:getChildByName("Image_btn" .. index):setVisible(false)
		else
			content_rewards:getChildByName("Label_btnText" .. index):setString(hp.lang.getStrByID(11305))
		end
		index = index + 1
	end
end