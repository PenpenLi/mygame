--
-- ui/hallOfWar/hallOfWar.lua
-- 公会战
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_hallOfWar = class("UI_hallOfWar", UI)

local interval = 0

--init
function UI_hallOfWar:init(building_)
	-- data
	-- ===============================
	self.tab = 1
	self.defenseIDMap = {}
	self.building = building_
	-- ui data
	self.uiTab = {}
	self.uiTabText = {}
	self.uiLoadingBar = {}
	self.uiCountTime = {}
	self.uiNumIcon = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(building_.bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item)

	self.sizeSelected = self.uiTab[1]:getScale()
	self.sizeUnselected = self.uiTab[2]:getScale()

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	self:tabPage(1)
end

function UI_hallOfWar:changeNumber()
	local homePageInfo_ = player.getAlliance():getUnionHomePageInfo()
	if homePageInfo_.war > 0 then
		self.uiNumIcon[1]:getChildByName("Label_3"):setString(homePageInfo_.war)
		self.uiNumIcon[1]:setVisible(true)
	else
		self.uiNumIcon[1]:setVisible(false)
	end

	if homePageInfo_.defense > 0 then
		self.uiNumIcon[2]:getChildByName("Label_3"):setString(homePageInfo_.defense)
		self.uiNumIcon[2]:setVisible(true)
	else
		self.uiNumIcon[2]:setVisible(false)
	end
end

function UI_hallOfWar:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hallOfWar.json")
	local content_ = self.wigetRoot:getChildByName("Panel_29874_Copy0_0")
	local idList_ = {1853, 1854}
	for i = 1, 2 do
		self.uiTab[i] = content_:getChildByName("ImageView_801"..(i + 2))
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		self.uiTabText[i] = self.uiTab[i]:getChildByName("Label_2987"..(6 + i))
		self.uiTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
		self.uiNumIcon[i] = self.uiTab[i]:getChildByName("Image_2")
	end
	
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/hallOfWar/hallOFWarInfo"
			local moreInfoBox = UI_hallOfWarInfo.new(self.building)
			self:addModalUI(moreInfoBox)
		end
	end
	
	
	
	-- 更多信息
	local moreInfo_ = content_:getChildByName("Image_48")
	moreInfo_:getChildByName("Label_49"):setString(hp.lang.getStrByID(1030))
	moreInfo_:addTouchEventListener(onMoreInfoTouched)

	self.listView = self.wigetRoot:getChildByName("ListView_24")
	self.item = self.listView:getChildByName("Panel_25"):clone()
	self.item:retain()
	self.listView:removeAllItems()

	self.colorSelected = self.uiTab[1]:getColor()
	self.colorUnselected = self.uiTab[2]:getColor()
end

function UI_hallOfWar:tabPage(id_)
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
		player.getAlliance():unPrepareData(dirtyType.DEFENSE, "UI_hallOfWar")
		player.getAlliance():prepareData(dirtyType.ATTACK, "UI_hallOfWar")
		player.getAlliance():prepareData(dirtyType.VARIABLENUM, "UI_hallOfWar")
	elseif id_ == 2 then
		player.getAlliance():unPrepareData(dirtyType.ATTACK, "UI_hallOfWar")
		player.getAlliance():prepareData(dirtyType.DEFENSE, "UI_hallOfWar")
		player.getAlliance():prepareData(dirtyType.VARIABLENUM, "UI_hallOfWar")
	end
end

function UI_hallOfWar:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	-- 查看玩家信息
	local function onJoinAttackTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/war/rallyWarDetail"
			ui_ = UI_rallyWarDetail.new(sender:getTag())
			self:addUI(ui_)
		end
	end

	local function onJoinDefenseTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/war/rallyDefenseDetail"
			ui_ = UI_rallyDefenseDetail.new(self.defenseIDMap[sender:getTag()])
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
	self.onJoinDefenseTouched = onJoinDefenseTouched
	self.onJoinAttackTouched = onJoinAttackTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_hallOfWar:removeItem(type_)
	local listView_ = nil
	if type_ == 1 then
		listView_ = self.listView1
	elseif type_ == 2 then
		listView_ = self.listView2
	elseif type_ == 3 then
		listView_ = self.listView3
	end

	listView_:removeChild(self.itemMap[self.chooseID])
end

function UI_hallOfWar:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.ATTACK then
			self:refreshPage1()
		elseif param_ == dirtyType.DEFENSE then
			self:refreshPage2()
		elseif param_ == dirtyType.VARIABLENUM then
			self:changeNumber()
		end
	end
end

function UI_hallOfWar:close()
	self.item:release()
	player.getAlliance():unPrepareData(dirtyType.ATTACK, "UI_hallOfWar")
	player.getAlliance():unPrepareData(dirtyType.DEFENSE, "UI_hallOfWar")
	player.getAlliance():unPrepareData(dirtyType.VARIABLENUM, "UI_hallOfWar")
	self.super.close(self)
end

function UI_hallOfWar:refreshPage1()
	self.listView:removeAllItems()
	local warInfo_ = player.getAlliance():getRallyWarInfo()
	if warInfo_ == nil then
		return
	end

	self.idMap = {}
	self.itemMap = {}
	self.index = 1
	self.uiLoadingBar = {}
	self.uiCountTime = {}
	for i, v in ipairs(warInfo_) do
		local item_ = self.item:clone()
		self.listView:pushBackCustomItem(item_)
		item_:setTag(v.id)
		item_:addTouchEventListener(self.onJoinAttackTouched)
		local content_ = item_:getChildByName("Panel_33")
		-- 攻击者
		content_:getChildByName("Label_34"):setString(string.format(hp.lang.getStrByID(1855), v.ownerInfo.union, v.ownerInfo.name))
		-- 被攻击者
		content_:getChildByName("Label_34_0"):setString(string.format(hp.lang.getStrByID(1856), v.targetInfo.union, v.targetInfo.name))
		-- 城池名称
		content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(1857), v.targetInfo.city))
		
		content_:getChildByName("Label_39"):setString(hp.lang.getStrByID(1858))
		
		content_:getChildByName("Label_39_0"):setString(hp.lang.getStrByID(1859))
		
		-- 参与兵力
		content_:getChildByName("Label_50"):setString(string.format("%d/%d", v.curSoldier, v.totalSoldier))
		-- 倒计时
		self.uiCountTime[i] = content_:getChildByName("Label_51")
		self.uiCountTime[i]:setString(hp.datetime.strTime(v.lastTime - player.getServerTime()))

		self.uiLoadingBar[i] = item_:getChildByName("Panel_26"):getChildByName("Image_29"):getChildByName("ProgressBar_30")
	end
	self:updateInfo()
	self:changeNumber()
end

function UI_hallOfWar:refreshPage2()
	self.listView:removeAllItems()
	local warInfo_ = player.getAlliance():getRallyDefenseInfo()
	if warInfo_ == nil then
		return
	end

	self.idMap = {}
	self.itemMap = {}
	self.index = 1
	self.uiLoadingBar = {}
	self.uiCountTime = {}
	for i, v in ipairs(warInfo_) do
		local item_ = self.item:clone()
		self.listView:pushBackCustomItem(item_)
		item_:setTag(i)
		self.defenseIDMap[i] = v.fellowID
		item_:addTouchEventListener(self.onJoinDefenseTouched)
		local content_ = item_:getChildByName("Panel_33")
		-- 攻击者
		content_:getChildByName("Label_34"):setString(string.format(hp.lang.getStrByID(1855), v.ownerInfo.union, v.ownerInfo.name))
		-- 被攻击者
		content_:getChildByName("Label_34_0"):setString(string.format(hp.lang.getStrByID(1856), v.targetInfo.union, v.targetInfo.name))
		-- 城池名称
		content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(1857), v.targetInfo.city))
		
		content_:getChildByName("Label_39"):setString(hp.lang.getStrByID(1858))
		
		content_:getChildByName("Label_39_0"):setString(hp.lang.getStrByID(1859))
		
		-- 参与兵力
		content_:getChildByName("Label_50"):setString(string.format("%d/%d", v.curSoldier, v.totalSoldier))
		-- 倒计时
		self.uiCountTime[i] = content_:getChildByName("Label_51")
		self.uiCountTime[i]:setString(hp.datetime.strTime(v.lastTime - player.getServerTime()))

		self.uiLoadingBar[i] = item_:getChildByName("Panel_26"):getChildByName("Image_29"):getChildByName("ProgressBar_30")
	end
	self:updateInfo()
	self:changeNumber()
end

function UI_hallOfWar:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:updateInfo()
end

function UI_hallOfWar:updateInfo()
	for i, v in ipairs(self.uiLoadingBar) do
		local warInfo_ = nil 
		if self.tab == 1 then
			warInfo_ = player.getAlliance():getRallyWarInfo()[i]
		else
			warInfo_ = player.getAlliance():getRallyDefenseInfo()[i]
		end
		local lastTime_ = warInfo_.lastTime - player.getServerTime()
		local percent = hp.common.round(100 - lastTime_ / warInfo_.totalTime * 100)
		self.uiLoadingBar[i]:setPercent(percent)
		local countTime_ = hp.datetime.strTime(lastTime_)
		self.uiCountTime[i]:setString(countTime_)
	end
end