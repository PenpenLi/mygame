--
-- ui/bigMap/teleport.lua
-- 传送
--===================================
require "ui/UI"


UI_teleport = class("UI_teleport", UI)

local ITEM_SID = 20302

--init
function UI_teleport:init(tileInfo_)
	-- data
	-- ===============================
	self.haveNum = player.getItemNum(ITEM_SID)
	self.itemInfo = hp.gameDataLoader.getInfoBySid("item", ITEM_SID)
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	local function onBuyItemHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if tag == 1 then
				player.expendResource("gold", self.itemInfo.sale)
			elseif tag == 2 then
				player.expendItem(ITEM_SID, 1)
			end
			player.setPosition(data.x, data.y)

			if game.curScene.mapLevel == 2 then
				game.curScene:objAppearOnMap()
			end
			self:closeAll()
		end
	end

	-- call back
	local function OnChargeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 14
			oper.type = 1
			oper.sid = ITEM_SID
			oper.gold = self.itemInfo.sale
			oper.param = 0 + tileInfo_.position.x * math.pow(2, 10) + tileInfo_.position.y
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
		end
	end

	local function onTransportTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 14
			oper.type = 1
			oper.sid = ITEM_SID
			oper.gold = 0
			oper.param = 0 + tileInfo_.position.x * math.pow(2, 10) + tileInfo_.position.y
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 2)
		end
	end

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1214))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	if self.haveNum > 0 then
		self.charge:addTouchEventListener(onTransportTouched)
		self.charge:getChildByName("Label_7985"):setString(hp.lang.getStrByID(1200))
		self.charge:getChildByName("ImageView_gold"):setVisible(false)
	else
		self.charge:addTouchEventListener(OnChargeTouched)
		self.charge:getChildByName("Label_7985"):setString(hp.lang.getStrByID(5064))
		self.charge:getChildByName("ImageView_gold"):getChildByName("Label_goldCost"):setString(self.itemInfo.sale)
	end	
end

function UI_teleport:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "teleport.json")
	local Content = self.wigetRoot:getChildByName("Panel_7978")

	-- 询问
	Content:getChildByName("Label_7979"):setString(hp.lang.getStrByID(1211))

	local k_ = self.tileInfo.position.kx.."-"..self.tileInfo.position.ky
	local x_, y_ = self.tileInfo.position.x, self.tileInfo.position.y

	-- 位置
	Content:getChildByName("Label_7980"):setString(string.format(hp.lang.getStrByID(1220), k_, x_, y_))

	-- 描述
	Content:getChildByName("Label_7983"):setString(hp.lang.getStrByID(1212))

	-- 拥有
	Content:getChildByName("ImageView_7982"):getChildByName("Label_8066"):setString(string.format(hp.lang.getStrByID(1213), self.haveNum))

	self.charge = Content:getChildByName("ImageView_7984")
end
