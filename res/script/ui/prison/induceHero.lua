--
-- ui/prison/induceHero.lua
-- 监狱劝降英雄界面
--===================================


UI_induceHero = class("UI_induceHero", UI)


--init
function UI_induceHero:init(building_, prisonMgr_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo
	local prisonMgr = prisonMgr_

	local curSelectItem = nil
	local itemSid = 20851
	self.itemSid = itemSid
	local itemInfo = hp.gameDataLoader.getInfoBySid("item", itemSid)


	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "prison_induceHero.json")


	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)

	--
	-- ===============================
	-- cont
	local contPanel = wigetRoot:getChildByName("Panel_headCont")
	local induceBtn = contPanel:getChildByName("Image_induce")
	local itemBg = contPanel:getChildByName("Image_item")
	local itemIcon = itemBg:getChildByName("Image_icon")
	local itemName = itemBg:getChildByName("Label_text")
	local function buyItem()
		require("ui/item/commonItem")
		local ui = UI_commonItem.new(itemSid, hp.lang.getStrByID(2839))
		self:addUI(ui)
	end
	local function induce()
		prisonMgr.induceHero(curSelectItem:getTag())
	end
	local function onInduceTouched(sender, eventType)
		if curSelectItem==nil then
			return
		end
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then

			if player.getItemNum(itemSid)<=0 then
			-- 道具不足
				require "ui/msgBox/msgBox"
				local text = string.format(hp.lang.getStrByID(4013), itemInfo.name)
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(4012), text, hp.lang.getStrByID(1209),
					hp.lang.getStrByID(2412), buyItem)
				self:addModalUI(msgBox)
			elseif prisonMgr.getInduceCD()>0 then
			-- 劝降cd中
				require "ui/msgBox/msgBox"
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(4005), hp.lang.getStrByID(4016), hp.lang.getStrByID(1209))
				self:addModalUI(msgBox)
			else
			-- 可以劝降
				require "ui/msgBox/msgBox"
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(4005), hp.lang.getStrByID(4015), hp.lang.getStrByID(1209),
					hp.lang.getStrByID(2412), induce)
				self:addModalUI(msgBox)
			end
		end
	end
	induceBtn:addTouchEventListener(onInduceTouched)
	induceBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(4005))
	itemIcon:loadTexture(config.dirUI.item .. itemSid .. ".png")
	local itemDefColor = itemName:getColor()
	local function setItemInfo()
		local itemNum = player.getItemNum(itemSid)
		itemName:setString(string.format("%s: %d/1", itemInfo.name, itemNum))
		if itemNum>0 then
			itemName:setColor(itemDefColor)
		else
			itemName:setColor(cc.c3b(255, 0, 0))
		end
	end
	setItemInfo()
	self.setItemInfo = setItemInfo

	-- list
	local infoListView = wigetRoot:getChildByName("ListView_info")
	local cdItem = infoListView:getItem(0):clone()
	local descItem = infoListView:getItem(1)
	local heroItem = infoListView:getItem(2)
	cdItem:retain()
	self.cdItem = cdItem
	heroItem:retain()
	self.heroItem = heroItem
	infoListView:removeItem(2)
	infoListView:removeItem(0)
	descItem:getChildByName("Panel_cont"):getChildByName("Label_desc"):setString(hp.lang.getStrByID(4014))
	cdItem:getChildByName("Panel_cont"):getChildByName("Label_name"):setString(hp.lang.getStrByID(4005))

	local cdState = false
	local cdNode = nil
	local prcessNode = nil
	local function setCDStateInfo(checkFlag)
		local cd = prisonMgr.getInduceCD()
		if checkFlag then
			if cd>0 then
				if cdState==false then
					local item = cdItem:clone()
					infoListView:insertCustomItem(item, 0)
					cdState = true
					cdNode = item:getChildByName("Panel_cont"):getChildByName("Label_time")
					prcessNode = item:getChildByName("Panel_frame"):getChildByName("Image_proBg"):getChildByName("ProgressBar_cd")
				end
				cdNode:setString(hp.datetime.strTime(cd))
				prcessNode:setPercent((3600-cd)*100/3600)


			else
				if cdState==true then
					infoListView:removeItem(0)
					cdState = false
					cdNode = nil
				end
			end
		else
			if cdState and cdNode~=nil then
				cdNode:setString(hp.datetime.strTime(cd))
				prcessNode:setPercent((3600-cd)*100/3600)
			end
		end
	end
	self.setCDStateInfo = setCDStateInfo
	setCDStateInfo(true)

	local function setCurSelectItem(item_)
		if curSelectItem~=nil then
			curSelectItem:getChildByName("Image_selected"):setVisible(false)
		else
			if item_~=nil then
				induceBtn:loadTexture(config.dirUI.common .. "button_blue.png")
				induceBtn:setTouchEnabled(true)
			end
		end
		curSelectItem = item_
		if curSelectItem~=nil then
			curSelectItem:getChildByName("Image_selected"):setVisible(true)
		else
			induceBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			induceBtn:setTouchEnabled(false)
		end
	end
	setCurSelectItem(nil)
	local function onItemTouched(sender, eventType)
		if sender==curSelectItem then
			return
		end
		setCurSelectItem(sender)
	end
	local heroItemNum = 0
	local function refreshInfoList()
		-- 移除之前的
		local itemIndex = 0
		if cdState then
			itemIndex = heroItemNum+1
		else
			itemIndex = heroItemNum
		end
		for i=1, heroItemNum do
			infoListView:removeItem(itemIndex)
			itemIndex = itemIndex-1
		end
		-- 重新加载
		local heroList = prisonMgr.getHeros()
		local killCD = prisonMgr.getKillCD()
		curSelectItem = nil
		for i, heroInfo in ipairs(heroList) do
			local heroConstInfo = hp.gameDataLoader.getInfoBySid("hero", heroInfo.sid)
			-- 只有没有被处决的名将才能招降
			if heroConstInfo and heroConstInfo.soleFlag==1 then
				if killCD.cd<0 or heroInfo.ownerID~=killCD.ownerID or heroInfo.id~=killCD.id then
					local item = heroItem:clone()
					infoListView:pushBackCustomItem(item)
					item:setTag(heroInfo.localID)
					local panelFrame = item:getChildByName("Panel_frame")
					local panelCont = item:getChildByName("Panel_cont")
					local iconNode = panelCont:getChildByName("ImageView_icon")
					local nameNode = panelCont:getChildByName("Label_name")
					local lvNode = panelCont:getChildByName("Label_level")
					local descNode = panelCont:getChildByName("Label_desc")
					local loyNameNode = panelCont:getChildByName("Label_loy")
					local loyNumNode = panelCont:getChildByName("Label_loyNum")
					local sucNode = panelCont:getChildByName("Label_success")
					local progLoy = panelFrame:getChildByName("Image_proBg"):getChildByName("ProgressBar_loy")

					panelFrame:setTag(heroInfo.localID)
					panelFrame:addTouchEventListener(onItemTouched)

					iconNode:loadTexture(config.dirUI.heroHeadpic .. heroInfo.sid .. ".png")
					nameNode:setString(string.format(hp.lang.getStrByID(4006), heroInfo.name))
					lvNode:setString(string.format(hp.lang.getStrByID(4008), heroInfo.lv))
					descNode:setString(heroConstInfo.desc)
					loyNameNode:setString(hp.lang.getStrByID(4010))
					loyNumNode:setString(string.format("%d/%d", heroInfo.loyalty, heroInfo.tatoalLoyalty))
					local succ = (heroInfo.tatoalLoyalty-heroInfo.loyalty)*100/heroInfo.tatoalLoyalty*0.5
					progLoy:setPercent(succ)
					sucNode:setString(string.format(hp.lang.getStrByID(4011), succ))
					heroItemNum = heroItemNum+1
				end
			end
		end
	end 
	refreshInfoList()
	self.refreshInfoList = refreshInfoList

	-- 移除一项
	local function removeHeroItem( heroInfo )
		local listItem = infoListView:getChildByTag(heroInfo.localID)
		if listItem~=nil then
			infoListView:removeItem(infoListView:getIndex(listItem))
		end
	end
	self.removeHeroItem = removeHeroItem

	-- registMsg
	self:registMsg(hp.MSG.PRISON_MGR)
	self:registMsg(hp.MSG.ITEM_CHANGED)
end


--onRemove
function UI_induceHero:onRemove()
	-- must release
	self.cdItem:release()
	self.heroItem:release()

	self.super.onRemove(self)
end

-- onMsg
function UI_induceHero:onMsg(msg_, param_)
	if msg_==hp.MSG.PRISON_MGR then
		if param_.type==1 then
			self.setCDStateInfo(true)
			self.refreshInfoList()
		elseif param_.type==2 then
			self.removeHeroItem(param_.hero)
		elseif param_.type==3 then
			--self.refreshHeroListOper()
		elseif param_.type==4 then
			self.refreshInfoList()
		elseif param_.type==5 then
			self.setCDStateInfo(true)
		end
	elseif msg_==hp.MSG.ITEM_CHANGED then
		if param_.sid==self.itemSid then
			self.setItemInfo()
		end
	end
end

-- heartbeat
function UI_induceHero:heartbeat(dt)
	self.setCDStateInfo(false)
end