--
-- ui/prison/prison.lua
-- 监狱主界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_prison = class("UI_prison", UI)


--init
function UI_prison:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo
	local curChildUI = nil

	local prisonMgr = require "playerData/prisonMgr"
	prisonMgr.init()
	self.prisonMgr = prisonMgr

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "prison.json")


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)


	--
	-- ==============================
	local function tab2ChildUI(uiType)
		if curChildUI~=nil then
			self:removeChildUI(curChildUI)
		end

		if uiType==1 then
			require "ui/prison/killHero"
			curChildUI = UI_killHero.new(building_, prisonMgr)
		else
			require "ui/prison/induceHero"
			curChildUI = UI_induceHero.new(building_, prisonMgr)
		end
		self:addChildUI(curChildUI)
	end
	tab2ChildUI(1)
	
	local panelCont = wigetRoot:getChildByName("Panel_headCont")
	local tabKill = panelCont:getChildByName("ImageView_kill")
	local tabInduce = panelCont:getChildByName("ImageView_induce")
	tabKill:getChildByName("Label_text"):setString(hp.lang.getStrByID(4001))
	tabInduce:getChildByName("Label_text"):setString(hp.lang.getStrByID(4002))
	local selectScale = tabKill:getScale()
	local selectColor = tabKill:getColor()
	local normalScale = tabInduce:getScale()
	local normalColor = tabInduce:getColor()
	local selectTab = tabKill
	local function onTabTouched(sender, eventType)
		if sender==selectTab then
			return
		end

		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(selectColor)
			sender:getChildByName("Label_text"):setColor(selectColor)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(selectColor)
				sender:getChildByName("Label_text"):setColor(selectColor)
			else
				sender:setColor(normalColor)
				sender:getChildByName("Label_text"):setColor(normalColor)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			selectTab:setColor(normalColor)
			selectTab:setScale(normalScale)
			selectTab:getChildByName("Label_text"):setColor(normalColor)
			selectTab = sender
			selectTab:setColor(selectColor)
			selectTab:setScale(selectScale)
			selectTab:getChildByName("Label_text"):setColor(selectColor)
			if selectTab==tabKill then
				tab2ChildUI(1)
			else
				tab2ChildUI(2)
			end
		end
	end
	tabKill:addTouchEventListener(onTabTouched)
	tabInduce:addTouchEventListener(onTabTouched)

	prisonMgr.getHero()
end

-- heartbeat
function UI_prison:heartbeat(dt)
	self.prisonMgr.heartbeat(dt)

	self.super.heartbeat(self)
end