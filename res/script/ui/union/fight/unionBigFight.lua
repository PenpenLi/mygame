--
-- ui/union/unionBigFight.lua
-- 大型团体作战
--===================================
require "ui/fullScreenFrame"

UI_unionBigFight = class("UI_unionBigFight", UI)

--init
function UI_unionBigFight:init()
	-- data
	-- ===============================

	-- ui data

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

	hp.uiHelper.uiAdaption(self.item)

	self:refreshShow()
end

function UI_unionBigFight:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bigFight.json")
	local content_ = self.wigetRoot:getChildByName("Panel_29874_Copy0_0")
	content_:getChildByName("Label_6"):setString(hp.lang.getStrByID(5051))

	-- 更多信息
	local moreInfo_ = content_:getChildByName("Image_48")
	moreInfo_:getChildByName("Label_49"):setString(hp.lang.getStrByID(1030))
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)

	self.listView = self.wigetRoot:getChildByName("ListView_24")
	self.item = self.listView:getItem(0):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_unionBigFight:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
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
			local ui_ = UI_unionBigFightDetail.new(player.getID())
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
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionBigFight:onRemove()
	self.item:release()
	self.super.onRemove(self)
end

function UI_unionBigFight:refreshShow()
	self.listView:removeAllItems()
	local fightInfo_ = hp.gameDataLoader.getTable("bigFight")
	if fightInfo_ == nil then
		return
	end

	for i, v in ipairs(fightInfo_) do
		local item_ = self.item:clone()
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_33")
		-- 作战名称
		content_:getChildByName("Label_34"):setString(string.format(hp.lang.getStrByID(5038), v.name))
		-- 人数
		content_:getChildByName("Label_34_0"):setString(string.format(hp.lang.getStrByID(5048), v.num))
		-- 要求战斗力
		content_:getChildByName("Label_34_0_0"):setString(string.format(hp.lang.getStrByID(5049), v.power))
		-- 时间
		content_:getChildByName("Label_34_0_1"):setString(string.format(hp.lang.getStrByID(5033), hp.datetime.strTime(v.time)))
		-- 奖励		
		local function freshReward()
			local reward_ = ""
			for j, w in ipairs(v["reward"]) do
				if w ~= 0 then
					local resource_ = hp.gameDataLoader.getInfoBySid("resInfo", j)
					reward_ = reward_..resource_.name..hp.common.changeNumUnit(w).."  "
				end
			end
			content_:getChildByName("Label_34_1"):setString(string.format(hp.lang.getStrByID(5149), reward_))
		end
		
		local create_ = content_:getChildByName("Image_38")
		create_:getChildByName("Label_11"):setString(hp.lang.getStrByID(5035))
		create_:setTag(v.sid)
		create_:addTouchEventListener(self.onCreateTouched)
		freshReward()
	end	
end