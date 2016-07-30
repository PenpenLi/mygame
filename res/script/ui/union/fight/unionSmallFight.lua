--
-- ui/union/unionSmallFight.lua
-- 小型团体作战
--===================================
require "ui/fullScreenFrame"

UI_unionSmallFight = class("UI_unionSmallFight", UI)

local interval = 0
local hardGrademap = {"normal", "hard", "elite"}
local difficultyIcon = {"fight_15.png", "fight_13.png", "fight_11.png", "fight_14.png", "fight_12.png", "fight_2.png"}
local rewardName = {5034, 5145, 5146}

--init
function UI_unionSmallFight:init(tab_)
	-- data
	-- ===============================
	self.tab = 1
	self.defenseIDMap = {}
	self.smallFightInfoList = {}

	-- ui data
	self.uiTab = {}
	self.uiTabText = {}
	self.uiFightLoadingBar = {}
	self.uiLoadingBar = {}
	self.uiCountTime = {}
	self.uiJoinNum = {}
	self.uiNumIcon = {}

	-- init data
	self:initData()

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5135))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self.sizeSelected = self.uiTab[1]:getScale()
	self.sizeUnselected = self.uiTab[2]:getScale()

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	self:tabPage(tab_)
end

function UI_unionSmallFight:initData()
	local fightInfo_ = hp.gameDataLoader.getTable("smallFight")
	if fightInfo_ == nil then
		return
	end

	local index_ = 1
	for i, v in ipairs(fightInfo_) do
		if player.getPower() >= v.power then
			self.smallFightInfoList[index_] = v
			index_ = index_ + 1
		end
	end
end

function UI_unionSmallFight:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "smallFight.json")
	local content_ = self.wigetRoot:getChildByName("Panel_29874_Copy0_0")
	local idList_ = {5071, 5072}
	for i = 1, 2 do
		self.uiTab[i] = content_:getChildByName("ImageView_801"..(i + 2))
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		self.uiTabText[i] = self.uiTab[i]:getChildByName("Label_2987"..(6 + i))
		self.uiTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
		self.uiNumIcon[i] = self.uiTab[i]:getChildByName("Image_2")
	end

	-- 更多信息
	local moreInfo_ = content_:getChildByName("Image_48")
	moreInfo_:getChildByName("Label_49"):setString(hp.lang.getStrByID(1030))
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)

	self.listView = self.wigetRoot:getChildByName("ListView_24")
	self.item1 = self.listView:getItem(0):clone()
	self.item1:retain()
	self.item2 = self.listView:getItem(1):clone()
	self.item2:retain()
	self.listView:removeAllItems()

	self.colorSelected = self.uiTab[1]:getColor()
	self.colorUnselected = self.uiTab[2]:getColor()
end

function UI_unionSmallFight:tabPage(id_)
	local scale_ = {self.sizeUnselected, self.sizeUnselected}
	local color_ = {self.colorUnselected, self.colorUnselected}
	scale_[id_] = self.sizeSelected
	color_[id_] = self.colorSelected

	for i = 1, 2 do
		self.uiTab[i]:setColor(color_[i])
		self.uiTab[i]:setScale(scale_[i])
		self.uiTabText[i]:setColor(color_[i])
		self.uiTabText[i]:setScale(scale_[i])
		self.uiNumIcon[i]:setScale(scale_[i])
	end

	self.tab = id_
	if id_ == 1 then
		player.getAlliance():unPrepareData(dirtyType.SMALFIGHT, "UI_unionSmallFight")
		self:refreshPage1()
	elseif id_ == 2 then
		player.getAlliance():prepareData(dirtyType.SMALFIGHT, "UI_unionSmallFight")
	end	
end

function UI_unionSmallFight:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	-- 查看玩家信息
	local function onCreateResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local function createMySmallFight()
			return Alliance.parseSmallFight({self.smallFightSid, 0, {player.getID()}})
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			local fight_ = createMySmallFight()
			player.getAlliance():insertSmallFight(fight_)
			require "ui/union/fight/unionSmallFightDetail"
			local ui_ = UI_unionSmallFightDetail.new(player.getID())
			self:addUI(ui_)
		end
	end

	local function onCreateTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			cclog_("create")
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 43
			oper.sid = sender:getTag()
			self.smallFightSid = oper.sid
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onCreateResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onDetailTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/fight/unionSmallFightDetail"

			ui_ = UI_unionSmallFightDetail.new(self.defenseIDMap[sender:getTag()])
			self:addUI(ui_)
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

	self.onTabTouched = onTabTouched
	self.onDetailTouched = onDetailTouched
	self.onCreateTouched = onCreateTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionSmallFight:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		cclog_(param_, self.tab)
		if param_ == dirtyType.SMALFIGHT then
			if self.tab == 2 then
				self:refreshPage2()
			end
		end
	end
end

function UI_unionSmallFight:onRemove()
	self.item1:release()
	self.item2:release()
	player.getAlliance():unPrepareData(dirtyType.SMALFIGHT, "UI_unionSmallFight")
	self.super.onRemove(self)
end

function UI_unionSmallFight:refreshPage1()
	local function createItemByindex(index_)
		local v = self.smallFightInfoList[index_]
		if v == nil then
			return nil
		end

		local item_ = self.item1:clone()
		local content_ = item_:getChildByName("Panel_33")
		-- 作战名称
		content_:getChildByName("Label_34"):setString(string.format(hp.lang.getStrByID(5038), v.name))
		-- 人数
		content_:getChildByName("Label_34_0"):setString(string.format(hp.lang.getStrByID(5031), v.num))
		-- 要求战斗力
		content_:getChildByName("Label_34_0_0"):setString(string.format(hp.lang.getStrByID(5032), v.power))
		-- 时间
		content_:getChildByName("Label_34_0_1"):setString(string.format(hp.lang.getStrByID(5033), hp.datetime.strTime(v.time)))

		local icon_ = {}
		icon_[1] = content_:getChildByName("Image_32")
		icon_[2] = content_:getChildByName("Image_32_0")
		icon_[3] = content_:getChildByName("Image_32_1")

		-- 奖励		
		local function freshReward(type_)
			local reward_ = ""
			for j, w in ipairs(v[hardGrademap[type_]]) do
				if w ~= 0 then
					local resource_ = hp.gameDataLoader.getInfoBySid("resInfo", j)
					reward_ = reward_..resource_.name..hp.common.changeNumUnit(w).."  "
				end
			end

			-- 设置图标
			local path_ = nil
			for j = 1, 3 do
				if j == type_ then
					icon_[j]:loadTexture(config.dirUI.common..difficultyIcon[j + 3])
					path_ = config.dirUI.common..difficultyIcon[j + 3]
				else
					icon_[j]:loadTexture(config.dirUI.common..difficultyIcon[j])
					path_ = config.dirUI.common..difficultyIcon[j]
				end
				cclog_(path_)
			end
			content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(rewardName[type_]), reward_))
		end

		local function onHardGradeTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType==TOUCH_EVENT_ENDED then
				freshReward(sender:getTag())
			end
		end

		icon_[1]:addTouchEventListener(onHardGradeTouched)
		icon_[2]:addTouchEventListener(onHardGradeTouched)
		icon_[3]:addTouchEventListener(onHardGradeTouched)

		-- 难度等级
		content_:getChildByName("Label_39"):setString(v.grade[1])
		content_:getChildByName("Label_39_0"):setString(v.grade[2])
		content_:getChildByName("Label_50"):setString(v.grade[3])
		
		local create_ = content_:getChildByName("Image_38")
		create_:getChildByName("Label_11"):setString(hp.lang.getStrByID(5035))
		create_:setTag(v.sid)
		create_:addTouchEventListener(self.onCreateTouched)
		freshReward(1)
		return item_
	end

	self.listView:removeAllItems()

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.item1:getSize().height, 3)
	end
	self.listViewHelper.initShow()

	if self.smallFightInfoList == nil then
		return
	end

	-- for i, v in ipairs(self.smallFightInfoList) do
	-- 	local item_ = createItemByindex(i)
	-- 	cclog_(item_)
	-- 	self.listView:pushBackCustomItem(item_)
	-- end	
end

function UI_unionSmallFight:refreshPage2()
	if self.listViewHelper ~= nil then
		self.listViewHelper.stopHelper()
	end
	self.listView:removeAllItems()
	local fightInfo_ = player.getAlliance():getSmallFight()
	if fightInfo_ == nil then
		return
	end

	self.itemMap = {}
	self.index = 1
	self.uiLoadingBar = {}
	self.uiCountTime = {}
	self.uiJoinNum = {}
	self.defenseIDMap = {}
	for i, v in ipairs(fightInfo_) do
		local item_ = self.item2:clone()
		self.listView:pushBackCustomItem(item_)
		item_:setTag(i)
		self.defenseIDMap[i] = v.members[1]
		item_:addTouchEventListener(self.onDetailTouched)
		local content_ = item_:getChildByName("Panel_33")
		-- 作战名称
		content_:getChildByName("Label_34"):setString(string.format(hp.lang.getStrByID(5038), v.info.name))
		-- 创建者
		local member_ = player.getAlliance():getMemberByID(v.members[1])
		content_:getChildByName("Label_34_2"):setString(hp.lang.getStrByID(5036))
		content_:getChildByName("Label_34_0_1"):setString(member_:getName())
		-- 人数
		self.uiJoinNum[i] = content_:getChildByName("Label_34_0")
		self.uiJoinNum[i]:setString(string.format(hp.lang.getStrByID(5037), table.getn(v.members), v.info.num))

		if v.myFight == 1 then
			item_:getChildByName("Panel_26"):getChildByName("Image_1"):setVisible(true)
		end
		if v.state == 1 then
			-- 状态
			content_:getChildByName("Label_34_0_0"):setString(hp.lang.getStrByID(5039))
			content_:getChildByName("Image_38"):loadTexture(config.dirUI.common.."fight_6.png")
		elseif v.state == 2 then
			content_:getChildByName("Label_34_0_0"):setVisible(false)
			content_:getChildByName("ImageView_1644_0"):setVisible(true)
			content_:getChildByName("Image_38"):loadTexture(config.dirUI.common.."fight_1.png")
		end
		self.uiLoadingBar[i] = content_:getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
		content_:getChildByName("ImageView_1644_0"):getChildByName("Label_1643"):setString(hp.lang.getStrByID(5040))
		self.uiCountTime[i] = self.uiLoadingBar[i]:getChildByName("ImageView_1641"):getChildByName("Label_1642")
		self.uiFightLoadingBar[i] = item_:getChildByName("Panel_26"):getChildByName("Image_29"):getChildByName("ProgressBar_30")

		local icon_ = {}
		icon_[1] = content_:getChildByName("Image_32")
		icon_[2] = content_:getChildByName("Image_32_0")
		icon_[3] = content_:getChildByName("Image_32_1")
		-- 奖励		
		local function freshReward(type_)
			local reward_ = ""
			for j, w in ipairs(v.info[hardGrademap[type_]]) do
				if w ~= 0 then
					local resource_ = hp.gameDataLoader.getInfoBySid("resInfo", j)
					reward_ = reward_..resource_.name..hp.common.changeNumUnit(w).."  "
				end
			end

			-- 设置图标
			for j = 1, 3 do
				if j == type_ then
					icon_[j]:loadTexture(config.dirUI.common..difficultyIcon[j + 3])
				else
					icon_[j]:loadTexture(config.dirUI.common..difficultyIcon[j])
				end
			end
			content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(rewardName[type_]), reward_))
		end

		local function onHardGradeTouched(sender, eventType)
			hp.uiHelper.btnImgTouched(sender, eventType)
			if eventType==TOUCH_EVENT_ENDED then
				freshReward(sender:getTag())
			end
		end

		icon_[1]:addTouchEventListener(onHardGradeTouched)
		icon_[2]:addTouchEventListener(onHardGradeTouched)
		icon_[3]:addTouchEventListener(onHardGradeTouched)
		
		-- 难度等级
		content_:getChildByName("Label_39"):setString(v.info.grade[1])
		content_:getChildByName("Label_39_0"):setString(v.info.grade[2])
		content_:getChildByName("Label_50"):setString(v.info.grade[3])
		
		freshReward(1)
	end
	self:updateFight()
	self:tickUpdateInfo()
end

function UI_unionSmallFight:updateFight()
	for i, v in ipairs(self.defenseIDMap) do
		local fightInfo_ = player.getAlliance():getSmallFightByID(v)
		self.uiJoinNum[i]:setString(string.format(hp.lang.getStrByID(5037), table.getn(fightInfo_.members), fightInfo_.info.num))
		local percent_ = fightInfo_.power / fightInfo_.info.grade[3] * 100
		cclog_(percent_)
		self.uiFightLoadingBar[i]:setPercent(percent_)
	end
end

function UI_unionSmallFight:tickUpdateInfo()
	if self.tab ~= 2 then
		return
	end
	local fightInfos_ = player.getAlliance():getSmallFight()
	for i, v in ipairs(fightInfos_) do
		if v.state == 2 then
			local restTime_= v.endTime - player.getServerTime()
			if restTime_ >= 0 then
				self.uiCountTime[i]:setString(hp.datetime.strTime(restTime_))
				local percent_ = 100 - restTime_ / v.info.time * 100
				self.uiLoadingBar[i]:setPercent(percent_)
			end
		end
	end
end

function UI_unionSmallFight:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:tickUpdateInfo()
end