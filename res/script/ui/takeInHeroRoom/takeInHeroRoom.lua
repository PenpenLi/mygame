--
-- ui/anguoss.lua
-- 城内信息
--===================================
require "ui/UI"
require "ui/fullScreenFrame"
require "ui/buildingHeader"

--包含三个页面的lua
require "ui/takeInHeroRoom/noremalHero"
require "ui/takeInHeroRoom/famousHeroList"
require "ui/takeInHeroRoom/famousHeroListDetail"
require "ui/takeInHeroRoom/famousHero"
require "ui/common/promotionInfo"


UI_takeInHeroRoom = class("UI_takeInHeroRoom", UI)




--init
function UI_takeInHeroRoom:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	uiFrame:setTopShadePosY(700)



	--local uiHeader = UI_buildingHeader.new(building_)
	local promotionUI = UI_promotionInfo.new()

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "takeInHeroRoom.json")



	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)	
	self:addCCNode(wigetRoot)
	self:addChildUI(promotionUI)

	local cont = wigetRoot:getChildByName("Panel_cont")
	local btn_noremalHero = cont:getChildByName("btn_noremalHero")
	local btn_famousHero = cont:getChildByName("btn_famousHero")
	local btn_famousHeroList = cont:getChildByName("btn_famousHeroList")

	local label_noremalHero = btn_noremalHero:getChildByName("label_noremalHero")
	local label_famousHero = btn_famousHero:getChildByName("label_famousHero")
	local label_famousHeroList = btn_famousHeroList:getChildByName("label_famousHeroList")
	
	--多语言匹配
	label_noremalHero:setString(hp.lang.getStrByID(6001))
	label_famousHero:setString(hp.lang.getStrByID(6002))
	label_famousHeroList:setString(hp.lang.getStrByID(6003))



	--记录按钮样式
	local scaleSelectedX = btn_noremalHero:getScaleX()
	local scaleSelectedY = btn_noremalHero:getScaleY()
	local colorSelected = btn_noremalHero:getColor()
	local scaleUnselectedX = btn_famousHero:getScaleX()
	local scaleUnselectedY = btn_famousHero:getScaleY()
	local colorUnselected = btn_famousHero:getColor()
	local headerTabSelected = btn_noremalHero
	
	
	--local tabPage = 1
	
	local curChildUI = UI_famousHero.new(bInfo)
	self:addChildUI(curChildUI)

	
	--换页
	local function selectTabPage()
		
		if curChildUI~=nil then
			self:removeChildUI(curChildUI)
		end

		if headerTabSelected == btn_noremalHero then 
			
			curChildUI = UI_noremalHero.new(bInfo)
			self:addChildUI(curChildUI)

		elseif headerTabSelected == btn_famousHero then 

			curChildUI = UI_famousHero.new(bInfo)
			self:addChildUI(curChildUI)

		elseif headerTabSelected == btn_famousHeroList then 

			curChildUI = UI_famousHeroList.new()
			self:addChildUI(curChildUI)

		end
		
	end

	
	
	
	--切换tab按钮样式
	local function changeStyle(sender)
		headerTabSelected:setColor(colorUnselected)
		headerTabSelected:setScale(scaleUnselectedX,scaleUnselectedY)
		headerTabSelected = sender
		headerTabSelected:setColor(colorSelected)
		headerTabSelected:setScale(scaleSelectedX,scaleSelectedY)
	end
	
	
	
	--初始页默认为名将
	changeStyle(btn_famousHero)

	
	
	
	-- 点击tab头 切换页面 回调函数
	-- ===============================
	local function tabMemuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			-- if headerTabSelected == sender then 
			-- 	return
			-- else 
				changeStyle(sender)
				
			-- end
			selectTabPage()
		end
	end

	--添加回调
	btn_noremalHero:addTouchEventListener(tabMemuItemOnTouched)
	btn_famousHero:addTouchEventListener(tabMemuItemOnTouched)
	btn_famousHeroList:addTouchEventListener(tabMemuItemOnTouched)




end