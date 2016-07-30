--
-- ui/destory.lua
-- 摧毁建筑界面
--===================================
require "ui/frame/popFrame"


UI_destory = class("UI_destory", UI)


--init
function UI_destory:init(building_)
	-- data
	-- ===============================
	local b = building_.build
	local block = building_.block
	local bInfo = building_.bInfo
	local upInfo = nil

	local lv = b.lv-1
	for i, v in ipairs(game.data.upgrade) do
		if b.sid==v.buildSid and lv==v.level then
			upInfo = v
			break
		end
	end

	local itemSid = 20751

	--
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				if tag==-1 then
				-- 更新建筑cd
					cdBox.initCDInfo(cdBox.CDTYPE.BUILD, {data.cd, data.cd, 3, b.sid, b.lv})
				elseif tag== 0 then
					player.expendItem(itemSid, 1)
				end
				building_:destoryBuilding()
			end
		end

		self:closeAll()
	end

	-- 请求加速队列
	local function onSpeedQueue()
		self:close()
		require("ui/item/speedItem")
		local ui  = UI_speedItem.new(cdBox.CDTYPE.BUILD)
		self:addUI(ui)
	end

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "destory.json")
	local uiFrame = UI_popFrame.new(wigetRoot, hp.lang.getStrByID(2402))

	local contNode = wigetRoot:getChildByName("Panel_cont")
	local btn1 = contNode:getChildByName("ImageView_btn1")
	local btn2 = contNode:getChildByName("ImageView_btn2")
	contNode:getChildByName("Label_destory1"):setString(hp.lang.getStrByID(2401))
	local itemNum = player.getItemNum(itemSid)
	contNode:getChildByName("Label_num1"):setString(string.format(hp.lang.getStrByID(2403), itemNum))
	contNode:getChildByName("Label_desc1"):setString(hp.lang.getStrByID(2404))
	if itemNum<=0 then
		local itemInfo = hp.gameDataLoader.getInfoBySid("item", itemSid)
		btn1:getChildByName("Label_text"):setString(hp.lang.getStrByID(2405))
		btn1:getChildByName("ImageView_descBg"):getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(2024), itemInfo.sale))
	else
		btn1:getChildByName("ImageView_descBg"):setVisible(false)
		btn1:getChildByName("Label_text"):setString(hp.lang.getStrByID(2406))
	end

	contNode:getChildByName("Label_destory2"):setString(hp.lang.getStrByID(2402))
	contNode:getChildByName("Label_num2"):setString(hp.lang.getStrByID(2408))
	contNode:getChildByName("Label_desc2"):setString(hp.lang.getStrByID(2409))
	btn2:getChildByName("Label_text"):setString(hp.lang.getStrByID(2410))
	local realTime = player.helper.getBuildRealCD(upInfo.cd/2) - player.helper.getFreeCD()
	if realTime<0 then
		realTime = 0
	end
	btn2:getChildByName("Label_desc"):setString(hp.datetime.strTime(realTime))

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btn1 then
				--摧毁
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 1
				oper.type = 7
				oper.index = block.sid
				oper.side = block.type
				if itemNum<=0 then
					local itemInfo = hp.gameDataLoader.getInfoBySid("item", itemSid)
					if player.getResource("gold")<itemInfo.sale then
						-- 金币不够
						require("ui/msgBox/msgBox")
						UI_msgBox.showCommonMsg(self, 1)
						return
					end
					oper.gold = itemInfo.sale
				else
					oper.gold = 0
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, oper.gold)
				self:showLoading(cmdSender, sender)
			elseif sender==btn2 then
				-- 如果只是建筑在cd中
				local iTime = cdBox.getCD(cdBox.CDTYPE.BUILD)
				if iTime>0 then
					require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(2413), 
						hp.lang.getStrByID(2411), 
						hp.lang.getStrByID(2414), 
						hp.lang.getStrByID(2412),  
						onSpeedQueue
						)
					self:addModalUI(msgBox)
					return
				end
				
				--拆除
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 1
				oper.type = 3
				oper.index = block.sid
				oper.side = block.type
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, -1)
				self:showLoading(cmdSender, sender)
			end
		end
	end
	btn1:addTouchEventListener(onBtnTouched)
	btn2:addTouchEventListener(onBtnTouched)


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)
end
