--
-- ui/smith/equipInfo.lua
-- 装备信息界面
--===================================
--require "ui/fullScreenFrame"

UI_equipInfo = class("UI_equipInfo", UI)

--init
function UI_equipInfo:init(equipInfo_,level_)
	-- data
	-- ===============================
	local equipInfo=equipInfo_
	local level=1
	if level_ ~= nil then
		level=level_
	end
	-- ui
	-- ===============================

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipInfo.json")

	-- ===============================
	self:addCCNode(widgetRoot)
	

	local infoPanel = widgetRoot:getChildByName("Panel_info")
	infoPanel:getChildByName("Image_title"):getChildByName("Label_title"):setString(hp.lang.getStrByID(2908))

	local attrsListView=widgetRoot:getChildByName("ListView_attrs")
	local attrDemo=attrsListView:getChildByName("Panel_att_demo")
	self.attrDemo=attrDemo

	attrDemo:retain()
	infoPanel:getChildByName("Image_icon_bg"):loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, level))
	infoPanel:getChildByName("Image_icon_bg"):getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.equip, equipInfo.sid))
	infoPanel:getChildByName("Image_name"):getChildByName("Label_name"):setString(equipInfo.name)
	infoPanel:getChildByName("Label_desc"):setString(equipInfo.desc)
	infoPanel:getChildByName("Label_mustlv"):setString(string.format(hp.lang.getStrByID(3503), equipInfo.mustLv))
	infoPanel:getChildByName("Label_0"):setString(hp.lang.getStrByID(2907))


	-- 显示品质信息
	local function showQuaInfo(level)
		attrsListView:removeAllItems()
		if equipInfo.type1 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type1)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value="      +"..(equipInfo.value1[level]/100).."%"
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				attrsListView:pushBackCustomItem(contAttr)
			end
		end
		if equipInfo.type2 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type2)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value="      +"..(equipInfo.value2[level]/100).."%"
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				attrsListView:pushBackCustomItem(contAttr)
			end
		end
		if equipInfo.type3 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type3)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value="      +"..(equipInfo.value3[level]/100).."%"
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				attrsListView:pushBackCustomItem(contAttr)
			end
		end
		-- 选中对应品质
		local node = nil
		for i=1,6 do
			node = infoPanel:getChildByName("Image_"..i)
			if i==level then
				node:getChildByName("Image_select"):setVisible(true)
			else
				node:getChildByName("Image_select"):setVisible(false)
			end
		end
	end

	--点击品质按钮
	local function onQuaTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local lv=sender:getTag()
			infoPanel:getChildByName("Image_icon_bg"):loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, lv))
			showQuaInfo(lv)
		end
	end

	for i=1,6 do
		infoPanel:getChildByName("Image_"..i):addTouchEventListener(onQuaTouched)
	end

	--关闭信息面板
	local function onCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end
	local closeBtn = infoPanel:getChildByName("ImageView_close")
	closeBtn:addTouchEventListener(onCloseTouched)

	showQuaInfo(level)
end

--onRemove
function UI_equipInfo:onRemove()
	-- must release
	self.attrDemo:release()
	self.super.onRemove(self)
end
