--
-- ui/union/rallyWarDetail.lua
-- 公会战细节
--===================================
require "ui/fullScreenFrame"

UI_rallyWarDetail = class("UI_rallyWarDetail", UI)

local interval = 0
local totalItem = 50
local interval = 0

local function setEmptyPlaceInfo(self, content_, iAmInWar)
	-- 名字
	content_:getChildByName("Label_58"):setVisible(false)
	-- 兵力
	content_:getChildByName("Label_58_0"):setVisible(false)
	local join_ = content_:getChildByName("Image_62")
	join_:getChildByName("Label_63"):setString(hp.lang.getStrByID(1875))
	if iAmInWar == false then
		join_:addTouchEventListener(self.onJoinTouched)
		join_:loadTexture(config.dirUI.common.."button_blue.png")
	end
	join_:setVisible(true)
	content_:getChildByName("Image_62_0"):setVisible(false)
end

local function setUnlockPlaceInfo(self, content_, myWar_)
	-- 名字
	content_:getChildByName("Label_58"):setVisible(false)
	-- 兵力
	content_:getChildByName("Label_58_0"):setVisible(false)
	local unlock_ = content_:getChildByName("Image_62_0")
	if myWar_ then
		unlock_:getChildByName("Label_63"):setString(hp.lang.getStrByID(1876))
	else
		unlock_:getChildByName("Label_63"):setString(hp.lang.getStrByID(5457))
	end
	unlock_:addTouchEventListener(self.onUnlockTouched)
	unlock_:setVisible(true)
end

local function setJoinArmyInfo(self, content_, info_, i)
	-- 名字
	content_:getChildByName("Label_58"):setVisible(true)
	content_:getChildByName("Label_58"):setString(string.format("【%s】%s", player.getAlliance():getBaseInfo().name, info_[1]))
	-- 兵力
	content_:getChildByName("Label_58_0"):setVisible(true)
	content_:getChildByName("Label_58_0"):setString(hp.lang.getStrByID(1873)..":"..info_[2])
	content_:getChildByName("Label_58_1"):setVisible(true)
	self.stateLabel[i] = content_:getChildByName("Label_58_1")
	self.stateLabel[i]:setVisible(true)
	content_:getChildByName("Image_62"):setVisible(false)
	content_:getChildByName("Image_62"):setTouchEnabled(false)
	if info_[3] > player.getServerTime() then
		self.stateLabel[i]:setString(hp.lang.getStrByID(5180))
		self.stateLabel[i]:setTag(0)
	else
		self.stateLabel[i]:setString(hp.lang.getStrByID(1874))
		self.stateLabel[i]:setTag(1)
	end
end

--init
function UI_rallyWarDetail:init(index_)
	-- data
	-- ===============================
	self.myWar = false
	self.rallyInfo = player.getAlliance():getRallyWarByID(index_)
	self.iAmInWar = false	
	self.emptyIndex = 0
	self.index = index_

	self.uiItemList = {}

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

	hp.uiHelper.uiAdaption(self.item)
	
	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	self:requestData()

	self:updateInfo()
end

function UI_rallyWarDetail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "rallyWarDetail.json")
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
	local name_ = self.rallyInfo.targetInfo.totalName
	if name_ == "" then
		name_ = self.rallyInfo.targetInfo.city
	end
	content_:getChildByName("Label_17_0"):setString(name_)
	content_:getChildByName("Label_17_1"):setString(hp.lang.getStrByID(1862))
	content_:getChildByName("Label_17_2"):setString(self.rallyInfo.targetInfo.city)

	-- 兵力
	self.soldierNum = content_:getChildByName("Label_23")
	self.soldierNum:setString(string.format("%d/%d", self.rallyInfo.curSoldier, self.rallyInfo.totalSoldier))
	content_:getChildByName("Label_23_0"):setString(hp.lang.getStrByID(1864))
	self.countTime = content_:getChildByName("Label_23_1")
	self.countTime:setString(hp.datetime.strTime(self.rallyInfo.lastTime - player.getServerTime()))

	content_:getChildByName("Label_6_0"):setString(hp.lang.getStrByID(1865))
	content_:getChildByName("Label_6_1"):setString(hp.lang.getStrByID(1866))
	content_:getChildByName("Label_6_2"):setString(hp.lang.getStrByID(1867))

	self.listView = self.wigetRoot:getChildByName("ListView_27")
	self.item = self.listView:getItem(0):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_rallyWarDetail:requestData()
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
	oper.type = 37
	oper.id = self.rallyInfo.id
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onRallyWarResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_rallyWarDetail:initCallBack()
	local function adjustIndexInfo()
		if self.emptyIndex > self.supportInfo.len then
			self.emptyIndex = 0
		end
	end
	self.adjustIndexInfo = adjustIndexInfo

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

	-- 查看玩家信息
	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function marchCallBack(army_, time_, hero_)
				cclog_("marchCallBackmarchCallBackmarchCallBackmarchCallBackmarchCallBack",self.emptyIndex)
				-- 加入部队
				local total_ = army_:getSoldierTotalNumber()
				table.insert(self.supportInfo.support, {player.getName(), total_, time_ + player.getServerTime()})

				-- 取消按钮点击
				if table.getn(self.supportInfo.support) < self.supportInfo.len then
					for i=table.getn(self.supportInfo.support) + 1, self.supportInfo.len do
						if self.uiItemList[i] ~= nil then
							local content_ = self.uiItemList[i]:getChildByName("Panel_55")
							local join_ = content_:getChildByName("Image_62")
							join_:loadTexture(config.dirUI.common.."button_gray.png")
							join_:setTouchEnabled(false)
							self.iAmInWar = true
						end
					end
				end

				player.getAlliance():joinAttack(self.index, army_)

				-- 项目还未加载，返回
				local item_ = self.uiItemList[self.emptyIndex]
				if item_ ~= nil then
					local content_ = item_:getChildByName("Panel_55")
					setJoinArmyInfo(self, content_, self.supportInfo.support[self.emptyIndex], self.emptyIndex)					
				end

				self.emptyIndex = self.emptyIndex + 1
				self.adjustIndexInfo()
			end

			local soldierNum_ = self.rallyInfo.totalSoldier - self.rallyInfo.curSoldier

			local function onConfirm1Touched()
				require "ui/march/march"
				UI_march.openMarchUI(self, self.rallyInfo.friendPos, globalData.MARCH_TYPE.DONATE, {maxNumber=soldierNum_, armyID=self.rallyInfo.id}, marchCallBack)
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
	end

	local function unlockOneWarSlot()
		if self.supportInfo == nil then
			return
		end

		self.supportInfo.len = self.supportInfo.len + 1
		if self.emptyIndex == 0 then
			self.emptyIndex = table.getn(self.supportInfo.support) + 1
		end
		cclog_("self.supportInfo.lenself.supportInfo.lenself.supportInfo.lenself.supportInfo.len",self.supportInfo.len)
		setEmptyPlaceInfo(self, self.uiItemList[self.supportInfo.len]:getChildByName("Panel_55"), self.iAmInWar)
	end

	local function unlockWarSlot(id_)		
		local function onApplicantResponse(status, response, tag)
			if status ~= 200 then
				return
			end

			local data = hp.httpParse(response)
			if data.result == 0 then
				if self.rallyInfo.fellowID == id_ then
					unlockOneWarSlot()
				end
			end
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 16
		oper.type = 39
		oper.id = string.format("%.0f", id_)
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onApplicantResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end

	local function onUnlockConfirmed()
		if self.myWar == false then
			require "ui/union/war/unlockWarSlot"
			ui_ = UI_unlockWarSlot.new(self.rallyInfo, unlockWarSlot)
			self:addModalUI(ui_)
		else
			unlockWarSlot(player.getID())
		end
	end

	local function onUnlockTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/goldCostConfirm"
			local ui_ = UI_goldCostConfirm.new(hp.lang.getStrByID(1192), 1, hp.gameDataLoader.getInfoBySid("item", 20701), onUnlockConfirmed)
			self:addModalUI(ui_)
		end
	end

	-- 切换标签
	local function onTabTouched(sender, eventType)
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
	self.onJoinTouched = onJoinTouched
	self.onUnlockTouched = onUnlockTouched
	self.onGoToCityTouched = onGoToCityTouched
end

function UI_rallyWarDetail:onRemove()
	self.item:release()
	self.super.onRemove(self)
end

function UI_rallyWarDetail:refreshView(info_)
	self.listView:removeAllItems()

	if info_.support[1][1] == player.getName() then
		self.myWar = true
	end

	self.emptyIndex = table.getn(info_.support) + 1

	self.adjustIndexInfo()

	self.uiItemList = {}
	self.stateLabel = {}

	for i, v in ipairs(info_.support) do
		if v[1] == player.getName() then
			self.iAmInWar = true
			break
		end
	end

	local function createItemByindex(index_)
		if index_ > totalItem then
			return nil
		end

		local item_ = self.item:clone()
		self.uiItemList[index_] = item_
		local content_ = item_:getChildByName("Panel_55")
		-- 序号
		content_:getChildByName("Label_57"):setString(tostring(index_))
		-- 参战军队
		if info_.support[index_] ~= nil then
			setJoinArmyInfo(self, content_, info_.support[index_], index_)
		-- 空格
		elseif index_ <= info_.len then
			setEmptyPlaceInfo(self, content_, self.iAmInWar)
		-- 锁定，开一个就可以，break
		else
			setUnlockPlaceInfo(self, content_, self.myWar)
			-- break
		end
		return item_
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.item:getSize().height, 5)
	end
	self.listViewHelper.initShow()
end

function UI_rallyWarDetail:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:updateInfo()
end

function UI_rallyWarDetail:updateInfo()
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
		if v[3] < player.getServerTime() then
			if self.stateLabel[i] ~= nil then
				if self.stateLabel[i]:getTag() == 0 then
					self.stateLabel[i]:setTag(1)
					self.stateLabel[i]:setString(hp.lang.getStrByID(1874))
				end
			end
		end
	end
end

function UI_rallyWarDetail:updateRallyInfo()
	self.rallyInfo = player.getAlliance():getRallyWarByID(self.index)
	if self.rallyInfo == nil then
		self:close()
		return
	end
	self.soldierNum:setString(string.format("%d/%d", self.rallyInfo.curSoldier, self.rallyInfo.totalSoldier))
end

function UI_rallyWarDetail:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.ATTACK then
			self:updateRallyInfo()
		end
	end
end