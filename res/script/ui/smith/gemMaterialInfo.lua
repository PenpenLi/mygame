
--
-- ui/smith/gemMaterialInfo.lua
-- 宝石/材料信息界面
--===================================
--require "ui/fullScreenFrame"

UI_gemMaterialInfo = class("UI_gemMaterialInfo", UI)

--init
function UI_gemMaterialInfo:init(type_,data_)
	-- data
	-- ===============================
	local type=type_
	local info=data_
	-- ui
	-- ===============================

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "gemInfo.json")

	-- ===============================
	
	
	--local infoP=widgetRoot:getChildByName("Panel_info")
	
	--设置锚点
	--infoP:setPosition(320,650)
	--infoP:setAnchorPoint(0.5,0.5)


	local infoPanel = widgetRoot:getChildByName("Panel_cont")
	local attrsListView=infoPanel:getChildByName("ListView_attrs")
	local attrDemo=attrsListView:getChildByName("Label_attr")
	self.attrDemo=attrDemo
	attrDemo:retain()

	attrsListView:removeAllItems()

	local title= nil
	local imgBgPath = nil
	local imgPath = nil
	if type==1 then
		title = hp.lang.getStrByID(3518)
		imgBgPath = string.format("%scolorframe_%d.png", config.dirUI.common, info.level)
		imgPath = string.format("%s%d.png", config.dirUI.gem, info.type)
		for i,v in ipairs(info.key) do
			local attrInfo = hp.gameDataLoader.getInfoBySid("attr", v)
			local attrNode=self.attrDemo:clone()
			local value="   +"..(info.value[i]/100).."%"
			attrNode:setString(attrInfo.desc..value)
			attrsListView:pushBackCustomItem(attrNode)
		end
	elseif type==2 then
		title = hp.lang.getStrByID(7714)
		imgBgPath = string.format("%scolorframe_%d.png", config.dirUI.common, info.level+1)
		imgPath = string.format("%s%d.png", config.dirUI.material, info.type)
		local attrInfo = hp.gameDataLoader.getInfoBySid("attr", info.key)
		local attrNode=self.attrDemo:clone()
		attrNode:setString(info.desc)
		attrsListView:pushBackCustomItem(attrNode)
	end

	infoPanel:getChildByName("Label_title"):setString(title)
	infoPanel:getChildByName("Image_icon_bg"):loadTexture(imgBgPath)
	infoPanel:getChildByName("Image_icon"):loadTexture(imgPath)
	infoPanel:getChildByName("Image_88_0"):getChildByName("Label_name"):setString(info.name)
	

	--关闭宝石信息面板
	local function onGemCloseTouched(sender, eventType)
		--hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	local closeGem = widgetRoot:getChildByName("Image_bg")
	closeGem:addTouchEventListener(onGemCloseTouched)



	self:addCCNode(widgetRoot)

end

--onRemove
function UI_gemMaterialInfo:onRemove()
	-- must release
	self.attrDemo:release()
	self.super.onRemove(self)
end
