--
-- ui/bigMap/myArmyCamp.lua
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
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5148), tileInfo_.position)

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
			hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, data.army)
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
			end
			require "ui/common/successBox"
			local box_ = UI_successBox.new(hp.lang.getStrByID(5108), hp.lang.getStrByID(5109), callBackConfirm)
 			self:addModalUI(box_)
		end
	end

	local function OnViewTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
		end
	end

	self.backHome:addTouchEventListener(OnBackHomeTouched)

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
	self.kindom = content:getChildByName("Label_13787_Copy3")
	self.position = content:getChildByName("Label_13787_Copy4")

	-- 返回
	self.backHome = content:getChildByName("ImageView_13793")
	self.backHome:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1302))

	-- 查看信息
	self.view = content:getChildByName("ImageView_13793_Copy0")
	self.view:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1316))
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
	self.kindom:setString(hp.lang.getStrByID(1310)..": "..hp.lang.getStrByID(5147))
	self.position:setString(hp.lang.getStrByID(1204)..string.format(": K:%s X:%d Y:%d", "2-2", player.getPosition().x, player.getPosition().y))
	-- 头像
	self.image:loadTexture(config.dirUI.heroHeadpic..self.armyInfo.image..".png")
end