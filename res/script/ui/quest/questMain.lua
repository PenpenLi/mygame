--
-- ui/quest/questMain.lua
-- 任务主界面
--===================================
require "ui/fullScreenFrame"

UI_questMain = class("UI_questMain", UI)

local speedupcode = {11,12,13}

--init
function UI_questMain:init()
	-- data
	-- ===============================
	self.showState = {false, false, false}
	self.backgroud = {}
	self.recQuest = {}
	self.resetTime = {}
	self.check = {}
	self.progress = {}
	self.proText = {}
	self.progressCon = {}

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(766)
	uiFrame:setTitle(hp.lang.getStrByID(1410))

	require "ui/common/promotionInfo"
	local promotion_ = UI_promotionInfo.new()
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(promotion_)
	self:addCCNode(self.wigetRoot)

	-- call back
	function OnQuestBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			if tag_ == 1 then
				require "ui/quest/empireQuest"
				local ui_ = UI_empireQuest.new()
				self:addUI(ui_)
				player.guide.step(4003)
			elseif tag_ == 2 then
				require "ui/quest/dailyQuest"
				local ui_ = UI_dailyQuest.new(1)
				self:addUI(ui_)				
			elseif tag_ == 3 then
				if player.getAlliance():getUnionID() ~= 0 then
					require "ui/quest/dailyQuest"
					local ui_ = UI_dailyQuest.new(2)
					self:addUI(ui_)
				elseif table.getn(player.questManager.getDailyTasks(2)) ~= 0 then
					require "ui/quest/dailyQuest"
					local ui_ = UI_dailyQuest.new(2)
					self:addUI(ui_)
				else
					local function onConfirm()
						require "ui/union/invite/unionJoin"
						local ui_ = UI_unionJoin.new()
						self:addUI(ui_)
					end
					require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(5236), 
						hp.lang.getStrByID(5237), 
						hp.lang.getStrByID(1209), 
						hp.lang.getStrByID(2412),  
						onConfirm,nil,"red"
						)
					game.curScene:addModalUI(msgBox)
				end
			elseif tag_ == 4 then
				if player.vipStatus.isActive() == true then
					require "ui/quest/dailyQuest"
					local ui_ = UI_dailyQuest.new(3)
					self:addUI(ui_)
				else
					require "ui/quest/activateVIP"
					local ui_ = UI_activateVIP.new()
					self:addModalUI(ui_)
				end				
			end
		end
	end


	for i = 1, 4 do
		self.backgroud[i]:addTouchEventListener(OnQuestBtnTouched)
	end

	-- 初始显示
	self:updateUIShow()

	-- 消息注册
	self:registMsg(hp.MSG.MISSION_COMPLETE)
	self:registMsg(hp.MSG.MISSION_COLLECT)	
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.MISSION_DAILY_COMPLETE)
	self:registMsg(hp.MSG.MISSION_DAILY_START)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)
	self:registMsg(hp.MSG.GUIDE_STEP)
	self:registMsg(hp.MSG.MISSION_DAILY_QUICKFINISH)


	-- 进行新手引导绑定
	-- ================================
	local function bindGuideUI( step )
		if step==4003 then
			self.wigetRoot:getChildByName("ListView_15172"):visit()
			player.guide.bind2Node111(step, self.backgroud[1], OnQuestBtnTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_questMain:updateUIShow()
	for i = 2, 4 do
		local info_ = cdBox.getCDInfo(speedupcode[i - 1])
		if info_ ~= nil then
			if info_.cd > 0 then
				self:setShowState(true, i)
				self:updateCDTime(i)
			else
				self:setShowState(false, i)
			end
		else
			self:setShowState(false, i)
		end
		local timeNum_ = player.questManager.getResetTime(i - 1) - player.getServerTime()
		if timeNum_ < 0 then
			timeNum_ = 0
		end
		local time_ = hp.datetime.strTime(timeNum_)
		self.resetTime[i]:setString(hp.lang.getStrByID(1406)..":"..time_)
	end
end

function UI_questMain:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "questMain.json")
	local listView = self.wigetRoot:getChildByName("ListView_15172")
	local rootName_ = {"Panel_15173", "Panel_15173_Copy0", "Panel_15173_Copy1", "Panel_15173_Copy2"}
	local title_ = {1400, 1401, 1402, 1403}

	for i = 1, 4 do
		-- 背景
		self.backgroud[i] = listView:getChildByName(rootName_[i]):getChildByName("Panel_15175"):getChildByName("ImageView_14047")
		self.backgroud[i]:setTag(i)

		-- 内容
		local container = listView:getChildByName(rootName_[i]):getChildByName("Panel_15176")

		-- 头像图片
		-- container:getChildByName("ImageView_15155"):getChildByName("ImageView_15156"):loadTexture()

		if i > 1 then
			local bottomContent = container:getChildByName("ImageView_15205")
			-- 可接任务
			bottomContent:getChildByName("Label_15206"):setString(hp.lang.getStrByID(1405))
			self.recQuest[i] = bottomContent:getChildByName("ImageView_15207"):getChildByName("Label_15208")

			-- 重置时间
			self.resetTime[i] = bottomContent:getChildByName("Label_15210")		

			-- 进度条
			self.progressCon[i] = container:getChildByName("ImageView_111")
			self.progress[i] = container:getChildByName("ImageView_111"):getChildByName("LoadingBar_1640")
			self.proText[i] = self.progress[i]:getChildByName("Label_1642")	
		end

		-- 有任务完成提示
		self.check[i] = container:getChildByName("ImageView_15211")
	end

	self:updateCheckStatus()	
	self:updateRecievable()
end

function UI_questMain:updateCheckStatus()
	if table.getn(player.questManager.getBranchReward()) ~= 0 or player.questManager.getMainReward() ~= nil then
		self.check[1]:setVisible(true)
	else
		self.check[1]:setVisible(false)
	end

	for i = 2, 4 do
		self.check[i]:setVisible(player.questManager.rewardNotCollected(i - 1))
	end
end

function UI_questMain:updateRecievable()
	for i = 2, 4 do
		local num_ = 0
		for j, v in ipairs(player.questManager.getDailyTasks(i - 1)) do
			if v.flag == 3 then
				num_ = num_ + 1
			end
		end
		self.recQuest[i]:setString(tostring(num_))
	end
end

function UI_questMain:onMsg(msg_, parm_)
	if msg_ == hp.MSG.MISSION_COMPLETE or msg_ == hp.MSG.MISSION_COLLECT then
		-- 帝国任务完成或者领取之后触发
		self:updateCheckStatus()
	elseif msg_ == hp.MSG.MISSION_DAILY_COLLECTED or msg_ == hp.MSG.MISSION_DAILY_COMPLETE then
		self:updateCheckStatus()		
	elseif (msg_ == hp.MSG.MISSION_DAILY_START) or (msg_ == hp.MSG.MISSION_DAILY_REFRESH) or (msg_ == hp.MSG.MISSION_DAILY_QUICKFINISH) then
		self:updateRecievable()
	elseif msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(parm_)
	end
end

function UI_questMain:heartbeat(dt_)
	-- 刷新时间
	self:updateUIShow()
end

function UI_questMain:updateCDTime(index_)
	local cdInfo_ = cdBox.getCDInfo(speedupcode[index_ - 1])
	self.proText[index_]:setString(hp.datetime.strTime(cdInfo_.cd))
	local percent_ = 100 - cdInfo_.cd / cdInfo_.total_cd * 100
	self.progress[index_]:setPercent(percent_)
end

function UI_questMain:setShowState(show_, index_)
	if self.showState[index_ - 1] ~= show_ then
		self.showState[index_ - 1] = show_
		self.progressCon[index_]:setVisible(show_)
	end
end