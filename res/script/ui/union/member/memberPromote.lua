--
-- ui/union/memberPromote.lua
-- 提升/降级
--===================================
require "ui/frame/popFrame"

UI_memberPromote = class("UI_memberPromote", UI)

--init
function UI_memberPromote:init(id_)
	-- data
	-- ===============================
	self.memberInfo_ = player:getAlliance():getMemberByID(id_)
	self.rank = self.memberInfo_:getRank()

	-- ui data
	self.uiItem = {}
	self.uiContainer = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1871))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	self:initAuthority()

	self:refreshChoose(self.memberInfo_:getRank())

	-- self:registMsg(hp.MSG.UNION_DATA_PREPARED)
end

function UI_memberPromote:initAuthority()
	for i, v in ipairs(self.uiContainer) do
		if i >= player.getAlliance():getMyUnionInfo():getRank() then
			self.uiContainer[i]:setVisible(false)
		end
	end
end

function UI_memberPromote:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "memberPromote.json")
	local content_ = self.wigetRoot:getChildByName("Panel_2")

	local info_ = hp.gameDataLoader.getInfoBySid("unionRank", self.memberInfo_:getRank())
	content_:getChildByName("Label_9"):setString(string.format(hp.lang.getStrByID(1877), self.memberInfo_:getName(), info_.name))
	content_:getChildByName("Label_9_0"):setString(hp.lang.getStrByID(1878))

	local strList_ = {"Panel_23", "Panel_23_0", "Panel_23_1", "Panel_23_2"}
	for i, v in ipairs(strList_) do
		local container_ = content_:getChildByName(v)
		local info_ = hp.gameDataLoader.getInfoBySid("unionRank", i)
		self.uiItem[i] = container_:getChildByName("Image_12")
		self.uiItem[i]:setTag(i)
		local item_ = container_:getChildByName("Image_22")
		item_:loadTexture(config.dirUI.common..info_.image)
		item_:addTouchEventListener(self.onItemTouched)
		item_:setTag(i)
		container_:getChildByName("Label_13"):setString(info_.name)
		self.uiContainer[i] = container_
	end

	local cancel_ = content_:getChildByName("Image_44")
	cancel_:addTouchEventListener(self.onCloseTouched)
	cancel_:getChildByName("Label_45"):setString(hp.lang.getStrByID(2412))

	local confirm_ = content_:getChildByName("Image_44_0")
	confirm_:getChildByName("Label_45"):setString(hp.lang.getStrByID(1209))
	confirm_:addTouchEventListener(self.onConfirmTouched)
end

function UI_memberPromote:initCallBack()
	-- 关闭
	local function onCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	-- 确定
	local function onChangeResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if tag == 0 then
				Scene.showMsg({1013})
			else
				Scene.showMsg({1014})
			end
			self:close()
		end
	end

	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 9
			oper.lv = self.rank
			oper.id = self.memberInfo_:getID()
			local tag_ = 1
			if self.memberInfo_:getRank() == self.rank then
				return
			elseif self.memberInfo_:getRank() > self.rank then
				tag_ = 0
			end
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onChangeResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
		end
	end


	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.rank = sender:getTag()
			self:refreshChoose(sender:getTag())
		end
	end

	self.onCloseTouched = onCloseTouched
	self.onConfirmTouched = onConfirmTouched
	self.onItemTouched = onItemTouched
end

function UI_memberPromote:refreshChoose(index_)
	print("index_", index_)
	for i, v in ipairs(self.uiItem) do
		if index_ == v:getTag() then
			v:setVisible(true)
		else
			v:setVisible(false)
		end
	end
end

function UI_memberPromote:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if dirtyType.MEMBER == param_ then
			self:refreshChoose(self.memberInfo_:getRank())
		end
	end
end