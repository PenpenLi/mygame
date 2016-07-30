--
-- ui/bigMap/camp/myArmyCamp.lua
-- 自己营地弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_myArmyCamp = class("UI_myArmyCamp", UI)

--init
function UI_myArmyCamp:init(tileInfo_)
	-- ===============================
	self.tileInfo = tileInfo_
	self.armyInfo = self.tileInfo.objInfo.armyInfo

	-- ui
	-- ===============================
	self:initUI()
	
	local name_ = hp.lang.getStrByID(5304)
	if self.armyInfo.unionID == 0 then
		name_ = name_..self.armyInfo.name
	else
		name_ = name_..hp.lang.getStrByID(21)..self.armyInfo.unionName..hp.lang.getStrByID(22)..self.armyInfo.name
	end
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5148), tileInfo_.position, name_)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function OnCallBackRespond(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			-- self:showLoading(player.marchMgr.sendCmd(8))
			player.marchMgr.sendCmd(8)
			hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, {army=data.army})
		end
		self:close()
	end

	local function OnBackHomeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function callBackConfirm()
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 6
				oper.type = 4
				oper.sid = 0
				oper.gold = 0
				oper.id = tileInfo_.objInfo.armyInfo.id
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(OnCallBackRespond)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(5108), 
   				hp.lang.getStrByID(5109), 
   				hp.lang.getStrByID(1209), 
   				hp.lang.getStrByID(2412), 
      			callBackConfirm
   				)
   			self:addModalUI(msgBox)
		end
	end

	local function OnViewTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.armyInfo.pid, self.armyInfo.serverID)
			self:addUI(ui_)
			self:close()
		end
	end

	self.backHome:addTouchEventListener(OnBackHomeTouched)
	self.view:addTouchEventListener(OnViewTouched)

	-- 初始显示
	self:initShow()
end

function UI_myArmyCamp:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "myArmyCamp.json")
	local content = self.wigetRoot:getChildByName("Panel_13785_Copy0")

	-- 头像
	self.image = content:getChildByName("ImageView_13786")

	-- 描述
	self.name = content:getChildByName("Label_13787_Copy0")
	self.power = content:getChildByName("Label_13787")
	self.kill = content:getChildByName("Label_13787_Copy1")
	self.alliance = content:getChildByName("Label_13787_Copy2")
	self.kingdom = content:getChildByName("Label_13787_Copy3")
	self.position = content:getChildByName("Label_13787_Copy4")

	-- 返回
	self.backHome = content:getChildByName("ImageView_13793")
	self.backHome:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1302))

	-- 查看信息
	self.view = content:getChildByName("ImageView_13793_Copy0")
	self.view:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1312))
end

function UI_myArmyCamp:initShow()
	self.name:setString(hp.lang.getStrByID(1307)..": "..player.getName())
	self.power:setString(string.format(hp.lang.getStrByID(2032), player.getPower()))
	self.kill:setString(hp.lang.getStrByID(1308)..": "..self.armyInfo.kill)
	if player.getAlliance():getUnionID() == 0 then
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..hp.lang.getStrByID(5147))
	else
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..player.getAlliance():getBaseInfo().name)
	end
	self.kingdom:setString(hp.lang.getStrByID(5494)..": "..player.serverMgr.getCountryByPos(self.tileInfo.position))
	self.position:setString(player.serverMgr.formatMyPosition())
	-- 头像
	self.image:loadTexture(config.dirUI.heroHeadpic..self.armyInfo.image..".png")
end