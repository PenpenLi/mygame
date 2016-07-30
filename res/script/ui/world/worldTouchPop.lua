--
-- ui//world/worldTouchPop.lua
-- 世界城市点击弹出
--===================================
require "ui/UI"

UI_worldTouchPop = class("UI_worldTouchPop", UI)

local resList = {"rock", "wood", "mine", "food", "silver"}

--init
function UI_worldTouchPop:init()
	-- data
	-- ===============================	

	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)
end

function UI_worldTouchPop:initCallBack()
	local function onEnterTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "scene/kingdomMap"
			local map = kingdomMap.new()
			map:enter()
			map:gotoPosition(cc.p(255, 511), nil, self.sid)
		end
	end

	self.onEnterTouched = onEnterTouched
end

function UI_worldTouchPop:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "worldTouchPop.json")
	local content = self.wigetRoot:getChildByName("Panel_2")

	local enter_ = content:getChildByName("Image_3")
	enter_:getChildByName("Label_4"):setString(hp.lang.getStrByID(5514))
	enter_:addTouchEventListener(self.onEnterTouched)
end

function UI_worldTouchPop:show(sid_)
	self.sid = sid_
	self.layer:setVisible(true)
end

function UI_worldTouchPop:hide()
	self.layer:setVisible(false)
end