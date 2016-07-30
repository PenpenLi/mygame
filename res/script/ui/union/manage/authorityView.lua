--
-- ui/union/authorityView.lua
-- 查看权限
--===================================
require "ui/fullScreenFrame"

UI_authorityView = class("UI_authorityView", UI)

--init
function UI_authorityView:init()
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5132))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.item)

	self:refreshShow()
end

function UI_authorityView:initCallBack()
	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/union/manage/authorityDetail"
			local ui_ = UI_authorityDetail.new(sender:getTag())
			self:addUI(ui_)
		end
	end

	self.onItemTouched = onItemTouched
end

function UI_authorityView:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionAuthority.json")
	self.listView = self.widgetRoot:getChildByName("ListView_14")

	self.item = self.listView:getItem(0):clone()
	self.item:retain()
	self.listView:removeLastItem()
end

function UI_authorityView:onRemove()
	self.item:release()
	self.super.onRemove(self)
end

function UI_authorityView:refreshShow()
	local unionRank_ = hp.gameDataLoader.getTable("unionRank")
	if unionRank_ == nil then
		return
	end

	self.listView:removeAllItems()

	for i, v in ipairs(unionRank_) do
		local item_ = self.item:clone()
		item_:setTag(v.sid)
		item_:addTouchEventListener(self.onItemTouched)
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_18")
		content_:getChildByName("Image_19"):loadTexture(config.dirUI.common..v.image)
		content_:getChildByName("Label_20"):setString(v.name)
	end
end