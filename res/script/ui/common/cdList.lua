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
	self.cdItems = {}
	local cdItems = self.cdItems
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
		local itemNun = #cdItems
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
			cdItem.operBtn:loadTexture(config.dirUI.common .. "button_purple1.png")
		elseif state==2 then
			cdItem.operBtn:loadTexture(config.dirUI.common .. "button_yellow1.png")
		else
			cdItem.operBtn:loadTexture(config.dirUI.common .. "button_blue1.png")
		end
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

		if cdBox.canFreeSpeed(cdItem.type) then
			if cdInfo.cd<=player.helper.getFreeCD() then
				setCDItemState(cdItem, 1)
			elseif cdBox.canHelp(cdItem.type) then
				setCDItemState(cdItem, 2)
			else
				setCDItemState(cdItem, 3)
			end
		else
			setCDItemState(cdItem, 3)
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
				Alliance.requestHelp(cdType, onRequestSuccess)
			else
				require("ui/item/speedItem")
				local ui  = UI_speedItem.new(cdType)
				self:addUI(ui)
			end
		end
	end

	local function addCDItem(cdType, needReposition)
		if not cdBox.canSpeed(cdType) then
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
		name:setString(hp.lang.getStrByID(3100+cdType))
		operBtn:setTag(cdType)
		operBtn:addTouchEventListener(onCDBtnTouched)
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
	setCDListPosition()

	self.addCDItem = addCDItem
	self.deleteCDItem = deleteCDItem
	self.updataCDItem = updataCDItem

	-- registMsg
	self:registMsg(hp.MSG.CD_STARTED)
	self:registMsg(hp.MSG.CD_FINISHED)
	self:registMsg(hp.MSG.GUIDE_STEP)

	-- 进行新手引导绑定
	-- ================================
	local function bindGuideUI( step )
		if step==2005 or step==3005 or step==7005 then
			for i, v in ipairs(cdItems) do
				if v.type==cdBox.CDTYPE.BUILD then
					cdList:visit()
					player.guide.bind2Node(step, v.operBtn, onCDBtnTouched)
					break
				end
			end
		end
	end
	self.bindGuideUI = bindGuideUI
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
	elseif msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(paramInfo_)
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
end
