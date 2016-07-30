--
-- ui/union/unionSourceHelp.lua
-- 公会资源帮助
--===================================
require "ui/fullScreenFrame"

UI_unionSourceHelp = class("UI_unionSourceHelp", UI)

--init
function UI_unionSourceHelp:init(type_)
	-- data
	-- ===============================
	self.type = type_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	if self.type == 1 then
		uiFrame:setTitle(hp.lang.getStrByID(5124))
	else
		uiFrame:setTitle(hp.lang.getStrByID(1820))
	end

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.item)
	hp.uiHelper.uiAdaption(self.uiTitle)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	player.getAlliance():prepareData(dirtyType.MEMBER, "UI_unionSourceHelp")
end

function UI_unionSourceHelp:initCallBack()
	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then			
			local resource_ = require "playerData/resourceHelpMgr"
			local playerInfo_ = player.getAlliance():getMemberByLocalID(sender:getTag())
			local cmd_ = resource_.sendCmd(9, {playerInfo_:getID()})
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
						local member_ = player.getAlliance():getMemberByLocalID(sender:getTag())
						local ui_ = UI_reinforce.new(member_:getID())
						self:addUI(ui_)
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
			local playerInfo_ = player.getAlliance():getMemberByLocalID(sender:getTag())
			oper.id = playerInfo_:getID()
			oper.sid = 1010
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)	
			self:showLoading(cmdSender, sender)
		end
	end

	self.onHelpTouched = onHelpTouched
	self.onReinforceTouched = onReinforceTouched
end

function UI_unionSourceHelp:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionSourceHelp.json")
	self.listView = self.widgetRoot:getChildByName("ListView_8344")

	self.item = self.listView:getChildByName("Panel_8345"):clone()
	self.item:retain()
	if self.type == 1 then
		self.item:getChildByName("Panel_8351"):getChildByName("ImageView_8363"):getChildByName("Label_27736"):setString(hp.lang.getStrByID(5214))
	else
		self.item:getChildByName("Panel_8351"):getChildByName("ImageView_8363"):getChildByName("Label_27736"):setString(hp.lang.getStrByID(5095))
	end
	self.uiTitle = self.listView:getChildByName("Panel_30173_Copy0"):clone()
	self.uiTitle:retain()
	self.listView:removeLastItem()
end

function UI_unionSourceHelp:onRemove()
	player.getAlliance():unPrepareData(dirtyType.MEMBER, "UI_unionSourceHelp")
	self.item:release()
	self.uiTitle:release()
	self.super.onRemove(self)
end

function UI_unionSourceHelp:refreshShow()
	local unionRank_ = hp.gameDataLoader.getTable("unionRank")
	if unionRank_ == nil then
		return
	end

	self.listView:removeAllItems()

	for i, v in ipairs(unionRank_) do
		local rankMembers_ = player.getAlliance():getMembersByRank(v.sid)
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		local content_ = title_:getChildByName("Panel_30179")
		content_:getChildByName("Label_30181"):setString(v.name)
		for j, w in ipairs(rankMembers_) do
			local item_ = self.item:clone()
			local content_ = item_:getChildByName("Panel_8351")
			content_:getChildByName("Label_8358"):setString(w:getName())
			-- 图片
			content_:getChildByName("ImageView_27733"):loadTexture(config.dirUI.common..v.image)
			-- 战力
			content_:getChildByName("Label_30194"):setString(w:getPower())
			
			local helpBtn = content_:getChildByName("ImageView_8363")
			helpBtn:setTag(w:getLocalID())
			if w:getID() == player.getID() then
				helpBtn:setVisible(false)
			else				
				if self.type == 1 then
					helpBtn:addTouchEventListener(self.onHelpTouched)
				else
					helpBtn:addTouchEventListener(self.onReinforceTouched)
				end
			end
			self.listView:pushBackCustomItem(item_)
		end
	end
end

function UI_unionSourceHelp:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if dirtyType.MEMBER == param_ then
			cclog_("UI_market:onMsg")
			self:refreshShow()
		end
	end
end