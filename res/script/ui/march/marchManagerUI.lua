--
-- ui/march/marchManagerUI.lua
-- 行军管理器
--===================================
require "ui/fullScreenFrame"

UI_marchManagerUI = class("UI_marchManagerUI", UI)

local marchTypeName = {1300, 5094, 5093, 1313, 5096, 5095, 5097, 5095, 5184, 5386, 5385, 5184, 5093}
local textList = {5102,5101,5101,5102,5102,5102,5102,5101,5101,5102,5101,5101,5101}
local INTERVAL = 12

--init
function UI_marchManagerUI:init()
	-- data
	-- ===============================
	self.marchMgr = player.getMarchMgr()

	-- ui data
	self.uiGoldLoadingBar = {}
	self.uiLoadingBarImage = {}
	self.uiLoadingBar = {}
	self.uiLoadingText = {}
	self.enemyLoadingBar = {}
	self.enemyLoadingText = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(816)
	uiFrame:hideTopBackground()
	uiFrame:setTitle(hp.lang.getStrByID(5123))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item)
	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.item2)	
	hp.uiHelper.uiAdaption(self.item3)	
	hp.uiHelper.uiAdaption(self.item4)	
	hp.uiHelper.uiAdaption(self.item5)

	self:refreshShow()
	self:registMsg(hp.MSG.MARCH_MANAGER)
	-- self.marchMgr.sendCmd(8)
end

function UI_marchManagerUI:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "armyMgr.json")
	local content_ = self.wigetRoot:getChildByName("Panel_42")
	content_:getChildByName("Label_43"):setString(hp.lang.getStrByID(5091))
	self.noArmyCont = self.wigetRoot:getChildByName("Panel_11")

	self.listView = self.wigetRoot:getChildByName("ListView_27")
	self.uiTitle = self.listView:getItem(0):clone()
	self.uiTitle:retain()
	self.item = self.listView:getItem(1):clone()
	self.item:retain()
	self.item2 = self.listView:getItem(2):clone()
	self.item2:retain()
	self.item3 = self.listView:getItem(3):clone()
	self.item3:retain()
	self.item4 = self.listView:getItem(4):clone()
	self.item4:retain()
	self.item5 = self.listView:getItem(5):clone()
	self.item5:retain()
	local content_ = self.item:getChildByName("Panel_3")
	-- 名字
	content_:getChildByName("Label_37_0"):setString(hp.lang.getStrByID(5099)..player.getName())

	self.item4:getChildByName("Panel_3"):getChildByName("Label_37_0"):setString(hp.lang.getStrByID(5099)..player.getName())

	self.item5:getChildByName("Panel_3"):getChildByName("Label_37_0"):setString(hp.lang.getStrByID(5099)..player.getName())

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
		self:showLoading(cmdSender)
	end

	local function callBackConfirm(gold_, param_)
		sendBackHomeCmd(gold_, param_.param, 23251)
	end

	local function onCallBackTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local info_ = player.getMarchMgr().getFieldArmy()[sender:getTag()]
			local marchFunc_ = globalData.ARMY_FUNC[info_.marchType]
			if marchFunc_.backCost then
				require "ui/common/buyAndUseItemPop"
				local ui_ = UI_buyAndUseItem.new(23251, 1, callBackConfirm, {param = sender:getTag()})
				self:addModalUI(ui_)
			else
				local function callBackConfirm()
					sendBackHomeCmd(0, sender:getTag(), 0)
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
	end

	local function onCancelRallyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			local info_ = player.getMarchMgr().getFieldArmy()[tag_]
			if info_.marchType == globalData.ARMY_TYPE.RALLYING or info_.marchType == globalData.ARMY_TYPE.KING_BATTLE_RALLY then
				local function callBackConfirm()
					self.marchMgr.cancelRallyWar(tag_)
				end
     			require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(5185), 
	   				hp.lang.getStrByID(5186), 
	   				hp.lang.getStrByID(1209), 
	   				hp.lang.getStrByID(2412), 
	      			callBackConfirm
	   				)
	   			self:addModalUI(msgBox)
	   		end
	   	end
	end

	local function onArmyInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/march/viewArmy"
			local ui_ = UI_viewArmy.new(player.getMarchMgr().getFieldArmy()[sender:getTag()])
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
			game.curScene:gotoPosition(curPos_)
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
	
	self.onCallBackTouched = onCallBackTouched
	self.onArmyInfoTouched = onArmyInfoTouched
	self.onGoToTouched = onGoToTouched
	self.onSpeedUpTouched = onSpeedUpTouched
	self.onCancelRallyTouched = onCancelRallyTouched
end

function UI_marchManagerUI:onRemove()
	self.item:release()
	self.uiTitle:release()
	self.item2:release()
	self.item3:release()
	self.item4:release()
	self.item5:release()
	self.super.onRemove(self)
end

function UI_marchManagerUI:refreshShow()
	self.listView:removeAllItems()
	self.uiLoadingBarImage = {}
	self.uiLoadingBar = {}
	self.uiLoadingText = {}	
	self.uiGoldLoadingBar = {}
	self.enemyLoadingBar = {}
	self.enemyLoadingText = {}

	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	title_:getChildByName("Panel_33"):getChildByName("Label_34"):setString(hp.lang.getStrByID(5092))
	if player.marchMgr.getFieldArmyNum() == 0 then
		self.noArmyCont:setVisible(true)
		self.noArmyCont:getChildByName("Label_12"):setString(hp.lang.getStrByID(5310))
	else
		self.noArmyCont:setVisible(false)
		for i, v in pairs(player.getMarchMgr().getFieldArmy()) do
			local item_ = nil
			local marchFunc_ = globalData.ARMY_FUNC[v.marchType]
			if marchFunc_.loadingBar then
				if v.marchType == globalData.ARMY_TYPE.SOURCE_GOLD then
					item_ = self.item5:clone()
				else
					item_ = self.item:clone()
				end
			else
				item_ = self.item4:clone()
			end
			local itemBtn_ = self.item2:clone()
			self:loadItem(item_, itemBtn_, v, i)

			self.listView:pushBackCustomItem(item_)

			-- 处理冲突
			for j, w in ipairs(v.enemyIndex) do
				local item_ = self.item3:clone()
				self.listView:pushBackCustomItem(item_)
				local content_ = item_:getChildByName("Panel_3")
				local enemyInfo_ = player.getMarchMgr().getEnemyArmyByIndex(w)

				content_:getChildByName("Label_37"):setString(hp.lang.getStrByID(5279))

				content_:getChildByName("Label_37_1"):setString(string.format(hp.lang.getStrByID(5280), "K", enemyInfo_.pEnd.x, enemyInfo_.pEnd.y))

				if self.enemyLoadingBar[i] == nil then
					self.enemyLoadingBar[i] = {}
					self.enemyLoadingText[i] = {}
				end

				self.enemyLoadingBar[i][j] = item_:getChildByName("Panel_32"):getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
				self.enemyLoadingBar[i][j]:setTag(w)
				self.enemyLoadingText[i][j] = content_:getChildByName("Label_1643")
			end

			self.listView:pushBackCustomItem(itemBtn_)
		end
		self:updateInfo()
	end	
end

function UI_marchManagerUI:loadItem(item_, itemBtn_, info_, index_)
	local content_ = item_:getChildByName("Panel_3")
	local contentBtn_ = itemBtn_:getChildByName("Panel_3")

	local uiState_ = content_:getChildByName("Label_37")
	local soldierNum_ = content_:getChildByName("Label_37_2")
	local location_ = content_:getChildByName("Label_37_1")
	local uiName_ = content_:getChildByName("Label_37_0")

	-- 英雄
	if info_.hero ~= 0 then
		local uiHero_ = content_:getChildByName("Image_36")
		uiHero_:setVisible(true)
		uiHero_:getChildByName("Image_35_0"):loadTexture(config.dirUI.heroHeadpic..info_.image..".png")
		local x_, y_ = uiState_:getPosition()
		local newX_ = x_+(uiHero_:getSize().width+INTERVAL)*hp.uiHelper.RA_scaleX
		uiState_:setPosition(newX_, y_)
		local x_, y_ = uiName_:getPosition()
		uiName_:setPosition(newX_, y_)
		local x_, y_ = location_:getPosition()
		location_:setPosition(newX_, y_)
		local bg_ = item_:getChildByName("Panel_32"):getChildByName("Image_23")
		local x_, y_ = bg_:getPosition()
		local newX_ = x_+(uiHero_:getSize().width+INTERVAL)*hp.uiHelper.RA_scaleX
		bg_:setPosition(newX_, y_)		
	end

	-- 状态
	uiState_:setString(hp.lang.getStrByID(marchTypeName[info_.marchType]))

	-- 图片
	local image_ = content_:getChildByName("Image_35"):getChildByName("Image_36")
	image_:loadTexture(player.marchMgr.getMarchIcon(info_.marchType))

	-- 兵力	
	soldierNum_:setString(hp.lang.getStrByID(5100)..info_.number)

	-- 位置
	location_:setString(string.format(hp.lang.getStrByID(textList[info_.marchType]), "K", info_.pEnd.x, info_.pEnd.y))

	local marchFunc_ = globalData.ARMY_FUNC[info_.marchType]
	if marchFunc_.loadingBar then
		self.uiLoadingBarImage[index_] = item_:getChildByName("Panel_32"):getChildByName("ImageView_1644_0")--:getChildByName("LoadingBar_1640")
		self.uiLoadingBar[index_] = self.uiLoadingBarImage[index_]:getChildByName("LoadingBar_1640")
		self.uiLoadingText[index_] = content_:getChildByName("Label_1643")
	end

	if info_.marchType == globalData.ARMY_TYPE.SOURCE_GOLD then
		cclog_(item_:getChildByName("Panel_32"))
		cclog_(item_:getChildByName("Panel_32"):getChildByName("ImageView_1644_0_0"))
		self.uiGoldLoadingBar[index_] = item_:getChildByName("Panel_32"):getChildByName("ImageView_1644_0_0"):getChildByName("LoadingBar_1640")
		item_:getChildByName("Panel_3"):getChildByName("Label_1643_0"):setString(hp.lang.getStrByID(5507))
	end

	local btn1_ = contentBtn_:getChildByName("Image_17")
	btn1_:setTag(info_.id)
	btn1_:getChildByName("Label_18"):setString(hp.lang.getStrByID(5098))
	btn1_:addTouchEventListener(self.onCallBackTouched)

	local btn2_ = contentBtn_:getChildByName("Image_17_0")
	btn2_:setTag(info_.id)
	btn2_:getChildByName("Label_18"):setString(hp.lang.getStrByID(1408))
	btn2_:addTouchEventListener(self.onArmyInfoTouched)

	local btn3_ = contentBtn_:getChildByName("Image_17_1")
	btn3_:setTag(info_.id)
	btn3_:getChildByName("Label_18"):setString(hp.lang.getStrByID(1223))
	btn3_:addTouchEventListener(self.onGoToTouched)

	local btn4_ = contentBtn_:getChildByName("Image_17_2")
	btn4_:setTag(info_.id)
	btn4_:getChildByName("Label_18"):setString(hp.lang.getStrByID(2414))
	btn4_:addTouchEventListener(self.onSpeedUpTouched)

	local buttonList_ = {}
	buttonList_[1] = btn1_
	buttonList_[2] = btn2_
	buttonList_[3] = btn3_
	buttonList_[4] = btn4_

	for i = 1, 4 do
		if marchFunc_.func[i] ~= i then
			if marchFunc_.func[i] == 0 then
				buttonList_[i]:setVisible(false)
				buttonList_[i]:setTouchEnabled(false)
			elseif marchFunc_.func[i] == 5 then
				buttonList_[i]:addTouchEventListener(self.onCancelRallyTouched)
				buttonList_[i]:getChildByName("Label_18"):setString(hp.lang.getStrByID(2412))
			end
		end
	end

	if info_.marchType == 3 then
		img_ = content_:getChildByName("Image_2")
		img_:setVisible(true)
		local resInfo_ = hp.gameDataLoader.getInfoBySid("resources", info_.name2)
		local resTypeInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", resInfo_.growth + 1)
		img_:loadTexture(config.dirUI.common..resTypeInfo_.image)
	end
end

function UI_marchManagerUI:updateInfo()
	for i, v in pairs(self.uiLoadingBarImage) do
		if v:isVisible() == true then
			local info_ = player.getMarchMgr().getFieldArmy()[i]
			local per_ = (player.getServerTime() - info_.tStart) / info_.totalTime
			if per_ < 0 then
				per_ = 0
			elseif per_ > 1 then
				per_ = 1
			end
			local cd_ = ""
			if info_.marchType == 3 then
				local resInfo_ = hp.gameDataLoader.getInfoBySid("resources", info_.name2)
				local load_ = math.floor(per_ * info_.resCanLoaded)
				if resInfo_ ~= nil then
					cd_ = string.format("%s %s/%s", hp.lang.getStrByID(5107), load_, info_.resCanLoaded)
				end
			elseif info_.marchType == 13 then
				local resInfo_ = hp.gameDataLoader.getInfoBySid("resources", info_.name2)
				local pointNum_ = per_ * info_.resCanLoaded
				local load_ = math.floor(pointNum_)
				per_ = load_ / info_.resCanLoaded
				if resInfo_ ~= nil then
					cd_ = string.format("%s %s/%s", hp.lang.getStrByID(5107), load_, info_.resCanLoaded)
				end

				local gatherPer_ = (pointNum_ - load_) * 100
				self.uiGoldLoadingBar[i]:setPercent(gatherPer_)
			else
				local cdTime_ = info_.tEnd - player.getServerTime()			
				if cdTime_ < 0 then
					cdTime_ = 0
				end
				cd_ = hp.lang.getStrByID(1507).." "..hp.datetime.strTime(cdTime_)	
			end

			local percent_ = per_ * 100
			self.uiLoadingBar[i]:setPercent(percent_)
			self.uiLoadingText[i]:setString(cd_)
		end
	end

	for k, v in pairs(self.enemyLoadingBar) do
		for i, w in ipairs(v) do
			local enemyInfo_ = player.getMarchMgr().getEnemyArmyByIndex(w:getTag())

			local per_ = (player.getServerTime() - enemyInfo_.tStart) / enemyInfo_.totalTime
			if per_ > 1 then
				per_ = 1
			end

			local cdTime_ = enemyInfo_.tEnd - player.getServerTime()			
			if cdTime_ < 0 then
				cdTime_ = 0
			end
			local cd_ = hp.lang.getStrByID(5281).." "..hp.datetime.strTime(cdTime_)
			local percent_ = per_ * 100
			w:setPercent(percent_)
			self.enemyLoadingText[k][i]:setString(cd_)
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