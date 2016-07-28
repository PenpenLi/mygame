--
-- ui/march/march.lua
-- 行军界面
--===================================
require "ui/UI"
require "obj/army"

MARCH_TYPE = {
	OCCUPY = 2,
	ATTACK = 3,
	RALLY_ATTACK = 7,
	RALLY_DEFENSE = 6,
	RALLY_ASSIT = 6,
}

UI_march = class("UI_march", UI)


--init
function UI_march:init(position_, attackType_, param_, callBack_)
	-- data
	-- ===============================
	self.heroAvailable = true
	self.position = position_
	self.param = param_
	self.type = attackType_
	self:initData()
	self.checked = false
	self.cityArmyClone = Army.new()
	self.cityArmyClone:addArmy(player.getCityArmy())
	local helper = require "playerData/helper"
	self.marchSpeedAdd = helper.getMarchSpeedAdd()

	-- ui
	-- ===============================
	self:initUI()

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)

	self.selectClone = self.soldierSelect:clone()
	self.selectClone:retain()

	-- call back
	local function OnGoBackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function OnMarchRespond(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if attackType_ == 6 then
				Scene.showMsg({1017, self.army:getSoldierTotalNumber()})
			else
				Scene.showMsg({1005, self.army:getSoldierTotalNumber()})
			end
			-- 军队减少
			player.armyLeave(self.army)			
			hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, data.army)

			-- 取消保护
			player.clearGuard()

			if callBack_ ~= nil then
				print("callBack_callBack_callBack_callBack_callBack_callBack_callBack_callBack_callBack_callBack_")
				callBack_(self.army, self.time, self.checked)
			end
		end
		self:close()
	end

	local function confirmMarch()
		local oper = {}
		if self.checked then
			oper.hero = 1
		end
		local cmdData={operation={}}
		oper.channel = 6
		oper.type = attackType_
		oper["in"] = self.army:getSoldierNumberByType(1)
		oper.an = self.army:getSoldierNumberByType(2)
		oper.ca = self.army:getSoldierNumberByType(3)
		oper.app = self.army:getSoldierNumberByType(4)				
		oper.x = self.position.x
		oper.y = self.position.y
		if attackType_ == 7 then
			oper.param = param_
		elseif attackType_ == 6 then
			oper.id = param_
		end
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(OnMarchRespond)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end

	local function OnMarchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			-- 未选择部队
			if self.army:getSoldierTotalNumber() == 0 then
				require "ui/bigMap/warning"
				ui_ = UI_warning.new()
				self:addModalUI(ui_)
			else
				if self.checked then
					confirmMarch()
				elseif self.heroAvailable == false then
					confirmMarch()
				else
					require "ui/march/marchNoHeroWarning"
					ui_ = UI_marchNoHeroWarning.new(confirmMarch)
					self:addModalUI(ui_)
				end
			end
		end
	end

	local function OnHeroSelectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local heroInfo = player.hero.getBaseInfo()
			if heroInfo.state == 1 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5170), hp.lang.getStrByID(5171))
      			self:addModalUI(box_)
      		elseif heroInfo.state == 2 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5172), hp.lang.getStrByID(5173))
      			self:addModalUI(box_)
      		elseif heroInfo.state == 3 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5174), hp.lang.getStrByID(5175))
      			self:addModalUI(box_)
			elseif heroInfo.armyID ~= 0 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5176), hp.lang.getStrByID(5177))
      			self:addModalUI(box_)
			elseif self.type == MARCH_TYPE.RALLY_DEFENSE or self.type == MARCH_TYPE.RALLY_ASSIT then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5178), hp.lang.getStrByID(5179))
      			self:addModalUI(box_)
      		else
      			self.heroCheck:setVisible(not self.heroCheck:isVisible())
				self.checked = not self.checked
			end			
		end
	end

	local function OnSliderPercentChange(sender, eventType)
		local tag_ = sender:getTag()
		if self.percentList[tag_] == sender:getPercent() then
			return
		end

		self.percentList[tag_] = sender:getPercent()
		local maxNum_ = self.numList[tag_]
		-- 对应派出的士兵数
		local soldierNum_ = hp.common.round(self.percentList[tag_] * maxNum_ / 100)
		-- 是否超出上限
		if soldierNum_ > self.remainNumber then
			soldierNum_ = self.remainNumber
			self.percentList[tag_] = hp.common.round(soldierNum_ / maxNum_ * 100)
			sender:setPercent(self.percentList[tag_])
		end
		self.army:setSoldier(tag_, soldierNum_)
		self.remainNumber = self.maxNumber - self.army:getSoldierTotalNumber()
		self:updateUIInfo()
		self.numTextList[tag_]:setText(tostring(soldierNum_))
		self.restNum[tag_]:setString(tostring(maxNum_ - soldierNum_))
	end

	local function onAllSelectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if sender:getTag() == 0 then
				sender:setTag(1)
				self.remainNumber = 0
				self.army:clear()
				local totalNum_ = 0
				for i = 1, player.getSoldierType() do
					if self.numList[i] ~= nil then
						if totalNum_ + self.numList[i] < self.maxNumber then
							totalNum_ = self.numList[i] + totalNum_
							self.army:addSoldier(i, self.numList[i])
						else
							self.army:addSoldier(i, self.maxNumber - totalNum_)
							totalNum_ = self.maxNumber
						end
					end
				end
				self.remainNumber = self.maxNumber - totalNum_
				if self.heroAvailable == true then
					self.heroCheck:setVisible(true)
					self.checked = true
				end
			else
				sender:setTag(0)
				self.remainNumber = self.maxNumber
				self.army:clear()
				self.heroCheck:setVisible(false)
				self.checked = false
			end
			self:updateUIInfo()
			self:updateProgressBar()
		end
	end

	self.sliderListener = OnSliderPercentChange

	self.goBack:addTouchEventListener(OnGoBackTouched)

	self.marchBtn:addTouchEventListener(OnMarchTouched)

	self.allSelect:addTouchEventListener(onAllSelectTouched)

	self.heroCheckFrame:addTouchEventListener(OnHeroSelectTouched)

	-- 界面数据初始化
	-- 士兵初始化
	self:initSoldiers()

	-- 刷新界面信息
	self:updateUIInfo()
	self:updateProgressBar()
end

function UI_march:initData()
	-- ui
	self.numTextList = {}

	self.restNum = {}

	self.progress = {}

	-- 数据
	self.percentList = {}
	-- 士兵数量列表
	self.numList = {}
	-- 最大出兵数量
	self.maxNumber = hp.gameDataLoader.getBuildingInfoByLevel("main", player.buildingMgr.getBuildingMaxLvBySid(1001), "soldierMax", 0)
	-- 还可以派出士兵数量
	self.remainNumber = self.maxNumber
	-- 军队信息
	self.army = Army.new()
end

function UI_march:updateUIInfo()
	self.soldierNum:setString(string.format("%d/%d", self.maxNumber - self.remainNumber, self.maxNumber))
	self.loaded:setString(tostring(self.army:getArmyLoaded()))
	local time_ = self.army:calcMarchTime(self.position, self.marchSpeedAdd)
	self.time = time_
	self.marchTime:setString(hp.datetime.strTime(time_))	
end	

function UI_march:updateProgressBar()
	for i = 1, player.getSoldierType() do
		if self.progress[i] ~= nil then
			local num_ = self.army:getSoldierNumberByType(i)
			local per = hp.common.round(num_ / self.numList[i] * 100)
			self.progress[i]:setPercent(per)
			self.numTextList[i]:setText(tostring(num_))
			self.restNum[i]:setString(tostring(self.numList[i] - num_))
		end
	end
end

function UI_march:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "march.json")
	local content = self.wigetRoot:getChildByName("Panel_8329")
	self.listView = self.wigetRoot:getChildByName("ListView_8344")
	local heroInfo = player.hero.getBaseInfo()

	-- 返回
	self.goBack = content:getChildByName("ImageView_9388")

	-- 士兵数量
	self.soldierNum = content:getChildByName("ImageView_8330"):getChildByName("Label_8332")

	-- 士兵负载
	self.loaded = content:getChildByName("ImageView_8331"):getChildByName("Label_8332")

	-- 行军时间
	self.marchBtn = content:getChildByName("ImageView_8336")
	self.marchBtn:getChildByName("Label_8337"):setString(hp.lang.getStrByID(1300))
	self.marchTime = self.marchBtn:getChildByName("ImageView_8338"):getChildByName("Label_8339")

	-- 武将头像
	self.heroImage = content:getChildByName("ImageView_9383")
	self.heroImage:loadTexture(config.dirUI.heroHeadpic .. heroInfo.sid..".png")

	-- 武将名称
	content:getChildByName("Label_8341"):setString(heroInfo.name)

	-- 武将选择
	self.heroCheckFrame = content:getChildByName("ImageView_8342")
	self.heroCheck = self.heroCheckFrame:getChildByName("ImageView_8343")
	print("player.getCurrentHero().state", heroInfo.state)
	print("self.type",self.type)
	if heroInfo.state ~= 0 then
		self.heroAvailable = false
		-- self.heroCheckFrame:setTouchEnabled(false)
	elseif heroInfo.armyID ~= 0 then
		self.heroAvailable = false
		-- self.heroCheckFrame:setTouchEnabled(false)
	elseif self.type == MARCH_TYPE.RALLY_DEFENSE or self.type == MARCH_TYPE.RALLY_ASSIT then
		self.heroAvailable = false
		-- self.heroCheckFrame:setTouchEnabled(false)
	end

	self.soldierSelect = self.listView:getChildByName("Panel_8345")
	self.allSelectPanel = self.listView:getChildByName("Panel_9385")

	self.allSelect = self.allSelectPanel:getChildByName("Panel_9390"):getChildByName("ImageView_9386")
	self.allSelect:getChildByName("Label_9387"):setString(hp.lang.getStrByID(1301))
	self.allSelect:setTag(0)
end

function UI_march:initSoldiers()
	local btnAutoSelectPanel = self.allSelectPanel
	local soldierPanel = self.soldierSelect
	self.listView:removeAllItems()

	local num_ = 0
	for i = 1, player.getSoldierType() do
		v = self.cityArmyClone:getSoldierByType(i)
		if v:getNumber() > 0 then
			local clonePanel = soldierPanel:clone()
			local soldierInfo = v:getSoldierInfo()
			local panel_ = clonePanel:getChildByName("Panel_8351")

			local soldierInfoPanel = panel_:getChildByName("Panel_8354")
			-- 头像
			soldierInfoPanel:getChildByName("ImageView_8353"):loadTexture(config.dirUI.soldier..soldierInfo.image)
			-- 总数
			self.restNum[i] = soldierInfoPanel:getChildByName("ImageView_8355"):getChildByName("Label_8356")
			self.restNum[i]:setString(v:getNumber())
			-- 类型
			soldierInfoPanel:getChildByName("Label_8357"):setString(player.getTypeName(v:getSoldierType()))

			-- 名字
			panel_:getChildByName("Label_8358"):setString(soldierInfo.name)

			-- 进度条
			local progress = panel_:getChildByName("ImageView_8359"):getChildByName("Slider_8361")
			progress:setTag(i)
			progress:addEventListenerSlider(self.sliderListener)
			self.progress[i] = progress

			-- 数量
			self.numTextList[i] = panel_:getChildByName("ImageView_8363"):getChildByName("TextField_9428")
			self.percentList[i] = 0
			self.numList[i] = v:getNumber()
			if self.numList[i] == 0 then
				self.progress[i]:setTouchEnabled(false)
			end
			self.listView:pushBackCustomItem(clonePanel)
			num_ = num_ + 1
		end
	end

	if num_ > 0 then
		self.listView:pushBackCustomItem(btnAutoSelectPanel)
	else
		self.wigetRoot:getChildByName("Panel_28"):setVisible(true)
		self.wigetRoot:getChildByName("Panel_28"):getChildByName("Label_29"):setString(hp.lang.getStrByID(5115))
		self.listView:setVisible(false)
	end
end

function UI_march:close()
	self.selectClone:release()
	self.super.close(self)
end	

function UI_march.openMarchUI(parent_, position_, type_, param_, callBack_)
	ui_ = UI_march.new(position_, type_, param_, callBack_)
	parent_:addUI(ui_)
end