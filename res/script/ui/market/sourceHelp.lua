--
-- ui/market/sourceHelp.lua
-- 资源援助
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_sourceHelp = class("UI_sourceHelp", UI)

local resouceMap = {2, 3, 4, 5, 6}
local resName_ = {"silver", "food", "wood", "rock", "mine"}

--init
function UI_sourceHelp:init(playerID_)
	-- data
	-- ===============================
	self.percent = {}
	self.resNumber = {}	-- 资源总量
	self.resNumLoaded = {} -- 资源可携带最大量
	self.loaded = 0	-- 总负载
	self.totalNumber = 0
	self.taxRateData = 0
	self.taxData = 0
	self.playerID = playerID_
	self.targetMem = player.getAlliance():getMemberByID(self.playerID)

	-- ui data
	self.resource = {}	-- 顶部UI
	self.slider = {}
	self.resouceNum = {} -- 输入框

	self:initData()

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(1701))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.item)

	self:initShow()
end

function UI_sourceHelp:initData()
	-- resource
	for i = 1, 5 do
		local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", resouceMap[i])
		if resInfo_ ~= nil then
			self.resNumber[i] = player.getResource(resInfo_.code)
			self.resNumLoaded[i] = self.resNumber[i]
		end
	end

	-- 运送速度加成
	local unitMarchTime_ = {}
	for i = 1, globalData.TOTAL_LEVEL do
		local info_ = player.soldierManager.getArmyInfoByType(i)
		local unitTime_ = player.helper.getResourceTransTime(info_.moveSpeed, i)
		table.insert(unitMarchTime_, unitTime_)
	end

	local speed_ = hp.common.getMaxNumber(unitMarchTime_)

	-- 市场信息	
	local market_ = player.buildingMgr.getMaxLvBuildingBySid(1015)
	if market_ ~= nil then
		self.taxRateData = hp.gameDataLoader.getBuildingInfoByLevel("market", market_.lv, "taxRate", 0)
		self.loaded = hp.gameDataLoader.getBuildingInfoByLevel("market", market_.lv, "donateMax", 0)
	end

	for i = 1, 5 do
		if self.resNumLoaded[i] > self.loaded then
			self.resNumLoaded[i] = self.loaded
		end
	end

	local destination_ = self.targetMem:getPosition()
	local mainCityPos_ = player.serverMgr.getMyPosition()
	local distance_ = math.sqrt(math.pow(mainCityPos_.x - destination_.x, 2) + math.pow(mainCityPos_.y - destination_.y, 2))
	self.costTime = distance_ * speed_

	-- 跨服
	if self.targetMem:getPosition().k ~= player.serverMgr.getMyPosServer().sid then
		self.myServer = false
	else
		self.myServer = true
	end
end

function UI_sourceHelp:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "sourceHelp.json")
	self.content = self.widgetRoot:getChildByName("Panel_29831")

	-- 税率
	self.taxRate = self.content:getChildByName("Label_29832")
	self.tax = self.content:getChildByName("ImageView_29833"):getChildByName("Label_29834")

	-- 资源上限
	self.source = self.content:getChildByName("ImageView_29833_Copy0"):getChildByName("Label_29834")
	self.content:getChildByName("Label_29832_Copy0"):setString(hp.lang.getStrByID(1702))

	self.content:getChildByName("Label_29838"):setString(hp.lang.getStrByID(1700))

	self.helpBtn = self.content:getChildByName("ImageView_20457_Copy0")
	self.helpBtn:getChildByName("Label_20458"):setString(hp.lang.getStrByID(5214))
	self.helpBtn:addTouchEventListener(self.onHelpTouched)
	self.time = self.helpBtn:getChildByName("ImageView_20459"):getChildByName("Label_20460")
	if not self.myServer then
		self.time:setString(hp.lang.getStrByID(5516))
	else
		self.time:setString(hp.datetime.strTime(self.costTime))
	end

	self.listView = self.widgetRoot:getChildByName("ListView_8344")
	local sourceContent = self.listView:getChildByName("Panel_27745"):getChildByName("Panel_29802")
	self.resource[1] = sourceContent:getChildByName("Panel_coin"):getChildByName("Label_cost")
	self.resource[2] = sourceContent:getChildByName("Panel_food"):getChildByName("Label_cost")
	self.resource[3] = sourceContent:getChildByName("Panel_wood"):getChildByName("Label_cost")
	self.resource[4] = sourceContent:getChildByName("Panel_stone"):getChildByName("Label_cost")
	self.resource[5] = sourceContent:getChildByName("Panel_iron"):getChildByName("Label_cost")

	self.item = self.listView:getChildByName("Panel_8345"):clone()
	self.item:retain()
	self.listView:removeLastItem()
end

function UI_sourceHelp:onRemove()
	self.item:release()
	self.super.onRemove(self)
end

function UI_sourceHelp:initShow()
	for i = 1, 5 do
		local item_ = self.item:clone()
		local content_ = item_:getChildByName("Panel_8351")
		local resInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", resouceMap[i])
		if resInfo_ ~= nil then
			-- 图片
			content_:getChildByName("ImageView_29818"):loadTexture(config.dirUI.common..resInfo_.imageBig)
			-- 名称
			content_:getChildByName("Label_8358"):setString(resInfo_.name)
			-- 滑动条
			self.slider[i] = content_:getChildByName("ImageView_8359"):getChildByName("Slider_8361")
			self.slider[i]:setTag(i)
			self.slider[i]:addEventListenerSlider(self.onSliderPercentChange)
			if self.resNumLoaded[i] == 0 then
				self.slider[i]:setTouchEnabled(false)
			end
			-- 资源数
			self.resouceNum[i] = content_:getChildByName("ImageView_8363"):getChildByName("TextField_9428")
			self.resouceNum[i]:setTag(i)
		end
		self.resource[i]:setString(tostring(self.resNumber[i]))
		self.listView:pushBackCustomItem(item_)
	end

	self.taxRate:setString(string.format(hp.lang.getStrByID(1703), self.taxRateData))
	self.source:setString(string.format("0/%d", self.loaded))
end

function UI_sourceHelp:initCallBack()
	-- 改变某种资源
	local function changeResource(type_, num_, change_)
		-- 文字
		self.resouceNum[type_]:setString(tostring(num_))

		-- 进度条
		if change_ then
			local per_ = num_ / self.resNumLoaded[type_] * 100
			self.slider[type_]:setPercent(per_)
		end
	end

	local function onSliderPercentChange(sender, eventType)
		local tag_ = sender:getTag()
		local per = sender:getPercent()
		if self.percent[tag_] == per then
			return
		end
		local changeOtherRes_ = false
		self.percent[tag_] = per

		-- update resource number
		local restNum_ = self.loaded - self.totalNumber + tonumber(self.resouceNum[tag_]:getString())
		local resNum = hp.common.round(self.resNumLoaded[tag_] * per / 100)
		if resNum > self.loaded then
			resNum = self.loaded
			self.percent[tag_] = resNum / self.resNumLoaded[tag_] * 100
			sender:setPercent(self.percent[tag_])
		end

		if resNum > restNum_ then
			changeOtherRes_ = true
		end

		local delta = resNum - tonumber(self.resouceNum[tag_]:getString())
		self.resouceNum[tag_]:setString(tostring(resNum))

		-- update tax
		self.totalNumber = self.totalNumber + delta
		local restNumber_ = 0
		if self.totalNumber > self.loaded then
			self.totalNumber = self.loaded
		end
		-- 剩余可分配部分
		restNumber_ = self.loaded - resNum
		self.source:setString(string.format("%d/%d", self.totalNumber, self.loaded))
		self.taxData = hp.common.round(self.totalNumber * self.taxRateData / 100)
		self.tax:setString(tostring(self.taxData))

		-- update other resource
		if changeOtherRes_ == true then
			local restTotal_ = 0
			for i = 1, 5 do
				if i ~= tag_ then
					restTotal_ = restTotal_ + tonumber(self.resouceNum[i]:getString())
				end
			end

			if restTotal_ ~= 0 then
				local index_ = 1
				local used_ = 0
				for i = 1, 5 do
					if i ~= tag_ then
						local per_ = tonumber(self.resouceNum[i]:getString()) / restTotal_
						used_ = used_ + math.floor(restNumber_ * per_)
						changeResource(i, math.floor(restNumber_ * per_), true)
						index_ = index_ + 1
					end
				end
				-- 补全
				changeResource(tag_, self.loaded - used_, false)								
			else
				for i = 1, 5 do
					if i ~= tag_ then
						changeResource(i, 0, true)
					end
				end
			end			
		end

		-- update button
		if self.totalNumber > 0 then
			self.helpBtn:loadTexture(config.dirUI.common.."button_blue.png")
			self.helpBtn:setTouchEnabled(true)
		else
			self.helpBtn:loadTexture(config.dirUI.common.."button_gray.png")
			self.helpBtn:setTouchEnabled(false)
		end
	end

	local function onHelpRespond(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			local total_ = 0
			for i, v in ipairs(resName_) do 
				local res_ = tonumber(self.resouceNum[i]:getString())
				player.expendResource(resName_[i], res_)
				total_ = res_ + total_
			end
			Scene.showMsg({1006, total_})
			self:close()
		end
	end

	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			if not self.myServer then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5516), hp.lang.getStrByID(5518), nil)
      			self:addModalUI(box_)
			elseif self.costTime > 3600 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5076), hp.lang.getStrByID(5075), nil)
      			self:addModalUI(box_)
				return 
			end
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 6
			oper.type = 5		
			cclog_(self.playerID)
			oper.x = self.targetMem:getPosition().x
			oper.y = self.targetMem:getPosition().y
			oper.k = self.targetMem:getPosition().k
			for i, v in ipairs(resName_) do
				oper[resName_[i]] = tonumber(self.resouceNum[i]:getString())
				cclog_(resName_[i])
			end
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onHelpRespond)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	self.onSliderPercentChange = onSliderPercentChange
	self.onHelpTouched = onHelpTouched
end