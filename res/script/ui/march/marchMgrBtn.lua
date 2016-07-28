--
-- ui/march/marchMgrBtn.lua
-- 行军管理按钮
--===================================
require "ui/UI"


UI_marchMgrBtn = class("UI_marchMgrBtn", UI)


--init
function UI_marchMgrBtn:init()
	-- data
	-- ===============================
	local function onButtonTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/march/marchManagerUI"
			ui_ = UI_marchManagerUI.new()
			self:addUI(ui_)
		end
	end

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bigMapArmyBtn.json")
	local image_ = wigetRoot:getChildByName("Panel_2"):getChildByName("Image_3")
	image_:getChildByName("Image_4"):addTouchEventListener(onButtonTouched)
	self.num = image_:getChildByName("Image_5"):getChildByName("Label_6")

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)

	self:registMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)

	self:updateInfo()
end

function UI_marchMgrBtn:updateInfo()
	self.num:setString(player.getMarchMgr().getFieldArmyNum())
end

function UI_marchMgrBtn:onMsg(msg_, param_)
	if msg_ == hp.MSG.MARCH_ARMY_NUM_CHANGE then
		self:updateInfo()
	end
end