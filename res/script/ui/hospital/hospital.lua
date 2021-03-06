--
-- ui/hospital/hospital.lua
-- 兵营信息
--===================================
require "ui/common/effect.lua"
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_hospital = class("UI_hospital", UI)

local costMap = {5, 4, 6, 3, 2}
local costOffSet = {0.1,0.2,0.4,0.8}
local unitGoldCost = 5

--init
function UI_hospital:init(building_)
	-- data
	-- ===============================
	self.building = building_
	self.chooseSoldier = {}	-- 选择的士兵数量
	self.restSoldier = {}	-- 剩余可治疗的士兵数量
	self.healingNumber = 0	-- 正在治疗的士兵总数
	self.healingTime = 0	-- 剩余治疗时间
	self.resource = {}		-- 剩余可用资源
	self.resourceCost = {0, 0, 0, 0, 0}	-- 治疗当前选择士兵的资源消耗
	self.showStatus = false				-- 显示状态
	self.hurtExist = false				-- 是否存在伤兵

	-- ui data
	self.labelNum = {}
	self.ImageNumRest = {}
	self.resourceText = {}
	self.resourceImg = {}

	-- ui
	-- ===============================
	self:initCallBack()

	self:initUI()
	local uiFrame = UI_fullScreenFrame.new()
	local bInfo = building_.bInfo
	uiFrame:setTopShadePosY(584)
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)	

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(self.widgetRoot)

	-- 注册消息
	self:registMsg(hp.MSG.HOSPITAL_CHOOSE_SOLDIER)
	self:registMsg(hp.MSG.HOSPITAL_HEAL_FINISH)
	self:registMsg(hp.MSG.HOSPITAL_HURT_REFRESH)
	self:registMsg(hp.MSG.RESOURCE_CHANGED)

	-- 初始化数据
	self:initData()

	hp.uiHelper.uiAdaption(self.moreInfoContainer)
	hp.uiHelper.uiAdaption(self.noHurt)
	hp.uiHelper.uiAdaption(self.soldierContainer)
	hp.uiHelper.uiAdaption(self.description)

	self:refreshSoldierShow()

	self:refreshShow()

	self:updateTrainShow()
end

function UI_hospital:refreshShow()
	self:updateSoldier()
	self:updateHeal()
	self:updateHurt()
	self:updateCost()
	self:updateButtonStatus()
end

function UI_hospital:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hospital.json")
	local content = self.widgetRoot:getChildByName("Panel_23213")

	-- 进度条
	self.loadingBack = self.widgetRoot:getChildByName("Panel_22")
	self.loadingContainer = self.widgetRoot:getChildByName("Panel_1345")
	self.loadingBarHeal = self.loadingBack:getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640")
	self.loadingContent = self.loadingContainer:getChildByName("Label_1642")
	self.loadingTime = self.loadingContainer:getChildByName("Label_1643")
	self.speedUp = self.loadingContainer:getChildByName("ImageView_1639")
	self.loadingContent:setString(hp.lang.getStrByID(1507))
	self.speedUp:addTouchEventListener(self.onSpeedUpTouched)

	-- 消耗
	local resourceList = {"", "_Copy0", "_Copy1", "_Copy2", "_Copy3"}
	for i, v in ipairs(resourceList) do
		self.resourceImg[i] = content:getChildByName("ImageView_23216"..resourceList[i])
		self.resourceText[i] = self.resourceImg[i]:getChildByName("Label_23217")
		self.resourceImg[i]:addTouchEventListener(self.onResItemTouched)
	end

	-- 上限和当前伤兵
	self.loadingBar = self.widgetRoot:getChildByName("Panel_8263"):getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640")
	self.loadingText = content:getChildByName("Label_1642")

	-- 治疗人数
	self.healNumber = content:getChildByName("ImageView_23234"):getChildByName("Label_23235")

	-- 全选
	self.allSelect = content:getChildByName("ImageView_23241")
	self.allSelect:setTag(0)
	self.allSelect:getChildByName("Label_23242"):setString(hp.lang.getStrByID(1301))

	--全选按钮闪光
	local light1 = nil
	self.light1 = light1
	self.light1 = inLight(self.allSelect:getVirtualRenderer(),1)
	self.allSelect:addChild(self.light1)
	self.light1:setVisible(false)
	
	-- 立即治愈
	self.soonHeal = content:getChildByName("ImageView_23241_Copy0")
	self.soonHeal:getChildByName("Label_23242"):setString(hp.lang.getStrByID(1502))
	self.uiDiamond = content:getChildByName("ImageView_23247"):getChildByName("Label_23249")

	-- 治疗
	self.heal = content:getChildByName("ImageView_23241_Copy1")
	self.heal:getChildByName("Label_23242"):setString(hp.lang.getStrByID(1503))
	self.healTime = content:getChildByName("ImageView_23247_Copy0"):getChildByName("Label_23249")

	--治疗按钮闪光
	local light2 = nil
	self.light2 = light2
	self.light2 = inLight(self.heal:getVirtualRenderer(),1)
	self.heal:addChild(self.light2)
	self.light2:setVisible(false)
	
	
	
	
	-- 士兵
	self.listView = self.widgetRoot:getChildByName("ListView_list")
	self.moreInfoContainer = self.listView:getChildByName("Panel_23315"):clone()
	self.moreInfoContainer:retain()
	self.listView:removeLastItem()
	self.noHurt = self.listView:getChildByName("Panel_5189"):clone()
	self.noHurt:retain()
	self.listView:removeLastItem()
	self.soldierContainer = self.listView:getChildByName("Panel_horContainer"):clone()
	self.soldierContainer:retain()
	self.listView:removeLastItem()
	self.description = self.listView:getChildByName("Panel_1953"):clone()
	self.description:retain()
	self.listView:removeLastItem()

	self.allSelect:addTouchEventListener(self.onAllSelectTouched)
	self.soonHeal:addTouchEventListener(self.onSoonHealTouched)
	self.heal:addTouchEventListener(self.onHealTouched)
end

function UI_hospital:initData()
	for i = 1, globalData.TOTAL_LEVEL do
		self.chooseSoldier[i] = 0
		self.restSoldier[i] = player.soldierManager.getHealableSoldierNum(i) - self.chooseSoldier[i]
	end 

	if player.soldierManager.getHurtArmy():getSoldierTotalNumber() - player.soldierManager.getHealingSoldierNumber() == 0 then
		self.hurtExist = false
	else
		self.hurtExist = true
	end

	self:updateResource() 
end

function UI_hospital:updateResource()
	self.resourceCost = {0, 0, 0, 0, 0}
	for j, v in ipairs(self.resourceCost) do
		for i = 1, globalData.TOTAL_LEVEL do
			local soldierInfo = player.soldierManager.getArmyInfoByType(i)	
			self.resourceCost[j] = math.floor(self.resourceCost[j] + self.chooseSoldier[i] * soldierInfo.costs[costMap[j]] * costOffSet[soldierInfo.level])
		end
	end
end

function UI_hospital:updateAvailableResource()
	for i, v in ipairs(costMap) do
		local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", v)
		self.resource[i] = player.getResource(resInfo_.code) - self.resourceCost[i]
	end
end

function UI_hospital:initCallBack()
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/hospital/hospitalInfo"
			local ui_ = UI_hospitalInfo.new(self.building)
			self:addModalUI(ui_)
		end
	end

	local function onAllSelectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			for i = 1, globalData.TOTAL_LEVEL do
				self.chooseSoldier[i] = 0
				self.restSoldier[i] = player.soldierManager.getHealableSoldierNum(i)
			end
			self:updateResource()

			if sender:getTag() == 0 then
				local notAll_ = false
				local lackIndex_ = 1
				for i = 1, globalData.TOTAL_LEVEL do
					self:updateAvailableResource()
					local MaxHealNumber_, index_ = self:MaxHealNumber(i)					
					local hurtSoldier_ = player.soldierManager.getHealableSoldierNum(i)
					if MaxHealNumber_ >= hurtSoldier_ then
						self.chooseSoldier[i] = hurtSoldier_
						self.restSoldier[i] = 0
					else
						notAll_ = true
						lackIndex_ = index_
						self.chooseSoldier[i] = MaxHealNumber_
						self.restSoldier[i] = hurtSoldier_ - MaxHealNumber_
					end
					self:updateResource()
				end
				if notAll_ then
					require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(5194), 
						hp.lang.getStrByID(5378), 
						hp.lang.getStrByID(2028), 
						hp.lang.getStrByID(5381),  
						function()
							require "ui/item/resourceItem"
							local ui  = UI_resourceItem.new(costMap[lackIndex_]-1)
							self:addUI(ui)
						end
						)
					self:addModalUI(msgBox)
				end
				sender:setTag(1)
			else
				sender:setTag(0)
			end
			self:refreshShow()
		end
	end

	local function sendHealResponse(gold_)
		local function onFastTrainResponse(status, response, tag)
			if status ~= 200 then
				return
			end

			local data = hp.httpParse(response)
			if data.result == 0 then
				if gold_ == 0 then
					if data.cd == 0 then
						player.soldierManager.healSoldierFinish(self.chooseSoldier)
					else
						local healData = {data.cd, data.cd, self.chooseSoldier[1], self.chooseSoldier[2], self.chooseSoldier[3], self.chooseSoldier[4]}
						player.soldierManager.initSoldierHealingInfo(healData)
						cdBox.initCDInfo(cdBox.CDTYPE.REMEDY, healData)
						self:updateTrainShow()
					end
				else
					player.soldierManager.healSoldierFinish(self.chooseSoldier)
				end

				self:initData()
				self:refreshShow()
				if player.soldierManager.getHurtArmy():getSoldierTotalNumber() - player.soldierManager.getHealingSoldierNumber() == 0 then
					self.hurtExist = false
					self:refreshSoldierShow()
				end
			end
		end

		local function onConfirm()
			-- start train
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 5
			if gold_ == 0 then
				oper.type = 7
			else
				oper.type = 11
			end
			oper["in"] = self.chooseSoldier[1]
			oper.an = self.chooseSoldier[2]
			oper.ca = self.chooseSoldier[3]
			oper.app = self.chooseSoldier[4]
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onFastTrainResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender)
		end

		if gold_ == 0 then
			if cdBox.getCD(cdBox.CDTYPE.REMEDY) > 0 then
				local function callBackConfirm()
					require("ui/item/speedItem")
					local ui  = UI_speedItem.new(cdBox.CDTYPE.REMEDY)
					self:addUI(ui)
					self:close()
				end
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(5156), 
					hp.lang.getStrByID(5157), 
					hp.lang.getStrByID(2414), 
					hp.lang.getStrByID(2412),  
					callBackConfirm
					)
				self:addModalUI(msgBox)
			else
				onConfirm()
			end
		else
			local diamond_ = tonumber(self.uiDiamond:getString())
			if diamond_ > player.getResource("gold") then
				local function buyDiamond()
					cclog_("购买钻石")
				end
				require("ui/msgBox/msgBox")
				UI_msgBox.showCommonMsg(self, 1)
	   		else
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(1502), 
	   				hp.lang.getStrByID(1508), 
	   				hp.lang.getStrByID(1209), 
	   				hp.lang.getStrByID(2412), 
	      			onConfirm
	   				)
	   			self:addModalUI(msgBox)
	   		end
		end		
	end

	local function onSoonHealTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			sendHealResponse(1)
		end
	end

	local function onHealTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			sendHealResponse(0)
		end
	end

	local function onSoldierTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/hospital/soldierSelect"
			self:updateAvailableResource()
			-- 还原当前士兵的资源数量
			local resource_ = {}
			local soldierInfo = player.soldierManager.getArmyInfoByType(sender:getTag())	
			for i, v in ipairs(costMap) do
				resource_[i] = self.resource[i] + self.chooseSoldier[sender:getTag()] * soldierInfo.costs[v] * costOffSet[soldierInfo.level]
			end
			local ui_ = UI_soldierHeal.new(sender:getTag(), resource_)
			self:addModalUI(ui_)
		end
	end

	local function onSpeedUpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/speedItem")
			local ui  = UI_speedItem.new(cdBox.CDTYPE.REMEDY)
			self:addUI(ui)
		end
	end

	local function onResItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/resourceItem"
			local ui  = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
		end
	end

	self.onMoreInfoTouched = onMoreInfoTouched
	self.onAllSelectTouched = onAllSelectTouched
	self.onSoonHealTouched = onSoonHealTouched
	self.onHealTouched = onHealTouched
	self.onSoldierTouched = onSoldierTouched
	self.onSpeedUpTouched = onSpeedUpTouched
	self.onResItemTouched = onResItemTouched
end

function UI_hospital:refreshSoldierShow()
	self.listView:removeAllItems()

	local description_ = self.description:clone()
	description_:getChildByName("Panel_2263"):getChildByName("Label_2264"):setString(hp.lang.getStrByID(1504))
	self.listView:pushBackCustomItem(description_)

	if self.hurtExist == false then
		local noHurt_ = self.noHurt:clone()
		noHurt_:getChildByName("Panel_5190"):getChildByName("Label_23316"):setString(hp.lang.getStrByID(1505))
		self.listView:pushBackCustomItem(noHurt_)
	else
		local container_ = self.soldierContainer:clone()
		self.listView:pushBackCustomItem(container_)
		local adampt = container_:getChildByName("Panel_adampt")
		local index = 1
		for i = 1, globalData.TOTAL_LEVEL do
			local soldierInfo_ = player.soldierManager.getArmyInfoByType(i)
			if player.soldierManager.getHurtArmy():getSoldierNumberByType(i) > 0 then

				local soldier = adampt:getChildByName(string.format("%d", index))

				-- set image
				local soldierImage = soldier:getChildByName("ImageView_soldier")
				soldierImage:loadTexture(string.format("%s%s", config.dirUI.soldier, soldierInfo_.image))

				-- set clickEvent
				soldierImage:addTouchEventListener(self.onSoldierTouched)

				-- set tag
				soldierImage:setTag(soldierInfo_.type)

				-- set name
				soldier:getChildByName("Label_name"):setString(soldierInfo_.name)

				-- get number label
				self.labelNum[soldierInfo_.type] = soldier:getChildByName("ImageView_numberbg"):getChildByName("Label_number")
				self.ImageNumRest[soldierInfo_.type] = soldier:getChildByName("ImageView_numberbg_Copy0")

				if index == 3 then
					container_ = self.soldierContainer:clone()
					self.listView:pushBackCustomItem(container_)	
					adampt = container_:getChildByName("Panel_adampt")		
					index = 1
				else
					index = index + 1
				end
			end			
		end

		-- hide redundant ui
		for i = index, 3 do
			adampt:getChildByName(string.format("%d", i)):setVisible(false)
		end

		if index == 1 then
			self.listView:removeLastItem()
		end
	end

	local moreInfo_ = self.moreInfoContainer:clone()
	local moreInfoBtn_ = moreInfo_:getChildByName("Panel_23317"):getChildByName("ImageView_23318")
	moreInfoBtn_:addTouchEventListener(self.onMoreInfoTouched)
	moreInfoBtn_:getChildByName("Label_23319"):setString(hp.lang.getStrByID(1030))
	self.listView:pushBackCustomItem(moreInfo_)
end

function UI_hospital:updateCost()
	self:updateResource()

	for j = 1, 5 do
		local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", costMap[j])
		self.resourceText[j]:setString(hp.common.changeNumUnit(self.resourceCost[j]).."/"..hp.common.changeNumUnit(player.getResource(resInfo_.code)))
	end

	local res_ = self.resourceCost
	local time_ = self:getHealingTime()

	-- 立即训练钻石消耗
	local resource_ = {0,res_[5],res_[4],res_[2],res_[1],res_[3]}	
	self.uiDiamond:setString(player.quicklyMgr.getDiamondCost(resource_, time_))
end

function UI_hospital:updateHurt()
	local buildList_ = player.buildingMgr.getBuildingsBySid(self.building.build.sid)
	local num_ = 0
	for i, v in ipairs(buildList_) do
		num_ = num_ + hp.gameDataLoader.getBuildingInfoByLevel("hospital", v.lv, "woundedSoldierMax", 0)
	end
	local hurtNum_ = player.soldierManager.getHurtArmy():getSoldierTotalNumber()
	local percent_ = 0
	if num_ ~= 0 then
		percent_ = (hurtNum_ / num_) * 100
	end
	self.loadingText:setString(hurtNum_.."/"..num_)
	self.loadingBar:setPercent(percent_)
end

function UI_hospital:updateHeal()
	local num_ = 0
	for i, v in ipairs(self.chooseSoldier) do
		num_ = num_ + v
	end
	self.healingNumber = num_
	self.healNumber:setString(num_)
end

function UI_hospital:updateSoldier()
	if self.hurtExist == false then
		self.allSelect:setTouchEnabled(false)
		self.allSelect:loadTexture(config.dirUI.common.."button_gray.png")
		self.light1:setVisible(false)
		return
	else
		self.allSelect:setTouchEnabled(true)
		self.allSelect:loadTexture(config.dirUI.common.."button_blue.png")
		self.light1:setVisible(true)
	end

	for i, v in ipairs(self.restSoldier) do
		if self.labelNum[i] ~= nil then
			self.labelNum[i]:setString(v)
		end
	end

	for i, v in ipairs(self.chooseSoldier) do		
		if self.ImageNumRest[i] ~= nil then
			if v == 0 then
				self.ImageNumRest[i]:setVisible(false)
			else
				self.ImageNumRest[i]:setVisible(true)
				self.ImageNumRest[i]:getChildByName("Label_number"):setString(v)
			end
		end
	end
end

function UI_hospital:updateButtonStatus()
	if self.healingNumber == 0 then
		self.heal:loadTexture(config.dirUI.common.."button_gray.png")
		self.soonHeal:loadTexture(config.dirUI.common.."button_gray.png")
		self.heal:setTouchEnabled(false)
		self.soonHeal:setTouchEnabled(false)
		self.healTime:setString(hp.datetime.strTime(self:getHealingTime()))
		self.light2:setVisible(false)
	else
		self.heal:loadTexture(config.dirUI.common.."button_blue.png")
		self.soonHeal:loadTexture(config.dirUI.common.."button_blue.png")
		self.heal:setTouchEnabled(true)
		self.soonHeal:setTouchEnabled(true)
		self.healTime:setString(hp.datetime.strTime(self:getHealingTime()))
		self.light2:setVisible(true)
	end
end

function UI_hospital:getHealingTime()
	local time_ = 0
	for i = 1, globalData.TOTAL_LEVEL do
		local soldierInfo = player.soldierManager.getArmyInfoByType(i)
		if soldierInfo.level > 1 then
			time_ = time_ + soldierInfo.cd * self.chooseSoldier[i] * soldierInfo.remedyCDRate / 100
		end
	end
	self.healingTime = math.floor(time_)
	if self.healingTime < 0 then
		self.healingTime = 0
	end
	return self.healingTime
end

function UI_hospital:onSoldierSelected(type_, num_)
	self.chooseSoldier[type_] = num_
	self.restSoldier[type_] = player.soldierManager.getHealableSoldierNum(type_) - num_
	self:refreshShow()
end

function UI_hospital:onSoldierHealingFinish()
	self:updateHurt()
end

function UI_hospital:onHurtSoldierRefresh()
	self:updateHurt()
	if self.hurtExist == false then
		self.hurtExist = true
		self:refreshSoldierShow()
	end

	for i = 1, globalData.TOTAL_LEVEL do
		self.restSoldier[i] = player.soldierManager.getHealableSoldierNum(i) - self.chooseSoldier[i]
	end

	self:updateSoldier()
end

function UI_hospital:onMsg(msg_, param_)
	if msg_ == hp.MSG.HOSPITAL_CHOOSE_SOLDIER then
		self:onSoldierSelected(param_[1], param_[2])
	elseif msg_ == hp.MSG.HOSPITAL_HEAL_FINISH then
		self:onSoldierHealingFinish()
		self:updateTrainShow()
	elseif msg_ == hp.MSG.HOSPITAL_HURT_REFRESH then
		self:onHurtSoldierRefresh()
	elseif msg_ == hp.MSG.RESOURCE_CHANGED then
		self:updateCost()
	end
end

function UI_hospital:MaxHealNumber(type_)
	local maxTrainNum = {}

	-- resource limit
	local soldierInfo = player.soldierManager.getArmyInfoByType(type_)
	for i = 1, table.getn(self.resource) do
		if soldierInfo.costs[costMap[i]] ~= 0 then
			maxTrainNum[i] = math.floor(self.resource[i]/soldierInfo.costs[costMap[i]]/costOffSet[soldierInfo.level])
		end
	end

	local min, index_ = hp.common.getMinNumber(maxTrainNum)
	return min, index_
end

function UI_hospital:onRemove()
	self.moreInfoContainer:retain()
	self.noHurt:retain()
	self.soldierContainer:retain()
	self.description:retain()
	self.super.onRemove(self)
end

function UI_hospital:heartbeat(dt_)
	local healingInfo_ = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY)
	if healingInfo_ ~= nil then
		if healingInfo_.cd > 0 then
			self:setShowStatus(true)
			self:updateCDTime(healingInfo_)
		else
			self:setShowStatus(false)
		end
	else
		self:setShowStatus(false)
	end
end

function UI_hospital:setShowStatus(show_)
	if show_ == self.showStatus then
		return
	end

	self.showStatus = show_
	if show_ == true then
		self.loadingContainer:setVisible(true)
		self.loadingBack:setVisible(true)
		local size_ = self.listView:getSize()
		size_.height = size_.height - self.loadingContainer:getSize().height
		self.listView:setSize(size_)
	else
		self.loadingContainer:setVisible(false)
		self.loadingBack:setVisible(false)
		local size_ = self.listView:getSize()
		size_.height = size_.height + self.loadingContainer:getSize().height
		self.listView:setSize(size_)
	end
end

function UI_hospital:updateCDTime(info_)
	local healingInfo_ = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY)
	self.loadingTime:setString(hp.datetime.strTime(healingInfo_.cd))
	local percent_ = 100 - healingInfo_.cd / healingInfo_.total_cd * 100
	self.loadingBarHeal:setPercent(percent_)
end

function UI_hospital:updateTrainShow()
	local healingInfo_ = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY)
	if healingInfo_ ~= nil then
		if healingInfo_.cd > 0 then
			self:setShowStatus(true)
			self:updateCDTime(healingInfo_)
		else
			self:setShowStatus(false)
		end
	else
		self:setShowStatus(false)
	end
end