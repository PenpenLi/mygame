--
-- ui/bigMap/battle/fortressPopInfo.lua
-- 要塞弹出信息
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_fortressPopInfo = class("UI_fortressPopInfo", UI)

--init
function UI_fortressPopInfo:init()
	-- data
	-- ===============================

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5443))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	local function onGotoFortressTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			game.curScene:gotoPosition(cc.p(255, 511))
			self:close()
		end
	end

	self.gotoFortress:addTouchEventListener(onGotoFortressTouched)

	self:tickUpdate()
end

function UI_fortressPopInfo:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fortressPopInfo.json")
	local content_ = self.wigetRoot:getChildByName("Panel_6")

	content_:getChildByName("Label_7"):setString(hp.lang.getStrByID(5444))
	content_:getChildByName("Label_7_0"):setString(hp.lang.getStrByID(5445))
	content_:getChildByName("Label_7_1"):setString(hp.lang.getStrByID(5446))

	content_:getChildByName("Label_11"):setString(hp.lang.getStrByID(5447))
	content_:getChildByName("Label_11_0"):setString(hp.lang.getStrByID(5448))
	content_:getChildByName("Label_11_1"):setString(hp.lang.getStrByID(5449))

	self.desc = content_:getChildByName("Label_15")
	self.gotoFortress = content_:getChildByName("Image_16")
	self.gotoFortress:getChildByName("Label_17"):setString(hp.lang.getStrByID(5450))
end

function UI_fortressPopInfo:tickUpdate()
	local info_ = player.fortressMgr.getFortressInfo()
	local status_ = globalData.OPEN_STATUS
	if info_.open == status_.OPEN then
		local time_ = info_.endTime - player.getServerTime()
		self.desc:setString(string.format(hp.lang.getStrByID(5383), hp.datetime.strTime(time_)))
	elseif info_.open == status_.NOT_OPEN then
		local time_ = info_.startTime - player.getServerTime()
		self.desc:setString(string.format(hp.lang.getStrByID(5357), hp.datetime.strTime(info_.startTime - player.getServerTime())))
	end
end

function UI_fortressPopInfo:heartbeat(dt_)
	self:tickUpdate()
end