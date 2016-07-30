--
-- ui/quest/questDetail.lua
-- 任务详情
--===================================
require "ui/fullScreenFrame"

UI_questDetail = class("UI_questDetail", UI)

local availableImage = "button_blue.png"

--init
function UI_questDetail:init(questID_)
	-- data
	-- ===============================
	cclog_("questID_",questID_)
	self.questInfo = hp.gameDataLoader.getInfoBySid("quests", questID_)
	self.questID = questID_

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(1411))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function OnCollectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:showLoading(player.questManager.httpReqCollectEmpireReward(questID_), sender)
		end
	end

	self.collect:addTouchEventListener(OnCollectTouched)

	-- 消息注册
	self:registMsg(hp.MSG.MISSION_COMPLETE)
	self:registMsg(hp.MSG.MISSION_COLLECT)
end

-- 初始化UI
function UI_questDetail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "questDetail.json")
	local content = self.wigetRoot:getChildByName("Panel_18660")

	content:getChildByName("Label_18661"):setString(self.questInfo.name)
	content:getChildByName("Label_18663"):setString(self.questInfo.text)
	content:getChildByName("ImageView_18664"):getChildByName("Label_18665"):setString(hp.lang.getStrByID(1412))

	local listView = self.wigetRoot:getChildByName("ListView_18670")
	local oneReward = listView:getChildByName("Panel_18671"):clone()

	-- 图片
	content:getChildByName("ImageView_18662"):loadTexture(config.dirUI.quest..self.questInfo.image)

	listView:removeLastItem()

	local index_ = 1
	for j, w in ipairs(self.questInfo.reward) do
		local rewardInfo_ = hp.gameDataLoader.getInfoBySid("rewards", w)
		-- 道具
		for i, v in ipairs(rewardInfo_.item) do
			if v ~= -1 then
				local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", v)
				local cloneReward_ = oneReward:clone()
				cloneReward_:getChildByName("Panel_20378"):getChildByName("ImageView_20379"):loadTexture(config.dirUI.item..v..".png")
				cloneReward_:getChildByName("Panel_20378"):getChildByName("Label_20380"):setString(itemInfo_.name..": "..rewardInfo_.num[i])

				if index_ % 2 == 0 then
					cloneReward_:getChildByName("Panel_20377"):getChildByName("ImageView_20382"):setVisible(false)
				end
				listView:pushBackCustomItem(cloneReward_)
				index_ = index_ + 1
			end
		end

		-- 资源
		for i, v in ipairs(rewardInfo_.resource) do
			if v ~= 0 then
				local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
				local cloneReward_ = oneReward:clone()
				cloneReward_:getChildByName("Panel_20378"):getChildByName("ImageView_20379"):loadTexture(config.dirUI.common..resourceInfo_.image)
				cloneReward_:getChildByName("Panel_20378"):getChildByName("Label_20380"):setString(resourceInfo_.name..": "..v)

				if index_ % 2 == 0 then
					cloneReward_:getChildByName("Panel_20377"):getChildByName("ImageView_20382"):setVisible(false)
				end
				listView:pushBackCustomItem(cloneReward_)
				index_ = index_ + 1
			end
		end
	end

	self.collect = content:getChildByName("Panel_23185"):getChildByName("ImageView_20396")
	self.collect:getChildByName("Label_20397"):setString(hp.lang.getStrByID(1413))
	self:changeRewardStatus()

	-- add by huangwei 任务指引
	local function questGuide(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local buildingId = self.questInfo.parameter1
			local buidingInfo = hp.gameDataLoader.getInfoBySid("building", buildingId)
			local questType = self.questInfo.showtype
			self:closeAll()
			if questType == 1 then
				local buiding = game.curScene:getBuildingBySid(buildingId)
				if buiding == nil then
					self:closeAll()
				else
					buiding:Scroll2Here(0.5)
					buiding:addGuide()
				end
			elseif questType == 2 then
				local buiding = game.curScene:getBlock(buidingInfo.type)
				buiding:Scroll2Here(0.5)
				buiding:addGuide()
			end
		end
	end

	local guideBtn = content:getChildByName("Image_guide")
	local btnText = content:getChildByName("Label_guideText")
	-- 非主线任务
	if self.questInfo.type ~= 1 then
		guideBtn:setVisible(false)
		btnText:setVisible(false)
		guideBtn:setTouchEnabled(false)
	else
		guideBtn:addTouchEventListener(questGuide)
		btnText:setString(hp.lang.getStrByID(1223))
	end
end

function UI_questDetail:changeRewardStatus()
	if player.questManager.isRewardCollectable(self.questInfo.sid) then
		self.collect:loadTexture(config.dirUI.common..availableImage)
		self.collect:setTouchEnabled(true)
	end
end

function UI_questDetail:onMsg(msg_, param_)
	if msg_ == hp.MSG.MISSION_COMPLETE then
		self:changeRewardStatus()
	elseif msg_ == hp.MSG.MISSION_COLLECT then
		if param_ == self.questID then
			self:close()
		end
	end
end