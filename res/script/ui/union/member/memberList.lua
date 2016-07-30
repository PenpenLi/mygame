--
-- ui/union/memberList.lua
-- 成员列表
--===================================
require "ui/fullScreenFrame"

UI_memberList = class("UI_memberList", UI)

--init
function UI_memberList:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(1822))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.uiMember)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	player.getAlliance():prepareData(dirtyType.MEMBER, "UI_memberList")
end

function UI_memberList:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "memberList.json")
	self.listView = self.wigetRoot:getChildByName("ListView_30172")

	self.uiTitle = self.listView:getChildByName("Panel_30173"):clone()
	self.uiTitle:retain()
	self.uiMember = self.listView:getChildByName("Panel_30177"):clone()
	self.uiMember:retain()
	self.listView:removeAllItems()
end

function UI_memberList:refreshShow()
	local unionRank_ = hp.gameDataLoader.getTable("unionRank")
	if unionRank_ == nil then
		return
	end

	self.listView:removeAllItems()

	for i, v in ipairs(unionRank_) do
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		local content_ = title_:getChildByName("Panel_30179")
		content_:getChildByName("Label_30181"):setString(v.name)

		local members_ = player.getAlliance():getMembersByRank(v.sid)
		for j, w in ipairs(members_) do
			local uiMember_ = self.uiMember:clone()
			local memContent_ = uiMember_:getChildByName("Panel_30185")
			local manage_ = memContent_:getChildByName("ImageView_30186")
			if w:getID() ~= player.getID() then				
				manage_:addTouchEventListener(self.onManageTouched)
				manage_:setTag(w:getLocalID())
				manage_:getChildByName("Label_4"):setString(hp.lang.getStrByID(5056))
			else
				manage_:setVisible(false)
			end
			-- rank icon
			memContent_:getChildByName("ImageView_30189"):loadTexture(config.dirUI.common..v.image)
			-- name
			memContent_:getChildByName("Label_30190"):setString(w:getName())
			-- 战力
			memContent_:getChildByName("Label_30194"):setString(w:getPower())
			-- 新人
			if w:getIsNew() == 0 then
				memContent_:getChildByName("Image_11"):setVisible(true)
			end

			self.listView:pushBackCustomItem(uiMember_)
		end
	end
end

function UI_memberList:initCallBack()
	local function onManageTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/union/member/manageFellow"
			local ui_ = UI_manageFellow.new(sender:getTag())
			self:addModalUI(ui_)
		end
	end

	self.onManageTouched = onManageTouched
end

function UI_memberList:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if dirtyType.MEMBER == param_ then
			self:refreshShow()
		end
	end
end

function UI_memberList:onRemove()
	player.getAlliance():unPrepareData(dirtyType.MEMBER, "UI_memberList")
	self.uiTitle:release()
	self.uiMember:release()
	self.super.onRemove(self)
end