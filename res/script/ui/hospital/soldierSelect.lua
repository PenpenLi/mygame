--
-- ui/hospital/soldierHeal.lua
-- 士兵训练
--===================================
require "ui/fullScreenFrame"
require "ui/frame/popFrame"
require "player"

UI_soldierHeal = class("UI_soldierHeal", UI)

local costOffSet = 0.4
local timeOffSet = 0
local costMap = {5, 4, 6, 3, 2}

--init
function UI_soldierHeal:init(type_, resource_)
	-- data
	-- ===============================
	self.resource = resource_
	-- get soldier infomation
	local soldierInfo = player.soldierManager.getArmyInfoByType(type_)

	-- max train number
	local maxTrainNum = self:CanTrainNumber(type_)
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
	local panelStone = panelCost:getChildByName("Panel_stone")
	local stone = panelStone:getChildByName("Label_cost")
	local panelWood = panelCost:getChildByName("Panel_wood")
	local wood = panelWood:getChildByName("Label_cost")
	local panelIron = panelCost:getChildByName("Panel_iron")
	local iron = panelIron:getChildByName("Label_cost")
	local panelFood = panelCost:getChildByName("Panel_food")
	local food = panelFood:getChildByName("Label_cost")
	local panelCoin = panelCost:getChildByName("Panel_coin")
	local coin = panelCoin:getChildByName("Label_cost")

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
	panelTrain:getChildByName("ImageView_gold"):setVisible(false)
	panelTrain:getChildByName("Label_word"):setVisible(false)
	local x_, y_ = btnTrain:getPosition()
	btnTrain:setAnchorPoint(0.5, 0.5)
	btnTrain:setPosition(panelTrain:getSize().width / 2, y_)
	local trainText = panelTrain:getChildByName("Label_word1")
	trainText:setPosition(panelTrain:getSize().width / 2, y_)

	-- update ui
	soldierImage:loadTexture(config.dirUI.soldier..soldierInfo.image)

	-- prop
	labelPorp:setString(hp.lang.getStrByID(1000))

	-- subdue
	local strName = ""
	for i,v in ipairs(soldierInfo.abnegate) do
		if i == 1 then
			strName = strName..player.soldierManager.getTypeName(v)
		else
			strName = strName..","..player.soldierManager.getTypeName(v)
		end
	end
	panelDesc:getChildByName("Label_subdue"):setString(string.format(hp.lang.getStrByID(1005), strName))

	-- subdued
	local strName = ""
	for i,v in ipairs(soldierInfo.abnegated) do
		if i == 1 then
			strName = strName..player.soldierManager.getTypeName(v)
		else
			strName = strName..","..player.soldierManager.getTypeName(v)
		end
	end
	panelDesc:getChildByName("Label_subdued"):setString(string.format(hp.lang.getStrByID(1006), strName))

	-- dailyCost
	panelDesc:getChildByName("Label_dailyCost"):setString(hp.lang.getStrByID(1007))

	-- type
	local typeName_ = player.soldierManager.getTypeName(type_)
	local level_ = player.getSoldierLevel(type_)
	local name_ = string.format(hp.lang.getStrByID(5355), level_)..typeName_
	panelDesc:getChildByName("Label_type"):setString(string.format(hp.lang.getStrByID(1008), name_))

	trainText:setString(hp.lang.getStrByID(1506))

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
		stone:setString(self.resource[1].."/"..trainCost[1])
		wood:setString(self.resource[2].."/"..trainCost[2])
		iron:setString(self.resource[3].."/"..trainCost[3])
		food:setString(self.resource[4].."/"..trainCost[4])
		coin:setString(self.resource[5].."/"..trainCost[5])

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

	local function onResItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/resourceItem"
			local ui  = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
			self:close()
		end
	end

	-- set callBack
	property:addTouchEventListener(OnPropBtnTouched)

	btnTrain:addTouchEventListener(OnTrainTouched)

	minus:addTouchEventListener(OnMinusTouched)

	plus:addTouchEventListener(OnPlusTouched)

	slider:addEventListenerSlider(OnSliderPercentChange)

	panelCoin:getChildByName("ImageView_image"):addTouchEventListener(onResItemTouched)
	panelStone:getChildByName("ImageView_image"):addTouchEventListener(onResItemTouched)
	panelFood:getChildByName("ImageView_image"):addTouchEventListener(onResItemTouched)
	panelWood:getChildByName("ImageView_image"):addTouchEventListener(onResItemTouched)
	panelIron:getChildByName("ImageView_image"):addTouchEventListener(onResItemTouched)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(widgetRoot)
	changeSliderPercent(100)
end


function UI_soldierHeal:CanTrainNumber(type_)
	local maxTrainNum = {}

	maxTrainNum[1] = player.soldierManager.getHurtArmy():getSoldierNumberByType(type_) - player.soldierManager.getHealingSoldierByType(type_)

	-- resource limit
	local soldierInfo = player.soldierManager.getArmyInfoByType(type_)
	for i = 1, table.getn(self.resource) do
		if soldierInfo.costs[costMap[i]] ~= 0 then
			maxTrainNum[table.getn(maxTrainNum) + 1] = math.floor(self.resource[i]/soldierInfo.costs[costMap[i]]/costOffSet)
		end
	end

	local min = hp.common.getMinNumber(maxTrainNum)
	return min
end