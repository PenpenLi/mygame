--
-- ui/union/unionBigFightNoFight.lua
-- 没有大型作战
--===================================
require "ui/fullScreenFrame"

UI_unionBigFightNoFight = class("UI_unionBigFightNoFight", UI)

--init
function UI_unionBigFightNoFight:init(tab_)
	-- data
	-- ===============================

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5136))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_unionBigFightNoFight:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "noBigFight.json")
	local content_ = self.wigetRoot:getChildByName("Panel_29874_Copy0_0_0")

	local moreInfo_ = content_:getChildByName("Image_48")
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
	moreInfo_:getChildByName("Label_49"):setString(hp.lang.getStrByID(1030))

	content_:getChildByName("Label_6"):setString(hp.lang.getStrByID(5054))
	content_:getChildByName("Label_13"):setString(hp.lang.getStrByID(5055))
end

function UI_unionBigFightNoFight:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
		end
	end

	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionBigFightNoFight:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.SMALFIGHT then
		end
	end
end