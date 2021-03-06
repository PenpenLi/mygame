--
-- ui/wall/trapInfo.lua
-- 陷阱信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_trapInfo = class("UI_trapInfo", UI)

local armytype = 5
-- 通用
local propCommon = {51,52,53}
-- 加成来源
local attrSource = {
	globalData.ADDNFILTER.RESEARCH,
	globalData.ADDNFILTER.HERO,
	globalData.ADDNFILTER.BUILDBUFF
}

local sourceNameId = {1433,5483,1016}

--init
function UI_trapInfo:init(sid_)
	-- data
	-- ===============================	
	self.trapInfo = hp.gameDataLoader.getInfoBySid("trap", sid_)
	self.sid = sid_
	self.trapNum = player.trapManager.getTraps()[tostring(sid_)]:getNumber()
	self.fireNumber = 0
	self.percent = 0

	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "soldierInfo.json")
	local popFrame = UI_popFrame.new(self.wigetRoot, self.trapInfo.name)

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
			self.fire:loadTexture(config.dirUI.common.."button_red.png")
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
				local percent = hp.common.round(self.fireNumber / self.trapNum * 100)
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
			if self.fireNumber < self.trapNum then
				self.fireNumber = self.fireNumber + 1
				local percent = hp.common.round(self.fireNumber / self.trapNum * 100)
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
		self.fireNumber = hp.common.round(self.trapNum * per / 100)
		changeFireNumber()
	end

	local function onFireResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.trapManager.fireTrap(sid_, self.fireNumber)
		end

		self:close()
		hp.msgCenter.sendMsg(hp.MSG.CLOSE_WINDOW, 2)
	end

	local function onFireConfirm()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 5
		oper.type = 6
		oper.sid = sid_
		oper.num = self.fireNumber
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onFireResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender)
	end

	local function onFireSoldierTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(5005), 
				hp.lang.getStrByID(5289), 
				hp.lang.getStrByID(2407), 
				hp.lang.getStrByID(2412),  
				onFireConfirm
				)
			self:addModalUI(msgBox)
		end
	end

	if self.trapNum == 0 then
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
function UI_trapInfo:updatUIData()
	-- trap image
	local trapImage = self.wigetRoot:getChildByName("Panel_4921"):getChildByName("ImageView_1210")
	trapImage:loadTexture(config.dirUI.trap..self.trapInfo.image)

	-- description 
	local desc = self.wigetRoot:getChildByName("Panel_1211")
	desc:getChildByName("Label_1212"):setString(string.format(hp.lang.getStrByID(1008), player.soldierManager.getTypeName(armytype)))

	-- 克制
	local strName = ""
	for i,v in ipairs(self.trapInfo.abnegate) do
		if i == 1 then
			strName = strName..player.soldierManager.getTypeName(v)
		else
			strName = strName..","..player.soldierManager.getTypeName(v)
		end
	end
	if strName == "" then
		strName = hp.lang.getStrByID(5147)
	end
	desc:getChildByName("Label_1213"):setString(string.format(hp.lang.getStrByID(1005), strName))

	-- 被克制
	local strName = player.soldierManager.getTypeName(self.trapInfo.abnegated)
	desc:getChildByName("Label_1214"):setString(string.format(hp.lang.getStrByID(1006), strName))

	-- 战力描述
	local fightValue = self.wigetRoot:getChildByName("Panel_1215")
	-- 兵力
	fightValue:getChildByName("Label_1216"):setString(string.format(hp.lang.getStrByID(1017), self.trapNum))
	-- 单兵消耗
	fightValue:getChildByName("Label_1217"):setString(string.format(hp.lang.getStrByID(1018), 0))
	-- 权利值
	fightValue:getChildByName("Label_1218"):setString(string.format(hp.lang.getStrByID(1019), self.trapInfo.point))	
	-- 负载
	fightValue:getChildByName("Label_1219"):setString(string.format(hp.lang.getStrByID(1020), 0))

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
		setAbiliby(self.trapInfo[prop_[i]], list_)
	end

	-- 奖励
	self.wigetRoot:getChildByName("Panel_5185"):getChildByName("ImageView_1244"):getChildByName("Label_1245"):setString(hp.lang.getStrByID(1013))
	
	-- 加成信息
	local listView = self.wigetRoot:getChildByName("ListView_59")
	local item1_ = listView:getChildByName("Panel_60"):clone()
	local item2_ = listView:getChildByName("Panel_1246"):clone()
	listView:removeAllItems()

	for i, v in ipairs(attrSource) do
		local num_ = 0
		-- 来源
		local title_ = item1_:clone()
		listView:pushBackCustomItem(title_)
		title_:getChildByName("Panel_62"):getChildByName("Label_1280"):setString(hp.lang.getStrByID(sourceNameId[i]))

		-- 通用
		for j, w in ipairs(propCommon) do			
			local addn_ = player.helper.getAttrAddn(w, v)
			if addn_ ~= 0 then
				local item_ = item2_:clone()
				listView:pushBackCustomItem(item_)
				num_ = num_ + 1
				local content_ = item_:getChildByName("Panel_65")

				local info_ = hp.gameDataLoader.getInfoBySid("attr", w)
				-- 描述
				content_:getChildByName("Label_1250"):setString(info_.desc)
				-- 加成
				content_:getChildByName("Label_1251"):setString((addn_ / 100).."%")
			end
		end

		-- 无
		if num_ == 0 then
			local item_ = item2_:clone()
			listView:pushBackCustomItem(item_)
			local content_ = item_:getChildByName("Panel_65")
			-- 无
			content_:getChildByName("Label_1250"):setString(hp.lang.getStrByID(5147))
			content_:getChildByName("Label_1251"):setString("")
		end
	end

	-- 开除
	self.fire = self.wigetRoot:getChildByName("Panel_1208"):getChildByName("ImageView_1268")
	self.fire:getChildByName("Label_1269"):setString(hp.lang.getStrByID(2402))
end