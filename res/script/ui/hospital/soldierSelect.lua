--
-- ui/hospital/soldierHeal.lua
-- 士兵训练
--===================================
require "ui/fullScreenFrame"
require "ui/frame/popFrame"
require "player"

UI_soldierHeal = class("UI_soldierHeal", UI)

local costOffSet = 0.4
local timeOffSet = 1800
local costMap = {5, 4, 6, 3, 2}

--init
function UI_soldierHeal:init(type_, resource_)
	-- data
	-- ===============================
	self.resource = resource_
	-- get soldier infomation
	local soldierInfo = player.getArmyInfoByType(type_)

	-- max train number
	local maxTrainNum = self:CanTrainNumber(type_)
	local resource = {player.getResource("rock"),player.getResource("wood"),player.getResource("mine"),player.getResource("food"),player.getResource("silver")}
	local trainNum = maxTrainNum
	local trainCost = {0,0,0,0,0}

	-- ui
	-- ===============================

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "soldierTrain.json")

	local popFrame = UI_popFrame.new(widgetRoot, soldierInfo.name)

	local soldierImage = widgetRoot:getChildByName("Panel_container1"):getChildByName("ImageView_soldier")
	local property = widgetRoot:getChildByName("Panel_container1"):getChildByName("ImageView_property")
	local labelPorp = property:getChildByName("Label_prop")

	local panelDesc = widgetRoot:getChildByName("Panel_desc")

	local panelCost = widgetRoot:getChildByName("Panel_produceCost")
	local stone = panelCost:getChildByName("Panel_stone"):getChildByName("Label_cost")
	local wood = panelCost:getChildByName("Panel_wood"):getChildByName("Label_cost")
	local iron = panelCost:getChildByName("Panel_iron"):getChildByName("Label_cost")
	local food = panelCost:getChildByName("Panel_food"):getChildByName("Label_cost")
	local coin = panelCost:getChildByName("Panel_coin"):getChildByName("Label_cost")

	local panelTrain = widgetRoot:getChildByName("Panel_train")
	local changeNum = panelTrain:getChildByName("Panel_4920")
	local plus = changeNum:getChildByName("ImageView_plus")
	local minus = changeNum:getChildByName("ImageView_minus")
	local slider = changeNum:getChildByName("ImageView_sliderBg"):getChildByName("Slider_produce")
	local timer = panelTrain:getChildByName("ImageView_timeCost"):getChildByName("Label_value")
	local uiTrainNum = panelTrain:getChildByName("ImageView_soldierNum"):getChildByName("Label_value")
	local btnFastTrain = panelTrain:getChildByName("ImageView_fastTrain")
	local btnTrain = panelTrain:getChildByName("ImageView_Train")
	btnFastTrain:setVisible(false)
	local sz_ = btnTrain:getSize()
	btnTrain:getChildByName("Label_word"):setPosition(sz_.width / 2, sz_.height / 2)
	btnTrain:setAnchorPoint(0.5, 0.5)
	local x_, y_ = btnTrain:getPosition()
	btnTrain:setPosition(panelTrain:getSize().width / 2, y_)

	-- update ui
	soldierImage:loadTexture(config.dirUI.soldier..soldierInfo.image)

	-- prop
	labelPorp:setString(hp.lang.getStrByID(1000))

	-- subdue
	local strName = ""
	for i,v in ipairs(soldierInfo.abnegate) do
		if i == 1 then
			strName = strName..player.getTypeName(v)
		else
			strName = strName..","..player.getTypeName(v)
		end
	end
	panelDesc:getChildByName("Label_subdue"):setString(string.format(hp.lang.getStrByID(1005), strName))

	-- subdued
	local strName = ""
	for i,v in ipairs(soldierInfo.abnegated) do
		if i == 1 then
			strName = strName..player.getTypeName(v)
		else
			strName = strName..","..player.getTypeName(v)
		end
	end
	panelDesc:getChildByName("Label_subdued"):setString(string.format(hp.lang.getStrByID(1006), strName))

	-- dailyCost
	panelDesc:getChildByName("Label_dailyCost"):setString(hp.lang.getStrByID(1007))

	-- type
	panelDesc:getChildByName("Label_type"):setString(string.format(hp.lang.getStrByID(1008), soldierInfo.name))

	btnTrain:getChildByName("Label_word"):setString(hp.lang.getStrByID(1506))

	-- callBack function
	-- many callback is logic code, should not be placed in UI-dealing class
	local function OnPropBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/barrack/soldierInfo"
			local ui = UI_soldierInfo.new(type_)
			self:addModalUI(ui)
		end
	end

	local function trainCostChange()
		uiTrainNum:setString(trainNum)

		-- update resource cost
		trainCost[1] = math.floor(trainNum * soldierInfo.costs[5] * costOffSet)
		trainCost[2] = math.floor(trainNum * soldierInfo.costs[4] * costOffSet)
		trainCost[3] = math.floor(trainNum * soldierInfo.costs[6] * costOffSet)
		trainCost[4] = math.floor(trainNum * soldierInfo.costs[3] * costOffSet)
		trainCost[5] = math.floor(trainNum * soldierInfo.costs[2] * costOffSet)
		stone:setString(resource[1].."/"..trainCost[1])
		wood:setString(resource[2].."/"..trainCost[2])
		iron:setString(resource[3].."/"..trainCost[3])
		food:setString(resource[4].."/"..trainCost[4])
		coin:setString(resource[5].."/"..trainCost[5])

		-- update time cost
		local time_ = 0
		if soldierInfo.level > 1 then
			time_ = soldierInfo.cd * trainNum * 0.1 - timeOffSet
		end
		if time_ < 0 then
			time_ = 0
		end
		timer:setString(hp.datetime.strTime(time_))

		-- update daily cost
		panelDesc:getChildByName("Panel_cost"):getChildByName("Label_cost"):setString(trainNum * soldierInfo.charge)		

		if trainNum == 0 then
			btnTrain:setTouchEnabled(false)
			btnTrain:loadTexture(config.dirUI.common.."button_gray.png")
		else
			btnTrain:setTouchEnabled(true)
			btnTrain:loadTexture(config.dirUI.common.."button_blue.png")
		end
	end

	local percent = -1
	local function OnSliderPercentChange(sender, eventType)
		local per = sender:getPercent()
		if percent == per then
			return
		end
		percent = per
		-- update train number
		trainNum = hp.common.round(maxTrainNum * per / 100)
		trainCostChange()
	end

	local function changeSliderPercent(per)
		slider:setPercent(per)
		OnSliderPercentChange(slider, 0)
	end

	local function OnMinusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if trainNum > 0 then
				trainNum = trainNum - 1
				local percent = hp.common.round(trainNum / maxTrainNum * 100)
				slider:setPercent(percent)
				trainCostChange()
			end
		end
	end

	local function OnPlusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if trainNum < maxTrainNum then
				trainNum = trainNum + 1
				local percent = hp.common.round(trainNum / maxTrainNum * 100)
				slider:setPercent(percent)
				trainCostChange()
			end
		end
	end

	local function OnTrainTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then			
			hp.msgCenter.sendMsg(hp.MSG.HOSPITAL_CHOOSE_SOLDIER, {type_, trainNum})
			self:close()
		end
	end

	-- set callBack
	property:addTouchEventListener(OnPropBtnTouched)

	btnTrain:addTouchEventListener(OnTrainTouched)

	minus:addTouchEventListener(OnMinusTouched)

	plus:addTouchEventListener(OnPlusTouched)

	slider:addEventListenerSlider(OnSliderPercentChange)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(widgetRoot)
	changeSliderPercent(100)
end


function UI_soldierHeal:CanTrainNumber(type_)
	local maxTrainNum = {}

	maxTrainNum[1] = player.getHurtArmy():getSoldierNumberByType(type_) - player.getHealingSoldierByType(type_)

	-- resource limit
	local soldierInfo = player.getArmyInfoByType(type_)
	for i = 1, table.getn(self.resource) do
		if soldierInfo.costs[costMap[i]] ~= 0 then
			maxTrainNum[table.getn(maxTrainNum) + 1] = math.floor(self.resource[i]/soldierInfo.costs[costMap[i]]/costOffSet)
		end
	end

	local min = hp.common.getMinNumber(maxTrainNum)
	return min
end