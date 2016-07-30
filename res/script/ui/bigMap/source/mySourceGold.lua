--
-- ui/bigMap/source/mySourceGold.lua
-- 点击资源弹出UI，采集钻石
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_mySourceGold = class("UI_mySourceGold", UI)

--init
function UI_mySourceGold:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_
	self.totalRes = self.tileInfo.objInfo.resNum
	self.resourceInfo = hp.gameDataLoader.getInfoBySid("resources", tileInfo_.objInfo.sid)

	-- ui
	-- ===============================
	self:initUI()	
	local popFrame = UI_popFrame.new(self.wigetRoot, self.resourceInfo.name, tileInfo_.position, self.resourceInfo.name)

	-- call back
	local function OnInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/source/sourceInformation"
			ui_ = UI_sourceInformation.new(self.tileInfo)
			self:addModalUI(ui_)
		end
	end

	local function sendBackHomeCmd()
		local function OnCallBackRespond(status, response, tag)
			if status ~= 200 then
				return
			end

			local data = hp.httpParse(response)
			if data.result == 0 then
				if data.army ~= nil then
					hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, {army=data.army})
				end
				-- self:showLoading(player.marchMgr.sendCmd(8))
				player.marchMgr.sendCmd(8)
				self:close()
			end
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 6
		oper.type = 4
		oper.id = self.tileInfo.objInfo.armyInfo.id
		oper.gold = 0
		oper.sid = 0
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(OnCallBackRespond)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
		self:showLoading(cmdSender)
	end

	local function onCallBackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(5108), 
   				hp.lang.getStrByID(5109), 
   				hp.lang.getStrByID(1209), 
   				hp.lang.getStrByID(2412), 
      			sendBackHomeCmd
   				)
   			self:addModalUI(msgBox)
		end
	end
	self.onCallBackTouched = onCallBackTouched

	self.information:addTouchEventListener(OnInfoTouched)
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- 初始显示
	self:initShow()
end

function UI_mySourceGold:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mySourceGold.json")
	local content = self.wigetRoot:getChildByName("Panel_12334")

	-- 描述
	content:getChildByName("Label_13757"):setString(hp.lang.getStrByID(1224))
	content:getChildByName("Label_13757_0"):setString(hp.lang.getStrByID(5506))

	-- 数量
	content:getChildByName("Label_13758"):setString(hp.lang.getStrByID(1317))
	self.resNum = content:getChildByName("Label_13760")
	self.resNum:setString(self.totalRes)

	-- 占领者
	content:getChildByName("Label_13761"):setString(hp.lang.getStrByID(1226)..":")
	self.ownerImage = content:getChildByName("ImageView_13762")
	self.owner = content:getChildByName("Label_13763")

	-- 采集进度条
	self.proContainer = self.wigetRoot:getChildByName("Panel_10919"):getChildByName("ImageView_1644")
	self.loadingBar = self.proContainer:getChildByName("LoadingBar_1640")
	self.proText = content:getChildByName("Label_1643")

	-- 下一个金币进度条
	self.nextGoldBar = self.wigetRoot:getChildByName("Panel_10919"):getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
	content:getChildByName("Label_1643_0"):setString(hp.lang.getStrByID(5507))

	-- 提示
	content:getChildByName("Label_13764"):setString(hp.lang.getStrByID(1225))

	-- 信息
	self.information = content:getChildByName("ImageView_13775")
	self.information:getChildByName("Label_13776"):setString(hp.lang.getStrByID(5154))

	-- 占领
	self.occupy = content:getChildByName("ImageView_13777")	
end

function UI_mySourceGold:initShow()
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	if armyInfo_ == nil then
		self.owner:setString(hp.lang.getStrByID(5183))
		self.proContainer:setVisible(false)
		self.occupy:getChildByName("Label_13778"):setString(hp.lang.getStrByID(1201))
		cclog_("there should be a troop on the resource!!!")
		self:close()
	elseif armyInfo_.pid == player.getID() then
		-- 被自己占领
		local name_ = player.getName()
		if player.getAlliance():getUnionID() ~= 0 then
			name_ = hp.lang.getStrByID(21)..player.getAlliance():getBaseInfo().name..hp.lang.getStrByID(22)..name_
		end
		self.owner:setString(name_)
		
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
		local per = dt / self.totalTime * 100
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
		self:tickUpdateInfo()
	end
end

function UI_mySourceGold:tickUpdateInfo()
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	if armyInfo_ == nil then
		return
	end

	local dt_ = player.getServerTime() - armyInfo_.tStart
	if dt_ < 0 then
		dt_ = 0
	elseif dt_ > self.totalTime then
		dt_ = self.totalTime
	end

	local pointNum_ = self.loaded * dt_ / self.totalTime
	local num_ = math.floor(pointNum_)
	local per = num_ / self.loaded * 100
	if num_ < 0 then
		num_ = 0
	end

	self.loadingBar:setPercent(per)
	self.proText:setString(num_.."/"..self.loaded)
	self.resNum:setString(tostring(self.totalRes - num_))

	-- 采集中
	local per_ = (pointNum_ - num_) * 100
	self.nextGoldBar:setPercent(per_)
end

function UI_mySourceGold:heartbeat(dt)
	if not self.proContainer:isVisible() then
		return
	end

	self:tickUpdateInfo()
end

function UI_mySourceGold:getType()
	return globalData.ARMY_BELONG.ME
end

function UI_mySourceGold:updateInfo()
	self:tickUpdateInfo()
end

function UI_mySourceGold:onRemove()
	hp.msgCenter.sendMsg(hp.MSG.SOURCEUI_CLOSE)
	self.super.onRemove(self)
end