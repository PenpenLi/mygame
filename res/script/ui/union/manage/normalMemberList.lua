--
-- ui/union/manage/normalMemberList.lua
-- 成员列表
--===================================
require "ui/fullScreenFrame"

UI_normalMemberList = class("UI_normalMemberList", UI)

--init
function UI_normalMemberList:init(members_)
	-- data
	-- ===============================
	self.members = members_
	self.localMap = {}

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

	self:refreshShow()
end

function UI_normalMemberList:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "normalMemberList.json")
	self.listView = self.wigetRoot:getChildByName("ListView_30172")

	self.uiTitle = self.listView:getChildByName("Panel_30173"):clone()
	self.uiTitle:retain()
	self.uiMember = self.listView:getChildByName("Panel_30177"):clone()
	self.uiMember:retain()
	self.listView:removeAllItems()
end

function UI_normalMemberList:refreshShow()
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

		local members_ = self.members[v.sid]
		for j, w in ipairs(members_) do
			local uiMember_ = self.uiMember:clone()
			local memContent_ = uiMember_:getChildByName("Panel_30185")
			local manage_ = memContent_:getChildByName("ImageView_30186")
			manage_:addTouchEventListener(self.onMailTouched)
			manage_:setTag(w:getLocalID())
			self.localMap[w:getLocalID()] = w
			-- rank icon
			memContent_:getChildByName("ImageView_30189"):loadTexture(config.dirUI.common..v.image)
			-- name
			memContent_:getChildByName("Label_30190"):setString(w:getName())
			-- 战力
			memContent_:getChildByName("Label_30194"):setString(w:getPower())

			self.listView:pushBackCustomItem(uiMember_)
		end
	end
end

function UI_normalMemberList:initCallBack()
	local function onMailTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local name_ = self.localMap[sender:getTag()]:getName()
			require "ui/mail/writeMail"
			local ui_ = UI_writeMail.new(name_)
			self:addUI(ui_)
		end
	end

	self.onMailTouched = onMailTouched
end

function UI_normalMemberList:onRemove()
	self.uiTitle:release()
	self.uiMember:release()
	self.super.onRemove(self)
end