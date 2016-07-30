--
-- ui/mansion/manager.lua
-- 总管展示页面
--===================================
require "ui/fullScreenFrame"
require "ui/common/promotionInfo"

UI_manager = class("UI_manager", UI)


--init
function UI_manager:init(building_)
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "manager.json")
	
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(8101))
	uiFrame:setTopShadePosY(770)

	local promotionUI = UI_promotionInfo.new()
	
	local panelCont = wigetRoot:getChildByName("Panel_cont")
	
	local btnItem = panelCont:getChildByName("Image_btnItem")
	local btnEquip = panelCont:getChildByName("Image_btnEquip")
	local btnMaterial = panelCont:getChildByName("Image_btnMaterial")
	local btnGem = panelCont:getChildByName("Image_btnGem")
	local btnUnionShop = panelCont:getChildByName("Image_btnUnionShop")
	local btnUnionItemList = panelCont:getChildByName("Image_btnUnionItemList")
	local btnItemShop = panelCont:getChildByName("Image_btnItemShop")
	
	btnItem:getChildByName("Label_item"):setString(hp.lang.getStrByID(8102))
	btnEquip:getChildByName("Label_equip"):setString(hp.lang.getStrByID(8103))
	btnMaterial:getChildByName("Label_Material"):setString(hp.lang.getStrByID(8104))
	btnGem:getChildByName("Label_Gem"):setString(hp.lang.getStrByID(8105))
	btnUnionShop:getChildByName("Label_UnionShop"):setString(hp.lang.getStrByID(8106))
	btnUnionItemList:getChildByName("Label_UnionItemList"):setString(hp.lang.getStrByID(8107))
	btnItemShop:getChildByName("Label_itemShop"):setString(hp.lang.getStrByID(8108))
	
	
	local function btnCallback(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			if sender == btnItem then
				require "ui/item/shopItem.lua"
				local ui_ = UI_shopItem.new(2)
				self:addUI(ui_)
			elseif sender == btnEquip or sender == btnMaterial or sender == btnGem then
				local building=game.curScene:getBuildingBySid(1011)
				if building == nil then
					require "ui/common/noBuildingNotice"
					local ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(2913), 1011, 1)
					self:addUI(ui_)
				else
					if sender == btnEquip then
						require "ui/smith/equipBag.lua"
						local ui_ = UI_equipBag.new()
						self:addUI(ui_)
					elseif sender == btnMaterial then
						require "ui/smith/material_gem.lua"
						local ui_ = UI_material_gem.new(2)
						self:addUI(ui_)
					elseif sender == btnGem then
						require "ui/smith/material_gem.lua"
						local ui_ = UI_material_gem.new(1)
						self:addUI(ui_)
					end
				end	
			elseif sender == btnUnionShop then
				
				if player.getAlliance():getUnionID() == 0 then
					require "ui/msgBox/msgBox"
					local msgbox = nil
					local msgTips = hp.lang.getStrByID(8148)
					local msgIs = hp.lang.getStrByID(6035)
					local ts = hp.lang.getStrByID(1191)
					msgbox = UI_msgBox.new(ts,msgTips,msgIs)
					self:addUI(msgbox)
				else
					require "ui/union/shop/unionShop.lua"
					local ui_ = UI_unionShop.new()
					self:addUI(ui_)
				end
				
			elseif sender == btnUnionItemList then
			
				if player.getAlliance():getUnionID() == 0 then
					require "ui/msgBox/msgBox"
					local msgbox = nil
					local msgTips = hp.lang.getStrByID(8148)
					local msgIs = hp.lang.getStrByID(6035)
					local ts = hp.lang.getStrByID(1191)
					msgbox = UI_msgBox.new(ts,msgTips,msgIs)
					self:addUI(msgbox)
				else
					require "ui/union/shop/unionShopCatalog"
					local ui_ = UI_unionShopCatalog.new()
					self:addUI(ui_)
				end
			
			elseif sender == btnItemShop then
				require "ui/item/shopItem.lua"
				local ui_ = UI_shopItem.new(1)
				self:addUI(ui_)
			
			else
			
			end
			
		end
	end
		
	btnItem:addTouchEventListener(btnCallback)
	btnEquip:addTouchEventListener(btnCallback)
	btnMaterial:addTouchEventListener(btnCallback)
	btnGem:addTouchEventListener(btnCallback)
	btnUnionShop:addTouchEventListener(btnCallback)
	btnUnionItemList:addTouchEventListener(btnCallback)
	btnItemShop:addTouchEventListener(btnCallback)
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(promotionUI)
	self:addCCNode(wigetRoot)
end
