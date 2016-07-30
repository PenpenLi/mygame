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

UI_cemeteryOtherPlayer = class("UI_cemeteryOtherPlayer", UI)

-- init
function UI_cemeteryOtherPlayer:init(playerid)
	-- data
	-- ===============================
	--local bInfo = building_.bInfo

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(10307))
	uiFrame:setTopShadePosY(820)

	--local uiHeader = UI_buildingHeader.new(building_)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "cemeteryOtherPlayer.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	--self:addChildUI(uiHeader)
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
	
	-- local curChildUI = UI_sacrificeHero.new(bInfo)
	-- self:addChildUI(curChildUI)


	--列表
	local listView = wigetRoot:getChildByName("ListView_hero")
	self.item1 = listView:getItem(0)
	self.item1:retain()
	self.item2 = listView:getItem(1)
	self.item2:retain()

	self.xisheng = nil
	self.chujue = nil

	--刷新数据
	local function refreshData( tag )
		-- body
		if tag == 0 then
			listView:removeAllItems()
			cclog("1111111")
			if table.getn(self.chujue.kill) == 0 then
					wigetRoot:getChildByName("Label_Null"):setString(hp.lang.getStrByID(7937))
			else
				wigetRoot:getChildByName("Label_Null"):setString("")
				for i,v in ipairs(self.chujue.kill) do
					local d2 = self.item2:clone()
					d2:getChildByName("Panel_cont"):getChildByName("img_heroIcon"):loadTexture(
						config.dirUI.heroHeadpic .. v[1] .. ".png")
					d2:getChildByName("Panel_cont"):getChildByName("Label_heroName"):setString(v[2])
					d2:getChildByName("Panel_cont"):getChildByName("Label_heroLv"):setString(v[5])
					d2:getChildByName("Panel_cont"):getChildByName("Label_manager"):setString(v[3])
					d2:getChildByName("Panel_cont"):getChildByName("Label_executeTime"):setString(
						hp.lang.getStrByID(7935) .. os.date("%Y-%m-%d %H:%M:%S", v[6]))
					cclog("-----pushBackCustomItem--22--")
					listView:pushBackCustomItem(d2)
				end
			end

			
		else
			listView:removeAllItems()
			if table.getn(self.xisheng.kill) == 0 then
				wigetRoot:getChildByName("Label_Null"):setString(hp.lang.getStrByID(7936))
			else
				wigetRoot:getChildByName("Label_Null"):setString("")
				for i,v in ipairs(self.xisheng.kill) do
					local d1 = self.item1:clone()
					d1:getChildByName("Panel_cont"):getChildByName("img_heroIcon"):loadTexture(
						config.dirUI.heroHeadpic .. v[1] .. ".png")
					d1:getChildByName("Panel_cont"):getChildByName("Label_heroName"):setString(v[2])
					d1:getChildByName("Panel_cont"):getChildByName("Label_heroLv"):setString(v[5])
					d1:getChildByName("Panel_cont"):getChildByName("Label_heroIntro"):setString(
						hp.gameDataLoader.getInfoBySid("hero",v[1]).desc)
					cclog("-----pushBackCustomItem--11--")
					listView:pushBackCustomItem(d1)
					
				end
			end
		end
	end
	
	--服务器消息处理
	local function onBaseInfoResponse(status, response, tag)

		cclog("-------tag:"..tag)
		-- 服务器正常连接
		if status == 200 then
			local res = hp.httpParse(response)
			-- 成功
			cclog("status == 200")
			if res.result ~= nil and res.result == 0 then
				cclog("res.result == 0")
				if tag == 0 then
					self.chujue = res
				else
					self.xisheng = res
				end
				listView:setVisible(true)
				refreshData(tag)
				
			end
		else
		end
	end

	--发送消息 牺牲
	local cmdData={}
	cmdData.type = 7
	cmdData.id = playerid
	cmdData.subtype = 1
	local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld,1)
	self:showLoading(cmdSender)
	
	--换页
	local function selectTabPage(sender)

		if curChildUI~=nil then
			self:removeChildUI(curChildUI)
		end
		headerTabSelected = sender

		if headerTabSelected == btn_sacrifice then
			cclog("btn_sacrifice")
			btn_execute:setColor(colorUnselected)
			btn_execute:setScale(scaleUnselectedX,scaleUnselectedY)
			label_execute:setColor(colorUnselected2)
			btn_sacrifice:setColor(colorSelected)
			btn_sacrifice:setScale(scaleSelectedX,scaleSelectedY)
			label_sacrifice:setColor(colorSelected2)

			
			if self.xisheng ~= nil then
				refreshData(1)
			else
				--发送消息 牺牲
				local cmdData={}
				cmdData.type = 7
				cmdData.id = playerid
				cmdData.subtype = 1
				local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld,1)
				self:showLoading(cmdSender)
			end
			
			
		elseif headerTabSelected == btn_execute then
			cclog("btn_execute")
			btn_sacrifice:setColor(colorUnselected)
			btn_sacrifice:setScale(scaleUnselectedX,scaleUnselectedY)
			label_sacrifice:setColor(colorUnselected2)
			btn_execute:setColor(colorSelected)
			btn_execute:setScale(scaleSelectedX,scaleSelectedY)
			label_execute:setColor(colorSelected2)

			--发送消息 处决
			if self.chujue ~= nil then
				refreshData(0)
			else
				local cmdData={}
				cmdData.type = 7
				cmdData.id = playerid
				cmdData.subtype = 0
				local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld,0)
				self:showLoading(cmdSender)
			end
			
			

			

			-- local function onBaseInfoResponse(status, response, tag)
			-- 	-- 服务器正常连接
			-- 	if status == 200 then
			-- 		local res = hp.httpParse(response)
			-- 		-- 成功
			-- 		if res.result ~= nil and res.result == 0 then

			-- 			btn_sacrifice:setColor(colorUnselected)
			-- 			btn_sacrifice:setScale(scaleUnselectedX,scaleUnselectedY)
			-- 			label_sacrifice:setColor(colorUnselected2)
			-- 			btn_execute:setColor(colorSelected)
			-- 			btn_execute:setScale(scaleSelectedX,scaleSelectedY)
			-- 			label_execute:setColor(colorSelected2)
						
			-- 			curChildUI = UI_executeHero.new(res.kill)
			-- 			self:addChildUI(curChildUI)
			-- 		end
			-- 		return
			-- 	else
			-- 		return
			-- 	end
			-- end
			-- -- 准备请求
			-- local cmdData = {operation = {}}
			-- local oper = {}
			-- oper.channel = 22
			-- oper.type = 4
			-- cmdData.operation[1] = oper
			-- local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			-- -- 发送请求
			-- cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			-- -- 等待相应
			-- self:showLoading(cmdSender, sender)
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