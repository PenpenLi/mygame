--
-- ui/bigMap/city/unionCity.lua
-- 自己城市弹出界面 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_unionCity = class("UI_unionCity", UI)

--init
function UI_unionCity:init(tileInfo_)
	-- data
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	
	local name_ = hp.lang.getStrByID(5302)
	if tileInfo_.objInfo.unionID == 0 then
		name_ = name_..tileInfo_.objInfo.name
	else
		name_ = name_..hp.lang.getStrByID(21)..tileInfo_.objInfo.unionName..hp.lang.getStrByID(22)..tileInfo_.objInfo.name
	end
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1306).."."..tileInfo_.objInfo.name, tileInfo_.position, name_)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function onSourceHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function callBack()
				self:close()
			end

			local resource_ = require "playerData/resourceHelpMgr"
			local cmd_ = resource_.sendCmd(9, {self.tileInfo.objInfo.id, callBack})
			if cmd_ ~= nil then
				self:showLoading(cmd_, sender)
			end
		end
	end

	local function onReinforceTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function onBaseInfoResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					if data.num > 0 then
						require "ui/union/mainFunc/reinforce"
						ui_ = UI_reinforce.new(self.tileInfo.objInfo.id)
						self:addUI(ui_)
						self:close()
					else
						require "ui/common/noBuildingNotice"
						local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1254), 1010, 1, hp.lang.getStrByID(5076))
						self:addModalUI(ui_)
					end
				end
			end

			local cmdData={operation={}}
			local oper = {}
			oper.channel = 6
			oper.type = 9
			oper.id = self.tileInfo.objInfo.id
			oper.sid = 1010
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	local function onProfileTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			ui_ = UI_playerInfo.new(self.tileInfo.objInfo.id, self.tileInfo.objInfo.serverID)
			self:addUI(ui_)
			self:close()
		end
	end

	self.help:addTouchEventListener(onSourceHelpTouched)
	self.reinforce:addTouchEventListener(onReinforceTouched)
	self.profile:addTouchEventListener(onProfileTouched)

	-- 初始显示
	self:initShow()
end

function UI_unionCity:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionCity.json")
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

	local btnContent = content:getChildByName("Panel_13929")
	-- 概览
	self.profile = btnContent:getChildByName("ImageView_13796")
	self.profile:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1312))

	-- 增援
	self.reinforce = btnContent:getChildByName("ImageView_13797")
	self.reinforce:getChildByName("Label_13798"):setString(hp.lang.getStrByID(1820))

	-- 捐献
	self.help = btnContent:getChildByName("ImageView_13793")
	self.help:getChildByName("Label_13795"):setString(hp.lang.getStrByID(1819))
end

function UI_unionCity:initShow()
	self.name:setString(hp.lang.getStrByID(1307)..": "..self.tileInfo.objInfo.name)
	self.power:setString(string.format(hp.lang.getStrByID(2032), self.tileInfo.objInfo.power))
	self.kill:setString(hp.lang.getStrByID(1308)..": "..self.tileInfo.objInfo.kill)
	if self.tileInfo.objInfo.unionID == 0 then
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..hp.lang.getStrByID(5147))
	else
		self.alliance:setString(hp.lang.getStrByID(1309)..": "..self.tileInfo.objInfo.unionName)
	end
	self.kingdom:setString(hp.lang.getStrByID(5494)..": "..player.serverMgr.getCountryByPos(self.tileInfo.position))
	self.position:setString(player.serverMgr.formatPosition(self.tileInfo.position))
	self.image:loadTexture(config.dirUI.heroHeadpic..self.tileInfo.objInfo.image..".png")
end