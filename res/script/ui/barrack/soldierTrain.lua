--
-- ui/barrack/soldierTrain.lua
-- 士兵训练
--===================================
require "ui/fullScreenFrame"
require "ui/frame/popFrame"

UI_soldierTrain = class("UI_soldierTrain", UI)

--init
function UI_soldierTrain:init(type_)
	-- data
	-- ===============================
	-- get soldier infomation
	local soldierInfo = player.soldierManager.getArmyInfoByType(type_)

	-- max train number
	local maxNormalTrainNum, maxTrainNum, lackRes_ = player.soldierManager.getCurTrainUpLimit(type_)
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

	panelTrain:getChildByName("Label_word"):setString(hp.lang.getStrByID(1009))
	panelTrain:getChildByName("Label_word1"):setString(hp.lang.getStrByID(1010))

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
					player.soldierManager.soldierTrainFinish({type=type_, number=trainNum})
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
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(1009), 
	   				hp.lang.getStrByID(1046), 
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
			local info_ = {data.cd, data.cd, type_, trainNum}
			cdBox.initCDInfo(cdBox.CDTYPE.BRANCH, info_)
			hp.msgCenter.sendMsg(hp.MSG.BARRACK_TRAIN, info_)
			player.guide.stepEx({5006})
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
		for i, v in ipairs(uiResLabel_) do
			v:setString(hp.common.changeNumUnit(resource[i]).."/"..hp.common.changeNumUnit(trainCost[i]))
		end

		-- update time cost
		local time_ = player.helper.getSoldierTrainTime(soldierInfo.cd * trainNum)
		timer:setString(hp.datetime.strTime(time_))

		-- update daily cost
		panelDesc:getChildByName("Panel_cost"):getChildByName("Label_cost"):setString(trainNum * soldierInfo.charge)		

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
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(5111), 
					hp.lang.getStrByID(5112), 
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
				oper.type = 1
				oper.branch = type_
				oper.num = trainNum
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(OnTrainResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)

			end
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

	-- 进行新手引导绑定
	-- =========================================
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI( step )
		if step==5006 then
			player.guide.bind2Node(step, btnTrain, OnTrainTouched)
			player.guide.getUI().uiLayer:runAction(cc.MoveBy:create(0.2, cc.p(game.visibleSize.width, 0)))
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_soldierTrain:onMsg(msg_, param_)
	if msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(param_)
	elseif msg_ == hp.MSG.CLOSE_WINDOW then
		if param_ == 1 then
			self:close()
		end
	end
end