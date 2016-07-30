--
--
-- ui/smith/equipDesign.lua
-- 选择装备制造秘籍界面
--===================================
require "ui/fullScreenFrame"

UI_equipDesign = class("UI_equipDesign", UI)

--init
function UI_equipDesign:init(callback_)
	-- data
	-- ===============================
	local callback=callback_
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2902))
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(890)
	--uiFrame:setBottomShadePosY(200)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipDesign.json")
	local listNode = widgetRoot:getChildByName("ListView_main")
	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/smith/equipSubDesign")
			local ui = UI_equipSubDesign.new(sender:getTag(),callback)
			self:addUI(ui)
		end
	end
	for i=1,5 do

		local contItem = listNode:getChildByName("Panel_equip"..i):getChildByName("Panel_cont")
		--local label = contItem:getChildByName("Panel_cont"):getChildByName("Label_name")
		--label:setString(hp.lang.getStrByID(4100+i))
		contItem:addTouchEventListener(onItemTouched)
	end
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)
end
