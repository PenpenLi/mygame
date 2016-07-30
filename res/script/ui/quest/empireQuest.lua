	--
-- ui/quest/empireQuest.lua
-- 帝国任务
--===================================
require "ui/fullScreenFrame"

UI_empireQuest = class("UI_empireQuest", UI)

local questTypeName = {1428, 1429, 1430, 1431, 1432, 1433, 1434}
local titleImage = {"cd_icon_remedy.png", "cd_icon_build.png", "quest_33.png", "quest_34.png", "cd_icon_equip.png", "cd_icon_research.png", "cd_icon_march.png"}

--init
function UI_empireQuest:init()
	-- data
	-- ===============================
	self.listRecord = {}
	self.uiItemList = {}
	self.itemPos = {0}
	self.itemInfoList = {}
	self.finishList = {}

	-- call back

	local function OnQuestTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/quest/questDetail"
			local ui_ = UI_questDetail.new(sender:getTag())
			self:addUI(ui_)
		end
	end
	self.OnQuestTouched = OnQuestTouched

	local function OnCollectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then			
			self:showLoading(player.questManager.httpReqCollectEmpireReward(sender:getTag(), self, sender))
		end
	end
	self.OnCollectTouched = OnCollectTouched

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(1400))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.uiItem)
	self.typeTitleHeight_ = self.uiTitle:getChildByName("Panel_15257"):getSize().height
	self.branchHeight_ = self.uiItem:getSize().height

	-- register msg
	self:registMsg(hp.MSG.MISSION_COLLECT)
	self:registMsg(hp.MSG.MISSION_REFRESH)
	self:registMsg(hp.MSG.GUIDE_STEP)

	-- 进行新手引导绑定
	-- ================================
	local function bindGuideUI( step )
		if step==4005 then
			player.guide.bind2Node111(step, self.mainCollectBtn, self.OnCollectTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

-- 初始化UI
function UI_empireQuest:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "empireMission.json")
	self.listView = self.wigetRoot:getChildByName("ListView_15254")

	-- 主线任务
	local mainQuest = self.wigetRoot:getChildByName("Panel_15260")
	self.mainQuest = mainQuest
	mainQuest:getChildByName("Label_15263"):setString(hp.lang.getStrByID(1407))
	self.mainCollectBtn = mainQuest:getChildByName("ImageView_20423")
	self.mainCollectBtn:getChildByName("Label_20424"):setString(hp.lang.getStrByID(1413))
	self.mainCollectBtn:addTouchEventListener(self.OnCollectTouched)
	self.mainQuestBg = self.wigetRoot:getChildByName("Panel_15257"):getChildByName("ImageView_15259")
	self.mainQuestBg:addTouchEventListener(self.OnQuestTouched)
	
	-- 主线图标
	self.mainImage = mainQuest:getChildByName("ImageView_15264")
	self:refreshMainTask()

	self.uiTitle = self.listView:getChildByName("Panel_15267"):clone()
	self.uiTitle:retain()
	self.uiItem = self.listView:getChildByName("Panel_15289"):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()

	-- 已完成支线任务
	self:refreshQuestList()

	-- 支线任务
	self:refreshBranchTask()
end

-- 刷新主线任务
function UI_empireQuest:refreshMainTask()
	local info_ = player.questManager.getMainQuestInfo()
	-- 没有任务了
	if info_ == nil then
		self.mainQuest:setVisible(false)
		self.wigetRoot:getChildByName("Panel_15257"):setVisible(false)
		local size_ = self.mainQuest:getSize()
		local size1_ = self.listView:getSize()
		size1_.height = size1_.height + size_.height
		self.listView:setSize(size1_)
		return
	end
	local mainQuestInfo_ = hp.gameDataLoader.getInfoBySid("quests", info_.id)	
	self.mainQuestBg:setTag(info_.id)
	self.mainQuest:getChildByName("Label_15265"):setString(mainQuestInfo_.name)
	self.mainQuest:getChildByName("Label_15266"):setString(mainQuestInfo_.text)

	-- 主线图标
	self.mainImage:loadTexture(config.dirUI.quest..mainQuestInfo_.image)

	-- 领奖按钮
	-- self.mainCollectBtn:setTag(info_.id)
	-- self.mainCollectBtn:setVisible(info_.reward)
	-- self.mainCollectBtn:setTouchEnabled(info_.reward)
end

-- 刷新任务奖励
function UI_empireQuest:refreshQuestList()
	do return end
	if self.finishList ~= nil then
		for i, v in ipairs(self.finishList) do
			local index_ = self.listView:getIndex(v.item)
			self.listView:removeItem(index_)
		end
		self.finishList = {}
	end
	if table.getn(player.questManager.getBranchReward()) > 0 then
		self.finishList = {}
		local item_ = self.uiTitle:clone()
		item_:getChildByName("Panel_15286"):getChildByName("Label_18652"):setString(hp.lang.getStrByID(1435))
		local ele_ = {item = item_, id = -1}
		table.insert(self.finishList, ele_)
		for i, v in ipairs(player.questManager.getBranchReward()) do
			local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", v)
			if questInfo_.type ~= 1 then
				local ele_ = {}
				local rewardQuest_ = self.uiItem:clone()
				local rewardContent_ = rewardQuest_:getChildByName("Panel_18648")
				local collect_ = rewardContent_:getChildByName("ImageView_20423")
				collect_:setTag(v)
				collect_:setVisible(true)
				collect_:setTouchEnabled(true)
				collect_:addTouchEventListener(self.OnCollectTouched)
				collect_:getChildByName("Label_20424"):setString(hp.lang.getStrByID(1413))
				rewardContent_:setTag(v)
				rewardContent_:addTouchEventListener(self.OnQuestTouched)				

				-- 任务信息
				rewardContent_:getChildByName("Label_18649"):setString(questInfo_.name)
				rewardContent_:getChildByName("Label_18650"):setString(questInfo_.text)

				ele_.id = v
				ele_.item = rewardQuest_
				table.insert(self.finishList, ele_)
			else
				cclog_(string.format("UI_empireQuest:refreshQuestList,quest:%d in BranchReward, type=1, impossible",v))
			end
		end

		-- 加入列表
		for i, v in ipairs(self.finishList) do
			self.listView:insertCustomItem(v.item, i - 1)
			if i == 1 then
				v.item:setLocalZOrder(1)
			else
				v.item:setLocalZOrder(0)
			end
		end

		self.itemPos[1] = table.getn(self.finishList)
	end	
end

-- 刷新支线任务
function UI_empireQuest:refreshBranchTask()
	for i, v in ipairs(player.questManager.getBranchQuest()) do
		if self.listRecord[i] ~= nil then
			for j, w in ipairs(self.listRecord[i]) do
				local index_ = self.listView:getIndex(w)
				self.listView:removeItem(index_)
			end
			self.listRecord[i] = nil
		end

		-- 不存在则创建
		if table.getn(v) > 0 then
			self.listRecord[i] = {}	
			self.listRecord[i][1] = self.uiTitle:clone()
			self.listRecord[i][1]:getChildByName("Panel_15286"):getChildByName("Label_18652"):setString(hp.lang.getStrByID(questTypeName[i]))
			-- 设置图标
			self.listRecord[i][1]:getChildByName("Panel_15286"):getChildByName("ImageView_15287"):getChildByName("ImageView_15295"):loadTexture(config.dirUI.common..titleImage[i])
			for j, w in ipairs(v) do
				local branchGroupClone_ = self.uiItem:clone()
				local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", w)

				-- 任务点击回调
				local branchContent_ = branchGroupClone_:getChildByName("Panel_18648")
				branchContent_:setTag(w)
				branchContent_:addTouchEventListener(self.OnQuestTouched)

				-- 任务信息
				branchContent_:getChildByName("Label_18649"):setString(questInfo_.name)
				branchContent_:getChildByName("Label_18650"):setString(questInfo_.text)

				self.listRecord[i][j + 1] = branchGroupClone_
			end	

			-- 加入列表
			for j, w in ipairs(self.listRecord[i]) do
				self.listView:insertCustomItem(w, self.itemPos[i] + j - 1)
					if j == 1 then
					w:setLocalZOrder(1)
				end
			end

			self.itemPos[i + 1] = table.getn(self.listRecord[i]) + self.itemPos[i]
		end
	end
end

function UI_empireQuest:refreshTasks(type_)
	-- 主线任务
	if type_ == 1 then
		self:refreshMainTask()
	-- 已完成支线任务
	elseif type_ == 2 then
		self:refreshQuestList()
	elseif type_ == 3 then
	-- 支线任务
		self:refreshBranchTask()
	end
end

function UI_empireQuest:removeBranchReward(questID_)
	cclog_("removeBranchReward")
	for i, v in ipairs(self.finishList) do
		if v.id == questID_ then
			table.remove(self.finishList, i)
			self.listView:removeItem(self.listView:getIndex(v.item))
			cclog_("removeBranchReward success")
			break
		end
	end	

	if table.getn(self.finishList) == 1 then
		self.listView:removeItem(self.listView:getIndex(self.finishList[1].item))
	end
end

function UI_empireQuest:onMissionCollect(questID_)
	local questInfo_ = hp.gameDataLoader.getInfoBySid("quests", questID_)

	if questInfo_.type == 1 then
		self:refreshMainTask()
	else
		self:removeBranchReward(questID_)
	end
	
	self.listView:refreshView()
end

function UI_empireQuest:onMsg(msg_, parm_)
	if msg_ == hp.MSG.MISSION_COLLECT then
		self:onMissionCollect(parm_)
		player.guide.step(4005)
	elseif msg_ == hp.MSG.MISSION_REFRESH then
		self:refreshTasks(parm_)
	elseif msg_ == hp.MSG.GUIDE_STEP then
		self.bindGuideUI(parm_)
	end
end

function UI_empireQuest:onRemove()
	self.uiItem:release()
	self.uiTitle:release()
	self.super.onRemove(self)
end