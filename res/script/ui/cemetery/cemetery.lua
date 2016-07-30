--
-- ui/cemetery/cemetery.lua
-- 墓地信息
--===================================

-- 请求处决英雄数据
-- channel = 22
-- @type = 4
--===================================

require "ui/UI"
require "ui/fullScreenFrame"
require "ui/buildingHeader"
require "ui/cemetery/sacrificeHero"
require "ui/cemetery/executeHero"

UI_cemetery = class("UI_cemetery", UI)

-- init
function UI_cemetery:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	uiFrame:setTopShadePosY(660)

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

	-- 多语言匹配
	label_sacrifice:setString(hp.lang.getStrByID(7801))
	label_execute:setString(hp.lang.getStrByID(7802))

	-- 记录按钮样式
	local scaleSelectedX = btn_sacrifice:getScaleX()
	local scaleSelectedY = btn_sacrifice:getScaleY()
	local colorSelected = btn_sacrifice:getColor()
	local colorSelected2 = label_sacrifice:getColor()
	local scaleUnselectedX = btn_execute:getScaleX()
	local scaleUnselectedY = btn_execute:getScaleY()
	local colorUnselected = btn_execute:getColor()
	local colorUnselected2 = label_execute:getColor()
	local headerTabSelected = btn_sacrifice
	
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
			label_execute:setColor(colorUnselected2)
			btn_sacrifice:setColor(colorSelected)
			btn_sacrifice:setScale(scaleSelectedX,scaleSelectedY)
			label_sacrifice:setColor(colorSelected2)

			curChildUI = UI_sacrificeHero.new(bInfo)
			self:addChildUI(curChildUI)
		elseif headerTabSelected == btn_execute then
			local function onBaseInfoResponse(status, response, tag)
				-- 服务器正常连接
				if status == 200 then
					local res = hp.httpParse(response)
					-- 成功
					if res.result ~= nil and res.result == 0 then

						btn_sacrifice:setColor(colorUnselected)
						btn_sacrifice:setScale(scaleUnselectedX,scaleUnselectedY)
						label_sacrifice:setColor(colorUnselected2)
						btn_execute:setColor(colorSelected)
						btn_execute:setScale(scaleSelectedX,scaleSelectedY)
						label_execute:setColor(colorSelected2)
						
						curChildUI = UI_executeHero.new(res.kill)
						self:addChildUI(curChildUI)
					end
					return
				else
					return
				end
			end
			-- 准备请求
			local cmdData = {operation = {}}
			local oper = {}
			oper.channel = 22
			oper.type = 4
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			-- 发送请求
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			-- 等待相应
			self:showLoading(cmdSender, sender)
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