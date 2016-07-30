--
-- ui/prison/killHero.lua
-- 监狱处决英雄界面
--===================================


UI_killHero = class("UI_killHero", UI)


--init
function UI_killHero:init(building_, prisonMgr_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo
	local prisonMgr = prisonMgr_
	local killCD = prisonMgr.getKillCD()

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "prison_killHero.json")


	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)


	-- 
	-- ===============================
	local heroListView = wigetRoot:getChildByName("ListView_info")
	local modelItem = heroListView:getItem(0)
	local itemCont = modelItem:getChildByName("Panel_cont")
	itemCont:getChildByName("ImageView_free"):getChildByName("Label_text"):setString(hp.lang.getStrByID(4003))
	itemCont:getChildByName("ImageView_kill"):getChildByName("Label_text"):setString(hp.lang.getStrByID(4004))
	itemCont:getChildByName("ImageView_killCD"):getChildByName("Label_text"):setString(hp.lang.getStrByID(4004))
	heroListView:setItemModel(modelItem)
	heroListView:removeAllItems()
	
	local btnMoreInfo = wigetRoot:getChildByName("Panel_headCont"):getChildByName("Image_moreInfo")

	local function onFreeBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			prisonMgr.freeHero(sender:getTag())
		end
	end
	local function onKillBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			prisonMgr.killHero(sender:getTag())
		end
	end
	-- 刷新英雄的操作
	local itemCDNodes = {}
	local killCDNode = nil
	local function refreshHeroListOper()
		local heroList = prisonMgr.getHeros()
		itemCDNodes = {}
		killCDNode = nil
		for i, heroInfo in ipairs(heroList) do
			local item = heroListView:getItem(i-1)
			local itemCont = item:getChildByName("Panel_cont")
			local timeNode = itemCont:getChildByName("Label_time")
			local btnFree = itemCont:getChildByName("ImageView_free")
			local btnKill = itemCont:getChildByName("ImageView_kill")
			local btnKillCD = itemCont:getChildByName("ImageView_killCD")
			itemCDNodes[i] = {}
			itemCDNodes[i].node = timeNode
			itemCDNodes[i].localID = heroInfo.localID
			timeNode:setString(string.format(hp.lang.getStrByID(4009), hp.datetime.strTime(heroInfo.leaveTime)))

			if killCD.cd>0 then
			-- 正在斩杀一个英雄
				btnKill:setTouchEnabled(false)
				if killCD.ownerID==heroInfo.ownerID and killCD.id==heroInfo.id then
				-- 斩杀的是这个英雄
					btnFree:setTouchEnabled(false)
					btnFree:loadTexture(config.dirUI.common .. "button_gray.png")
					btnKill:setVisible(false)
					btnKillCD:setVisible(true)
					killCDNode = btnKillCD:getChildByName("Label_cd")
					killCDNode:setString(hp.datetime.strTime(killCD.cd))
				else
					btnFree:setTag(heroInfo.localID)
					btnFree:setTouchEnabled(true)
					btnFree:addTouchEventListener(onFreeBtnTouched)
					btnFree:loadTexture(config.dirUI.common .. "button_blue.png")
					btnKill:setVisible(true)
					btnKill:loadTexture(config.dirUI.common .. "button_gray.png")
					btnKillCD:setVisible(false)
				end
			else
				btnFree:setTag(heroInfo.localID)
				btnFree:setTouchEnabled(true)
				btnFree:addTouchEventListener(onFreeBtnTouched)
				btnFree:loadTexture(config.dirUI.common .. "button_blue.png")
				btnKill:setTag(heroInfo.localID)
				btnKill:setTouchEnabled(true)
				btnKill:addTouchEventListener(onKillBtnTouched)
				btnKill:loadTexture(config .dirUI.common .. "button_red.png")
				btnKillCD:setVisible(false)
			end
		end
	end
	-- 刷新英雄列表
	local function refreshHeroList()
		heroListView:removeAllItems()
		local heroList = prisonMgr.getHeros()
		for i, heroInfo in ipairs(heroList) do
			heroListView:pushBackDefaultItem()
			local item = heroListView:getItem(i-1)
			item:setTag(heroInfo.localID)
			local itemCont = item:getChildByName("Panel_cont")
			local picNode = itemCont:getChildByName("ImageView_icon")
			local nameNode = itemCont:getChildByName("Label_name")
			local ownerNode = itemCont:getChildByName("Label_owner")
			local lvNode = itemCont:getChildByName("Label_level")

			picNode:loadTexture(config.dirUI.heroHeadpic .. heroInfo.sid .. ".png")
			nameNode:setString(string.format(hp.lang.getStrByID(4006), heroInfo.name))
			if string.len(heroInfo.unionName)>0 then
				ownerNode:setString(string.format(hp.lang.getStrByID(4007), hp.lang.getStrByID(21)..heroInfo.unionName..hp.lang.getStrByID(22)..heroInfo.ownerName))
			else
				ownerNode:setString(string.format(hp.lang.getStrByID(4007), heroInfo.ownerName))
			end
			lvNode:setString(string.format(hp.lang.getStrByID(4008), heroInfo.lv))

		end
		refreshHeroListOper()
	end
	refreshHeroList()

	-- 移除一项
	local function removeHeroItem( heroInfo )
		local listItem = heroListView:getChildByTag(heroInfo.localID)
		heroListView:removeItem(heroListView:getIndex(listItem))
		for i, v in ipairs(itemCDNodes) do
			if v.localID==heroInfo.localID then
				table.remove(itemCDNodes, i)
				break
			end
		end
	end

	local function refreshHeroCDTime()
		local heroList = prisonMgr.getHeros()
		for i, heroInfo in ipairs(heroList) do
			itemCDNodes[i].node:setString(string.format(hp.lang.getStrByID(4009), hp.datetime.strTime(heroInfo.leaveTime)))
		end

		if killCDNode then
			killCDNode:setString(hp.datetime.strTime(killCD.cd))
		end
	end

	self.refreshHeroList = refreshHeroList
	self.refreshHeroListOper = refreshHeroListOper
	self.removeHeroItem = removeHeroItem
	self.refreshHeroCDTime = refreshHeroCDTime


	local function onBtnMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/prison/prisonInfoBox"
			prisonInfo = UI_prisonInfo.new(building_)
			self:addModalUI(prisonInfo)
		end
	end
	
	
	btnMoreInfo:addTouchEventListener(onBtnMoreInfoTouched)
	
	
	-- registMsg
	self:registMsg(hp.MSG.PRISON_MGR)
end

function UI_killHero:onMsg(msg_, param_)
	if msg_==hp.MSG.PRISON_MGR then
		if param_.type==1 then
			self.refreshHeroList()
		elseif param_.type==2 then
			self.removeHeroItem(param_.hero)
		elseif param_.type==3 then
			self.refreshHeroListOper()
		elseif param_.type==4 then
			self.refreshHeroListOper(param_.hero)
		end
	end
end

function UI_killHero:heartbeat( dt )
	self.refreshHeroCDTime()
end
