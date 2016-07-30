--
-- ui/barrack/barrack.lua
-- 兵营信息
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_barracks = class("UI_barracks", UI)

local topContainer = nil
local trainText = nil
local cdTime = nil
local trainProgress = nil
local listView = nil
local interval = 0
local labelNum = {}
local totalSoldierNum = nil
local topContainer2 = nil

--init
function UI_barracks:init(building_)
	-- data
	-- ===============================
	self.showState = false
	topContainer = nil
	trainText = nil
	cdTime = nil
	trainProgress = nil
	listView = nil
	interval = 0
	labelNum = {}
	totalSoldierNum = nil

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	local bInfo = building_.bInfo
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "barracks.json")
	topContainer = widgetRoot:getChildByName("Panel_1345")
	topContainer2 = widgetRoot:getChildByName("Panel_30")
	local speedup = topContainer:getChildByName("ImageView_1639")
	self.speedup = speedup
	trainProgress = topContainer2:getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640")
	trainText = topContainer:getChildByName("Label_1642")
	cdTime = topContainer:getChildByName("Label_1643")
	listView = widgetRoot:getChildByName("ListView_list")
	local container = listView:getChildByName("Panel_horContainer")
	totalSoldierNum = listView:getChildByName("Panel_adampt1"):getChildByName("Panel_adampt2"):getChildByName("ImageView_troops"):getChildByName("Label_troops")
	local adampt = container:getChildByName("Panel_adampt")
	local hint = listView:getChildByName("Panel_1953"):getChildByName("Panel_2263"):getChildByName("Label_2264")
	local moreInfoContainer = listView:getChildByName("Panel_5189")
	local moreInfoBtn = moreInfoContainer:getChildByName("Panel_5190"):getChildByName("ImageView_5191")
	local moreInfoText = moreInfoBtn:getChildByName("Label_5192")

	-- soldier click callback
	local function memuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/barrack/soldierTrain"
			local ui_ = UI_soldierTrain.new(sender:getTag())
			self:addModalUI(ui_)

			player.guide.stepEx({5005})
		end
	end

	-- more info click callback
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/barrack/barrackInfo"
			local ui_ = UI_barrackInfo.new(building_)
			self:addModalUI(ui_)
		end
	end

	local function onSpeedQueue(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/speedItem")
			local ui  = UI_speedItem.new(cdBox.CDTYPE.BRANCH)
			self:addUI(ui)
			
			player.guide.stepEx({6003})
		end
	end

	speedup:addTouchEventListener(onSpeedQueue)

	moreInfoBtn:addTouchEventListener(onMoreInfoTouched)

	hint:setString(hp.lang.getStrByID(1012))

	-- clone container and load image,data

	local index = 1
	local soldierType = globalData.TOTAL_LEVEL
	listView:removeLastItem()

	local gongjian_item = nil

	for i = 1, globalData.TOTAL_LEVEL do
		local soldierInfo_ = player.soldierManager.getArmyInfoByType(i)

		local soldier = adampt:getChildByName(string.format("%d", index))

		-- set image
		local soldierImage = soldier:getChildByName("ImageView_soldier")
		soldierImage:loadTexture(string.format("%s%s", config.dirUI.soldier, soldierInfo_.image))

		-- set clickEvent
		soldierImage:addTouchEventListener(memuItemOnTouched)
		if i==2 then
			gongjian_item = soldierImage
		end

		-- set tag
		soldierImage:setTag(soldierInfo_.type)

		-- set name
		soldier:getChildByName("Label_name"):setString(soldierInfo_.name)

		-- get number label
		labelNum[soldierInfo_.type] = soldier:getChildByName("ImageView_numberbg"):getChildByName("Label_number")

		if index == 3 then
			container = container:clone()
			listView:pushBackCustomItem(container)	
			adampt = container:getChildByName("Panel_adampt")		
			index = 1
		else
			index = index + 1
		end
	end

	-- hide redundant ui
	for i = index, 3 do
		adampt:getChildByName(string.format("%d", i)):setVisible(false)
	end

	if index == 1 then
		listView:removeLastItem()
	end

	listView:pushBackCustomItem(moreInfoContainer)

	-- 界面初始化显示内容
	moreInfoText:setString(hp.lang.getStrByID(1030))

	-- register msg
	self:registMsg(hp.MSG.BARRACK_TRAIN)
	self:registMsg(hp.MSG.BARRACK_TRAIN_FIN)
	self:registMsg(hp.MSG.SOLDIER_NUM_CHANGE)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(widgetRoot)

	self:updateSoldierNum()
	self:updateTrainShow()


	-- 进行新手引导绑定
	-- =========================================
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI( step )
		if step==5005 then
			player.guide.bind2Node(step, gongjian_item, memuItemOnTouched)
		elseif step==6003 then
			player.guide.bind2Node(step, speedup, onSpeedQueue)
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_barracks:updateSoldierNum()
	local num_ = 0
	if player.soldierManager.getCityArmy() ~= nil then
		for i = 1, globalData.TOTAL_LEVEL do			
			local temp = player.soldierManager.getCityArmy():getSoldierNumberByType(i)
			num_ = num_ + temp
			labelNum[i]:setString(tostring(temp))
		end	
	end
	totalSoldierNum:setString(string.format(hp.lang.getStrByID(1011), tostring(num_)))
end

function UI_barracks:setShowState(show_)
	if show_ == self.showState then
		return
	end
	self.showState = show_

	if show_ == true then
		self.speedup:setTouchEnabled(true)
		topContainer:setVisible(show_)
		topContainer2:setVisible(show_)
		local size_ = listView:getSize()
		size_.height = size_.height - topContainer:getSize().height
		listView:setSize(size_)
	else	
		self.speedup:setTouchEnabled(false)	
		local size_ = listView:getSize()
		size_.height = size_.height + topContainer:getSize().height
		listView:setSize(size_)
		topContainer:setVisible(show_)
		topContainer2:setVisible(show_)
	end
end

function UI_barracks:updateTrainShow()
	local cdInfo = cdBox.getCDInfo(cdBox.CDTYPE.BRANCH)
	if cdInfo.cd > 0 then
		self:setShowState(true)
		local soldierInfo = player.soldierManager.getArmyInfoByType(cdInfo.type)
		local trainNum_ = soldierInfo.name.."x"..cdInfo.number
		trainText:setString(trainNum_)
		self:updateCDTime()
	else
		self:setShowState(false)
	end
end

-- only update cdtime and progress
function UI_barracks:updateCDTime()
	local cdInfo = cdBox.getCDInfo(cdBox.CDTYPE.BRANCH)
	local cdTimeNum = hp.datetime.strTime(cdInfo.cd)

	if cdTime ~= nil then
		cdTime:setString(cdTimeNum)
	end

	if trainProgress ~= nil then
		local total = cdInfo.total_cd
		local cd = cdInfo.cd
		if total ~= 0 then
			local percent = 100 - cd / total * 100
			trainProgress:setPercent(percent)
		end
	end
end

function UI_barracks:heartbeat(dt)
	interval = interval + dt
	if interval < 1 then
		-- return
	end

	interval = 0

	if cdBox.getCD(cdBox.CDTYPE.BRANCH) > 0 then
		self:setShowState(true)
		self:updateCDTime()
	else
		self:setShowState(false)
	end
end

function UI_barracks:onMsg(msg_, parm_)
	if msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(parm_)
	elseif msg_ == hp.MSG.BARRACK_TRAIN then
		self:updateTrainShow()
	elseif msg_ == hp.MSG.BARRACK_TRAIN_FIN then
		self:updateSoldierNum()
	elseif msg_ == hp.MSG.SOLDIER_NUM_CHANGE then
		if parm_[1] == 1 then
			self:updateSoldierNum()
		end
	end
end