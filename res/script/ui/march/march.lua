--
-- ui/march/march.lua
-- 行军界面
--===================================
require "ui/UI"
require "obj/army"

-- 出兵类型到网络请求类型映射表
local marchTypeMap = {3,3,3,3,13,2,3,7,13,6,6}

UI_march = class("UI_march", UI)

--init
-- function UI_march:init(position_, attackType_, param_, callBack_, maxNumber_, extraParam_)
-- extraParam_:目前的通用参数maxNumber,限定最大兵力;其余都是每种类型特有参数
function UI_march:init(position_, attackType_, extraParam_, callBack_)
	-- data
	-- ===============================
	self.position = position_
	self.attackType = attackType_
	self.extraParam = extraParam_
	self.callBack = callBack_

	self:initData()	

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
			if self.attackType == globalData.MARCH_TYPE.REINFORCE or self.attackType == globalData.MARCH_TYPE.DONATE then
				Scene.showMsg({1017, self.army:getSoldierTotalNumber()})
			else
				Scene.showMsg({1005, self.army:getSoldierTotalNumber()})
			end
			-- 军队减少
			player.soldierManager.armyLeave(self.army)			
			hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, {army=data.army})

			if callBack_ ~= nil then
				callBack_(self.army, self.time, self.checked)
			end

			if game.curScene.mapLevel == 2 then
				game.curScene:closeAllUI()
			end

			-- 重新请求行军信息
			-- self:showLoading(player.marchMgr.sendCmd(8))
			player.marchMgr.sendCmd(8)
		end
		self:close()
	end

	local function confirmMarch(addHero_)
		local oper = {}
		if self.checked then
			oper.hero = 1
		end

		if addHero_ == true then
			oper.hero = 1
		end

		local cmdData={operation={}}
		oper.channel = 6
		oper.type = marchTypeMap[self.attackType]
		oper["in"] = self.army:getSoldierNumberByType(1)
		oper.an = self.army:getSoldierNumberByType(2)
		oper.ca = self.army:getSoldierNumberByType(3)
		oper.app = self.army:getSoldierNumberByType(4)				
		oper.x = self.position.x
		oper.y = self.position.y
		-- 附加参数
		if self.attackType == globalData.MARCH_TYPE.ATTACK_FORTRESS then
			oper.param = -1
		elseif self.attackType == globalData.MARCH_TYPE.RALLY_FORTRESS then
			oper.param = self.extraParam.rallyTime
		elseif self.attackType == globalData.MARCH_TYPE.REINFORCE then
			oper.id = 0
			oper.k = self.position.k
		elseif self.attackType == globalData.MARCH_TYPE.DONATE then
			oper.id = self.extraParam.armyID
			oper.k = self.position.k
		elseif self.attackType == globalData.MARCH_TYPE.RALLY_CITY then
			oper.param = self.extraParam.rallyTime
		end
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(OnMarchRespond)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender)
	end

	local function OnMarchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			-- 跨服
			if not self.myServer then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5517), hp.lang.getStrByID(5518), nil)
      			self:addModalUI(box_)
			-- 未选择部队
			elseif self.army:getSoldierTotalNumber() == 0 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5198), hp.lang.getStrByID(5199), nil)
      			self:addModalUI(box_)
			else
				if self.checked then
					confirmMarch()
				elseif self.heroAvailable == false then
					confirmMarch()
				else
					require "ui/march/marchNoHeroWarning"
					local ui_ = UI_marchNoHeroWarning.new(confirmMarch)
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
			elseif self.attackType == globalData.MARCH_TYPE.REINFORCE or self.attackType == globalData.MARCH_TYPE.DONATE then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5178), hp.lang.getStrByID(5179))
      			self:addModalUI(box_)
      		else
      			self.heroCheck:setVisible(not self.heroCheck:isVisible())
				self.checked = not self.checked
				self:updateUIInfo()
			end			
		end
	end

	-- 改变兵力
	local function changeSoldier(type_, num_, change_)
		-- 文字
		self.army:setSoldier(type_, num_)
		self.numTextList[type_]:setString(tostring(num_))
		local maxNum_ = self.numList[type_]
		self.restNum[type_]:setString(tostring(maxNum_ - num_))

		-- 进度条
		if change_ then
			local per_ = num_ / self.numList[type_] * 100
			self.progress[type_]:setPercent(per_)
		end
	end

	local function OnSliderPercentChange(sender, eventType)	
		local tag_ = sender:getTag()
		if self.percentList[tag_] == sender:getPercent() then
			return
		end

		self.percentList[tag_] = sender:getPercent()
		-- 最多可选
		local maxNum_ = self.numList[tag_]
		-- 实际选中
		local soldierNum_ = hp.common.round(self.percentList[tag_] * maxNum_ / 100)
		-- 当前剩余可选
		local remainNumber_ = self.maxNumber - self.army:getSoldierTotalNumber() + tonumber(self.numTextList[tag_]:getString())
		-- 是否超出上限
		if soldierNum_ > remainNumber_ then
			local restTotal_ = 0
			for i = 1, globalData.TOTAL_LEVEL do
				if i ~= tag_ then
					restTotal_ = restTotal_ + tonumber(self.numTextList[i]:getString())
				end
			end

			if restTotal_ ~= 0 then
				local index_ = 1
				local used_ = 0
				local restNumber_ = self.maxNumber - soldierNum_
				for i = 1, globalData.TOTAL_LEVEL do
					if i ~= tag_ then
						local per_ = tonumber(self.numTextList[i]:getString()) / restTotal_
						used_ = used_ + math.floor(restNumber_ * per_)
						changeSoldier(i, math.floor(restNumber_ * per_), true)
						index_ = index_ + 1
					end
				end
				-- 补全
				changeSoldier(tag_, self.maxNumber - used_, false)
			end
		else
			changeSoldier(tag_, soldierNum_, false)
		end		
		self:updateUIInfo()
	end

	local function onAllSelectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if sender:getTag() == 0 then
				sender:setTag(1)
				self.army:clear()
				local totalNum_ = 0
				for i = 1, globalData.TOTAL_LEVEL do
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

				if self.heroAvailable == true then
					self.heroCheck:setVisible(true)
					self.checked = true
				end
			else
				sender:setTag(0)
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

	if self.bDiamond then
		self.loadImg:loadTexture(config.dirUI.common.."gold4.png")
		if player.getGatherGoldHint() == 0 then
			require "ui/march/goldMarchHint"
			local ui_ = UI_goldMarchHint.new()
			game.curScene:addModalUI(ui_)
		end		
	end
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
	self.maxNumber = player.helper.getNumPerTroop()
	-- 军队信息
	self.army = Army.new()

	self.heroAvailable = true

	self.checked = false

	self.cityArmyClone = Army.new()
	self.cityArmyClone:addArmy(player.soldierManager.getCityArmy())

	if self.extraParam.maxNumber ~= nil then
		if self.extraParam.maxNumber < self.maxNumber then
			self.maxNumber = self.extraParam.maxNumber
		end
	end

	self.pickupRate = 1
	self.bDiamond = false
	if self.attackType == globalData.MARCH_TYPE.OCCUPY_RESOURCE then
		-- 计算负重	
		if self.extraParam.pickupRate ~= nil then
			self.pickupRate = self.extraParam.pickupRate
		end

		-- 钻石
		if self.extraParam.sourceType == 0 then
			self.bDiamond = true
		end
	end	

	self.myServer = true
	if self.position.k ~= nil then
		if self.position.k ~= player.serverMgr.getMyPosServer().sid then
			self.myServer = false
		end
	elseif self.position.kx ~= nil then
		self.myServer = player.serverMgr.isMyPosServer(self.position.kx, self.position.ky)
	end

	-- 负载加成
	self.loadedAddWithHero = {}
	self.loadedAdd = {}
	local typeAddMap_ = {4,14,24,34}
	for i, v in ipairs(self.army.soldierList) do		
		local addition_ = player.helper.getAttrAddn(44) + player.helper.getAttrAddn(typeAddMap_[i])
		self.loadedAddWithHero[i] = addition_
		local heroAdd_ = player.helper.getAttrAddn(44, globalData.ADDNFILTER.HERO) + player.helper.getAttrAddn(typeAddMap_[i], globalData.ADDNFILTER.HERO)
		self.loadedAdd[i] = addition_ - heroAdd_
	end

	-- 行军速度加成
	self.speedAddWithHero = {}
	self.speedAdd = {}
	local typeAddMap_ = {5,15,25,35}
	for i, v in ipairs(self.army.soldierList) do		
		local addition_ = player.helper.getAttrAddn(45) + player.helper.getAttrAddn(typeAddMap_[i])	
		self.speedAddWithHero[i] = addition_
		local heroAdd_ = player.helper.getAttrAddn(45, globalData.ADDNFILTER.HERO) + player.helper.getAttrAddn(typeAddMap_[i], globalData.ADDNFILTER.HERO)
		self.speedAdd[i] = addition_ - heroAdd_
	end
end

function UI_march:updateUIInfo()
	self.soldierNum:setString(string.format("%d/%d", self.army:getSoldierTotalNumber(), self.maxNumber))
	self.loaded:setString(tostring(math.floor(self:getArmyLoadedTmp()/self.pickupRate)))
	if not self.myServer then
		self.marchTime:setString(hp.lang.getStrByID(5517))
		self.time = 0
	else
		local time_ = self:calcMarchTimeTmp(self.position)
		self.time = time_
		self.marchTime:setString(hp.datetime.strTime(time_))
	end
end	

function UI_march:updateProgressBar()
	for i = 1, globalData.TOTAL_LEVEL do
		if self.progress[i] ~= nil then
			local num_ = self.army:getSoldierNumberByType(i)
			local per = hp.common.round(num_ / self.numList[i] * 100)
			self.progress[i]:setPercent(per)
			self.numTextList[i]:setString(tostring(num_))
			self.restNum[i]:setString(tostring(self.numList[i] - num_))
		end
	end
end

function UI_march:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "march.json")
	local content = self.wigetRoot:getChildByName("Panel_8329")
	local backGroud = self.wigetRoot:getChildByName("Panel_8303")
	self.listView = self.wigetRoot:getChildByName("ListView_8344")
	local heroInfo = player.hero.getBaseInfo()

	-- 返回
	self.goBack = content:getChildByName("ImageView_9388")

	-- 士兵数量
	self.soldierNum = content:getChildByName("Label_833")

	-- 士兵负载
	self.loadImg = content:getChildByName("ImageView_8332")
	self.loaded = content:getChildByName("Label_8332")

	-- 行军时间
	self.marchBtn = backGroud:getChildByName("ImageView_8336")
	content:getChildByName("Label_8337"):setString(hp.lang.getStrByID(1300))
	self.marchTime = content:getChildByName("ImageView_8338"):getChildByName("Label_8339")

	-- 武将头像
	self.heroImage = content:getChildByName("ImageView_9383")
	self.heroImage:loadTexture(config.dirUI.heroHeadpic .. heroInfo.sid..".png")

	-- 武将名称
	content:getChildByName("Label_8341"):setString(heroInfo.name)

	-- 全选
	self.allSelect = backGroud:getChildByName("Image_78")
	content:getChildByName("Label_83"):setString(hp.lang.getStrByID(1301))
	self.allSelect:setTag(0)

	-- 武将选择
	self.heroCheckFrame = content:getChildByName("ImageView_8342")
	self.heroCheck = self.heroCheckFrame:getChildByName("ImageView_8343")
	if heroInfo.state ~= 0 then
		self.heroAvailable = false
	elseif heroInfo.armyID ~= 0 then
		self.heroAvailable = false
	elseif self.attackType == globalData.MARCH_TYPE.REINFORCE or self.attackType == globalData.MARCH_TYPE.DONATE then
		self.heroAvailable = false
	end

	self.soldierSelect = self.listView:getChildByName("Panel_8345")	
end

function UI_march:initSoldiers()
	local soldierPanel = self.soldierSelect
	self.listView:removeAllItems()

	local num_ = 0
	for i = 1, globalData.TOTAL_LEVEL do
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
			soldierInfoPanel:getChildByName("Label_8357"):setString(player.soldierManager.getTypeName(v:getSoldierType()))

			-- 名字
			panel_:getChildByName("Label_8358"):setString(soldierInfo.name)

			-- 进度条
			local progress = panel_:getChildByName("ImageView_8359"):getChildByName("Slider_8361")
			progress:setTag(i)
			progress:addEventListenerSlider(self.sliderListener)
			self.progress[i] = progress

			-- 数量
			self.numTextList[i] = panel_:getChildByName("ImageView_8363"):getChildByName("Label_47")
			self.percentList[i] = 0
			self.numList[i] = v:getNumber()
			-- 不能超过上限
			if self.numList[i] > self.maxNumber then
				self.numList[i] = self.maxNumber
			end

			if self.numList[i] == 0 then
				self.progress[i]:setTouchEnabled(false)
			end
			self.listView:pushBackCustomItem(clonePanel)
			num_ = num_ + 1
		end
	end

	if num_ == 0 then
		self.wigetRoot:getChildByName("Panel_28"):setVisible(true)
		self.wigetRoot:getChildByName("Panel_28"):getChildByName("Label_29"):setString(hp.lang.getStrByID(5115))
		self.listView:setVisible(false)
	end
end

function UI_march:onRemove()
	self.selectClone:release()
	self.super.onRemove(self)
end	

function UI_march.openMarchUI(parent_, position_, type_, extraParam_, callBack_)
	local extra_ = extraParam_ or {}
	local ui_ = UI_march.new(position_, type_, extra_, callBack_)
	parent_:addUI(ui_)
end

-- extra temp
function UI_march:getArmyLoadedTmp()
	local loaded_ = 0
	local loadedAdd_ = nil
	if self.checked then
		loadedAdd_ = self.loadedAddWithHero
	else
		loadedAdd_ = self.loadedAdd
	end
	for i, v in ipairs(self.army.soldierList) do
		local loadByType_ = math.floor(v:getSoldierInfo().loaded * v:getNumber() * (1 + loadedAdd_[i] / 10000))
		loaded_ = loaded_ + loadByType_
	end
	return loaded_
end

function UI_march:calcMarchTimeTmp(destination_)
	local unitMarchTime_ = {}
	local loadedAdd_ = nil
	if self.checked then
		loadedAdd_ = self.speedAddWithHero
	else
		loadedAdd_ = self.speedAdd
	end
	for i, v in ipairs(self.army.soldierList) do
		if v:getNumber() ~= 0 then
			local unitTime_ = math.floor(v:getSoldierInfo().moveSpeed / (1 + loadedAdd_[i] / 10000))
			table.insert(unitMarchTime_, unitTime_)
		end
	end

	local maxTime_ = hp.common.getMaxNumber(unitMarchTime_)
	if maxTime_ == 0 then
		return 0
	end
	if maxTime_ == nil then
		return 0
	end
	local mainCityPos_ = player.serverMgr.getMyPosition()
	local distance_ = math.sqrt(math.pow(mainCityPos_.x - destination_.x, 2) + math.pow(mainCityPos_.y - destination_.y, 2))
	local costTime_ = math.floor(distance_ * maxTime_)
	return costTime_
end