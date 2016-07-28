--
-- ui/bigMap/UISource.lua
-- 点击资源弹出UI 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_source = class("UI_source", UI)

local imageList = {"gold.png", "silver.png", "food.png", "wood.png", "rock.png", "mine.png"}

--init
function UI_source:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.totalRes = self.tileInfo.objInfo.resNum
	self.resourceInfo = hp.gameDataLoader.getInfoBySid("resources", tileInfo_.objInfo.sid)

	-- ui
	-- ===============================
	self:initUI()	
	local popFrame = UI_popFrame.new(self.wigetRoot, self.resourceInfo.name, tileInfo_.position)

	-- call back
	local function OnInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/source/sourceInformation"
			ui_ = UI_sourceInformation.new(self.tileInfo)
			self:addModalUI(ui_)
		end
	end

	local function OnOccupyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/march/march"
			UI_march.openMarchUI(self, tileInfo_.position, 3)
			self:close()
		end
	end

	local function sendBackHomeCmd(gold_, id_, sid_)
		local function OnCallBackRespond(status, response, tag)
			if status ~= 200 then
				return
			end

			local data = hp.httpParse(response)
			if data.result == 0 then
				if tag == 1 then -- 消耗道具
					player.expendItem(sid_, 1)
				elseif tag == 2 then -- 消耗元宝
					player.expendResource("gold", gold_)
				end				
				if data.army ~= nil then
					hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, data.army)
				end
				self:close()
			end
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 6
		oper.type = 4
		oper.id = id_
		oper.gold = gold_
		oper.sid = sid_
		local tag_ = 1
		if oper.gold == 0 then
			tag_ = 1
		else
			tag_ = 2
		end
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(OnCallBackRespond)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
	end

	local function callBackConfirm(gold_, param_)
		sendBackHomeCmd(gold_, param_.param, 23251)
	end

	local function onCallBackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/buyAndUseItemPop"
			ui_ = UI_buyAndUseItem.new(23251, 1, callBackConfirm, {param = sender:getTag()})
			self:addModalUI(ui_)
		end
	end
	self.onCallBackTouched = onCallBackTouched
	self.OnOccupyTouched = OnOccupyTouched

	self.information:addTouchEventListener(OnInfoTouched)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- 初始显示
	self:initShow()
end

function UI_source:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "source.json")
	local content = self.wigetRoot:getChildByName("Panel_12334")

	-- 描述
	content:getChildByName("Label_13757"):setString(hp.lang.getStrByID(1224))

	-- 数量
	content:getChildByName("Label_13758"):setString(hp.lang.getStrByID(1317))
	content:getChildByName("ImageView_13759"):loadTexture(config.dirUI.common..imageList[self.resourceInfo.growth+1])
	self.resNum = content:getChildByName("Label_13760")
	self.resNum:setString(self.totalRes)

	-- 占领者
	content:getChildByName("Label_13761"):setString(hp.lang.getStrByID(1226)..":")
	self.ownerImage = content:getChildByName("ImageView_13762")
	self.owner = content:getChildByName("Label_13763")

	-- 采集进度条
	self.proContainer = content:getChildByName("ImageView_1644")
	self.loadingBar = self.proContainer:getChildByName("LoadingBar_1640")
	self.proText = self.loadingBar:getChildByName("ImageView_1641"):getChildByName("Label_1643")
	self.loadingBar:getChildByName("ImageView_1641"):getChildByName("ImageView_13774"):loadTexture(config.dirUI.common..imageList[self.resourceInfo.growth+1])

	-- 提示
	content:getChildByName("Label_13764"):setString(hp.lang.getStrByID(1225))

	-- 信息
	self.information = content:getChildByName("ImageView_13775")
	self.information:getChildByName("Label_13776"):setString(hp.lang.getStrByID(1303))

	-- 占领
	self.occupy = content:getChildByName("ImageView_13777")	
end

function UI_source:initShow()
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	if armyInfo_ == nil then
		self.owner:setString(hp.lang.getStrByID(5183))
		self.proContainer:setVisible(false)
		self.occupy:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1201))
		self.occupy:addTouchEventListener(self.OnOccupyTouched)
	elseif armyInfo_.pid == player.getID() then
		-- 被自己占领
		self.owner:setString(player.getName())
		local dt = player.getServerTime() - armyInfo_.tStart
		self.totalTime = armyInfo_.tEnd - armyInfo_.tStart
		if dt > self.totalTime then
			dt = self.totalTime
		end

		local loaded_ = math.floor(armyInfo_.loaded / self.resourceInfo.pickupRate)
		if loaded_ > self.totalRes then
			loaded_ = self.totalRes
		end
		self.loaded = loaded_
		local num_ = math.floor(loaded_ * dt / self.totalTime)
		local per = math.floor(dt / self.totalTime * 100)
		self.loadingBar:setPercent(per)
		self.proText:setString(num_.."/"..loaded_)
		self.occupy:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1302))
		self.occupy:setTag(armyInfo_.id)
		self.occupy:addTouchEventListener(self.onCallBackTouched)
		if player.getAlliance():getUnionID() ~= 0 then
			local rank_ = player.getAlliance():getMyUnionInfo():getRank()
			rankInfo_ = hp.gameDataLoader.getInfoBySid("unionRank", rank_)
			self.ownerImage:setVisible(true)
			self.ownerImage:loadTexture(config.dirUI.common..rankInfo_.image)
		end
	end
end

function UI_source:heartbeat(dt)
	if not self.proContainer:isVisible() then
		return
	end

	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	if armyInfo_ == nil then
		return
	end

	if self.loadingBar:getPercent() == 100 then
		self.owner:setString(hp.lang.getStrByID(5183))
		self.proContainer:setVisible(false)
		self.occupy:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1201))
		self.occupy:addTouchEventListener(self.OnOccupyTouched)
		self.ownerImage:setVisible(false)
	end

	local dt_ = player.getServerTime() - armyInfo_.tStart
	if dt_ > self.totalTime then
		dt_ = self.totalTime
	end

	local num_ = math.floor(self.loaded * dt_ / self.totalTime)
	local per = math.floor(dt_ / self.totalTime * 100)

	self.loadingBar:setPercent(per)
	self.proText:setString(num_.."/"..self.loaded)
	self.resNum:setString(tostring(self.totalRes - num_))
end