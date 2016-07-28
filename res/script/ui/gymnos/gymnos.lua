--
-- ui/gymnos/gymnos.lua
-- 别院界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_gymnos = class("UI_gymnos", UI)


--init
function UI_gymnos:init(building_)
	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo
	local gymnosInfo = nil
	for i, v in ipairs(game.data.gymnos) do
		if b.lv==v.level then
			gymnosInfo = v
			break
		end
	end


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "gymnos.json")

	--
	local contNode = wigetRoot:getChildByName("Panel_cont")
	local descNode = contNode:getChildByName("Label_desc")
	local moreBtn = contNode:getChildByName("Image_moreInfo")
	local moreTxt = contNode:getChildByName("Label_moreInfo")
	descNode:setString(bInfo.desc)
	moreTxt:setString(hp.lang.getStrByID(2033))
	local function onItemOperTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/gymnos/gymnosInfo"
			local moreInfoBox = UI_gymnosInfo.new(building_)
			self:addModalUI(moreInfoBox)
		end
	end
	moreBtn:addTouchEventListener(onItemOperTouched)

	--
	local bonusNode = contNode:getChildByName("Image_bonus")
	local retainNode = contNode:getChildByName("Image_retain")
	bonusNode:getChildByName("Label_name"):setString(hp.lang.getStrByID(3201))
	bonusNode:getChildByName("Label_desc"):setString(hp.lang.getStrByID(3202))
	bonusNode:getChildByName("Label_num"):setString(string.format("%d%%", gymnosInfo.extraExpRate))
	retainNode:getChildByName("Label_name"):setString(hp.lang.getStrByID(3203))
	retainNode:getChildByName("Label_desc"):setString(hp.lang.getStrByID(3204))
	retainNode:getChildByName("Label_num"):setString(string.format("%d%%", gymnosInfo.deadSpareExpRate))



	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)
end
