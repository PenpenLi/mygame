--
-- ui/march/marchManagerUI.lua
-- 行军管理器
--===================================
require "ui/fullScreenFrame"

UI_marchManagerUI = class("UI_marchManagerUI", UI)

local marchTypeName = {1300, 5094, 5093, 1313, 5096, 5095, 5097, 5095, 5184}
local marchImage = {"march_3", "march_3", "march_3", "march_3", "march_3", "march_3", "march_3", "march_3", "march_3"}
local textList = {5102,5101,5101,5102,5102,5102,5102,5101,5101}

--init
function UI_marchManagerUI:init()
	-- data
	-- ===============================
	self.marchMgr = player.getMarchMgr()

	-- ui data
	self.uiLoadingBarImage = {}
	self.uiLoadingBar = {}
	self.uiLoadingText = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5123))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item)
	hp.uiHelper.uiAdaption(self.uiTitle)

	-- self:refreshShow()
	self:registMsg(hp.MSG.MARCH_MANAGER)
	self.marchMgr.sendCmd(8)
end

function UI_marchManagerUI:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "armyMgr.json")
	local content_ = self.wigetRoot:getChildByName("Panel_42")
	content_:getChildByName("Label_43"):setString(hp.lang.getStrByID(5091))

	self.listView = self.wigetRoot:getChildByName("ListView_27")
	self.uiTitle = self.listView:getItem(0):clone()
	self.uiTitle:retain()
	self.item = self.listView:getItem(1):clone()
	self.item:retain()
	local content_ = self.item:getChildByName("Panel_3")
	-- 名字
	content_:getChildByName("Label_37_0"):setString(hp.lang.getStrByID(5099)..player.getName())

	self.listView:removeAllItems()
end

function UI_marchManagerUI:initCallBack()
	-- 召回
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
		local tag_ = 0
		if oper.sid ~= 0 then
			if oper.gold == 0 then
				tag_ = 1
			else
				tag_ = 2
			end
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
			local info_ = player.getMarchMgr().getFieldArmy()[sender:getTag()]
			if info_.marchType == ARMY_TYPE.RALLYING then
				local function callBackConfirm()
					self.marchMgr.cancelRallyWar(sender:getTag())
				end
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5185), hp.lang.getStrByID(5186), callBackConfirm)
     			self:addModalUI(box_)				
			elseif info_.marchType == ARMY_TYPE.CAMP_ING or info_.marchType == ARMY_TYPE.SOURCE_ING
				or info_.marchType == ARMY_TYPE.LEAGUECITY then
				local function callBackConfirm()
					sendBackHomeCmd(0, sender:getTag(), 0)
				end
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5108), hp.lang.getStrByID(5109), callBackConfirm)
     			self:addModalUI(box_)
			else
				require "ui/common/buyAndUseItemPop"
				ui_ = UI_buyAndUseItem.new(23251, 1, callBackConfirm, {param = sender:getTag()})
				self:addModalUI(ui_)
			end
		end
	end

	local function onArmyInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/march/viewArmy"
			ui_ = UI_viewArmy.new(player.getMarchMgr().getFieldArmy()[sender:getTag()])
			self:addUI(ui_)
		end
	end

	local function onGoToTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local info_ = player.getMarchMgr().getFieldArmy()[sender:getTag()]
			local dis_ = {x=info_.pEnd.x - info_.pStart.x, y=info_.pEnd.y - info_.pStart.y}
			local v_ = {x=dis_.x / info_.totalTime, y=dis_.y / info_.totalTime}
			local curPos_ = {}
			curPos_.x = info_.pStart.x + v_.x * (player.getServerTime() - info_.tStart)
			curPos_.y = info_.pStart.y + v_.y * (player.getServerTime() - info_.tStart)
			game.curScene:gotoPosition("K", curPos_)
			self:close()
		end
	end

	local function onSpeedUpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/armySpeedItem")
			local ui  = UI_armySpeedItem.new(sender:getTag())
			self:addUI(ui)
		end
	end

	-- 查看玩家信息
	local function onCreateResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local function createMyBigFight()
			local fightInfo_ = hp.gameDataLoader.getInfoBySid("bigFight", self.bigFightSid)
			return Alliance.parseBigFight({self.bigFightSid, fightInfo_.time + player.getServerTime(), {player.getID()}})
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			local fight_ = createMyBigFight()
			player.getAlliance():insertBigFight(fight_)
			require "ui/union/fight/unionBigFightDetail"
			ui_ = UI_marchManagerUIDetail.new(player.getID())
			self:addUI(ui_)
			self:close()
		end
	end

	local function onCreateTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 46
			oper.sid = sender:getTag()
			self.bigFightSid = oper.sid
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onCreateResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	self.onCreateTouched = onCreateTouched
	self.onCallBackTouched = onCallBackTouched
	self.onArmyInfoTouched = onArmyInfoTouched
	self.onGoToTouched = onGoToTouched
	self.onSpeedUpTouched = onSpeedUpTouched
end

function UI_marchManagerUI:close()
	self.item:release()
	self.uiTitle:release()
	self.super.close(self)
end

function UI_marchManagerUI:refreshShow()
	self.listView:removeAllItems()
	self.uiLoadingBarImage = {}
	self.uiLoadingBar = {}
	self.uiLoadingText = {}

	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	title_:getChildByName("Panel_33"):getChildByName("Label_34"):setString(hp.lang.getStrByID(5092))
	for i, v in pairs(player.getMarchMgr().getFieldArmy()) do
		local item_ = self.item:clone()
		self.listView:pushBackCustomItem(item_)

		self:loadItem(item_, v, i)
	end
	self:updateInfo()
end

function UI_marchManagerUI:loadItem(item_, info_, index_)
	local content_ = item_:getChildByName("Panel_3")
	-- 状态
	content_:getChildByName("Label_37"):setString(hp.lang.getStrByID(marchTypeName[info_.marchType]))

	-- 图片
	content_:getChildByName("Image_35"):getChildByName("Image_36"):loadTexture(string.format("%s%s.png", config.dirUI.common, marchImage[info_.marchType]))

	-- 兵力
	local soldierNum_ = content_:getChildByName("Label_37_2")
	soldierNum_:setString(hp.lang.getStrByID(5100)..info_.number)

	-- 位置
	content_:getChildByName("Label_37_1"):setString(string.format(hp.lang.getStrByID(textList[info_.marchType]), "K", info_.pEnd.x, info_.pEnd.y))

	self.uiLoadingBarImage[index_] = item_:getChildByName("Panel_32"):getChildByName("ImageView_1644_0")--:getChildByName("LoadingBar_1640")
	self.uiLoadingBar[index_] = self.uiLoadingBarImage[index_]:getChildByName("LoadingBar_1640")
	self.uiLoadingText[index_] = content_:getChildByName("Label_1643")

	local btn1_ = content_:getChildByName("Image_17")
	btn1_:setTag(info_.id)
	btn1_:getChildByName("Label_18"):setString(hp.lang.getStrByID(5098))
	btn1_:addTouchEventListener(self.onCallBackTouched)

	local btn2_ = content_:getChildByName("Image_17_0")
	btn2_:setTag(info_.id)
	btn2_:getChildByName("Label_18"):setString(hp.lang.getStrByID(1408))
	btn2_:addTouchEventListener(self.onArmyInfoTouched)

	local btn3_ = content_:getChildByName("Image_17_1")
	btn3_:setTag(info_.id)
	btn3_:getChildByName("Label_18"):setString(hp.lang.getStrByID(1223))
	btn3_:addTouchEventListener(self.onGoToTouched)

	local btn4_ = content_:getChildByName("Image_17_2")
	btn4_:setTag(info_.id)
	btn4_:getChildByName("Label_18"):setString(hp.lang.getStrByID(2414))
	btn4_:addTouchEventListener(self.onSpeedUpTouched)

	if info_.marchType == 2 then
		btn4_:setTouchEnabled(false)
		btn4_:setVisible(false)
		self.uiLoadingBarImage[index_]:setVisible(false)
		self.uiLoadingText[index_]:setVisible(false)
	elseif info_.marchType == 3 then
		btn4_:setTouchEnabled(false)
		btn4_:setVisible(false)
		img_ = content_:getChildByName("Image_2")
		img_:setVisible(true)
		self.resInfo_ = hp.gameDataLoader.getInfoBySid("resources", info_.name2)
		local resTypeInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", self.resInfo_.growth + 1)
		img_:loadTexture(config.dirUI.common..resTypeInfo_.image)
	elseif info_.marchType == 4 then
		btn2_:setTouchEnabled(false)
		btn2_:setVisible(false)
		soldierNum_:setVisible(false)
	elseif info_.marchType == 5 then
		btn2_:setTouchEnabled(false)
		btn2_:setVisible(false)
		soldierNum_:setVisible(false)
	elseif info_.marchType == 7 then
		btn1_:setTouchEnabled(false)
		btn1_:setVisible(false)
	elseif info_.marchType == 8 then
		btn4_:setTouchEnabled(false)
		btn4_:setVisible(false)
	elseif info_.marchType == 9 then
		btn2_:setTouchEnabled(false)
		btn2_:setVisible(false)
		btn4_:setTouchEnabled(false)
		btn4_:setVisible(false)
		btn1_:getChildByName("Label_18"):setString(hp.lang.getStrByID(2412))
	end
end

function UI_marchManagerUI:updateInfo()
	for i, v in pairs(self.uiLoadingBarImage) do
		if v:isVisible() == true then
			local info_ = player.getMarchMgr().getFieldArmy()[i]
			local per_ = (player.getServerTime() - info_.tStart) / info_.totalTime
			if per_ > 1 then
				per_ = 1
			end
			local cd_ = ""
			if info_.marchType ~= 3 then
				local cdTime_ = info_.tEnd - player.getServerTime()			
				if cdTime_ < 0 then
					cdTime_ = 0
				end
				cd_ = hp.lang.getStrByID(1507).." "..hp.datetime.strTime(cdTime_)				
			else
				local rate_ = 1
				if self.resInfo_ ~= nil then
					rate_ = self.resInfo_.pickupRate
				end
				local load_ = math.floor(per_ * info_.loaded / rate_)
				if self.resInfo_ ~= nil then
					cd_ = string.format("%s %s/%s", hp.lang.getStrByID(5107), load_, info_.loaded)
				end
			end
			local percent_ = hp.common.round(per_ * 100)
			self.uiLoadingBar[i]:setPercent(percent_)
			self.uiLoadingText[i]:setString(cd_)
		end
	end
end

function UI_marchManagerUI:onMsg(msg_, param_)
	if hp.MSG.MARCH_MANAGER == msg_ then
		self:refreshShow()
	end
end

function UI_marchManagerUI:heartbeat(dt_)
	self:updateInfo()
end