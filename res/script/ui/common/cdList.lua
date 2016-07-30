--
-- ui/common/cdList.lua
-- cd队列
--===================================
require "ui/UI"


UI_cdList = class("UI_cdList", UI)


--init
function UI_cdList:init()
	-- data
	-- ===============================
	local cdItems = {}
	local marchItmes = {}
	self.cdItems = cdItems
	local isFolded = true
		
	-- ui
	-- ===============================
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "cdList.json")

	-- addCCNode
	-- ===============================
	self:addCCNode(widgetRoot)
	
	--cd队列
	--=============================================
	local freeCDType = -1
	local function onFreecdHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				cdBox.setCD(freeCDType, 0)
			end
		end

		freeCDType=-1
	end
	local function freeCD(senderBtn, cdType)
		if freeCDType~=-1 then
			return
		end
		freeCDType = cdType
		
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 3
		oper.type = 1
		oper.cd = cdType
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onFreecdHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender, senderBtn)
	end


	local foldBg = widgetRoot:getChildByName("Panel_cont"):getChildByName("Image_foldbg")
	local foldNum = foldBg:getChildByName("Label_num")
	local cdList = widgetRoot:getChildByName("ListView_cd")
	local cdItemDemo = cdList:getItem(0):clone()
	local cdFold = cdList:getItem(1)
	self.cdItemDemo = cdItemDemo
	cdItemDemo:retain()
	cdList:removeItem(0)
	--
	local foldPx, foldPy = foldBg:getPosition()
	local listPx, listPy = cdList:getPosition()
	local listSize = cdList:getSize()
	local itemSize = cdItemDemo:getSize()
	local function setCDListPosition()
		local itemNun = #cdItems + #marchItmes
		local posNum = 0
		if itemNun<=0 then
			cdList:setVisible(false)
			foldBg:setVisible(false)
			foldBg:setTouchEnabled(false)
			return
		end

		cdList:setVisible(true)
		if itemNun<=2 then
			foldBg:setVisible(false)
			foldBg:setTouchEnabled(false)
			posNum = itemNun-1
		else
			foldBg:setVisible(true)
			foldBg:setTouchEnabled(true)
			if isFolded then
				foldNum:setString(string.format(hp.lang.getStrByID(3148), itemNun-2))
				posNum = 1
			else
				foldNum:setString(hp.lang.getStrByID(3149))
				posNum = itemNun-1
			end
		end

		local py = listPy-itemSize.height*posNum 
		local sz = {}
		sz.width = listSize.width
		sz.height = listSize.height+itemSize.height*posNum
		cdList:setPosition(listPx, py)
		cdList:setSize(sz)
		foldBg:setPosition(foldPx, foldPy-itemSize.height*posNum)
	end
	local function onFoldBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if isFolded then
				isFolded = false
			else
				isFolded = true
			end
			setCDListPosition()
		end
	end
	foldBg:addTouchEventListener(onFoldBtnTouched)

	--
	-- setCDItemState
	-- 设置状态 1:免费加速, 2:请求帮助加速, 3:道具加速
	local function setCDItemState(cdItem, state)
		if cdItem.state==state then
			return
		end

		cdItem.state = state
		if state==1 then
			-- cdItem.operBtn:loadTexture(config.dirUI.common .. "button_purple.png")
			-- cdItem.progress:loadTexture(config.dirUI.common .. "progress_purple.png")
		elseif state==2 then
			cdItem.operBtn:loadTexture(config.dirUI.common .. "button_yellow.png")
			cdItem.progress:loadTexture(config.dirUI.common .. "progress_cdList_yellow.png")
		else
			cdItem.operBtn:loadTexture(config.dirUI.common .. "button_blue.png")
			cdItem.progress:loadTexture(config.dirUI.common .. "progress_cdList.png")
		end
		cdItem.progress:setPercent(cdItem.progress:getPercent())
		cdItem.operName:setString(hp.lang.getStrByID(3140+state))
	end
	local function updataCDItem(cdItem)
		local cdInfo = cdBox.getCDInfo(cdItem.type)
		local cdUsed = cdInfo.total_cd - cdInfo.cd
		local percent = cdUsed*100/cdInfo.total_cd

		if percent<1 then
			percent = 1
		end
		cdItem.progress:setPercent(percent)
		cdItem.time:setString(hp.datetime.strTime(cdInfo.cd))

		if cdBox.canSpeed(cdItem.type) then
			if cdBox.canFreeSpeed(cdItem.type) then
				if cdBox.canHelp(cdItem.type) then
					setCDItemState(cdItem, 2)
				else
					setCDItemState(cdItem, 3)
				end
			else
				setCDItemState(cdItem, 3)
			end
		end
	end
	local function onRequestSuccess(type_)
		local cdItem = nil
		for i, v in ipairs(cdItems) do
			if type_==v.type then
				cdItem = v
				break
			end
		end
		cdBox.help(cdItem.type)
		setCDItemState(cdItem, 3)
	end
	-- 操作cd
	local function onCDBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cdItem = nil
			local cdType = sender:getTag()
			for i, v in ipairs(cdItems) do
				if cdType==v.type then
					cdItem = v
					break
				end
			end

			if cdItem.state==1 then
				freeCD(sender, cdType)
			elseif cdItem.state==2 then
				self:showLoading(Alliance.requestHelp(cdType, onRequestSuccess), sender)
			else
				require("ui/item/speedItem")
				local ui  = UI_speedItem.new(cdType)
				self:addUI(ui)
			end
		end
	end

	local function addCDItem(cdType, needReposition)
		if not cdBox.canVisible(cdType) then
			return
		end

		for i, v in ipairs(cdItems) do
			if cdType==v.type then
				return
			end
		end

		local cdInfo = cdBox.getCDInfo(cdType)
		if cdInfo.cd<=0 then
			return
		end

		local cdItem = {}
		local cdItemNode = cdItemDemo:clone()
		local cdBgNode = cdItemNode:getChildByName("Panel_cont"):getChildByName("Image_bg")
		local icon = cdBgNode:getChildByName("Image_icon")
		local name = cdBgNode:getChildByName("Label_name")
		local progress = cdBgNode:getChildByName("ProgressBar_prg")
		local time = cdBgNode:getChildByName("Label_time")
		local operBtn = cdBgNode:getChildByName("Image_operBtn")
		local operName = cdBgNode:getChildByName("Label_oper")

		cdItem.type = cdType
		cdItem.node = cdItemNode
		cdItem.progress = progress
		cdItem.time = time
		cdItem.operBtn = operBtn
		cdItem.operName = operName
		cdItem.state = -1
		local index = 0
		for i,v in ipairs(cdItems) do
			if cdType<v.type then
				break
			end
			index = index+1
		end
		table.insert(cdItems, index+1, cdItem)
		cdList:insertCustomItem(cdItemNode, index)

		--设置cd内容
		icon:loadTexture(cdBox.getIconFile(cdType))
		local cdDesc = cdBox.getDescInfo(cdType)
		if cdDesc then
			local timesFlag = false
			local cdDesc2 = hp.lang.getStrByID(3100+cdType)
			local function resetString()
				if timesFlag then
					timesFlag = false
					name:setString(cdDesc)
				else
					timesFlag = true
					name:setString(cdDesc2)
				end
			end
			local a1 = cc.FadeOut:create(0.5)
			local a2 = cc.CallFunc:create(resetString)
			local a3 = cc.FadeIn:create(0.5)
			local a4 = cc.DelayTime:create(1)
			local a = cc.RepeatForever:create(cc.Sequence:create(a1, a2, a3, a4))
			name:runAction(a)
			resetString()
		else
			name:setString(hp.lang.getStrByID(3100+cdType))
		end

		if cdBox.canSpeed(cdType) then
		-- 可以加速
			operBtn:setTag(cdType)
			operBtn:addTouchEventListener(onCDBtnTouched)
		else
			operBtn:loadTexture(config.dirUI.common .. "button_gray.png")
		end
		updataCDItem(cdItem)

		if needReposition then
			setCDListPosition()
		end
	end
	
	local function deleteCDItem(cdType)
		local index = 0
		for i,v in ipairs(cdItems) do
			if cdType==v.type then
				break
			end
			index = index+1
		end
		table.remove(cdItems, index+1)
		cdList:removeItem(index)

		setCDListPosition()

		if cdType==cdBox.CDTYPE.BUILD then
		-- 新手指引免费升级，建造农场,升级主建筑,建造地牢
			player.guide.stepEx({2005, 3005, 7005})
		end
	end
	for k, v in pairs(cdBox.CDTYPE) do
		addCDItem(v, false)
	end
	

	self.addCDItem = addCDItem
	self.deleteCDItem = deleteCDItem
	self.updataCDItem = updataCDItem
	
	
	--=====================================
	--行军CD队列
	local function onMarchCDBtn(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local id_ = sender:getTag()
			require("ui/item/armySpeedItem")
			local ui  = UI_armySpeedItem.new(id_)
			self:addUI(ui)
		end
	end
	
	--心跳更新CD的时间
	local function updataMarchItem(item_)
		local cdUsed = player.getServerTime() - item_.marchInfo.tStart
		local cdTotal = item_.marchInfo.tEnd - item_.marchInfo.tStart
		local percent = cdUsed*100/cdTotal
		if percent<1 then
			percent = 1
		end
		item_.progress:setPercent(percent)
		item_.time:setString(hp.datetime.strTime(cdTotal - cdUsed))
	end
	
	--删除CD已经完全冷却的队列
	local function deleteMarchItem(item_)
		local find_ = false
		for i, item in ipairs(marchItmes) do
			if item.marchInfo.id==item_.marchInfo.id then
				table.remove(marchItmes, i)
				find_ = true
				break
			end
		end

		if find_ == false then
			cclog_("deleteMarchItem***********************++++++++++++find it.id:%d,marchType:%d,x:%d,y:%d",item_.marchInfo.id,
				item_.marchInfo.marchType,item_.marchInfo.pEnd.x,item_.marchInfo.pEnd.y)
		end
		cdList:removeItem(cdList:getIndex(item_.node))
		setCDListPosition()
	end

	local function updataMarchItems()
		for i,v in ipairs(marchItmes) do
			if v.marchInfo.tEnd - player.getServerTime() > 0 then
				updataMarchItem(v)
			else
				deleteMarchItem(v)
				break
			end
		end
	end
	self.updataMarchItems = updataMarchItems
	
	--移除所有项
	local function removeAllMarchItem()
		for i,item in ipairs(marchItmes) do
			cdList:removeItem(cdList:getIndex(item.node))
		end

		marchItmes = {}
		setCDListPosition()
	end
	
	--更新所有的项
	local function marchCDItemsFlash()
		local marchCdData = player.marchMgr.getFieldArmy()
		removeAllMarchItem()
		if marchCdData ~= nil then
			for i,v in pairs(marchCdData) do
				if v.tEnd - player.getServerTime() >= 0 then
				
					local cdItem = {}
					local cdItemNode = cdItemDemo:clone()
					
					local cdBgNode = cdItemNode:getChildByName("Panel_cont"):getChildByName("Image_bg")
					local icon = cdBgNode:getChildByName("Image_icon")
					local name = cdBgNode:getChildByName("Label_name")
					local progress = cdBgNode:getChildByName("ProgressBar_prg")
					local time = cdBgNode:getChildByName("Label_time")
					local operBtn = cdBgNode:getChildByName("Image_operBtn")
					local operName = cdBgNode:getChildByName("Label_oper")

					cdItem.type = cdBox.CDTYPE.MARCH
					cdItem.node = cdItemNode
					cdItem.progress = progress
					cdItem.time = time
					cdItem.operBtn = operBtn
					cdItem.operName = operName
					cdItem.state = -1
					cdItem.marchInfo = v
					
					table.insert(marchItmes,cdItem)
					cdList:pushBackCustomItem(cdItemNode)
					
					--设置cd内容
					icon:loadTexture(player.marchMgr.getMarchIcon(v.marchType))
					
					local cdDesc = ""
					local cdDesc2 = ""
					if v.marchType == 3 then
						cdDesc = player.marchMgr.getMarchListType(v.marchType)
						local resInfo_ = hp.gameDataLoader.getInfoBySid("resources", v.name2)
						local resTypeInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", resInfo_.growth + 1)
						cdDesc2 = resInfo_.name
					else
						cdDesc = player.marchMgr.getMarchListType(v.marchType)
						cdDesc2 = player.serverMgr.formatMyServerPosition(v.pEnd, true)
					end
					
					local timesFlag = false
					local function resetString()
						if timesFlag then
							timesFlag = false
							name:setString(cdDesc)
						else
							timesFlag = true
							name:setString(cdDesc2)
						end
					end
					local a1 = cc.FadeOut:create(0.5)
					local a2 = cc.CallFunc:create(resetString)
					local a3 = cc.FadeIn:create(0.5)
					local a4 = cc.DelayTime:create(1)
					local a = cc.RepeatForever:create(cc.Sequence:create(a1, a2, a3, a4))
					name:runAction(a)
					resetString()
					
					if globalData.ARMY_FUNC[v.marchType].speedup then
						operBtn:setTag(v.id)
						operBtn:addTouchEventListener(onMarchCDBtn)
					else
						operBtn:setTouchEnabled(false)
						operBtn:loadTexture(config.dirUI.common.."button_gray.png")
					end
					
					setCDListPosition()
				end	
				
			end
		end
	end

	self.marchCDItemsFlash = marchCDItemsFlash
	marchCDItemsFlash()
	setCDListPosition()
	
	-- registMsg
	self:registMsg(hp.MSG.CD_STARTED)
	self:registMsg(hp.MSG.CD_FINISHED)
	self:registMsg(hp.MSG.MARCH_MANAGER)
end

--onRemove
function UI_cdList:onRemove()
	-- must release
	self.cdItemDemo:release()

	self.super.onRemove(self)
end

-- onMsg
function UI_cdList:onMsg(msg_, paramInfo_)
	if msg_==hp.MSG.CD_STARTED then
		self.addCDItem(paramInfo_.cdType, true)
	elseif msg_==hp.MSG.CD_FINISHED then
		self.deleteCDItem(paramInfo_.cdType)
	elseif msg_==hp.MSG.MARCH_MANAGER then
		self.marchCDItemsFlash()
		
	end
end

-- heartbeat
function UI_cdList:heartbeat(dt)
	for i,v in ipairs(self.cdItems) do
		if cdBox.getCD(v.type)>0 then
			self.updataCDItem(v)
		else
			self.deleteCDItem(v.type)
		end
	end

	self.updataMarchItems()
end
