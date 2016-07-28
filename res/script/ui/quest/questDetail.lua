--
-- ui/quest/questDetail.lua
-- 任务详情
--===================================
require "ui/fullScreenFrame"

UI_questDetail = class("UI_questDetail", UI)

local availableImage = "button_blue.png"

--init
function UI_questDetail:init(questID_)
	-- data
	-- ===============================
	print("questID_",questID_)
	self.questInfo = hp.gameDataLoader.getInfoBySid("quests", questID_)

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(1411))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function OnCollectResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			hp.msgCenter.sendMsg(hp.MSG.MISSION_COMPLETE, questID_)
			self:close()
		end
	end

	local function OnCollectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 2
			oper.type = 1
			oper.sid = questID_
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(OnCollectResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	self.collect:addTouchEventListener(OnCollectTouched)

	-- 消息注册
	self:registMsg(hp.MSG.MISSION_MAIN_STATUS_CHANGE)
end

-- 初始化UI
function UI_questDetail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "questDetail.json")
	local content = self.wigetRoot:getChildByName("Panel_18660")

	content:getChildByName("Label_18661"):setString(self.questInfo.name)
	content:getChildByName("Label_18663"):setString(self.questInfo.text)
	content:getChildByName("ImageView_18664"):getChildByName("Label_18665"):setString(hp.lang.getStrByID(1412))

	local listView = self.wigetRoot:getChildByName("ListView_18670")
	local oneReward = listView:getChildByName("Panel_18671"):clone()

	-- 图片
	if self.questInfo.type == 1 then
		if self.questInfo.parameter1 == 1001 then
			content:getChildByName("ImageView_18662"):loadTexture(config.dirUI.building.."fudi_icon.png")
		elseif self.questInfo.parameter1 == 1018 then
			content:getChildByName("ImageView_18662"):loadTexture(config.dirUI.building.."wall_icon.png")
		else
			local buildInfo_ = hp.gameDataLoader.multiConditionSearch("upgrade", {{"buildSid", self.questInfo.parameter1}, {"level", self.questInfo.parameter2}})
			content:getChildByName("ImageView_18662"):loadTexture(config.dirUI.building..buildInfo_.img)
		end
	end

	listView:removeLastItem()

	for j, w in ipairs(self.questInfo.reward) do
		local rewardInfo_ = hp.gameDataLoader.getInfoBySid("rewards", w)
		for i, v in ipairs(rewardInfo_.resource) do
			local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
			local cloneReward_ = oneReward:clone()
			cloneReward_:getChildByName("Panel_20378"):getChildByName("ImageView_20379"):loadTexture(config.dirUI.common..resourceInfo_.image)
			cloneReward_:getChildByName("Panel_20378"):getChildByName("Label_20380"):setString(resourceInfo_.name..": "..v)

			if i % 2 == 0 then
				cloneReward_:getChildByName("Panel_20377"):getChildByName("ImageView_20382"):setVisible(false)
			end
			listView:pushBackCustomItem(cloneReward_)
		end
	end

	self.collect = content:getChildByName("Panel_23185"):getChildByName("ImageView_20396")
	self.collect:getChildByName("Label_20397"):setString(hp.lang.getStrByID(1413))
	self:changeRewardStatus()
end

function UI_questDetail:changeRewardStatus()
	if player.isRewardCollectable(self.questInfo.sid) then
		self.collect:loadTexture(config.dirUI.common..availableImage)
		self.collect:setTouchEnabled(true)
	end
end

function UI_questDetail:onMsg(msg_, parm_)
	if msg_ == hp.MSG.MISSION_MAIN_STATUS_CHANGE then
		self:changeRewardStatus(parm_)
	end
end