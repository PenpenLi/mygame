--
-- ui/union/unionBigFightDetail.lua
-- 小型团体作战详细
--===================================
require "ui/fullScreenFrame"

UI_unionBigFightDetail = class("UI_unionBigFightDetail", UI)

local interval = 0
local hardGrademap = {"normal", "hard", "elite"}

--init
function UI_unionBigFightDetail:init(creatorID_)
	-- data
	-- ===============================
	self.fightInfo = player.getAlliance():getBigFight()
	self.creatorID = creatorID_

	-- ui data
	self.uiJoinNum = nil
	self.uiLoadingBar = nil
	self.uiCountTime = nil
	self.uiFightLoadingBar = nil

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5136))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	self:updateFight()
	self:tickUpdateInfo()
	player.getAlliance():prepareData(dirtyType.BIGFIGHT, "UI_unionBigFightDetail")
end

function UI_unionBigFightDetail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "smallFightDetail.json")
	local content_ = self.wigetRoot:getChildByName("Panel_33")
	local v = self.fightInfo
	-- 作战名称
	content_:getChildByName("Label_34"):setString(string.format(hp.lang.getStrByID(5038), v.info.name))
	-- 创建者
	local member_ = player.getAlliance():getMemberByID(v.members[1])
	content_:getChildByName("Label_34_2"):setString(hp.lang.getStrByID(5036))
	content_:getChildByName("Label_34_0_1"):setString(member_:getName())
	-- 人数
	self.uiJoinNum = content_:getChildByName("Label_34_0")
	self.uiJoinNum:setString(string.format(hp.lang.getStrByID(5037), table.getn(v.members), v.info.num))

	content_:getChildByName("Label_34_0_0"):setVisible(false)
	content_:getChildByName("ImageView_1644_0"):setVisible(true)
	content_:getChildByName("Image_38"):loadTexture(config.dirUI.common.."fight_1.png")

	self.uiFightLoadingBar = self.wigetRoot:getChildByName("Panel_26"):getChildByName("Image_29"):getChildByName("ProgressBar_30")
	-- 战斗时间进度条
	self.uiLoadingBar = content_:getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
	self.uiCountTime = self.uiLoadingBar:getChildByName("ImageView_1641"):getChildByName("Label_1642")
	content_:getChildByName("ImageView_1644_0"):getChildByName("Label_1643"):setString(hp.lang.getStrByID(5040))

	-- 奖励		
	local function freshReward()
		local reward_ = ""
		for i, v in ipairs(v.info["reward"]) do
			if v ~= 0 then
				local resource_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
				reward_ = reward_..resource_.name..v.."  "
			end
		end
		content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(5034), reward_))
	end

	-- 难度等级
	content_:getChildByName("Label_39"):setVisible(false)
	content_:getChildByName("Label_39_0"):setVisible(false)
	content_:getChildByName("Label_50"):setString(v.info.power)

	local moreInfo_ = content_:getChildByName("ImageView_20423_0")
	moreInfo_:getChildByName("Label_20424"):setString(hp.lang.getStrByID(1030))
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
	
	freshReward()

	self.listView = self.wigetRoot:getChildByName("ListView_15254")
	self.item1 = self.listView:getItem(0):clone()
	self.item1:retain()
	self.item2 = self.listView:getItem(1):clone()
	self.item2:retain()
	self.listView:removeAllItems()
end

function UI_unionBigFightDetail:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	-- 查看玩家信息
	local function onJoinResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.getAlliance():playerJoininBigFight(player.getID())
		end
	end

	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 47
			oper.id = self.creatorID
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onJoinResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	self.onJoinTouched = onJoinTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionBigFightDetail:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.BIGFIGHT then
			self:refreshShow()
		end
	end
end

function UI_unionBigFightDetail:onRemove()
	player.getAlliance():unPrepareData(dirtyType.BIGFIGHT, "UI_unionBigFightDetail")
	self.item1:release()
	self.item2:release()
	self.super.onRemove(self)
end

function UI_unionBigFightDetail:refreshShow()
	self.listView:removeAllItems()
	self.fightInfo = player.getAlliance():getBigFight()
	if self.fightInfo == nil then
		return
	end

	local item_ = self.item1:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_15286")
	content_:getChildByName("Label_18652"):setString(hp.lang.getStrByID(5041))
	content_:getChildByName("Label_18652_0"):setString(hp.lang.getStrByID(5042))
	content_:getChildByName("Label_18652_1"):setString(hp.lang.getStrByID(5043))
	local inFight_ = false
	for i =1, self.fightInfo.info.num do
		local item_ = self.item2:clone()
		self.listView:pushBackCustomItem(item_)
		content_ = item_:getChildByName("Panel_18648")	
		-- 编号
		content_:getChildByName("Label_18649"):setString(i)
		if self.fightInfo.members[i] ~= nil then
			local member_ = player.getAlliance():getMemberByID(self.fightInfo.members[i])				
			if member_:getID() == player.getID() then
				inFight_ = true
			end
			-- 名字
			content_:getChildByName("Label_18650"):setString(member_:getName())
			-- 战斗力
			content_:getChildByName("Label_18650_0"):setString(member_:getPower())
		else
			content_:getChildByName("Label_18650"):setVisible(false)
			content_:getChildByName("Label_18650_0"):setVisible(false)
			content_:getChildByName("ImageView_18651"):setVisible(false)
			local join_ = content_:getChildByName("ImageView_20423")
			if inFight_ == false then
				join_:setVisible(true)
				join_:getChildByName("Label_20424"):setString(hp.lang.getStrByID(5044))
				join_:addTouchEventListener(self.onJoinTouched)
				join_:setTouchEnabled(true)
			else
				join_:setVisible(false)
				join_:setTouchEnabled(false)
			end
		end
	end
	self:tickUpdateInfo()
end

function UI_unionBigFightDetail:updateFight()
	self.uiJoinNum:setString(string.format(hp.lang.getStrByID(5037), table.getn(self.fightInfo.members), self.fightInfo.info.num))
	local percent_ = self.fightInfo.power / self.fightInfo.info.power * 100
	self.uiFightLoadingBar:setPercent(percent_)
end

function UI_unionBigFightDetail:tickUpdateInfo()
	local restTime_= self.fightInfo.endTime - player.getServerTime()
	if restTime_ < 0 then
		return
	end

	self.uiCountTime:setString(hp.datetime.strTime(restTime_))
	local percent_ = 100 - restTime_ / self.fightInfo.info.time * 100
	self.uiLoadingBar:setPercent(percent_)
end

function UI_unionBigFightDetail:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:tickUpdateInfo()
end