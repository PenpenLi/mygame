--
-- ui/bigMap/army/myArmy.lua
-- 点击自己部队弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_myArmy = class("UI_myArmy", UI)

--init
function UI_myArmy:init(tileInfo_)
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, player.getName())

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
			
		end
		self:close()
	end

	local function OnBackHomeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 6
			oper.type = 4
			oper.id = tileInfo_.objInfo.armyInfo.id
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(OnCallBackRespond)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	self.backHome:addTouchEventListener(OnBackHomeTouched)

	-- 界面刷新
	self:initFirstShow()
end

function UI_myArmy:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "myArmy.json")
	local content = self.wigetRoot:getChildByName("Panel_13854")

	self.des = content:getChildByName("Label_13859")
	self.arriving = content:getChildByName("Label_13860")
	self.back = content:getChildByName("Label_13867")

	-- 召回
	self.backHome = content:getChildByName("ImageView_13861_Copy0")
	self.backHome:getChildByName("Label_13862"):setString(hp.lang.getStrByID(1302))
end

function UI_myArmy:initFirstShow()
	-- 目的地
	local armyInfo_ = self.tileInfo.objInfo.armyInfo
	local myPos = player.serverMgr.getMyPosition()
	if ((armyInfo.pEnd.x == myPos.x) and (armyInfo.y == myPos.y)) then
		-- 返回
		self.des:setVisible(false)
		self.arriving:setVisible(false)
		self.back:setVisible(true)
		self.back:setString(hp.lang.getStrByID(1305))
	elseif 
	end
end