--
-- ui/world/worldSearch.lua
-- 查找
--===================================
require "ui/UI"

UI_worldSearch = class("UI_worldSearch", UI)


--init
function UI_worldSearch:init()
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
			local kName = self.textField[1]:getString()
			game.curScene:gotoPosition(kName)
			self:close()
		end
	end

	self.clear:addTouchEventListener(OnClearTouched)
	self.confirm:addTouchEventListener(OnConfirmTouched)
end

function UI_worldSearch:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "worldSearch.json")
	local Content = self.wigetRoot:getChildByName("Panel_7990")

	Content:getChildByName("Label_7991"):setString(hp.lang.getStrByID(1217))
	self.textField = {}
	self.textField[1] = hp.uiHelper.labelBind2EditBox(Content:getChildByName("Label_5"))
	-- local curPosition = game.curScene:getCurPosition()
	-- local curServer = player.serverMgr.getServerByPos(curPosition.kx, curPosition.ky)
	-- self.textField[1].setString(curServer.name)
	self.textField[1].setString(player.serverMgr.getMyServer().name)

	self.clear = Content:getChildByName("ImageView_7999")
	self.confirm = Content:getChildByName("ImageView_8000")

	self.clear:getChildByName("Label_8001"):setString(hp.lang.getStrByID(2412))
	self.confirm:getChildByName("Label_8002"):setString(hp.lang.getStrByID(1209))
end
