--
-- ui/watchtower/watchtower.lua
-- 瞭望塔界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_watchtower = class("UI_watchtower", UI)


--init
function UI_watchtower:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "watchtower.json")

	local contNode = wigetRoot:getChildByName("Panel_cont")
	local descNode = contNode:getChildByName("Label_desc")
	local moreBtn = contNode:getChildByName("Image_moreInfo")
	local moreTxt = contNode:getChildByName("Label_moreInfo")
	descNode:setString(bInfo.desc)
	moreTxt:setString(hp.lang.getStrByID(2033))

	local function onItemOperTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/watchtower/watchtowerInfo"
			local moreInfoBox = UI_watchtowerInfo.new(building_)
			self:addModalUI(moreInfoBox)
		end
	end
	moreBtn:addTouchEventListener(onItemOperTouched)



	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)
end
