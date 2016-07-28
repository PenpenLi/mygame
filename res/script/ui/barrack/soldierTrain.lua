--
-- ui/barrack/soldierTrain.lua
-- 士兵训练
--===================================
require "ui/fullScreenFrame"
require "ui/frame/popFrame"
require "player"

UI_soldierTrain = class("UI_soldierTrain", UI)

--init
function UI_soldierTrain:init(type_)
	-- data
	-- ===============================
	local helper = require "playerData/helper"
	local addition_ = helper.getSoldierTrainAdd()

	-- get soldier infomation
	local soldierInfo = player.getArmyInfoByType(type_)

	-- max train number
	local maxNormalTrainNum, maxTrainNum = self:CanTrainNumber(type_)
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
	panelDesc:getChildByName("Label_type"):setString(string.format(hp.lang.getStrByID(1008), player.getTypeName(type_)))

	btnFastTrain:getChildByName("Label_word"):setString(hp.lang.getStrByID(1009))
	btnTrain:getChildByName("Label_word"):setString(hp.lang.getStrByID(1010))

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

	local function OnFastTrainTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function onFastTrainResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					player.soldierTrainFinish({type=type_, number=trainNum})
				end

				self:close()
			end

			local function onConfirm()
				-- start train
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 5
				oper.type = 9
				oper.branch = type_
				oper.num = trainNum
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onFastTrainResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			end

			-- if cdBox.getCD(cdBox.CDTYPE.BRANCH) > 0 then
			-- 	local function callBackConfirm()
			-- 		require("ui/item/speedItem")
			-- 		local ui  = UI_speedItem.new(cdBox.CDTYPE.BRANCH)
			-- 		self:addUI(ui)
			-- 		self:close()
			-- 	end
			-- 	require "ui/common/successBox"
   --  			local box_ = UI_successBox.new(hp.lang.getStrByID(5111), hp.lang.getStrByID(5112), callBackConfirm)
   --    			self:addModalUI(box_)
			-- else
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(1009), 
	   				hp.lang.getStrByID(1046), 
	   				hp.lang.getStrByID(1209), 
	   				hp.lang.getStrByID(2412), 
	      			onConfirm
	   				)
	   			self:addModalUI(msgBox)
			-- end			
		end
	end

	local function OnTrainResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			-- resource change
			player.expendResource("rock", trainCost[1])
			player.expendResource("wook", trainCost[2])
			player.expendResource("mine", trainCost[3])
			player.expendResource("food", trainCost[4])
			player.expendResource("silver", trainCost[5])

			local info_ = {data.cd, data.cd, type_, trainNum}
			cdBox.initCDInfo(cdBox.CDTYPE.BRANCH, info_)
			hp.msgCenter.sendMsg(hp.MSG.BARRACK_TRAIN, info_)
		end

		self:close()
	end

	local function trainCostChange()
		uiTrainNum:setString(trainNum)

		-- update resource cost
		trainCost[1] = trainNum * soldierInfo.costs[5]
		trainCost[2] = trainNum * soldierInfo.costs[4]
		trainCost[3] = trainNum * soldierInfo.costs[6]
		trainCost[4] = trainNum * soldierInfo.costs[3]
		trainCost[5] = trainNum * soldierInfo.costs[2]
		stone:setString(hp.common.changeNumUnit(resource[1]).."/"..hp.common.changeNumUnit(trainCost[1]))
		wood:setString(hp.common.changeNumUnit(resource[2]).."/"..hp.common.changeNumUnit(trainCost[2]))
		iron:setString(hp.common.changeNumUnit(resource[3]).."/"..hp.common.changeNumUnit(trainCost[3]))
		food:setString(hp.common.changeNumUnit(resource[4]).."/"..hp.common.changeNumUnit(trainCost[4]))
		coin:setString(hp.common.changeNumUnit(resource[5]).."/"..hp.common.changeNumUnit(trainCost[5]))

		-- update time cost
		timer:setString(hp.datetime.strTime(soldierInfo.cd * trainNum / (1 + addition_)))

		-- update daily cost
		panelDesc:getChildByName("Panel_cost"):getChildByName("Label_cost"):setString(trainNum * soldierInfo.charge)		

		if (trainNum == 0) or (trainNum > maxNormalTrainNum) then
			btnTrain:setTouchEnabled(false)
			btnTrain:loadTexture(config.dirUI.common.."button_gray.png")
			btnFastTrain:setTouchEnabled(false)
			btnFastTrain:loadTexture(config.dirUI.common.."button_gray.png")
		else
			btnTrain:setTouchEnabled(true)
			btnTrain:loadTexture(config.dirUI.common.."button_blue.png")
			btnFastTrain:setTouchEnabled(true)
			btnFastTrain:loadTexture(config.dirUI.common.."button_blue.png")
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
		if trainNum == 0 then
			slider:setPercent(percent)
		end
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
			-- 有士兵在训练
			if cdBox.getCD(cdBox.CDTYPE.BRANCH) > 0 then
				local function callBackConfirm()
					require("ui/item/speedItem")
					local ui  = UI_speedItem.new(cdBox.CDTYPE.BRANCH)
					self:addUI(ui)
					self:close()
				end
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5111), hp.lang.getStrByID(5112), callBackConfirm)
      			self:addModalUI(box_)
			else
				-- start train
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 5
				oper.type = 1
				oper.branch = type_
				oper.num = trainNum
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(OnTrainResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			end
		end
	end

	-- set callBack
	property:addTouchEventListener(OnPropBtnTouched)

	btnFastTrain:addTouchEventListener(OnFastTrainTouched)

	btnTrain:addTouchEventListener(OnTrainTouched)

	minus:addTouchEventListener(OnMinusTouched)

	plus:addTouchEventListener(OnPlusTouched)

	slider:addEventListenerSlider(OnSliderPercentChange)

	self:registMsg(hp.MSG.CLOSE_WINDOW)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(widgetRoot)
	changeSliderPercent(100)
end


function UI_soldierTrain:CanTrainNumber(type_)
	local barracklist = player.buildingMgr.getBuildingsBySid(1009)
	local barrackTrain = 0
	local maxTrainNum = {}

	for i, v in ipairs(barracklist) do
		barrackTrain = barrackTrain + game.data.barrack[v.lv].soldierMax
	end
	maxTrainNum[1] = barrackTrain

	maxTrainNum[2] = game.data.main[player.buildingMgr.getBuildingMaxLvBySid(1001)].soldierMax - player.getTotalArmy():getSoldierTotalNumber()
	if maxTrainNum[2] < 0 then
		maxTrainNum[2] = 0
	end
	local min1 = hp.common.getMinNumber(maxTrainNum)

	-- resource limit
	local resource = {player.getResource("rock"),player.getResource("wood"),player.getResource("mine"),player.getResource("food"),player.getResource("silver")}
	local soldierInfo = player.getArmyInfoByType(type_)
	local trainCost = {soldierInfo.costs[5], soldierInfo.costs[4], soldierInfo.costs[6], soldierInfo.costs[3], soldierInfo.costs[2]}
	for i = 1, table.getn(resource) do
		if trainCost[i] ~= 0 then
			maxTrainNum[table.getn(maxTrainNum) + 1] = math.floor(resource[i]/trainCost[i])
		end
	end

	local min = hp.common.getMinNumber(maxTrainNum)
	return min, min
end

function UI_soldierTrain:onMsg(msg_, param_)
	if msg_ == hp.MSG.CLOSE_WINDOW then
		if param_ == 1 then
			self:close()
		end
	end
end