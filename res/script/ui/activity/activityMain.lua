--
-- ui/activity/activityMain.lua
-- 活动主界面
--===================================
require "ui/fullScreenFrame"

UI_activityMain = class("UI_activityMain", UI)

--init
function UI_activityMain:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5318))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	self:registMsg(hp.MSG.SOLO_ACTIVITY)
	self:registMsg(hp.MSG.UNION_ACTIVITY)
	self:registMsg(hp.MSG.KINGDOM_ACTIVITY)
	self:registMsg(hp.MSG.BOSS_ACTIVITY)

	self:initShow()
	self:tickUpdate()
end

function UI_activityMain:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "activityMain.json")
	local content_ = self.wigetRoot:getChildByName("Panel_5")
	content_:getChildByName("Label_6"):setString(hp.lang.getStrByID(5319))
	content_:getChildByName("Label_6_0_1"):setString(hp.lang.getStrByID(5320))
	content_:getChildByName("Label_6_0_2"):setString(hp.lang.getStrByID(5321))

	self.listView = self.wigetRoot:getChildByName("ListView_16")
	self.listView:getChildByName("Panel_17"):getChildByName("Panel_19"):getChildByName("Label_21"):setString(hp.lang.getStrByID(5322))
	self.item = self.listView:getChildByName("Panel_20425")

	-- add by huangwei
	self.unionItem = self.item:clone()
	self.listView:pushBackCustomItem(self.unionItem)

	self.kingdomItem = self.item:clone()
	self.listView:pushBackCustomItem(self.kingdomItem)

	self.bossItem = self.item:clone()
	self.listView:pushBackCustomItem(self.bossItem)
end

function UI_activityMain:initCallBack()
	local function onSoloActivityTouched(sender, eventType)
	cclog_("onSoloActivityTouched")
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/activity/soloActivity"
			local info_ = player.soloActivityMgr.getActivity()
			local ui_ = UI_soloActivity.new(info_)
			self:addUI(ui_)
		end
	end

	self.onSoloActivityTouched = onSoloActivityTouched

	local function onUnionActivityTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if player.getAlliance() ~= nil and player.getAlliance():getUnionID() ~= 0 then
				player.unionActivityMgr.updateActivity(self)
				self.unionActClick = true
			else
				local function joinUnion()
					require "ui/union/invite/unionJoin.lua"
					local ui_ = UI_unionJoin.new()
					self:addUI(ui_)
				end	
				require "ui/msgBox/msgBox"
				local msgTips = hp.lang.getStrByID(6034)
				local msgIs = hp.lang.getStrByID(6035)
				local msgNo = hp.lang.getStrByID(6036)
				local msgContent = hp.lang.getStrByID(8179)
				local msgbox = UI_msgBox.new(msgTips,msgContent,msgIs,msgNo,joinUnion)
				self:addModalUI(msgbox)
			end
		end
	end
	self.onUnionActivityTouched = onUnionActivityTouched

	local function onKingdomActivityTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			player.kingdomActivityMgr.updateActivity(self)
			self.kingdomActClick = true
		end
	end
	self.onKingdomActivityTouched = onKingdomActivityTouched

	local function onBossActivityTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local bossActivity = player.bossActivityMgr.getActivity()
			if bossActivity and bossActivity.status ~= BOSS_ACTIVITY_STATUS.CLOSE then
				require "ui/activity/bossActivity/bossActivity"
				local ui = UI_bossActivity.new()
				self:addUI(ui)
			else
				player.bossActivityMgr.updateActivity(self)
				self.bossActClick = true
			end
		end
	end
	self.onBossActivityTouched = onBossActivityTouched
end

function UI_activityMain:onMsg(msg_, param_)
	if msg_ == hp.MSG.SOLO_ACTIVITY then
		if param_.msgType == 3 then
			self.uiLoadingBarBg:setVisible(false)
			self.uiTime:setVisible(false)
			self.uiDesc:setString(hp.lang.getStrByID(5374))
			self.uiBrightFrame:setVisible(false)
		elseif param_.msgType == 4 then
			self.uiLoadingBarBg:setVisible(true)
			self.uiTime:setVisible(true)
			self.uiDesc:setString(hp.lang.getStrByID(5354))
			self.uiBrightFrame:setVisible(true)
		elseif param_.msgType == 5 then
			self:dataUpdate()
		end
	elseif msg_ == hp.MSG.UNION_ACTIVITY then
		if param_ == 1 and self.unionActClick then
			self:dataUpdate()
			self.unionActivity = false
			if UNION_ACTIVITY_PAGE == 0 then
				UNION_ACTIVITY_PAGE = 1
				require "ui/activity/unionActivity/unionActivity"
				local ui = UI_unionActivity.new(player.unionActivityMgr.getActivity())
				self:addUI(ui)
			end
		elseif param_ == 5 or param_ == 6 then
			self:dataUpdate()
		end
	elseif msg_ == hp.MSG.KINGDOM_ACTIVITY then
		-- 王国活动数据更新成功，进入界面
		if param_ == 1 and self.kingdomActClick then
			self:dataUpdate()
			self.kingdomActClick = false
			require "ui/activity/kingdomActivity/kingdomActivity"
			local ui = UI_kingdomActivity.new()
			self:addUI(ui)
		elseif param_ == 3 or param_ == 4 then
			self:dataUpdate()
		end
	elseif msg_ == hp.MSG.BOSS_ACTIVITY then
		if param_ == 1 and self.bossActClick then
			self:dataUpdate()
			self.bossActClick = false
			require "ui/activity/bossActivity/bossActivity"
			local ui = UI_bossActivity.new()
			self:addUI(ui)
		else
			self:dataUpdate()
		end
	end
end

function UI_activityMain:onRemove()
	self.super.onRemove(self)
end

function UI_activityMain:initShow()

	-- 个人活动项
	-- =====================
	self.item:addTouchEventListener(self.onSoloActivityTouched)
	local content_ = self.item:getChildByName("Panel_20426")
	content_:getChildByName("Label_20462"):setString(hp.lang.getStrByID(5353))
	-- 描述
	self.uiDesc = content_:getChildByName("Label_20462_0")
	-- 进度背景
	self.uiLoadingBarBg = self.item:getChildByName("Panel_15291"):getChildByName("ImageView_1644_0")
	-- 时间背景
	self.uiTimeBg = self.item:getChildByName("Panel_15291"):getChildByName("Image_17")
	-- 进度条
	self.uiLoadingBar = self.uiLoadingBarBg:getChildByName("LoadingBar_1640")
	-- 时间
	self.uiTime = content_:getChildByName("Label_1643")
	-- 亮框
	self.uiBrightFrame = self.item:getChildByName("Panel_15291"):getChildByName("Image_69")

	-- 联盟活动项
	-- =====================
	self.unionItem:addTouchEventListener(self.onUnionActivityTouched)
	local content_unionAct = self.unionItem:getChildByName("Panel_20426")

	content_unionAct:getChildByName("Label_20462"):setString(hp.lang.getStrByID(5607))
	content_unionAct:getChildByName("ImageView_20455"):loadTexture(config.dirUI.common .. "activity_21.png")

	self.union_Desc = content_unionAct:getChildByName("Label_20462_0")
	self.union_LoadingBarBg = self.unionItem:getChildByName("Panel_15291"):getChildByName("ImageView_1644_0")
	self.union_TimeBg = self.unionItem:getChildByName("Panel_15291"):getChildByName("Image_17")
	self.union_LoadingBar = self.union_LoadingBarBg:getChildByName("LoadingBar_1640")
	self.union_Time = content_unionAct:getChildByName("Label_1643")
	self.union_BrightFrame = self.unionItem:getChildByName("Panel_15291"):getChildByName("Image_69")

	-- 王国活动项
	-- =====================
	self.kingdomItem:addTouchEventListener(self.onKingdomActivityTouched)
	local content_kingdomAct = self.kingdomItem:getChildByName("Panel_20426")

	content_kingdomAct:getChildByName("Label_20462"):setString(hp.lang.getStrByID(11171))
	content_kingdomAct:getChildByName("ImageView_20455"):loadTexture(config.dirUI.common .. "activity_22.png")

	self.king_Desc = content_kingdomAct:getChildByName("Label_20462_0")
	self.king_LoadingBarBg = self.kingdomItem:getChildByName("Panel_15291"):getChildByName("ImageView_1644_0")
	self.king_TimeBg = self.kingdomItem:getChildByName("Panel_15291"):getChildByName("Image_17")
	self.king_LoadingBar = self.king_LoadingBarBg:getChildByName("LoadingBar_1640")
	self.king_Time = content_kingdomAct:getChildByName("Label_1643")
	self.king_BrightFrame = self.kingdomItem:getChildByName("Panel_15291"):getChildByName("Image_69")

	-- BOSS活动项
	-- =====================
	self.bossItem:addTouchEventListener(self.onBossActivityTouched)
	local content_bossAct = self.bossItem:getChildByName("Panel_20426")

	content_bossAct:getChildByName("Label_20462"):setString(string.format(hp.lang.getStrByID(11616), hp.lang.getStrByID(11615)))
	content_bossAct:getChildByName("ImageView_20455"):loadTexture(config.dirUI.common .. "activity_23.png")

	self.boss_Desc = content_bossAct:getChildByName("Label_20462_0")
	self.boss_LoadingBarBg = self.bossItem:getChildByName("Panel_15291"):getChildByName("ImageView_1644_0")
	self.boss_TimeBg = self.bossItem:getChildByName("Panel_15291"):getChildByName("Image_17")
	self.boss_LoadingBar = self.boss_LoadingBarBg:getChildByName("LoadingBar_1640")
	self.boss_Time = content_bossAct:getChildByName("Label_1643")
	self.boss_BrightFrame = self.bossItem:getChildByName("Panel_15291"):getChildByName("Image_69")

	-- 数据更新
	self:dataUpdate()
end

-- 数据更新
function UI_activityMain:dataUpdate()
	local status_ = globalData.ACTIVITY_STATUS
	
	-- 个人活动数据更新
	local activity_ = player.soloActivityMgr.getActivity()
	
	if activity_.status == status_.CLOSE then
		self.uiDesc:setString(hp.lang.getStrByID(5374))
		self.uiTimeBg:setVisible(false)
		self.uiBrightFrame:setVisible(false)
		self.uiTime:setVisible(false)
		self.uiLoadingBarBg:setVisible(false)
	elseif activity_.status == status_.OPEN then
		self.uiDesc:setString(hp.lang.getStrByID(5354))
		self.uiLoadingBarBg:setVisible(true)
		self.uiTimeBg:setVisible(false)
		self.uiTime:setVisible(true)
	elseif activity_.status == status_.NOT_OPEN then
		self.uiDesc:setString(hp.lang.getStrByID(5375))
		self.uiLoadingBarBg:setVisible(false)
		self.uiTimeBg:setVisible(true)
		self.uiTime:setVisible(true)
		self.uiBrightFrame:setVisible(false)
	end

	-- 联盟活动数据更新
	local unionActivity = player.unionActivityMgr.getActivity()

	if unionActivity.status == UNION_ACTIVITY_STATUS.CLOSE then
		self.union_Desc:setString(hp.lang.getStrByID(5374))
		self.union_TimeBg:setVisible(false)
		self.union_BrightFrame:setVisible(false)
		self.union_Time:setVisible(false)
		self.union_LoadingBarBg:setVisible(false)
	elseif unionActivity.status == UNION_ACTIVITY_STATUS.OPEN then
		self.union_Desc:setString(hp.lang.getStrByID(5354))
		self.union_LoadingBarBg:setVisible(true)
		self.union_TimeBg:setVisible(false)
		self.union_Time:setVisible(true)
		self.union_BrightFrame:setVisible(true)
	elseif unionActivity.status == UNION_ACTIVITY_STATUS.NOT_OPEN then
		self.union_Desc:setString(hp.lang.getStrByID(5375))
		self.union_LoadingBarBg:setVisible(false)
		self.union_TimeBg:setVisible(true)
		self.union_Time:setVisible(true)
		self.union_BrightFrame:setVisible(false)
	end

	-- 王国活动数据更新
	local kingdomActivity = player.kingdomActivityMgr.getActivity()

	if kingdomActivity == nil or kingdomActivity.status == KINGDOM_ACTIVITY_STATUS.CLOSE then
		self.king_Desc:setString(hp.lang.getStrByID(5374))
		self.king_TimeBg:setVisible(false)
		self.king_BrightFrame:setVisible(false)
		self.king_Time:setVisible(false)
		self.king_LoadingBarBg:setVisible(false)
	elseif kingdomActivity.status == KINGDOM_ACTIVITY_STATUS.OPEN then
		self.king_Desc:setString(hp.lang.getStrByID(5354))
		self.king_LoadingBarBg:setVisible(true)
		self.king_TimeBg:setVisible(false)
		self.king_Time:setVisible(true)
		self.king_BrightFrame:setVisible(true)
	elseif kingdomActivity.status == KINGDOM_ACTIVITY_STATUS.NOT_OPEN then
		self.king_Desc:setString(hp.lang.getStrByID(5375))
		self.king_LoadingBarBg:setVisible(false)
		self.king_TimeBg:setVisible(true)
		self.king_Time:setVisible(true)
		self.king_BrightFrame:setVisible(false)
	end

	-- 精英boss活动数据更新
	local bossActivity = player.bossActivityMgr.getActivity()

	if bossActivity == nil or bossActivity.status == BOSS_ACTIVITY_STATUS.CLOSE then
		self.boss_Desc:setString(hp.lang.getStrByID(5374))
		self.boss_TimeBg:setVisible(false)
		self.boss_BrightFrame:setVisible(false)
		self.boss_Time:setVisible(false)
		self.boss_LoadingBarBg:setVisible(false)
	elseif bossActivity.status == BOSS_ACTIVITY_STATUS.OPEN then
		if bossActivity.endTime - player.getServerTime() > player.bossActivityMgr.getTime() then
			self.boss_Desc:setString(hp.lang.getStrByID(11618))
		else
			self.boss_Desc:setString(hp.lang.getStrByID(5354))
		end
		self.boss_LoadingBarBg:setVisible(true)
		self.boss_TimeBg:setVisible(false)
		self.boss_Time:setVisible(true)
		self.boss_BrightFrame:setVisible(true)
	elseif bossActivity.status == BOSS_ACTIVITY_STATUS.NOT_OPEN then
		self.boss_Desc:setString(hp.lang.getStrByID(5375))
		self.boss_LoadingBarBg:setVisible(false)
		self.boss_TimeBg:setVisible(true)
		self.boss_Time:setVisible(true)
		self.boss_BrightFrame:setVisible(false)
	end
end

function UI_activityMain:heartbeat(dt_)
	self:tickUpdate()
end

function UI_activityMain:tickUpdate()
	if self.uiTime == nil or self.uiLoadingBar == nil then
		return
	end

	local activity_ = player.soloActivityMgr.getActivity()
	local status_ = globalData.ACTIVITY_STATUS
	-- 无个人活动
	if activity_ == nil or activity_.status == status_.CLOSE then

	else
		if activity_.status == status_.NOT_OPEN then
			local cd_ = activity_.beginTime - player.getServerTime()
			if cd_ < 0 then
				cd_ = 0
			end
			self.uiTime:setString(hp.datetime.strTime(cd_))
		else
			local cd_ = activity_.endTime - player.getServerTime()
			if cd_ < 0 then
				cd_ = 0
			end

			self.uiTime:setString(hp.datetime.strTime(cd_))
			local per_ = cd_ / activity_.total * 100
			self.uiLoadingBar:setPercent(per_)
		end
	end
	
	-- 联盟活动
	local unionActivity = player.unionActivityMgr.getActivity()

	-- 无联盟活动
	if unionActivity == nil or unionActivity.status == UNION_ACTIVITY_STATUS.CLOSE then

	else
		-- 活动未开启
		if unionActivity.status == UNION_ACTIVITY_STATUS.NOT_OPEN then
			local cd = unionActivity.beginTime - player.getServerTime()
			if cd < 0 then
				cd = 0
			end
			self.union_Time:setString(hp.datetime.strTime(cd))
		else
			local cd = unionActivity.endTime - player.getServerTime()
			if cd < 0 then
				cd = 0
			end

			self.union_Time:setString(hp.datetime.strTime(cd))
			local per = cd / unionActivity.totalTime * 100
			self.union_LoadingBar:setPercent(per)
		end
	end
	
	local kingdomActivity = player.kingdomActivityMgr.getActivity()

	-- 无王国活动
	if kingdomActivity == nil or kingdomActivity.status == KINGDOM_ACTIVITY_STATUS.CLOSE then

	else
		local cd = 0
		-- 活动未开启
		if kingdomActivity.status == KINGDOM_ACTIVITY_STATUS.NOT_OPEN then
			cd = kingdomActivity.beginTime - player.getServerTime()
		else
			cd = kingdomActivity.endTime - player.getServerTime()
			self.king_LoadingBar:setPercent(cd / kingdomActivity.totalTime * 100)
		end
		
		if cd < 0 then
			cd = 0
		end
		self.king_Time:setString(hp.datetime.strTime(cd))
	end

	-- 精英boss活动
	local bossActivity = player.bossActivityMgr.getActivity()
	if bossActivity == nil or bossActivity.status == BOSS_ACTIVITY_STATUS.CLOSE then

	else
		local cd = 0
		if bossActivity.status == BOSS_ACTIVITY_STATUS.NOT_OPEN then
			cd = bossActivity.beginTime - player.getServerTime()
		else
			cd = player.bossActivityMgr.getTime()
			if cd > bossActivity.endTime - player.getServerTime() then
				cd = bossActivity.endTime - player.getServerTime()
			end
		end

		if cd < 0 then
			cd = 0
		end
		self.boss_Time:setString(hp.datetime.strTime(cd))
	end
end