--
-- ui/barrack/soldierTrain.lua
-- 伤兵调整
--===================================
require "ui/fullScreenFrame"
require "ui/frame/popFrame"
require "player"

UI_hospitalSolider = class("UI_hospitalSolider", UI)

local treatNum = 0
local maxTreatNum = 0
local treatCost = {0,0,0,0,0}
local resource = {player.getResource("rock"),player.getResource("wood"),player.getResource("mine"),player.getResource("food"),player.getResource("silver")}

--init
function UI_hospitalSolider:init(type_, number, maxNumber)

	

	-- data
	-- ===============================
	-- get soldier infomation
	local soldierInfo = player.getArmyInfoByType(type_)
	treatNum = number
	maxTreatNum = maxNumber
	

	-- ui
	-- ===============================

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hospitalSoldier.json")
	local popFrame = UI_popFrame.new(widgetRoot, soldierInfo.name)

	local soldierImage = widgetRoot:getChildByName("Panel_container1"):getChildByName("ImageView_soldierBg"):getChildByName("ImageView_soldier")
	local property = widgetRoot:getChildByName("Panel_container1"):getChildByName("ImageView_property")
	local labelPorp = property:getChildByName("Label_prop")

	local panelDesc = widgetRoot:getChildByName("Panel_desc")

	local panelCost = widgetRoot:getChildByName("Panel_produceCost")
	local stone = panelCost:getChildByName("Panel_stone"):getChildByName("Label_cost")
	local wood = panelCost:getChildByName("Panel_wood"):getChildByName("Label_cost")
	local iron = panelCost:getChildByName("Panel_iron"):getChildByName("Label_cost")
	local food = panelCost:getChildByName("Panel_food"):getChildByName("Label_cost")
	local coin = panelCost:getChildByName("Panel_coin"):getChildByName("Label_cost")

	local panelTrain = widgetRoot:getChildByName("Panel_treat")
	local changeNum = panelTrain:getChildByName("Panel_6606")
	local plus = changeNum:getChildByName("ImageView_plus")
	local minus = changeNum:getChildByName("ImageView_minus")
	local slider = changeNum:getChildByName("ImageView_sliderBg"):getChildByName("Slider_produce")
	local timer = changeNum:getChildByName("ImageView_time"):getChildByName("Label_value")
	local soldierNum = panelTrain:getChildByName("ImageView_soldierNum"):getChildByName("Label_value")
	local btnTreat = panelTrain:getChildByName("ImageView_Train")

	-- update ui
	soldierImage:loadTexture(config.dirUI.soldier.."/"..soldierInfo.image)
	
	
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
		soldierNum:setString(treatNum)

		-- update resource cost
		treatCost[1] = treatNum * soldierInfo.costs[5]
		treatCost[2] = treatNum * soldierInfo.costs[4]
		treatCost[3] = treatNum * soldierInfo.costs[6]
		treatCost[4] = treatNum * soldierInfo.costs[3]
		treatCost[5] = treatNum * soldierInfo.costs[2]
		stone:setString(resource[1].."/"..treatCost[1])
		wood:setString(resource[2].."/"..treatCost[2])
		iron:setString(resource[3].."/"..treatCost[3])
		food:setString(resource[4].."/"..treatCost[4])
		coin:setString(resource[5].."/"..treatCost[5])

		-- update time cost
		timer:setString(hp.datetime.strTime(soldierInfo.cd * treatNum))

		-- update daily cost
		panelDesc:getChildByName("Label_cost"):setString(treatNum * soldierInfo.charge)	

		local percent = hp.common.round(treatNum / maxTreatNum * 100)
	slider:setPercent(percent)	
	end

	local function OnSliderPercentChange(sender, eventType)
		local per = sender:getPercent()
		if percent == per then
			return
		end
		percent = per
		-- update train number
		treatNum = hp.common.round(maxTreatNum * per / 100)
		trainCostChange()
	end


	local function OnMinusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if treatNum > 0 then
				treatNum = treatNum - 1
				local percent = hp.common.round(treatNum / maxTreatNum * 100)
				slider:setPercent(percent)
				trainCostChange()
			end
		end
	end

	local function OnPlusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if treatNum < maxTreatNum then
				treatNum = treatNum + 1
				local percent = hp.common.round(treatNum / maxTreatNum * 100)
				slider:setPercent(percent)
				trainCostChange()
			end
		end
	end

	local function OnTreatTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		soldier_allNumber_changed[type_] = treatNum
		hp.msgCenter.sendMsg(hp.MSG.CHANGE_HURT_SOLDIER, type_)
		self:close()
	end



	property:addTouchEventListener(OnPropBtnTouched)

	btnTreat:addTouchEventListener(OnTreatTouched)

	minus:addTouchEventListener(OnMinusTouched)

	plus:addTouchEventListener(OnPlusTouched)

	slider:addEventListenerSlider(OnSliderPercentChange)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(widgetRoot)
	--changeSliderPercent(100)
	trainCostChange()








end


