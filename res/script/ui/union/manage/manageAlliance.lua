--
-- ui/union/manageAlliance.lua
-- 管理公会
--===================================
require "ui/fullScreenFrame"

UI_manageAlliance = class("UI_manageAlliance", UI)

-- 项目列表 1-公会邀请 2-屏蔽 3-屏蔽管理 4-权限 5-公会信息 6-改名
-- 7-改描述 8-收人 9-图标 10-军队颜色 11-转让 12-解散 13-退出
local imageList = {"alliance_35.png", "alliance_36.png", "alliance_37.png", "alliance_38.png", 
		"alliance_39.png", "alliance_40.png", "alliance_41.png", "alliance_42.png", "alliance_43.png",
		"alliance_44.png", "alliance_45.png", "alliance_47.png", "alliance_47.png"}
local nameIDList = {1829, 1830, 1831, 1832, 1833, 1834, 1835, 1836, 1837, 1838, 1839, 1840, 1841}

--init
function UI_manageAlliance:init()
	-- data
	-- ===============================
	self.loadItemList = {1,1,1,1,1,1,1,1,1,1,1,1,1}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5131))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiItem)

	self:initItemList()

	self:initShow()
end

function UI_manageAlliance:initItemList()
	local authority_ = hp.gameDataLoader.getInfoBySid("allienceRank", player.getAlliance():getMyUnionInfo():getRank())
	for i, v in ipairs(authority_.loadList) do
		self.loadItemList[i] = v
	end
end

function UI_manageAlliance:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "manageAlliance.json")
	self.listView = self.wigetRoot:getChildByName("ListView_30128_Copy0")

	self.uiItem = self.listView:getChildByName("Panel_30134"):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
end

function UI_manageAlliance:initCallBack()
	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()		
			if tag_ == 1 then
				require "ui/union/invite/unionInviteMember"
				ui_ = UI_unionInviteMember.new()
				self:addUI(ui_)
			elseif tag_ == 4 then
				require "ui/union/manage/authorityView"
				ui_ = UI_authorityView.new()
				self:addUI(ui_)
			elseif tag_ == 5 then
			elseif tag_ == 6 then
				require "ui/union/manage/unionChangeName"
				ui_ = UI_unionChangeName.new()
				self:addUI(ui_)				
			elseif tag_ == 7 then
				require "ui/union/manage/unionDesc"
				ui_ = UI_unionDesc.new()
				self:addUI(ui_)
			elseif tag_ == 8 then
				require "ui/union/manage/changeJoinState"
				ui_ = UI_changeJoinState.new()
				self:addUI(ui_)
			elseif tag_ == 9 then
				require "ui/union/manage/changeUnionIcon"
				ui_ = UI_changeUnionIcon.new()
				self:addUI(ui_)				
			elseif tag_ == 10 then
				require "ui/union/manage/changeColor"
				ui_ = UI_changeColor.new()
				self:addUI(ui_)
			elseif tag_ == 11 then
				require "ui/union/manage/transferLeader"
				ui_ = UI_transferLeader.new()
				self:addUI(ui_)
			elseif tag_ == 12 then
				require "ui/union/manage/disbandUnion"
				ui_ = UI_disbandUnion.new()
				self:addUI(ui_)
			elseif tag_ == 13 then
				require "ui/union/manage/leaveUnion"
				ui_ = UI_leaveUnion.new()
				self:addModalUI(ui_)
			end
			print("tag:",tag_)
		end
	end

	self.onItemTouched = onItemTouched
end

function UI_manageAlliance:exitUnion()
	local function onExitResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:closeAll()
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 4
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onExitResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_manageAlliance:initShow()
	for i, v in ipairs(self.loadItemList) do
		if v == 1 then
			local item_ = self.uiItem:clone()
			item_:setTag(i)
			item_:addTouchEventListener(self.onItemTouched)
			local content_ = item_:getChildByName("Panel_30144")
			content_:getChildByName("Label_30148"):setString(hp.lang.getStrByID(nameIDList[i]))

			-- 图标
			content_:getChildByName("ImageView_30145"):loadTexture(config.dirUI.common..imageList[i])
			self.listView:pushBackCustomItem(item_)
		end
	end
end

function UI_manageAlliance:close()
	self.uiItem:release()
	self.super.close(self)
end