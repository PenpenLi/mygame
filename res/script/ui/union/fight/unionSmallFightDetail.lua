--
-- ui/union/unionSmallFightDetailDetail.lua
-- 小型团体作战详细
--===================================
require "ui/fullScreenFrame"

UI_unionSmallFightDetail = class("UI_unionSmallFightDetail", UI)

local interval = 0
local hardGrademap = {"normal", "hard", "elite"}
local difficultyIcon = {"fight_15.png", "fight_13.png", "fight_11.png", "fight_14.png", "fight_12.png", "fight_2.png"}

--init
function UI_unionSmallFightDetail:init(creatorID_)
	-- data
	-- ===============================
	self.fightInfo = player.getAlliance():getSmallFightByID(creatorID_)
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
	uiFrame:setTitle(hp.lang.getStrByID(5135))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.item1)
	hp.uiHelper.uiAdaption(self.item2)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	player.getAlliance():prepareData(dirtyType.SMALFIGHT, "UI_unionSmallFight")
end

function UI_unionSmallFightDetail:initUI()
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

	self.uiFightLoadingBar = self.wigetRoot:getChildByName("Panel_26"):getChildByName("Image_29"):getChildByName("ProgressBar_30")
	-- 战斗时间进度条
	self.uiLoadingBar = content_:getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
	self.uiCountTime = self.uiLoadingBar:getChildByName("ImageView_1641"):getChildByName("Label_1642")
	content_:getChildByName("ImageView_1644_0"):getChildByName("Label_1643"):setString(hp.lang.getStrByID(5040))

	local icon_ = {}
	icon_[1] = content_:getChildByName("Image_32")
	icon_[2] = content_:getChildByName("Image_32_0")
	icon_[3] = content_:getChildByName("Image_32_1")

	-- 奖励		
	local function freshReward(type_)
		local reward_ = ""
		for i, v in ipairs(v.info[hardGrademap[type_]]) do
			if v ~= 0 then
				local resource_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
				reward_ = reward_..resource_.name..v.."  "
			end
		end

		-- 设置图标
		for i = 1, 3 do
			if i == type_ then
				icon_[i]:loadTexture(config.dirUI.common..difficultyIcon[i + 3])
			else
				icon_[i]:loadTexture(config.dirUI.common..difficultyIcon[i])
			end
		end
		content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(5034), reward_))
	end

	local function onHardGradeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			freshReward(sender:getTag())
		end
	end

	icon_[1]:addTouchEventListener(onHardGradeTouched)
	icon_[2]:addTouchEventListener(onHardGradeTouched)
	icon_[3]:addTouchEventListener(onHardGradeTouched)

	-- 难度等级
	content_:getChildByName("Label_39"):setString(v.info.grade[1])
	content_:getChildByName("Label_39_0"):setString(v.info.grade[2])
	content_:getChildByName("Label_50"):setString(v.info.grade[3])

	local moreInfo_ = content_:getChildByName("ImageView_20423_0")
	moreInfo_:getChildByName("Label_20424"):setString(hp.lang.getStrByID(1030))
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
	
	freshReward(1)

	self.listView = self.wigetRoot:getChildByName("ListView_15254")
	self.item1 = self.listView:getItem(0):clone()
	self.item1:retain()
	self.item2 = self.listView:getItem(1):clone()
	self.item2:retain()
	self.listView:removeAllItems()
end

function UI_unionSmallFightDetail:initCallBack()
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
			player.getAlliance():playerJoinInSmallFight(self.creatorID, player.getID())
		end
	end

	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 44
			oper.id = self.creatorID
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onJoinResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onLeaveResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.getAlliance():playerLeaveSmallFight(self.creatorID, player.getID())
		end
	end

	local function onLeaveTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function leaveConfirm()
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 16
				oper.type = 45
				oper.id = self.creatorID
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onLeaveResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			end			
			require "ui/msgBox/msgBox"
			local textID_ = 5053
			if self.creatorID == player.getID() then
				textID_ = 5052
			end
			ui_ = UI_msgBox.new(hp.lang.getStrByID(1885), hp.lang.getStrByID(textID_), hp.lang.getStrByID(1209),
				hp.lang.getStrByID(2412), leaveConfirm)
			self:addModalUI(ui_)
		end
	end

	self.onLeaveTouched = onLeaveTouched
	self.onJoinTouched = onJoinTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionSmallFightDetail:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.SMALFIGHT then
			self:refreshShow()
		end
	end
end

function UI_unionSmallFightDetail:close()
	player.getAlliance():unPrepareData(dirtyType.SMALFIGHT, "UI_unionSmallFightDetail")
	self.item1:release()
	self.item2:release()
	self.super.close(self)
end

function UI_unionSmallFightDetail:refreshShow()
	self.listView:removeAllItems()
	self.fightInfo = player.getAlliance():getSmallFightByID(self.creatorID)
	if self.fightInfo == nil then
		self:close()
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
			if self.fightInfo.state ~= 2 then			
				if member_:getID() == player.getID() then
					inFight_ = true
					local leave_ = content_:getChildByName("Image_69")
					leave_:setVisible(true)
					if i == 1 then
						leave_:getChildByName("Label_70"):setString(hp.lang.getStrByID(1025))
					else
						leave_:getChildByName("Label_70"):setString(hp.lang.getStrByID(1883))
					end
					leave_:addTouchEventListener(self.onLeaveTouched)
				end
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
	self:updateFight()
	self:tickUpdateInfo()
end

function UI_unionSmallFightDetail:updateFight()
	self.uiJoinNum:setString(string.format(hp.lang.getStrByID(5037), table.getn(self.fightInfo.members), self.fightInfo.info.num))
	local percent_ = hp.common.round(self.fightInfo.power / self.fightInfo.info.grade[3] * 100)
	self.uiFightLoadingBar:setPercent(percent_)
	local content_ = self.wigetRoot:getChildByName("Panel_33")
	if self.fightInfo.state == 1 then
		-- 状态
		content_:getChildByName("Label_34_0_0"):setString(hp.lang.getStrByID(5039))
		content_:getChildByName("Image_38"):loadTexture(config.dirUI.common.."fight_6.png")
	elseif self.fightInfo.state == 2 then
		content_:getChildByName("Label_34_0_0"):setVisible(false)
		content_:getChildByName("ImageView_1644_0"):setVisible(true)
		content_:getChildByName("Image_38"):loadTexture(config.dirUI.common.."fight_1.png")
	end
end

function UI_unionSmallFightDetail:tickUpdateInfo()
	if self.fightInfo.state ~= 2 then
		return
	end

	local restTime_= self.fightInfo.endTime - player.getServerTime()
	if restTime_ < 0 then
		return
	end

	self.uiCountTime:setString(hp.datetime.strTime(restTime_))
	local percent_ = hp.common.round(100 - restTime_ / self.fightInfo.info.time * 100)
	self.uiLoadingBar:setPercent(percent_)
end

function UI_unionSmallFightDetail:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:tickUpdateInfo()
end