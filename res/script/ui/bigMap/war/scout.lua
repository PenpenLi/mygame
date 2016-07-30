--
-- ui/bigMap/war/scout.lua
-- 侦察界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_scout = class("UI_scout", UI)

local SCOUT_COST = 1000
local SCOUT_SPEED = 1

--init
function UI_scout:init(position_, name_)
	-- data
	-- ===============================
	self.position = position_
	self.name = name_

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1313))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function onCancelTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function onScoutTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function onHttpRespond(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					if data.army ~= nil then
						-- 重新请求行军信息
						-- self:showLoading(player.marchMgr.sendCmd(8),sender)
						player.marchMgr.sendCmd(8)
						hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, {army=data.army})
						self:closeAll()
					end
				end
			end

			if player.getResource("silver") < SCOUT_COST then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5194), "", nil)
      			self:addModalUI(box_)
      		else
				local oper = {}
				local cmdData={operation={}}
				oper.channel = 6
				oper.type = 8				
				oper.x = self.position.x
				oper.y = self.position.y
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpRespond)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end
		end
	end

	self.cancel_:addTouchEventListener(onCancelTouched)
	self.scout:addTouchEventListener(onScoutTouched)
end

function UI_scout:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "scout.json")
	local content_ = self.wigetRoot:getChildByName("Panel_13785_Copy0")

	-- content_:getChildByName("Label_13787_Copy0"):setString(hp.lang.getStrByID(1204))

	content_:getChildByName("Label_13787"):setString(player.serverMgr.formatPosition(self.position))

	-- 描述
	content_:getChildByName("Label_13787_Copy1"):setString(hp.lang.getStrByID(5189))

	-- 侦察消耗
	content_:getChildByName("Label_13787_Copy2"):setString(hp.lang.getStrByID(5190))

	content_:getChildByName("ImageView_gold"):getChildByName("Label_goldCost"):setString(SCOUT_COST)

	-- 提示
	content_:getChildByName("Label_13844"):setString(hp.lang.getStrByID(5191))

	-- 取消
	self.cancel_ = content_:getChildByName("ImageView_13793")
	self.cancel_:getChildByName("Label_13795"):setString(hp.lang.getStrByID(2412))

	-- 侦查
	self.scout = content_:getChildByName("ImageView_13793_0")
	self.scout:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1313))

	local function scoutTime()
		local destination_ = self.position
		local mainCityPos_ = player.serverMgr.getMyPosition()
		local distance_ = math.sqrt(math.pow(mainCityPos_.x - destination_.x, 2) + math.pow(mainCityPos_.y - destination_.y, 2))
		local costTime_ = math.floor(distance_ * SCOUT_SPEED)
		return costTime_
	end
	self.scout:getChildByName("ImageView_time"):getChildByName("Label_goldCost"):setString(hp.datetime.strTime(scoutTime()))
end