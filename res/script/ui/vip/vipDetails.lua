--
-- ui/vip/vipDetails.lua
-- vip没等级详细信息界面
--===================================
require "ui/fullScreenFrame"


UI_vipDetails = class("UI_vipDetails", UI)


--init
function UI_vipDetails:init(gotoLv_)
	-- data
	-- ===============================
	local vipStatus = player.vipStatus


	local function getVIPInfoByLv( lv )
		for i, vipInfo in ipairs(game.data.vip) do
			if lv==vipInfo.level then
				return vipInfo
			end
		end

		return nil
	end

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle("VIP")
	uiFrame:setBgImg(config.dirUI.common .. "frame_bg1.png")
	uiFrame:setTopShadePosY(888)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "vipDetails.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)

	--
	-- ===============================
	-- cont
	local contNode = wigetRoot:getChildByName("Panel_cont")
	local descLabel = contNode:getChildByName("Label_desc")
	local pagePointNodes = {}
	for i=1,10 do
		pagePointNodes[i] = contNode:getChildByTag(i)
	end
	--pageView
	local pageView = wigetRoot:getChildByName("PagetView_vip")
	local pageModelItem = pageView:getPage(0)

	-- 动态更新
	local function onActivateBtnTouched(sender, eventType)
		if vipStatus.isActive() then
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/commonItem")
			local ui = UI_commonItem.new(20000, hp.lang.getStrByID(3703))
			self:addUI(ui)
		end
	end
	local function onGetPointsTouched(sender, eventType)
		if sender:getTag()<=vipStatus.getLv() then
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/commonItem")
			local ui = UI_commonItem.new(20050, hp.lang.getStrByID(3715))
			self:addUI(ui)
		end
	end

	local pageItems = {}
	local function updatePageItem( pageNum )
		local pageStart = pageNum-1
		local pageEnd = pageNum+1
		if pageStart<1 then
			pageStart = 1
		end
		if pageEnd>10 then
			pageEnd = 10
		end

		local curPoints = vipStatus.getPoints()
		for i=pageStart, pageEnd do
			if pageItems[i]==nil then
				local pageItem = pageView:getPage(i-1)
				pageItems[i] = pageItem
				local pageIcon = pageItem:getChildByName("Panel_cont"):getChildByName("Image_vip")
				pageIcon:loadTexture(config.dirUI.common .. "vip_icon_" .. i ..".png")
				-- 设置奖励信息
				local awardList = pageItem:getChildByName("ListView_award")
				local awardItem = awardList:getItem(0)
				local vipInfo = getVIPInfoByLv(i)
				local itemNum = 0
				local itemTmp = nil
				local function addItem( itemText )
					itemTmp = awardItem
					if itemNum==0 then
						itemTmp = awardItem
					else
						itemTmp = awardItem:clone()
						awardList:pushBackCustomItem(itemTmp)
					end
					itemTmp:getChildByName("Panel_cont"):getChildByName("Label_text"):setString(itemText)
					itemNum = itemNum+1
				end
				
				if vipInfo["award19"]>0 then
					addItem(hp.lang.getStrByID(3739))
				end
				for i=1, 18 do
					local tmp = vipInfo["award"..i]
					if type(tmp)=="table" then
						if tmp[2]>0 then
							addItem(string.format(hp.lang.getStrByID(3720+i), tmp[2]/100))
						end
					else
						if i==1 then
							if tmp>0 then
								addItem(string.format(hp.lang.getStrByID(3720+i), tmp/60))
							end
						elseif i==7 then
							if tmp~="-1" then
								addItem(tmp)
							end
						elseif i>=8 and i<=10 then
							if tmp>0 then
								addItem(string.format(hp.lang.getStrByID(3720+i), tmp))
							end
						elseif i>=13 and i<=15 then
							if tmp>0 then
								addItem(hp.lang.getStrByID(3720+i))
							end
						end
					end
				end
				-- 判断积分是否达到、是否激活
				if vipStatus.getLv()==i then
					if vipStatus.isActive() then
					else
						local panelTmp = pageItem:getChildByName("Panel_activate")
						local activeBtn = panelTmp:getChildByName("Image_activate")
						local activeLabel = panelTmp:getChildByName("Label_text")
						panelTmp:setVisible(true)
						activeBtn:setTouchEnabled(true)
						activeBtn:addTouchEventListener(onActivateBtnTouched)
						activeLabel:setString(hp.lang.getStrByID(3717))
					end
				elseif vipStatus.getLv()<i then
					local panelTmp = pageItem:getChildByName("Panel_getPoints")
					local pointsLabel = panelTmp:getChildByName("Label_text")
					local getBtn = panelTmp:getChildByName("Image_get")
					local getLabel = panelTmp:getChildByName("Label_get")
					panelTmp:setVisible(true)
					pointsLabel:setString(string.format(hp.lang.getStrByID(3716), vipInfo.points - curPoints))
					getBtn:setTouchEnabled(true)
					getBtn:addTouchEventListener(onGetPointsTouched)
					getBtn:setTag(i)
					getLabel:setString(hp.lang.getStrByID(3702))
				end
			end
		end
	end
	
	local curLv = 0
	local function onPageEvent(sender, eventType)
		if curLv>0 then
			pagePointNodes[curLv]:loadTexture(config.dirUI.common .. "page_point_off.png")
		end
		curLv = pageView:getCurPageIndex() + 1
		pagePointNodes[curLv]:loadTexture(config.dirUI.common .. "page_point_on.png")
		updatePageItem(curLv)
	end
	pageView:addEventListenerPageView(onPageEvent)

	for i=1, 9 do
		pageView:addPage(pageModelItem:clone())
	end
	
	pageView:scrollToPage(gotoLv_ -1)
	onPageEvent(pageView, 0)


	local function refreshPageItems()
		curPoints = vipStatus.getPoints()
		for i, pageItem in pairs(pageItems) do
			local vipInfo = getVIPInfoByLv(i)
			-- 判断积分是否达到、是否激活
			if vipStatus.getLv()==i then
				if vipStatus.isActive() then
					pageItem:getChildByName("Panel_activate"):setVisible(false)
					pageItem:getChildByName("Panel_getPoints"):setVisible(false)
				else
					local panelTmp = pageItem:getChildByName("Panel_activate")
					local activeBtn = panelTmp:getChildByName("Image_activate")
					local activeLabel = panelTmp:getChildByName("Label_text")
					panelTmp:setVisible(true)
					activeBtn:setTouchEnabled(true)
					activeBtn:addTouchEventListener(onActivateBtnTouched)
					activeLabel:setString(hp.lang.getStrByID(3717))
				end
			elseif vipStatus.getLv()<i then
				local panelTmp = pageItem:getChildByName("Panel_getPoints")
				local pointsLabel = panelTmp:getChildByName("Label_text")
				pointsLabel:setString(string.format(hp.lang.getStrByID(3716), vipInfo.points - curPoints))
			else
				pageItem:getChildByName("Panel_activate"):setVisible(false)
				pageItem:getChildByName("Panel_getPoints"):setVisible(false)
			end
		end
	end

	self.refreshPageItems = refreshPageItems

	self:registMsg(hp.MSG.VIP)
end

-- onMsg
function UI_vipDetails:onMsg(msg_, param_)
	if msg_==hp.MSG.VIP then
		self.refreshPageItems()
	end
end
