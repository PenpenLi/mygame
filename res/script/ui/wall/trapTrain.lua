--
-- ui/wall/trapTrain.lua
-- 陷阱训练
--===================================
require "ui/fullScreenFrame"
require "ui/frame/popFrame"
require "player"

UI_trapTrain = class("UI_trapTrain", UI)

local armytype = 5

--init
function UI_trapTrain:init(sid_)
	-- data
	-- ===============================
	-- get trap infomation
	local trapInfo = hp.gameDataLoader.getInfoBySid("trap", sid_)
	local active_ = true
	if trapInfo.unlock ~= -1 then
		if not player.researchMgr.isTechResearch(trapInfo.unlock) then
			active_ = false
		end
	end

	-- max train number
	local maxNormalTrainNum, maxTrainNum, lackRes_ = self:CanTrainNumber(sid_)
	local resource = {player.getResource("rock"),player.getResource("wood"),player.getResource("mine"),player.getResource("food"),player.getResource("silver")}
	local trainNum = maxTrainNum
	local trainCost = {0,0,0,0,0}

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "soldierTrain.json")

	local popFrame = UI_popFrame.new(widgetRoot, trapInfo.name)

	local soldierImage = widgetRoot:getChildByName("Panel_container1"):getChildByName("ImageView_soldier")
	local property = widgetRoot:getChildByName("Panel_container1"):getChildByName("ImageView_property")
	local labelPorp = property:getChildByName("Label_prop")

	local panelDesc = widgetRoot:getChildByName("Panel_desc")

	local panelCost = widgetRoot:getChildByName("Panel_produceCost")
	local panelList_ = {"Panel_stone","Panel_wood","Panel_iron","Panel_food","Panel_coin"}
	local uiPanel_ = {}
	local uiResLabel_ = {}
	local uiResImg_ = {}
	for i, v in ipairs(panelList_) do
		local panel_ = panelCost:getChildByName(v)
		uiPanel_[i] = panel_
		uiResLabel_[i] = panel_:getChildByName("Label_cost")
		uiResImg_[i] = panel_:getChildByName("ImageView_image")
	end

	local panelTrain = widgetRoot:getChildByName("Panel_train")
	local changeNum = panelTrain:getChildByName("Panel_4920")
	local plus = changeNum:getChildByName("ImageView_plus")
	local minus = changeNum:getChildByName("ImageView_minus")
	local slider = changeNum:getChildByName("ImageView_sliderBg"):getChildByName("Slider_produce")
	local timer = panelTrain:getChildByName("ImageView_timeCost"):getChildByName("Label_value")
	local uiTrainNum = panelTrain:getChildByName("ImageView_soldierNum"):getChildByName("Label_value")
	local btnFastTrain = panelTrain:getChildByName("ImageView_fastTrain")
	local btnTrain = panelTrain:getChildByName("ImageView_Train")
	self.uiDiamond = panelTrain:getChildByName("ImageView_gold"):getChildByName("Label_goldCost")
	
	require "ui/common/effect.lua"
	local light = nil
	light = inLight(btnTrain:getVirtualRenderer(),1)
	btnTrain:addChild(light)
	
	
	local Panel_toAcademy = widgetRoot:getChildByName("Panel_toAcademy")

	local btnToAcademy = Panel_toAcademy:getChildByName("ImageView_14044")
	btnToAcademy:getChildByName("Label_14045"):setString(hp.lang.getStrByID(5151))

	-- update ui
	soldierImage:loadTexture(config.dirUI.trap..trapInfo.image)

	-- prop
	labelPorp:setString(hp.lang.getStrByID(1000))

	-- set trap info

	-- subdue
	local strName = ""
	for i,v in ipairs(trapInfo.abnegate) do
		if i == 1 then
			strName = strName..player.soldierManager.getTypeName(v)
		else
			strName = strName..","..player.soldierManager.getTypeName(v)
		end
	end
	if strName == "" then
		strName = hp.lang.getStrByID(5147)
	end
	panelDesc:getChildByName("Label_subdue"):setString(string.format(hp.lang.getStrByID(1005), strName))

	-- subdued
	local strName = player.soldierManager.getTypeName(trapInfo.abnegated)
	panelDesc:getChildByName("Label_subdued"):setString(string.format(hp.lang.getStrByID(1006), strName))

	-- level
	panelDesc:getChildByName("Label_dailyCost"):setString(string.format(hp.lang.getStrByID(5499), trapInfo.level))
	
	panelDesc:getChildByName("Panel_cost"):setVisible(false)

	-- type
	panelDesc:getChildByName("Label_type"):setVisible(false)

	panelTrain:getChildByName("Label_word"):setString(hp.lang.getStrByID(2022))
	panelTrain:getChildByName("Label_word1"):setString(hp.lang.getStrByID(2023))

	if not active_ then
		widgetRoot:removeChild(widgetRoot:getChildByName("Panel_4626"))
		widgetRoot:removeChild(panelCost)
		widgetRoot:removeChild(panelTrain)
		Panel_toAcademy:setVisible(not active_)
		btnToAcademy:setTouchEnabled(true)
	else
		widgetRoot:removeChild(Panel_toAcademy)
	end


	-- callBack function
	-- many callback is logic code, should not be placed in UI-dealing class
	local function OnPropBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/wall/trapInfo"
			local ui = UI_trapInfo.new(sid_)
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
					player.trapManager.trapTrainFinish({sid=sid_, number=trainNum})
				end

				self:close()
			end

			local function onConfirm()
				-- start train
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 5
				oper.type = 10
				oper.sid = sid_
				oper.num = trainNum
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onFastTrainResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender)
			end

			local diamond_ = tonumber(self.uiDiamond:getString())
			if diamond_ > player.getResource("gold") then
				local function buyDiamond()
					cclog_("购买钻石")
				end
				require("ui/msgBox/msgBox")
				UI_msgBox.showCommonMsg(self, 1)
	   		else
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(2022), 
	   				hp.lang.getStrByID(5155), 
	   				hp.lang.getStrByID(1209), 
	   				hp.lang.getStrByID(2412), 
	      			onConfirm
	   				)
	   			self:addModalUI(msgBox)
			end			
		end
	end

	local function OnTrainResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			local info_ = {data.cd, data.cd, sid_, trainNum}
			cdBox.initCDInfo(cdBox.CDTYPE.TRAP, info_)
			hp.msgCenter.sendMsg(hp.MSG.TRAP_TRAIN, info_)
		end

		self:close()
	end

	local function trainCostChange()
		uiTrainNum:setString(trainNum)

		-- update resource cost
		trainCost[1] = trainNum * trapInfo.costs[5]
		trainCost[2] = trainNum * trapInfo.costs[4]
		trainCost[3] = trainNum * trapInfo.costs[6]
		trainCost[4] = trainNum * trapInfo.costs[3]
		trainCost[5] = trainNum * trapInfo.costs[2]
		for i, v in ipairs(uiResLabel_) do
			v:setString(hp.common.changeNumUnit(resource[i]).."/"..hp.common.changeNumUnit(trainCost[i]))
		end

		-- update time cost
		local time_ = player.helper.getTrapTrainTime(trapInfo.cd * trainNum)
		timer:setString(hp.datetime.strTime(time_))

		if (trainNum == 0) or (trainNum > maxNormalTrainNum) then
			btnTrain:setTouchEnabled(false)
			btnTrain:loadTexture(config.dirUI.common.."button_gray.png")
			btnFastTrain:setTouchEnabled(false)
			btnFastTrain:loadTexture(config.dirUI.common.."button_gray.png")
			light:setVisible(false)
		else
			btnTrain:setTouchEnabled(true)
			btnTrain:loadTexture(config.dirUI.common.."button_blue.png")
			btnFastTrain:setTouchEnabled(true)
			btnFastTrain:loadTexture(config.dirUI.common.."button_green.png")
			light:setVisible(true)
		end

		-- 立即训练钻石消耗
		local resource_ = {0,trainCost[5],trainCost[4],trainCost[2],trainCost[1],trainCost[3]}
		self.uiDiamond:setString(player.quicklyMgr.getDiamondCost(resource_, time_))
	end

	local percent = -1
	local function OnSliderPercentChange(sender, eventType)
		local per = sender:getPercent()
		if percent == per then
			return
		end
		percent = per
		-- update train number
		trainNum = math.floor(maxTrainNum * per / 100)
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
				local percent = math.floor(trainNum / maxTrainNum * 100)
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
				local percent = math.floor(trainNum / maxTrainNum * 100)
				slider:setPercent(percent)
				trainCostChange()
			end
		end
	end

	local function OnTrainTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			-- 有陷阱在训练
			if cdBox.getCD(cdBox.CDTYPE.TRAP) > 0 then
				local function callBackConfirm()
					require("ui/item/speedItem")
					local ui  = UI_speedItem.new(cdBox.CDTYPE.TRAP)
					self:addUI(ui)
					self:close()
				end
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(5113), 
					hp.lang.getStrByID(5114), 
					hp.lang.getStrByID(2414), 
					hp.lang.getStrByID(2412),  
					callBackConfirm
					)
				self:addModalUI(msgBox)
			else
				-- start train
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 5
				oper.type = 3
				oper.sid = sid_
				oper.num = trainNum
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(OnTrainResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end
		end
	end

	local function OnToAcademyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/academy/trapTree"
			local ui_ = UI_trapTree.new()
			self:addUI(ui_)
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

	local function setLackResHint()
		for i, v in ipairs(lackRes_) do
			if v then
				uiResLabel_[i]:setColor(cc.c3b(255,0,0))
				local fade_ = cc.FadeOut:create(1)
				local fadeIn_ = cc.FadeIn:create(1)
				local action_ = cc.Sequence:create(fade_, fadeIn_)
				local sprite_ = cc.Sprite:create(config.dirUI.common.."ui_barrack_6.png")
				sprite_:runAction(cc.RepeatForever:create(action_))
				sprite_:setAnchorPoint(0,0)
				uiPanel_[i]:addChild(sprite_)
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

	btnToAcademy:addTouchEventListener(OnToAcademyTouched)

	for i, v in ipairs(uiResImg_) do
		v:addTouchEventListener(onResItemTouched)
	end

	self:registMsg(hp.MSG.CLOSE_WINDOW)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(widgetRoot)
	if maxNormalTrainNum == 0 then
		slider:setTouchEnabled(false)
		changeSliderPercent(0)
		setLackResHint()
	else
		changeSliderPercent(100)
	end

	-- 渐入渐出
	self:moveIn(1, 0.2)
	popFrame:setCloseEvent(function() self:moveOut(2, 0.2, 1) end)
end


function UI_trapTrain:CanTrainNumber(sid_)
	local barracklist = player.buildingMgr.getBuildingsBySid(1018)
	local barrackTrain = 0
	local maxTrainNum = {}

	for i,v in ipairs(barracklist) do
		barrackTrain = barrackTrain + hp.gameDataLoader.getBuildingInfoByLevel("wall", v.lv, "deadfallMax")
	end

	-- 正在建造的
	local trainingInfo_ =  cdBox.getCDInfo(cdBox.CDTYPE.TRAP)
	local trainingNum_ = trainingInfo_.number
	if trainingNum_ == nil then
		trainingNum_ = 0
	end
	if trainingInfo_.cd == 0 then
		trainingNum_ = 0
	end
	maxTrainNum[1] = barrackTrain - player.trapManager.getTrapNum() - trainingNum_
	if maxTrainNum[1] < 0 then
		maxTrainNum[1] = 0
	end
	local min1 = maxTrainNum[1]

	-- resource limit
	local resource = {player.getResource("rock"),player.getResource("wood"),player.getResource("mine"),player.getResource("food"),player.getResource("silver")}
	local trapInfo = hp.gameDataLoader.getInfoBySid("trap", sid_)
	local trainCost = {trapInfo.costs[5], trapInfo.costs[4], trapInfo.costs[6], trapInfo.costs[3], trapInfo.costs[2]}
	local lackRes_ = {}
	for i = 1, table.getn(resource) do
		lackRes_[i] = false
		if trainCost[i] ~= 0 then
			local num_ = math.floor(resource[i]/trainCost[i])
			maxTrainNum[table.getn(maxTrainNum) + 1] = num_
			if num_ == 0 then
				lackRes_[i] = true
			end
		end
	end

	local min = hp.common.getMinNumber(maxTrainNum)
	return min, min, lackRes_
end

function UI_trapTrain:onMsg(msg_, param_)
	if msg_ == hp.MSG.CLOSE_WINDOW then
		if param_ == 2 then
			self:close()
		end
	end
end