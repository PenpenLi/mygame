--
-- ui/barrack/soldierInfo.lua
-- 架构 - 弹出窗口
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_soldierInfo = class("UI_soldierInfo", UI)


--init
function UI_soldierInfo:init(type_)
	-- data
	-- ===============================	
	self.soldierInfo = player.getArmyInfoByType(type_)
	self.type = type_
	self.soldierNum = player.getCityArmy():getSoldierByType(type_):getNumber()
	self.fireNumber = 0
	self.percent = 0

	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "soldierInfo.json")
	local popFrame = UI_popFrame.new(self.wigetRoot, self.soldierInfo.name)

	-- 士兵数量
	local numContainer = self.wigetRoot:getChildByName("Panel_1260")
	local sliderBg = numContainer:getChildByName("ImageView_1263")
	self.slider = sliderBg:getChildByName("Slider_1264")
	self.number = numContainer:getChildByName("ImageView_1265"):getChildByName("Label_1267")
	self.plus = sliderBg:getChildByName("ImageView_1262")
	self.minus = sliderBg:getChildByName("ImageView_1261")

	-- update ui
	self:updatUIData()

	-- local function
	local function changeFireNumber()
		self.number:setString(tostring(self.fireNumber))
		if self.fireNumber == 0 then
			self.fire:setTouchEnabled(false)
			self.fire:loadTexture(config.dirUI.common.."button_gray.png")
		else
			self.fire:setTouchEnabled(true)
			self.fire:loadTexture(config.dirUI.common.."button_blue.png")
		end
	end

	-- call back
	local function OnMinusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if self.soldierNum == 0 then
				return
			end
			if self.fireNumber > 0 then
				self.fireNumber = self.fireNumber - 1
				local percent = hp.common.round(self.fireNumber / self.soldierNum * 100)
				self.slider:setPercent(percent)
				changeFireNumber()
			end
		end
	end

	local function OnPlusTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			if self.soldierNum == 0 then
				return
			end
			if self.fireNumber < self.soldierNum then
				self.fireNumber = self.fireNumber + 1
				local percent = hp.common.round(self.fireNumber / self.soldierNum * 100)
				self.slider:setPercent(percent)
				changeFireNumber()
			end
		end
	end

	local function OnSliderPercentChange(sender, eventType)
		local per = sender:getPercent()
		if self.percent == per then
			return
		end
		self.percent = per
		-- update train number
		self.fireNumber = hp.common.round(self.soldierNum * per / 100)
		changeFireNumber()
	end

	local function onFireResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.fireSoldier(type_, self.fireNumber)
		end

		self:close()
		hp.msgCenter.sendMsg(hp.MSG.CLOSE_WINDOW, 1)
	end

	local function onFireConfirm()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 5
		oper.type = 5
		oper.branch = type_
		oper.num = self.fireNumber
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onFireResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end

	local function onFireSoldierTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new("是否确定", 
				"", 
				hp.lang.getStrByID(2414), 
				hp.lang.getStrByID(2412),  
				onFireConfirm
				)
			self:addModalUI(msgBox)
		end
	end

	if self.soldierNum == 0 then
		self.slider:setTouchEnabled(false)
	else
		self.slider:addEventListenerSlider(OnSliderPercentChange)
	end

	self.minus:addTouchEventListener(OnMinusTouched)

	self.plus:addTouchEventListener(OnPlusTouched)

	self.fire:addTouchEventListener(onFireSoldierTouched)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
	self.slider:setPercent(0)
	changeFireNumber()
end

-- update ui
function UI_soldierInfo:updatUIData()
	-- soldier image
	local soldierImage = self.wigetRoot:getChildByName("Panel_4921"):getChildByName("ImageView_1210")
	soldierImage:loadTexture(config.dirUI.soldier..self.soldierInfo.image)

	-- description 
	local desc = self.wigetRoot:getChildByName("Panel_1211")
	desc:getChildByName("Label_1212"):setString(string.format(hp.lang.getStrByID(1008), player.getTypeName(self.type)))

	-- 克制
	local strName = ""
	for i,v in ipairs(self.soldierInfo.abnegate) do
		if i == 1 then
			strName = strName..player.getTypeName(v)
		else
			strName = strName..","..player.getTypeName(v)
		end
	end
	desc:getChildByName("Label_1213"):setString(string.format(hp.lang.getStrByID(1005), strName))

	-- 被克制
	local strName = ""
	for i,v in ipairs(self.soldierInfo.abnegated) do
		if i == 1 then
			strName = strName..player.getTypeName(v)
		else
			strName = strName..","..player.getTypeName(v)
		end
	end
	desc:getChildByName("Label_1214"):setString(string.format(hp.lang.getStrByID(1006), strName))

	-- 战力描述
	local fightValue = self.wigetRoot:getChildByName("Panel_1215")
	-- 兵力
	fightValue:getChildByName("Label_1216"):setString(string.format(hp.lang.getStrByID(1017), player.getTotalArmy():getSoldierByType(self.type):getNumber()))
	-- 单兵消耗
	fightValue:getChildByName("Label_1217"):setString(string.format(hp.lang.getStrByID(1018), self.soldierInfo.charge))
	-- 权利值
	fightValue:getChildByName("Label_1218"):setString(string.format(hp.lang.getStrByID(1019), self.soldierInfo.addPoint))	
	-- 负载
	fightValue:getChildByName("Label_1219"):setString(string.format(hp.lang.getStrByID(1020), self.soldierInfo.loaded))

	-- 能力星级
	local list_ = {}
	local containerList_ = {"Panel_1224", "Panel_1225", "Panel_1226", "Panel_1227"}
	local prop_ = {"attack", "defense", "life", "speed"}
	local starList_ = {}
	local descList_ = {1026, 1027, 1028, 1029}

	local function setAbiliby(value_, starList_)
		for i = 1, value_ do
			starList_[i]:loadTexture(config.dirUI.common.."ui_barrack_starHigh.png")
		end
	end	

	for i = 1, 4 do
		starList_[i] = fightValue:getChildByName(containerList_[i])
		starList_[i]:getChildByName("Label_1220"):setString(hp.lang.getStrByID(descList_[i]))
		for j = 1, 4 do
			list_[j] = starList_[i]:getChildByName("ImageView_star"..j)
		end
		setAbiliby(self.soldierInfo[prop_[i]], list_)
	end

	-- 奖励
	self.wigetRoot:getChildByName("Panel_5185"):getChildByName("ImageView_1244"):getChildByName("Label_1245"):setString(hp.lang.getStrByID(1013))
	
	-- 加成信息
	local addContainer = self.wigetRoot:getChildByName("Panel_1246")
	-- 英雄天赋
	addContainer:getChildByName("Label_1280"):setString(hp.lang.getStrByID(1014))
	addContainer:getChildByName("Label_1250"):setString(string.format(hp.lang.getStrByID(1021), "0"))
	addContainer:getChildByName("Label_1251"):setString(string.format(hp.lang.getStrByID(1022), "0"))
	-- 书院
	addContainer:getChildByName("Label_1380"):setString(hp.lang.getStrByID(1015))
	addContainer:getChildByName("Label_1350"):setString(string.format(hp.lang.getStrByID(1023), "0"))
	-- 建筑奖励
	addContainer:getChildByName("Label_1480"):setString(hp.lang.getStrByID(1016))
	addContainer:getChildByName("Label_1450"):setString(string.format(hp.lang.getStrByID(1024), "0"))

	-- 开除
	self.fire = self.wigetRoot:getChildByName("Panel_1208"):getChildByName("ImageView_1268")
	self.fire:getChildByName("Label_1269"):setString(hp.lang.getStrByID(1025))
end