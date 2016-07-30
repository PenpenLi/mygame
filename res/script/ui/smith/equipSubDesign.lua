--
--
-- ui/smith/equipSubDesign.lua
-- 选择装备制造秘籍子界面(装备分类)
--===================================
require "ui/fullScreenFrame"

UI_equipSubDesign = class("UI_equipSubDesign", UI)

--init
function UI_equipSubDesign:init(type_,callback_)
	-- data
	-- ===============================
	local callback=callback_
	local etype = type_
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2902))
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(890)
	--uiFrame:setBottomShadePosY(200)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipSubDesign.json")
	local listNode = widgetRoot:getChildByName("ListView_main")
	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/smith/equipDesignDetail")
			local ui = UI_equipDesignDetail.new(etype,sender:getTag(),callback)
			self:addUI(ui)
		end
	end
	--local nodes=listNode:getChildren()
	local nodes=listNode:getItems()
	for i,v in ipairs(nodes) do
		local contItem = v:getChildByName("Panel_cont")
		--local label = contItem:getChildByName("Panel_cont"):getChildByName("Label_name")
		--label:setString(hp.lang.getStrByID(4100+i))
		contItem:addTouchEventListener(onItemTouched)
	end
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)
end
