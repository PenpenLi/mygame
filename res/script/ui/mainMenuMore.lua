--
-- ui/mainMenuMore.lua
-- 主菜单
--===================================
require "ui/fullScreenFrame"
require "ui/common/promotionInfo"


UI_mainMenuMore = class("UI_mainMenuMore", UI)


--init
function UI_mainMenuMore:init(selectedIndex_)
	-- data
	-- ===============================


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(10700))
	uiFrame:setTopShadePosY(766)
	local promotionUI = UI_promotionInfo.new()
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "mainMenuMore.json")
	self:addChildUI(uiFrame)
	self:addChildUI(promotionUI)
	self:addCCNode(wigetRoot)

	--
	local itemList = wigetRoot:getChildByName("ListView_items")
	local itemsCont = itemList:getItem(0):getChildByName("Panel_cont")

	-- 任务
	local questBg = itemsCont:getChildByName("Image_quest")
	local questIcon = questBg:getChildByName("Image_icon")
	questBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10701))
	-- 道具
	local itemBg = itemsCont:getChildByName("Image_item")
	local itemIcon = itemBg:getChildByName("Image_icon")
	itemBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10702))
	-- --联盟
	-- local unionBg = itemsCont:getChildByName("Image_union")
	-- local unionIcon = unionBg:getChildByName("Image_icon")
	-- unionBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10703))
	-- -- 邮件
	-- local mailBg = itemsCont:getChildByName("Image_mail")
	-- local mailIcon = mailBg:getChildByName("Image_icon")
	-- mailBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10704))
	-- 客服
	local serviceBg = itemsCont:getChildByName("Image_service")
	local serviceIcon = serviceBg:getChildByName("Image_icon")
	serviceBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10705))
	-- 设置
	local logoutBg = itemsCont:getChildByName("Image_logout")
	local logoutIcon = logoutBg:getChildByName("Image_icon")
	logoutBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10706))
	-- 设置
	local pushBg = itemsCont:getChildByName("Image_push")
	local pushIcon = pushBg:getChildByName("Image_icon")
	pushBg:getChildByName("Label_name"):setString(hp.lang.getStrByID(10707))

	local function onItemTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==questIcon then
				require "ui/quest/questMain"
				local ui_ = UI_questMain.new()
				self:addUI(ui_)
			elseif sender==itemIcon then
				require("ui/item/shopItem")
				local ui = UI_shopItem.new()
				self:addUI(ui)
			-- elseif sender==unionIcon then
			-- 	if player.getAlliance():getUnionID() == 0 then
			-- 		require("ui/union/invite/unionCreate")
			-- 		local ui = UI_unionCreate.new()
			-- 		self:addUI(ui)
			-- 	else
			-- 		require "ui/union/unionMain"
			-- 		local ui_ = UI_unionMain.new()
			-- 		self:addUI(ui_)
			-- 	end
			-- elseif sender==mailIcon then		
			-- 	require("ui/mail/mail")
			-- 	local ui = UI_mail.new()
			-- 	self:addUI(ui)
			elseif sender==serviceIcon then
				require("ui/msgBox/msgBox")
				local ui = UI_msgBox.new(hp.lang.getStrByID(10705), hp.lang.getStrByID(10751),
									hp.lang.getStrByID(10603))
				self:addModalUI(ui)
			elseif sender==logoutIcon then
				require "ui/options"
				local ui_ = UI_options.new()
				self:addUI(ui_)
			elseif sender==pushIcon then
				require "ui/common/pushConfig"
				local ui_ = UI_pushConfig.new()
				self:addUI(ui_)
			end
		end
	end

	questIcon:addTouchEventListener(onItemTouched)
	itemIcon:addTouchEventListener(onItemTouched)
	--unionIcon:addTouchEventListener(onItemTouched)
	--mailIcon:addTouchEventListener(onItemTouched)
	logoutIcon:addTouchEventListener(onItemTouched)
	pushIcon:addTouchEventListener(onItemTouched)
	serviceIcon:addTouchEventListener(onItemTouched)
end


-- onMsg
function UI_mainMenuMore:onMsg(msg_, parm_)
end