--
-- ui/wall/wall.lua
-- 城墙信息
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_wall = class("UI_wall", UI)

local topContainer = nil
local defenseContainer = nil
local trainText = nil
local cdTime = nil
local trainProgress = nil
local listView = nil
local showState = false
local interval = 0
local labelNum = {}
local trapTypeLabel = nil
local buildingInfo = nil
local defenseLoadingBar = nil
local defenseValue = nil
local speedup = nil
local topBack = nil

local function updateTrapNum()
	local num_ = 0
	local traps = player.trapManager.getTraps()
	if traps ~= nil then
		for k,v in pairs(traps) do
			labelNum[tostring(v:getTrapSid())]:setString(v:getNumber())
		end	
	end
end

local function setShowState(show_)
	if show_ == showState then
		return
	end
	showState = show_

	topContainer:setVisible(show_)
	topBack:setVisible(show_)
	if show_ == true then
		speedup:setTouchEnabled(true)
		local size1_ =  listView:getSize()
		size1_.height = size1_.height - topContainer:getSize().height
		listView:setSize(size1_)
		local x, y = defenseContainer:getPosition()
		y = y - topContainer:getSize().height
		defenseContainer:setPosition(x, y)
		defenseBack:setPosition(x, y)
	else
		speedup:setTouchEnabled(false)
		local size1_ =  listView:getSize()
		size1_.height = size1_.height + topContainer:getSize().height
		listView:setSize(size1_)
		local x, y = defenseContainer:getPosition()
		y = y + topContainer:getSize().height
		defenseContainer:setPosition(x, y)
		defenseBack:setPosition(x, y)
	end
end

-- only update cdtime and progress
local function updateCDTime()
	local cdInfo = cdBox.getCDInfo(cdBox.CDTYPE.TRAP)
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

local function updateTrainShow()
	local cdInfo = cdBox.getCDInfo(cdBox.CDTYPE.TRAP)
	if cdInfo.cd > 0 then
		setShowState(true)
		local trapInfo = hp.gameDataLoader.getInfoBySid("trap", cdInfo.sid)
		local trainNum_ = trapInfo.name.."x"..cdInfo.number
		trainText:setString(trainNum_)
		updateCDTime()
	else
		setShowState(false)
	end
end

local function updateWallDefense()
	local defense = player.trapManager.getWallDefense()
	local maxDefense = hp.gameDataLoader.getBuildingInfoByLevel("wall", buildingInfo.build.lv, "deadfallMax")
	local percent = (defense / maxDefense) * 100
	defenseValue:setString(string.format("%d/%d", defense, maxDefense))
	defenseLoadingBar:setPercent(percent)
end

--init
function UI_wall:init(building_)
	-- data
	-- ===============================
	topContainer = nil
	defenseContainer = nil
	defenseBack = nil
	trainText = nil
	cdTime = nil
	trainProgress = nil
	listView = nil
	showState = false
	labelNum = {}
	trapTypeLabel = nil
	buildingInfo = nil
	defenseLoadingBar = nil
	defenseValue = nil
	speedup = nil

	-- ui
	-- ===============================
	buildingInfo = building_
	local uiFrame = UI_fullScreenFrame.new()
	local bInfo = building_.bInfo
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "wall.json")
	topContainer = widgetRoot:getChildByName("Panel_1345")
	speedup = topContainer:getChildByName("ImageView_1645")
	topBack = widgetRoot:getChildByName("Panel_40")
	trainProgress = topBack:getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640")
	trainText = topContainer:getChildByName("Label_1642")
	cdTime = topContainer:getChildByName("Label_1643")
	defenseContainer = widgetRoot:getChildByName("Panel_2601")
	local defenseLabel = defenseContainer:getChildByName("ImageView_1212"):getChildByName("Label_troops")
	defenseBack = widgetRoot:getChildByName("Panel_38")
	defenseLoadingBar = defenseBack:getChildByName("ImageView_111"):getChildByName("LoadingBar_1640")
	defenseValue = defenseContainer:getChildByName("Label_1642")
	listView = widgetRoot:getChildByName("ListView_list")
	local container = listView:getChildByName("Panel_horContainer")
	trapTypeLabel = listView:getChildByName("Panel_adampt1"):getChildByName("Panel_adampt2"):getChildByName("ImageView_troops"):getChildByName("Label_troops")
	local adampt = container:getChildByName("Panel_adampt")
	local hint = listView:getChildByName("Panel_1953"):getChildByName("Panel_2263"):getChildByName("Label_2264")
	local moreInfoContainer = listView:getChildByName("Panel_5189")
	local moreInfoBtn = moreInfoContainer:getChildByName("Panel_5190"):getChildByName("ImageView_5191")
	local moreInfoText = moreInfoBtn:getChildByName("Label_5192")

	-- trap click callback
	local function memuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/wall/trapTrain"
			local ui_trapTrain = UI_trapTrain.new(sender:getTag())
			self:addModalUI(ui_trapTrain)
		end
	end

	-- more info click callback
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/wall/wallInfo"
			local ui_ = UI_wallInfo.new(building_)
			self:addModalUI(ui_)
		end
	end

	defenseLabel:setString(hp.lang.getStrByID(1101))
	hint:setString(hp.lang.getStrByID(1103))
	moreInfoBtn:addTouchEventListener(onMoreInfoTouched)


	-- clone container and load image,data

	local index = 1
	listView:removeLastItem()

	for i = 1, table.getn(game.data.trap) do
		local info = game.data.trap[i]
		local trap = adampt:getChildByName(string.format("%d", index))

		-- set image
		local trapImage = trap:getChildByName("ImageView_soldier")
		trapImage:loadTexture(string.format("%s%s", config.dirUI.trap, info.image))

		-- set clickEvent
		trapImage:addTouchEventListener(memuItemOnTouched)

		-- set tag
		trapImage:setTag(info.sid)

		-- set name
		trap:getChildByName("Label_name"):setString(info.name)

		-- get number label
		labelNum[tostring(info.sid)] = trap:getChildByName("ImageView_numberbg"):getChildByName("Label_number")

		-- lock
		self.lock = trap:getChildByName("ImageView_lock")

		if info.unlock == -1 then
			self.lock:setVisible(false)
		elseif player.researchMgr.isTechResearch(info.unlock) then
			self.lock:setVisible(false)
		else
			self.lock:setVisible(true)
		end

		if index == 3 then
			container = container:clone()
			listView:pushBackCustomItem(container)	
			adampt = container:getChildByName("Panel_adampt")		
			index = 1
		else
			index = index + 1
		end
	end

	trapTypeLabel:setString(hp.lang.getStrByID(1102))

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

	-- call back

	local function onSpeedQueue(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/speedItem")
			local ui  = UI_speedItem.new(cdBox.CDTYPE.TRAP)
			self:addUI(ui)
		end
	end

	speedup:addTouchEventListener(onSpeedQueue)

	-- register msg
	self:registMsg(hp.MSG.TRAP_TRAIN)
	self:registMsg(hp.MSG.TRAP_TRAIN_FIN)
	self:registMsg(hp.MSG.TRAP_MESSAGE)	

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(widgetRoot)

	updateTrapNum()
	updateTrainShow()
	updateWallDefense()
end


function UI_wall:heartbeat(dt)
	if cdBox.getCD(cdBox.CDTYPE.TRAP) > 0 then
		setShowState(true)
		updateCDTime()
	else
		setShowState(false)
	end
end

-- msg process
function UI_wall:onMsg(msg_, parm_)
	if msg_ == hp.MSG.TRAP_TRAIN then
		updateTrainShow()
	elseif msg_ == hp.MSG.TRAP_TRAIN_FIN then
		updateTrapNum()
		updateWallDefense()
	elseif msg_ == hp.MSG.TRAP_MESSAGE then
		updateTrapNum()
		updateWallDefense()
	end
end