--
-- ui/union/transferLeader.lua
-- 转让会长
--===================================
require "ui/fullScreenFrame"

UI_transferLeader = class("UI_transferLeader", UI)

--init
function UI_transferLeader:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5142))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.uiItem)
	hp.uiHelper.uiAdaption(self.uiTitle)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	player.getAlliance():prepareData(dirtyType.MEMBER, "UI_transferLeader")
end

function UI_transferLeader:initCallBack()
	local function onExitResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			Scene.showMsg({1010})
			require "ui/common/successBox"
			ui_ = UI_successBox.new(hp.lang.getStrByID(1888), hp.lang.getStrByID(1152))
			game.curScene:addModalUI(ui_)
		end
	end

	local function onConfirm2Touched(sender, eventType)
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 16
		oper.type = 8
		oper.id = self.member:getID()
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onExitResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end

	local function onConfirm1Touched(sender, eventType)
		require "ui/msgBox/msgBox"
		-- UI_msgBox:init(title_, msg_, okText_, cancelText_, onOK_, onCancel_)
		local text_ = string.format(hp.lang.getStrByID(1151), self.member:getName())
		ui_ = UI_msgBox.new(hp.lang.getStrByID(1885), text_, hp.lang.getStrByID(1209),
			hp.lang.getStrByID(2412), onConfirm2Touched)
		self:addModalUI(ui_)
	end

	local function onTransferTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/msgBox/msgBox"
			self.member = player.getAlliance():getMemberByLocalID(sender:getTag())
			local text_ = string.format(hp.lang.getStrByID(1150), self.member:getName())
			ui_ = UI_msgBox.new(hp.lang.getStrByID(1885), text_, hp.lang.getStrByID(1209),
				hp.lang.getStrByID(2412), onConfirm1Touched)
			self:addModalUI(ui_)
		end
	end

	self.onTransferTouched = onTransferTouched
end

function UI_transferLeader:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "transferLeader.json")
	local content_ = self.widgetRoot:getChildByName("Panel_4")

	content_:getChildByName("Label_11"):setString(hp.lang.getStrByID(1896))
	content_:getChildByName("Label_14"):setString(hp.lang.getStrByID(1897))
	content_:getChildByName("Label_14_0"):setString(hp.lang.getStrByID(1898))

	self.listView = self.widgetRoot:getChildByName("ListView_17")
	self.uiTitle = self.listView:getItem(0):clone()
	self.uiTitle:retain()
	self.uiItem = self.listView:getItem(1):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
end

function UI_transferLeader:close()
	player.getAlliance():unPrepareData(dirtyType.MEMBER, "UI_transferLeader")
	self.uiTitle:release()
	self.uiItem:release()
	self.super.close(self)
end

function UI_transferLeader:refreshShow()
	local unionRank_ = hp.gameDataLoader.getTable("unionRank")
	if unionRank_ == nil then
		return
	end

	self.listView:removeAllItems()

	for i, v in ipairs(unionRank_) do
		local rankMembers_ = player.getAlliance():getMembersByRank(v.sid)
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		local content_ = title_:getChildByName("Panel_21")
		content_:getChildByName("Image_22"):loadTexture(config.dirUI.common..v.image)
		content_:getChildByName("Label_23"):setString(v.name)
		for j, w in ipairs(rankMembers_) do
			if w:getID() ~= player.getID() then
				local item_ = self.uiItem:clone()
				local content_ = item_:getChildByName("Panel_21")
				content_:getChildByName("Label_23"):setString(tostring(w:getName()))
				content_:getChildByName("Image_22"):loadTexture(config.dirUI.common..v.image)
				local transfer_ = content_:getChildByName("Image_42")
				transfer_:getChildByName("Label_43"):setString(hp.lang.getStrByID(1899))
				transfer_:setTag(w:getLocalID())
				transfer_:addTouchEventListener(self.onTransferTouched)
				self.listView:pushBackCustomItem(item_)
			end
		end
	end
end

function UI_transferLeader:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.MEMBER then
			self:refreshShow()
		end
	end
end