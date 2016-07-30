--
-- ui/activity/soloActivity.lua
-- 单人活动
--===================================
require "ui/fullScreenFrame"

UI_soloActivity = class("UI_soloActivity", UI)

local rankImage_ = {"activity_1.png","activity_2.png","activity_3.png"}

local activityInfo = {
	[1]={name=hp.lang.getStrByID(5330)},
	[2]={name=hp.lang.getStrByID(5331)},
	[3]={name=hp.lang.getStrByID(5332)},
	[4]={name=hp.lang.getStrByID(5333)},
	[5]={name=hp.lang.getStrByID(5334)},
	[9]={name=hp.lang.getStrByID(5529)},
}

--init
function UI_soloActivity:init(activity_)
	-- data
	-- ===============================
	self.activity = activity_
	self.tab = 1
	self.smallTab = 1
	self.loaded = {false, false}
	self.index = {}
	self.uiGiftState = {}
	self.loadIndex = nil

	-- ui data
	self.uiTab = {}
	self.uiTabText = {}
	self.uiSmallTab = {}
	self.uiSmallTabText = {}
	self.redMask = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	self.uiFrame = uiFrame
	uiFrame:hideTopBackground()
	uiFrame:setTitle(hp.lang.getStrByID(5496), "title1")
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	self.sizeSelected = self.uiTab[1]:getScale()
	self.sizeUnselected = self.uiTab[2]:getScale()

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)
	hp.uiHelper.uiAdaption(self.item3)
	hp.uiHelper.uiAdaption(self.item4)
	hp.uiHelper.uiAdaption(self.desc)

	hp.uiHelper.uiAdaption(self.uiContent)
	hp.uiHelper.uiAdaption(self.uiDesc)
	hp.uiHelper.uiAdaption(self.uiTitle2)

	self:registMsg(hp.MSG.SOLO_ACTIVITY)

	self:tabPage(self.tab)
end

function UI_soloActivity:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "activityInfo.json")
	local content_ = self.wigetRoot:getChildByName("Panel_29874")
	local idList_ = {5318, 5323}
	for i = 1, 2 do
		self.uiTab[i] = content_:getChildByName("ImageView_801"..(i + 2))
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		self.uiTabText[i] = self.uiTab[i]:getChildByName("Label_2987"..(6 + i))
		self.uiTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
	end

	local back_ = self.wigetRoot:getChildByName("Panel_8012")
	local idList_ = {5324, 5335, 5340}
	for i = 1, 3 do
		self.redMask[i] = back_:getChildByName("Image_red_"..i)
		self.uiSmallTab[i] = back_:getChildByName("Image_205_"..i)
		self.uiSmallTab[i]:setTag(i)
		self.uiSmallTab[i]:addTouchEventListener(self.onSmallTabTouched)
		self.uiSmallTabText[i] = content_:getChildByName("Label_209_"..i)
		self.uiSmallTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
	end

	self.noActivity = self.wigetRoot:getChildByName("Panel_21")
	self.noActivity:getChildByName("Label_22"):setString(hp.lang.getStrByID(5374))

	self.listView = self.wigetRoot:getChildByName("ListView_76")
	self.item1 = self.listView:getChildByName("Panel_77"):clone()
	self.item1:retain()
	self.item2 = self.listView:getChildByName("Panel_90"):clone()
	self.item2:retain()
	self.item3 = self.listView:getChildByName("Panel_119"):clone()
	self.item3:retain()
	self.item4 = self.listView:getChildByName("Panel_119_0"):clone()
	self.item4:retain()
	self.desc = self.listView:getChildByName("Panel_151"):clone()
	self.desc:retain()
	self.listView:removeAllItems()

	self.listView2 = self.wigetRoot:getChildByName("ListView_266")
	self.uiContent = self.listView2:getChildByName("Panel_15289"):clone()
	self.uiContent:retain()
	self.listView2:removeLastItem()
	self.uiDesc = self.listView2:getChildByName("Panel_152"):clone()
	self.uiDesc:retain()
	self.listView2:removeLastItem()
	self.uiTitle2 = self.listView2:getChildByName("Panel_116"):clone()
	self.uiTitle2:retain()
	self.listView2:removeLastItem()
	self.uiTopDesc = self.listView2:getChildByName("Panel_151")

	self.colorSelected = self.uiTab[1]:getColor()
	self.colorUnselected = self.uiTab[2]:getColor()

	self.colorSelectedSmall = self.uiSmallTabText[1]:getColor()
	self.colorUnselectedSmall = self.uiSmallTabText[2]:getColor()
end

function UI_soloActivity:tabPage(id_)
	cclog_("tabPage",id_)
	local scale_ = {self.sizeUnselected, self.sizeUnselected}	
	local color_ = {self.colorUnselected, self.colorUnselected}
	scale_[id_] = self.sizeSelected
	color_[id_] = self.colorSelected

	for i = 1, 2 do
		self.uiTab[i]:setColor(color_[i])
		self.uiTab[i]:setScale(scale_[i])
		self.uiTabText[i]:setColor(color_[i])
	end

	self.tab = id_
	if id_ == 1 then
		self:preRefreshPage1()
	elseif id_ == 2 then
		local cmd_ = player.soloActivityMgr.httpReqRequestHistory()
		if cmd_ ~= nil then
			self:showLoading(cmd_, nil)
		end
	end
end

function UI_soloActivity:tabSmallPage(id_)
	cclog_("tabSmallPage",id_)

	for i = 1, 3 do
		self.uiSmallTab[i]:setColor(self.colorSelectedSmall)
		if i ~= id_ then
			self.redMask[i]:setVisible(false)
			self.uiSmallTabText[i]:setColor(self.colorUnselectedSmall)
		else
			self.uiSmallTabText[i]:setColor(self.colorSelectedSmall)
			self.redMask[i]:setVisible(true)
		end
	end

	self.smallTab = id_
	if id_ == 1 then
		self:refreshSmallPage1()
	elseif id_ == 2 then
		self:refreshSmallPage2()
	elseif id_ == 3 then
		self:refreshSmallPage3()
	end
	self.listView:jumpToTop()
end

function UI_soloActivity:preRefreshPage1()
	self.listView2:setVisible(false)
	if self.activity.status ~= 0 then
		self.listView:setVisible(false)
		self.noActivity:setVisible(true)		
		self.uiFrame:setTopShadePosY(822)
		for i = 1, 3 do
			self.uiSmallTab[i]:setVisible(false)
			self.uiSmallTabText[i]:setVisible(false)
			self.redMask[i]:setVisible(false)
		end
	else
		self:refreshPage1()
		self.listView:jumpToTop()
	end
end

function UI_soloActivity:initCallBack()
	-- 查看详细奖励
	local function onMoreRewardTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/activity/activityLeaderReward"
			ui_ = UI_activityLeaderReward.new(self.activity)
			self:addModalUI(ui_)
		end
	end

	-- 查看玩家历史奖励
	local function onPlayerHistoryTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			cclog_("onPlayerHistoryTouchedonPlayerHistoryTouched")
			local pos_ = self.index[sender:getTag()]
			cclog_(pos_[1],pos_[2])
			local historys_ = player.soloActivityMgr.getHistory()
			local history_ = historys_[pos_[1]]
			local player_ = history_.player[pos_[2]]
			if player_ == nil then
				return
			end
			require "ui/activity/activityHistoryReward"
			local ui_ = UI_activityHistoryReward.new(player_)
			self:addModalUI(ui_)
		end
	end

	-- 切换标签
	local function onTabTouched(sender, eventType)
		if self.tab == sender:getTag() then
			return
		end
		
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.uiTabText[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabPage(sender:getTag())
		end
	end

	-- 切换小标签
	local function onSmallTabTouched(sender, eventType)
		if self.smallTab == sender:getTag() then
			return
		end
		
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorUnselected)
			-- self.uiSmallTabText[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorUnselected)
				-- self.uiSmallTabText[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorSelected)
				-- self.uiSmallTabText[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabSmallPage(sender:getTag())
		end
	end

	self.onTabTouched = onTabTouched
	self.onSmallTabTouched = onSmallTabTouched
	self.onPlayerHistoryTouched = onPlayerHistoryTouched
	self.onMoreRewardTouched = onMoreRewardTouched
end

function UI_soloActivity:onRemove()
	-- self.item:release()
	self.super.onRemove(self)
end

function UI_soloActivity:refreshSmallPage1()
	self.listView:removeAllItems()
	self.time = nil
	self.uiPoint = nil
	self.progress = nil
	self.uiGiftState = {}

	local points_ = self.activity.info.points
	-- 第一部分
	-- 目标
	local item_ = self.item1:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_78")
	-- 剩余时间
	content_:getChildByName("Label_81"):setString(hp.lang.getStrByID(5325))
	self.time = content_:getChildByName("Label_82")
	-- 点数
	content_:getChildByName("Label_81_0"):setString(hp.lang.getStrByID(5326))
	self.uiPoint = content_:getChildByName("Label_81_0_1")
	-- 描述
	content_:getChildByName("Label_87"):setString(hp.lang.getStrByID(5327))
	-- 如何获取点数
	content_:getChildByName("Label_88"):setString(hp.lang.getStrByID(5328))
	-- 获取点数描述
	content_:getChildByName("Label_89"):setString(hp.lang.getStrByID(5329))

	content_:getChildByName("Label_88_0"):setString(hp.lang.getStrByID(5402))

	-- 进度条
	-- 点数
	for i=1, 3 do
		content_:getChildByName(tostring(i)):getChildByName("Label_65"):setString(points_[i])
	end

	-- 进度计算
	self.progress = item_:getChildByName("Panel_70"):getChildByName("Image_29_0"):getChildByName("ProgressBar_30")

	-- 获取方法
	for i = 1, 2 do
		local type_ = self.activity.info["type"..i]
		if type_ ~= -1 then
			local info_ = activityInfo[type_]
			local param_ = self.activity.info["param"..i]
			local point_ = self.activity.info["point"..i]
			for j, w in ipairs(param_) do
				local item_ = self.item2:clone()
				self.listView:pushBackCustomItem(item_)

				local content_ = item_:getChildByName("Panel_92")
				content_:getChildByName("Label_97"):setString(string.format(info_.name, w))
				content_:getChildByName("Label_97_0"):setString(point_[j])
			end
		end
	end
	self:updatePoint()
	self:tickUpdate()
end

function UI_soloActivity:refreshSmallPage2()
	self.listView:removeAllItems()
	self.time = nil
	self.uiPoint = nil
	self.progress = nil
	self.uiGiftState = {}

	local points_ = self.activity.info.points
	-- 第二部分
	-- 描述
	local desc_ = self.desc:clone()
	self.listView:pushBackCustomItem(desc_)
	desc_:getChildByName("Panel_63"):getChildByName("Label_152"):setString(hp.lang.getStrByID(5336))

	-- 奖品信息
	for i = 1, 3 do
		local reward_ = self.activity.info["reward"..i]
		local item_ = self.item3:clone()
		self.listView:pushBackCustomItem(item_)

		local listView_ = item_:getChildByName("ListView_122")
		-- 头
		local content_ = listView_:getChildByName("Panel_136"):getChildByName("Panel_121")
		content_:getChildByName("Label_127"):setString(hp.lang.getStrByID(5335)..i)
		content_:getChildByName("Label_127_0"):setString(hp.lang.getStrByID(5337))
		content_:getChildByName("Label_127_1"):setString(hp.lang.getStrByID(5338))

		-- 内容
		content_ = listView_:getChildByName("Panel_140"):getChildByName("Panel_142")
		-- 道具
		local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", reward_[1])
		if itemInfo_ ~= nil then
			-- 数量
			content_:getChildByName("BitmapLabel_15"):setString(reward_[2])
			-- 图标
			content_:getChildByName("Image_146"):loadTexture(config.dirUI.item..reward_[1]..".png")
			-- 名称
			content_:getChildByName("Label_147"):setString(itemInfo_.name)
			-- 点数
			content_:getChildByName("Label_147_0"):setString(points_[i])
			-- 奖励状态
			local state_ = content_:getChildByName("Image_150")
			table.insert(self.uiGiftState, state_)
		end

		-- 尾
		local content_ = listView_:getChildByName("Panel_135"):getChildByName("Panel_139")
		content_:getChildByName("Label_127_2"):setString(hp.lang.getStrByID(5339))
		if itemInfo_ ~= nil then
			-- 价值
			content_:getChildByName("Label_127_2_3"):setString(itemInfo_.sale*reward_[2])
		end
	end
	self:updatePoint()
end

function UI_soloActivity:refreshSmallPage3()
	self.listView:removeAllItems()
	self.time = nil
	self.uiPoint = nil
	self.progress = nil
	self.uiGiftState = {}

	-- 第三部分
	-- 描述
	local desc_ = self.desc:clone()
	self.listView:pushBackCustomItem(desc_)
	desc_:getChildByName("Panel_63"):getChildByName("Label_152"):setString(hp.lang.getStrByID(5341))
	-- 奖励
	-- 奖品信息
	local reward_ = hp.gameDataLoader.getInfoBySid("eventRank", self.activity.info.leaderReward)
	local item_ = self.item4:clone()
	self.listView:pushBackCustomItem(item_)

	local listView_ = item_:getChildByName("ListView_122")
	-- 头
	local content_ = listView_:getChildByName("Panel_136"):getChildByName("Panel_121")
	content_:getChildByName("Label_127"):setString(string.format(hp.lang.getStrByID(5342), 1))
	content_:getChildByName("Label_127_0"):setString(hp.lang.getStrByID(5343))

	-- 内容
	-- 金币
	local innerItem_ = listView_:getChildByName("Panel_140")
	local content_ = innerItem_:getChildByName("Panel_142")
	local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", 1)
	-- 图标
	content_:getChildByName("Image_146"):loadTexture(config.dirUI.common.."gold2.png")
	-- 名称
	content_:getChildByName("Label_147"):setString(reward_.gold..resInfo_.name)
	-- 数量
	content_:getChildByName("Label_147_0"):setString(1)

	-- 道具
	for i, v in ipairs(reward_.item) do
		local item_ = innerItem_:clone()
		listView_:insertCustomItem(item_, i + 1)
		content_ = item_:getChildByName("Panel_142")
		-- 道具
		local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", v)
		if itemInfo_ ~= nil then
			-- 图标
			content_:getChildByName("Image_146"):loadTexture(config.dirUI.item..v..".png")
			-- 名称
			content_:getChildByName("Label_147"):setString(itemInfo_.name)
			-- 数量
			content_:getChildByName("Label_147_0"):setString(1)
		end
	end

	-- 尾
	local content_ = listView_:getChildByName("Panel_135"):getChildByName("Panel_139")
	local more_ = content_:getChildByName("Image_213")
	more_:addTouchEventListener(self.onMoreRewardTouched)
	more_:getChildByName("Label_214"):setString(hp.lang.getStrByID(5344))

	-- 调整大小
	local itemNum_ = table.getn(reward_.item)
	local deltaHeight_ = itemNum_ * innerItem_:getSize().height
	local size_ = item_:getSize()
	size_.height = size_.height + deltaHeight_
	item_:setSize(size_)
	listView_:setSize(size_)
	cclog_("deltaHeight_",deltaHeight_)

	-- 领奖说明
	local desc_ = self.desc:clone()
	desc_:getChildByName("Panel_63"):getChildByName("Label_152"):setString(hp.lang.getStrByID(5345))
	self.listView:pushBackCustomItem(desc_)
end

function UI_soloActivity:refreshPage1()
	self.noActivity:setVisible(false)
	self.listView:setVisible(true)
	self.uiFrame:setTopShadePosY(776)
	for i = 1, 3 do
		self.uiSmallTab[i]:setVisible(true)
		self.uiSmallTabText[i]:setVisible(true)
		if i == self.smallTab then
			self.redMask[i]:setVisible(true)
		end
	end

	if self.loaded[1] then
		return
	end

	self:tabSmallPage(self.smallTab)
	self.loaded[1] = true
end

function UI_soloActivity:refreshPage2()
	self.listView:setVisible(false)
	self.noActivity:setVisible(false)
	self.listView2:setVisible(true)
	self.uiFrame:setTopShadePosY(822)
	for i = 1, 3 do
		self.uiSmallTab[i]:setVisible(false)
		self.uiSmallTabText[i]:setVisible(false)
		self.redMask[i]:setVisible(false)
	end

	if self.loaded[2] then		
		return
	end

	local history_ = player.soloActivityMgr.getHistory()

	-- 描述
	self.uiTopDesc:getChildByName("Panel_63"):getChildByName("Label_152"):setString(hp.lang.getStrByID(5348))

	-- 标题
	local function createTitle(beginTime_, endTime_)
		local title_ = self.uiTitle2:clone()
		local content_ = title_:getChildByName("Panel_118")
		content_:getChildByName("Label_79"):setString(hp.lang.getStrByID(5318))
		-- 时间
		local begin_ = os.date("%Y-%m-%d %H:%M:%S", beginTime_)
		local end_ = os.date("%Y-%m-%d %H:%M:%S", endTime_)
		content_:getChildByName("Label_79_0"):setString(begin_.." - "..end_)
		return title_
	end

	-- 恭喜
	local function createDesc(index_)
		local desc_ = self.uiDesc:clone()
		desc_:getChildByName("Panel_63"):getChildByName("Label_152"):setString(hp.lang.getStrByID(5349))
		return desc_
	end

	-- 内容
	local function createItem(i, j)
		if history_[i] == nil then
			return nil
		end

		local w = history_[i].player[j]
		if w == nil then
			return nil
		end

		local item_ = self.uiContent:clone()
		-- 加入索引
		item_:setTag(table.getn(self.index)+1)
		table.insert(self.index, {i, j})
		item_:addTouchEventListener(self.onPlayerHistoryTouched)
		content_ = item_:getChildByName("Panel_18648")
		-- 名称
		local name_ = w.name
		if w.unionName ~= "" then
			name_ = hp.lang.getStrByID(21)..w.unionName..hp.lang.getStrByID(22)..name_
		end
		content_:getChildByName("Label_18649"):setString(name_)
		-- 王国
		local serverInfo_ = hp.gameDataLoader.getInfoBySid("serverList", w.kingdom)
		content_:getChildByName("Label_18650"):setString(serverInfo_.name)
		-- 查看奖品
		content_:getChildByName("Label_18649_0"):setString(hp.lang.getStrByID(5350))
		if j <= 3 then
			-- 图标
			local img_ = content_:getChildByName("ImageView_20423")
			img_:setVisible(true)
			img_:loadTexture(config.dirUI.common..rankImage_[j])
		else
			-- 名次
			local rank_ = content_:getChildByName("Label_18649_1")
			rank_:setVisible(true)
			rank_:setString(j)
		end
		return item_
	end

	local function createItemByindex(index_)
		if self.loadIndex == nil then
			self.loadIndex = {1, 1}
		else
			if self.loadIndex[2] == 2 + table.getn(history_[self.loadIndex[1]].player) then
				self.loadIndex[1] = self.loadIndex[1] + 1
				self.loadIndex[2] = 1
			else
				self.loadIndex[2] = self.loadIndex[2] + 1
			end
		end

		local info_ = history_[self.loadIndex[1]]
		if info_ == nil then
			return nil
		end
		if self.loadIndex[2] == 1 then
			return createTitle(info_.beginTime, info_.endTime)
		elseif self.loadIndex[2] == 2 then
			return createDesc()
		else
			return createItem(self.loadIndex[1], self.loadIndex[2] - 2)
		end
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView2, createItemByindex, self.uiContent:getSize().height, 5)
	end
	self.listViewHelper.initShow(12)

	self.loaded[2] = true
end

function UI_soloActivity:heartbeat(dt_)
	if self.tab == 1 then
		self:tickUpdate()
	end
end

function UI_soloActivity:tickUpdate()
	if self.time == nil then
		return
	end

	local cd_ = self.activity.endTime - player.getServerTime()
	if cd_ < 0 then
		cd_ = 0
	end
	self.time:setString(hp.datetime.strTime(cd_))
end

function UI_soloActivity:updateInfo()
	cclog_("updateInfo")
	for i, v in ipairs(self.uiLoadingBar) do
		cclog_("i",i,self.tab)
		local warInfo_ = nil 
		if self.tab == 1 then
			warInfo_ = player.getAlliance():getRallyWarInfo()[i]
		else
			warInfo_ = player.getAlliance():getRallyDefenseInfo()[i]
		end
		local lastTime_ = warInfo_.lastTime - player.getServerTime()
		if lastTime_ < 0 then
			lastTime_ = 0
		end
		local percent = 100 - lastTime_ / warInfo_.totalTime * 100
		self.uiLoadingBar[i]:setPercent(percent)
		local countTime_ = hp.datetime.strTime(lastTime_)
		self.uiCountTime[i]:setString(countTime_)
	end
end

function UI_soloActivity:updatePoint()
	local points_ = self.activity.info.points
	local function calcProgress()
		local index_ = 0
		for i=3, 1, -1 do
			if self.activity.point >= points_[i] then
				index_ = i
				break
			end
		end

		if index_ == 3 then
			return 100
		end

		local progress_ = index_ * 33.33
		local low_ = points_[index_]
		local high_ = points_[index_+1]
		if low_ == nil then
			low_ = 0
		end
		progress_ = progress_ + (self.activity.point - low_)/(high_ - low_)*100/3
		cclog_("progress_",self.activity.point, index_, progress_)
		return progress_
	end

	if self.smallTab == 1 then
		if self.uiPoint ~= nil then
			self.uiPoint:setString(self.activity.point)
		end
		if self.progress ~= nil then
			self.progress:setPercent(calcProgress())
		end
	elseif self.smallTab == 2 then
		-- 奖励状态
		for i = 1, 3 do
			if self.uiGiftState[i] ~= nil then
				if self.activity.point >= points_[i] then
					self.uiGiftState[i]:loadTexture(config.dirUI.common.."right.png")
				else
					self.uiGiftState[i]:loadTexture(config.dirUI.common.."wrong.png")
				end
			end
		end
	end
end

function UI_soloActivity:onMsg(msg_, param_)
	if msg_ == hp.MSG.SOLO_ACTIVITY then
		if param_.msgType == 1 then
			self:refreshPage2()
		elseif param_.msgType == 2 then
			self:updatePoint()
		elseif param_.msgType == 3 then
			if self.tab == 1 then
				self.loaded[1] = false
				self:preRefreshPage1()
			end
		elseif param_.msgType == 4 then
			if self.tab == 1 then
				self.loaded[1] = false
				self:preRefreshPage1()
			end
		elseif param_.msgType == 5 then
			if self.tab == 1 then
				self.loaded[1] = false
				self:preRefreshPage1()
			end
		end
	end
end

function UI_soloActivity:onRemove()
	self.item1:release()
	self.item2:release()
	self.item3:release()
	self.item4:release()
	self.desc:release()
	self.uiContent:release()
	self.uiDesc:release()
	self.uiTitle2:release()
	self.super.onRemove(self)
end