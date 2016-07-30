--
-- ui/union/unionFightMain.lua
-- 公会战
--===================================
require "ui/fullScreenFrame"

UI_unionFightMain = class("UI_unionFightMain", UI)

local interval = 0

--init
function UI_unionFightMain:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5134))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	
	player.getAlliance():prepareData(dirtyType.FIGHTBASEINFO, "UI_unionFightMain")
end

function UI_unionFightMain:updateInfo()
	local smallInfo_ = player.getAlliance():getMySmallFightBase()
	self:updateSmall(smallInfo_)
end

function UI_unionFightMain:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fightMain.json")
	local help_ = self.wigetRoot:getChildByName("Panel_29874"):getChildByName("Image_48")
	help_:getChildByName("Label_49"):setString(hp.lang.getStrByID(1030))
	help_:addTouchEventListener(self.onMoreInfoTouched)

	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	self.listView:getItem(0):addTouchEventListener(self.onSmallFightTouched)
	self.item1 = self.listView:getItem(0):getChildByName("Panel_29900")	
	self.item1:getChildByName("Label_15"):setString(hp.lang.getStrByID(5026))
	self.item1:getChildByName("Label_29901"):setString(hp.lang.getStrByID(5027))
	self.item1:getChildByName("Label_3"):setString(hp.lang.getStrByID(5028))
	self.item1:getChildByName("Label_4"):setString(hp.lang.getStrByID(5045))	

	self.listView:getItem(1):addTouchEventListener(self.onBigFightTouched)
	self.item2 = self.listView:getItem(1):getChildByName("Panel_29900")
	self.item2:getChildByName("Label_29963"):setString(hp.lang.getStrByID(5029))
	self.item2:getChildByName("Label_19"):setString(hp.lang.getStrByID(5030))
	self.item2:getChildByName("ImageView_1"):getChildByName("Label_2"):setString(hp.datetime.strTime(0))
end

function UI_unionFightMain:updateSmall(info_)
	if info_ == nil then
		self.item1:getChildByName("Label_7"):setString(hp.lang.getStrByID(5046))
		self.item1:getChildByName("Label_8"):setVisible(false)
	elseif info_.state == 1 then
		self.item1:getChildByName("Label_7"):setString(hp.lang.getStrByID(5047))
		self.item1:getChildByName("Label_8"):setString(string.format(hp.lang.getStrByID(5037), table.getn(info_.members), info_.info.num))
	elseif info_.state == 2 then
		self.item1:getChildByName("Label_7"):setString(hp.lang.getStrByID(5047))
		self.item1:getChildByName("Label_8"):setString(hp.datetime.strTime(info_.endTime - player.getServerTime()))
	end

	-- 数量
	local fightInfo_ = player.getAlliance():getUnionHomePageInfo()
	local totalJoinAble_ = fightInfo_.joinAble
	if fightInfo_.joinTimes == 0 then
		totalJoinAble_ = 0
	end

	if totalJoinAble_ == 0 then
		self.item1:getChildByName("Image_9"):setVisible(false)
	else
		self.item1:getChildByName("Image_9"):setVisible(true)
		self.item1:getChildByName("Image_9"):getChildByName("Label_10"):setString(totalJoinAble_)
	end
end

function UI_unionFightMain:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			cclog_("djsdkjfiw")
			
			
			
		end
	end

	-- 查看玩家信息
	local function onSmallFightTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/fight/unionSmallFight"
			local ui_ = UI_unionSmallFight.new(2)
			self:addUI(ui_)
		end
	end

	local function onBigFightTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if player.getAlliance():getBigFight() == nil then
				if player.getAlliance():getMyUnionInfo():getRank() >= 4 then
					require "ui/union/fight/unionBigFight"
					local ui_ = UI_unionBigFight.new()
					self:addUI(ui_)
				else
					require "ui/union/fight/unionBigFightNoFight"
					local ui_ = UI_unionBigFightNoFight.new()
					self:addUI(ui_)
				end
			else
				require "ui/union/fight/unionBigFightDetail"
				local ui_ = UI_unionBigFightDetail.new(player.getID())
				self:addUI(ui_)
			end
		end
	end

	self.onBigFightTouched = onBigFightTouched
	self.onSmallFightTouched = onSmallFightTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionFightMain:onRemove()
	player.getAlliance():unPrepareData(dirtyType.FIGHTBASEINFO, "UI_unionFightMain")
	self.super.onRemove(self)
end

function UI_unionFightMain:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if dirtyType.FIGHTBASEINFO == param_ then
			self:updateInfo()
		end
	end
end

function UI_unionFightMain:tickSmallUpdateInfo()
	local smallInfo_ = player.getAlliance():getMySmallFightBase()
	if smallInfo_ == nil then
		return
	end

	if smallInfo_.state ~= 2 then
		return
	end

	local restTime_ = smallInfo_.endTime - player.getServerTime()
	if restTime_ <= 0 then
		restTime_ = 0
	end
	self.item1:getChildByName("Label_8"):setString(hp.datetime.strTime(restTime_))
end

function UI_unionFightMain:tickBigUpdateInfo()
	local bigInfo_ = player.getAlliance():getBigFight()
	if bigInfo_ == nil then
		return
	end

	local restTime_ = bigInfo_.endTime - player.getServerTime()
	if restTime_ <= 0 then
		restTime_ = 0
	end
	self.item2:getChildByName("ImageView_1"):getChildByName("Label_2"):setString(hp.datetime.strTime(restTime_))
end

function UI_unionFightMain:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:tickSmallUpdateInfo()
	self:tickBigUpdateInfo()
end