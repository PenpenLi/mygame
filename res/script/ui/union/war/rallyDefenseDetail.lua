--
-- ui/union/rallyDefenseDetail.lua
-- 公会战细节
--===================================
require "ui/fullScreenFrame"

UI_rallyDefenseDetail = class("UI_rallyDefenseDetail", UI)

local interval = 0
local totalItem = 50
local interval = 0

local function setJoinArmyInfo(self, content_, info_, i)
	-- 名字
	content_:getChildByName("Label_58"):setString(string.format("【%s】%s", player.getAlliance():getBaseInfo().name, info_[2]))
	content_:getChildByName("Label_58"):setVisible(true)

	-- 兵力
	content_:getChildByName("Label_58_0"):setString(hp.lang.getStrByID(1873)..":"..info_[3])
	content_:getChildByName("Label_58_0"):setVisible(true)

	self.stateLabel[i] = content_:getChildByName("Label_58_1")
	self.stateLabel[i]:setVisible(true)
	if info_[4] > player.getServerTime() then
		self.stateLabel[i]:setString(hp.lang.getStrByID(5180))
		self.stateLabel[i]:setTag(0)
	else
		self.stateLabel[i]:setString(hp.lang.getStrByID(1874))
		self.stateLabel[i]:setTag(1)
	end
end

--init
function UI_rallyDefenseDetail:init(index_)
	-- data
	-- ===============================
	cclog_("index==============",index_)
	self.rallyInfo = player.getAlliance():getRallyDefenseByFellowID(index_)
	self.index = index_
	self.iAmInWar = false

	self.stateLabel = {}
	self.lastIndex = 0

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(1800))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	hp.uiHelper.uiAdaption(self.item)

	self:requestData()

	self:updateInfo()
end

function UI_rallyDefenseDetail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "rallyDefenseDetail.json")
	self.loadingBar = self.wigetRoot:getChildByName("Panel_15291"):getChildByName("Image_29_0"):getChildByName("ProgressBar_30")

	local content_ = self.wigetRoot:getChildByName("Panel_5")
	-- 攻击者
	content_:getChildByName("Label_6_3"):setString(hp.lang.getStrByID(5404))
	content_:getChildByName("Label_6"):setString(self.rallyInfo.ownerInfo.totalName)
	local viewBtn_ = content_:getChildByName("Image_7")
	viewBtn_:addTouchEventListener(self.onGoToCityTouched)
	viewBtn_:getChildByName("Label_8"):setString(hp.lang.getStrByID(5459))
	-- 被攻击者
	content_:getChildByName("Label_17"):setString(hp.lang.getStrByID(1863))
	content_:getChildByName("Label_17_0"):setString(self.rallyInfo.targetInfo.totalName)
	content_:getChildByName("Label_17_1"):setString(hp.lang.getStrByID(1862))
	content_:getChildByName("Label_17_2"):setString(self.rallyInfo.targetInfo.city)

	-- 兵力
	self.soldierNum = content_:getChildByName("Label_23")
	self.soldierNum:setString(string.format("%d/%d", self.rallyInfo.curSoldier, self.rallyInfo.totalSoldier))
	content_:getChildByName("Label_23_0"):setString(hp.lang.getStrByID(1864))
	self.countTime = content_:getChildByName("Label_23_1")

	content_:getChildByName("Label_6_0"):setString(hp.lang.getStrByID(1865))
	content_:getChildByName("Label_6_1"):setString(hp.lang.getStrByID(1866))
	content_:getChildByName("Label_6_2"):setString(hp.lang.getStrByID(1867))

	-- 援助
	self.help = content_:getChildByName("Image_2")
	content_:getChildByName("Label_12"):setString(hp.lang.getStrByID(1820))
	if self.rallyInfo.fellowID ~= player.getID() then		
		self.help:addTouchEventListener(self.onJoinTouched)
	else
		self.help:loadTexture(config.dirUI.common.."button_gray.png")
		self.help:setTouchEnabled(false)
	end

	self.listView = self.wigetRoot:getChildByName("ListView_27")
	self.item = self.listView:getItem(0):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_rallyDefenseDetail:requestData()
	local function onRallyWarResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.supportInfo = data
			self:refreshView(data)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 38
	oper.id = self.rallyInfo.fellowID
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onRallyWarResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_rallyDefenseDetail:initCallBack()
	-- 切换到城市
	local function onGoToCityTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local pos_ = self.rallyInfo.ownerInfo.position
			if game.curScene.mapLevel == 2 then
				game.curScene:gotoPosition(cc.p(pos_.x,pos_.y), nil, pos_.k)
				self:closeAll()
			else
				require "scene/kingdomMap"
				local map = kingdomMap.new()
   				map:enter()
   				map:gotoPosition(cc.p(pos_.x,pos_.y), nil, pos_.k)
			end
		end
	end

	local function reinforce()
		local function marchCallBack(army_, time_, hero_)
			local total_ = army_:getSoldierTotalNumber()
			table.insert(self.supportInfo.support, {army_.id, player.getName(), total_, time_ + player.getServerTime()})

			local item_ = self.listView:getItem(self.lastIndex)
			self.lastIndex = self.lastIndex + 1
			if item_ ~= nil then
				local content_ = item_:getChildByName("Panel_55")
				setJoinArmyInfo(self, content_, self.supportInfo.support[self.lastIndex], self.lastIndex)
			end

			self.help:loadTexture(config.dirUI.common.."button_gray.png")
			self.help:setTouchEnabled(false)
			self.iAmInWar = true
			
			player.getAlliance():joinDefense(self.index, army_)
		end

		local soldierNum_ = self.rallyInfo.totalSoldier - self.rallyInfo.curSoldier

		local function onConfirm1Touched()
			require "ui/march/march"
			UI_march.openMarchUI(self, self.rallyInfo.friendPos, globalData.MARCH_TYPE.REINFORCE, {maxNumber=soldierNum_, armyID=0, endTime=self.rallyInfo.lastTime}, marchCallBack)
		end

		if soldierNum_ == 0 then
			require "ui/common/successBox"
   			local box_ = UI_successBox.new(hp.lang.getStrByID(5460), hp.lang.getStrByID(5461), nil)
   			self:addModalUI(box_)
		elseif player.getNewGuyGuard() ~= 0 then
			require "ui/common/msgBoxRedBack"
   			local ui_ = UI_msgBoxRedBack.new(hp.lang.getStrByID(5143), hp.lang.getStrByID(5144), hp.lang.getStrByID(1209),
   				hp.lang.getStrByID(2412), onConfirm1Touched)
   			self:addModalUI(ui_)
   		else
   			onConfirm1Touched()
   		end
	end

	-- 查看玩家信息
	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.rallyInfo.totalSoldier == 0 then
				require "ui/common/noBuildingNotice"
				local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1254), 1010, 1, hp.lang.getStrByID(5076))
				self:addModalUI(ui_)
			else
				reinforce()
			end
		end
	end

	self.onJoinTouched = onJoinTouched
	self.onGoToCityTouched = onGoToCityTouched
end

function UI_rallyDefenseDetail:onRemove()
	self.item:release()
	self.super.onRemove(self)
end

function UI_rallyDefenseDetail:refreshView(info_)
	self.listView:removeAllItems()
	self.stateLabel = {}

	for i, v in ipairs(info_.support) do
		if v[2] == player.getName() then
			self.iAmInWar = true
		end
	end

	if self.iAmInWar == true then
		self.help:loadTexture(config.dirUI.common.."button_gray.png")
		self.help:setTouchEnabled(false)
	end

	local function createItemByindex(index_)
		if index_ > totalItem then
			return nil
		end

		local item_ = self.item:clone()
		local content_ = item_:getChildByName("Panel_55")
		-- 序号
		content_:getChildByName("Label_57"):setString(tostring(index_))
		if info_.support[index_] ~= nil then
			self.lastIndex = index_
			setJoinArmyInfo(self, content_, info_.support[index_], index_)
		end
		return item_
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.item:getSize().height, 5)
	end
	self.listViewHelper.initShow()
end

function UI_rallyDefenseDetail:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:updateInfo()
end

function UI_rallyDefenseDetail:updateInfo()
	local lastTime_ = self.rallyInfo.lastTime - player.getServerTime()
	if lastTime_ < 0 then
		lastTime_ = 0
	end
	local percent = 100 - lastTime_ / self.rallyInfo.totalTime * 100
	self.loadingBar:setPercent(percent)
	local countTime_ = hp.datetime.strTime(lastTime_)
	self.countTime:setString(countTime_)

	if self.supportInfo == nil then
		return
	end

	if self.supportInfo.support == nil then
		return
	end

	for i, v in ipairs(self.supportInfo.support) do
		if v[4] < player.getServerTime() then
			if self.stateLabel[i] ~= nil then
				if self.stateLabel[i]:getTag() == 0 then
					self.stateLabel[i]:setTag(1)
					self.stateLabel[i]:setString(hp.lang.getStrByID(1874))
				end
			end
		end
	end
end

function UI_rallyDefenseDetail:updateRallyInfo()
	self.rallyInfo = player.getAlliance():getRallyDefenseByFellowID(self.index)
	if self.rallyInfo == nil then
		self:close()
		return
	end
	self.soldierNum:setString(string.format("%d/%d", self.rallyInfo.curSoldier, self.rallyInfo.totalSoldier))
end

function UI_rallyDefenseDetail:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.DEFENSE then
			self:updateRallyInfo()
		end
	end
end