--
-- ui/union/changeUnionIcon.lua
-- 查看权限
--===================================
require "ui/fullScreenFrame"

UI_changeUnionIcon = class("UI_changeUnionIcon", UI)

--init
function UI_changeUnionIcon:init()
	-- data
	-- ===============================
	self.unionBaseInfo = player.getAlliance():getBaseInfo()
	self.image = self.unionBaseInfo.icon

	-- ui data
	self.uiItemIcon = nil

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5140))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.item2)

	self:registMsg(hp.MSG.UNION_CHOOSE_ICON)
	self:registMsg(hp.MSG.UNION_NOTIFY)
end

function UI_changeUnionIcon:initCallBack()
	local function onKeepSymbolTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function onBrowseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/union/invite/unionIcon"
			local ui_ = UI_unionIcon:new()
			self:addUI(ui_)			
		end
	end

	local function onChangeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			cclog_("self.imageself.imageself.imageself.imageself.imageself.imageself.imageself.imageself.image",self.image)
			player.getUnionHttpHelper().changeUnionIcon(self.image)
		end
	end

	self.onBrowseTouched = onBrowseTouched
	self.onChangeTouched = onChangeTouched
	self.onKeepSymbolTouched = onKeepSymbolTouched
end

function UI_changeUnionIcon:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "changeUnionIcon.json")
	self.listView = self.widgetRoot:getChildByName("ListView_29885")

	self.item1 = self.listView:getChildByName("Panel_29886_Copy1")
	local content_ = self.item1:getChildByName("Panel_29900")
	content_:getChildByName("Label_29901"):setString(hp.lang.getStrByID(1183))
	self.browerBtn = content_:getChildByName("ImageView_29964")
	self.browerBtn:addTouchEventListener(self.onBrowseTouched)
	self.browerBtn:getChildByName("Label_29965"):setString(hp.lang.getStrByID(1184))
	local oldIcon = content_:getChildByName("ImageView_29941_0"):getChildByName("ImageView_29942")
	oldIcon:loadTexture(config.dirUI.icon..self.unionBaseInfo.icon..".png")
	oldIcon:addTouchEventListener(self.onBrowseTouched)

	self.item2 = self.listView:getChildByName("Panel_29886_Copy0"):clone()
	self.item2:retain()
	local content_ = self.item2:getChildByName("Panel_29900")
	content_:getChildByName("Label_29963"):setString(hp.lang.getStrByID(1185))
	content_:getChildByName("Label_14"):setString(hp.lang.getStrByID(1186))
	content_:getChildByName("ImageView_29941"):getChildByName("ImageView_29942"):addTouchEventListener(self.onBrowseTouched)

	-- 更改
	local change_ = content_:getChildByName("ImageView_29943")
	change_:addTouchEventListener(self.onChangeTouched)
	change_:getChildByName("Label_29944"):setString(hp.lang.getStrByID(1187))
	change_:getChildByName("ImageView_gold_0_0"):getChildByName("Label_goldCost"):setString("100")

	self.listView:removeItem(0)
end

function UI_changeUnionIcon:onRemove()
	self.item2:release()
	self.super.onRemove(self)
end

function UI_changeUnionIcon:setUnionIcon(tag_)
	if self.image == tostring(tag_) then
		return
	end

	self.image = tostring(tag_)
	if self.uiItemIcon == nil then
		self.browerBtn:addTouchEventListener(self.onKeepSymbolTouched)
		self.browerBtn:getChildByName("Label_29965"):setString(hp.lang.getStrByID(1188))
		self.uiItemIcon = self.item2:clone()
		self.listView:insertCustomItem(self.uiItemIcon, 0)
	end
	
	local content_ = self.uiItemIcon:getChildByName("Panel_29900")
	content_:getChildByName("ImageView_29941"):getChildByName("ImageView_29942"):loadTexture(string.format("%s%d.png", config.dirUI.icon, tag_))
end

function UI_changeUnionIcon:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_CHOOSE_ICON then
		self:setUnionIcon(param_)
	elseif msg_ == hp.MSG.UNION_NOTIFY then
		if param_.msgType == 1 then
			self:close()
		end
	end
end