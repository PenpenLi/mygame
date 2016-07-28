--
-- ui/cityMap/freeDiamond.lua
-- 免费钻石
--===================================


UI_freeDiamond = class("UI_freeDiamond", UI)


--init
function UI_freeDiamond:init()
	-- data
	-- ===============================
	local onlineGift = player.onlineGift

	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "rotateDiamond.json")
	local content_ = widgetRoot:getChildByName("Panel_1")
	local diamond_ = content_:getChildByName("Image_2")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)

	-- add animation
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(config.dirUI.animation.."diamond.ExportJson")
	local amature_ = ccs.Armature:create("diamond")
	amature_:getAnimation():play("aniDiamond")
	local x_, y_ = diamond_:getPosition()
	local sz_ = diamond_:getSize()
	amature_:setPosition(sz_.width / 2, sz_.height / 2)
	amature_:setScale(1.5)
	diamond_:addChild(amature_)

	--	logic
	-- ===============================
	local function onOperTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/guide/joinUnion"
			ui_ = UI_unionJoinDiamond.new()
			self:addModalUI(ui_)
		end
	end
	diamond_:addTouchEventListener(onOperTouched)
end
