--
-- ui/bigMap/search.lua
-- 查找
--===================================
require "ui/UI"


UI_search = class("UI_search", UI)


--init
function UI_search:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================

	-- 初始化界面
	self:initUI()

	require "ui/frame/popFrame"
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1216))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back
	local function OnClearTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function OnConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local x = self.textField[2]:getString()
			local y = self.textField[3]:getString()
			game.curScene:gotoPosition(self.textField[1], {x=tonumber(x), y=tonumber(y)})
			self:close()
		end
	end

	self.clear:addTouchEventListener(OnClearTouched)
	self.confirm:addTouchEventListener(OnConfirmTouched)
end

function UI_search:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "search.json")
	local Content = self.wigetRoot:getChildByName("Panel_7990")

	Content:getChildByName("Label_7998"):setString(hp.lang.getStrByID(5085))

	Content:getChildByName("Label_7991"):setString(hp.lang.getStrByID(1217))
	self.textField = {}
	self.textField[1] = hp.uiHelper.labelBind2EditBox(Content:getChildByName("Label_5"))
	self.textField[2] = hp.uiHelper.labelBind2EditBox(Content:getChildByName("Label_5_0"))
	self.textField[3] = hp.uiHelper.labelBind2EditBox(Content:getChildByName("Label_5_1"))

	self.clear = Content:getChildByName("ImageView_7999")
	self.confirm = Content:getChildByName("ImageView_8000")

	self.clear:getChildByName("Label_8001"):setString(hp.lang.getStrByID(2412))
	self.confirm:getChildByName("Label_8002"):setString(hp.lang.getStrByID(1209))
end
