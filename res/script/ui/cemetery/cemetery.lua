--
-- ui/cemetery/cemetery.lua
-- 城内信息
--===================================
require "ui/UI"
require "ui/fullScreenFrame"
require "ui/buildingHeader"
require "ui/cemetery/sacrificeHero"
require "ui/cemetery/executeHero"



UI_cemetery = class("UI_cemetery", UI)




--init
function UI_cemetery:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)


	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "cemetery.json")



	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(wigetRoot)


	local cont = wigetRoot:getChildByName("Panel_cont")
	local btn_sacrifice = cont:getChildByName("btn_sacrifice")
	local btn_execute = cont:getChildByName("btn_execute")

	local label_sacrifice = btn_sacrifice:getChildByName("label_sacrifice")
	local label_execute = btn_execute:getChildByName("label_execute")
	

	--多语言匹配
	label_sacrifice:setString(hp.lang.getStrByID(7801))
	label_execute:setString(hp.lang.getStrByID(7802))



	--记录按钮样式
	local scaleSelectedX = btn_sacrifice:getScaleX()
	local scaleSelectedY = btn_sacrifice:getScaleY()
	local colorSelected = btn_sacrifice:getColor()
	local scaleUnselectedX = btn_execute:getScaleX()
	local scaleUnselectedY = btn_execute:getScaleY()
	local colorUnselected = btn_execute:getColor()
	local headerTabSelected = btn_sacrifice
	



	
	--local tabPage = 1
	
	local curChildUI = UI_sacrificeHero.new(bInfo)
	self:addChildUI(curChildUI)

	
	--换页
	local function selectTabPage(sender)
		
		if curChildUI~=nil then
			self:removeChildUI(curChildUI)
		end

		headerTabSelected = sender

		if headerTabSelected == btn_sacrifice then 
			btn_execute:setColor(colorUnselected)
			btn_execute:setScale(scaleUnselectedX,scaleUnselectedY)
			btn_sacrifice:setColor(colorSelected)
			btn_sacrifice:setScale(scaleSelectedX,scaleSelectedY)

			curChildUI = UI_sacrificeHero.new(bInfo)
			self:addChildUI(curChildUI)

		elseif headerTabSelected == btn_execute then 
			btn_sacrifice:setColor(colorUnselected)
			btn_sacrifice:setScale(scaleUnselectedX,scaleUnselectedY)
			btn_execute:setColor(colorSelected)
			btn_execute:setScale(scaleSelectedX,scaleSelectedY)
			
			curChildUI = UI_executeHero.new()
			self:addChildUI(curChildUI)
			--self:addChildUI(curChildUI)

		end
		
	end

	
	-- 点击tab头 切换页面 回调函数
	-- ===============================
	local function tabMemuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if headerTabSelected == sender then 
				return
			else 
				selectTabPage(sender)
			end
			
		end
	end

	--添加回调
	btn_sacrifice:addTouchEventListener(tabMemuItemOnTouched)
	btn_execute:addTouchEventListener(tabMemuItemOnTouched)




end