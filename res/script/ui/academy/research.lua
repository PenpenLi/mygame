--
-- ui/academy/research.lua
-- 研究科技界面
--===================================
require "ui/fullScreenFrame"


UI_research = class("UI_research", UI)


--init
function UI_research:init(researchType_, researchId_)
	-- data
	-- ===============================
	local researchType = researchType_
	local researchId = researchId_
	local imgPath = string.format("%s%d.png", config.dirUI.research, researchId)
	local researchMgr = player.researchMgr
	local maxLv = researchMgr.getResearchMaxLv(researchId)
	local researchInfo = researchMgr.getResearchNextLvInfo(researchId)

	local buildLv = player.buildingMgr.getBuildingMaxLvBySid(1007)
	local bInfo = game.getDataBySid("building", 1007)
	local mustBuildComp = true
	
	--
	self.disableNum = 0
	self.listView = nil
	self.queueDesc = nil

	--
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				-- 更新科技cd
				if tag==1 then
					cdBox.initCDInfo(cdBox.CDTYPE.RESEARCH, {data.cd, data.cd})
				end
				-- 消耗资源
				for i,v in ipairs(researchInfo.costs) do
					if v>0 then
						player.expendResource(game.data.resType[i][1], v)
					end
				end
				-- 添加技能
				researchMgr.addResearch(researchInfo.sid)
			end
		end

		self:closeAll()
	end

	-- ui
	-- ===============================  
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(9100+researchType_))

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "research.json")

	-- head
	----------
	local headCont = wigetRoot:getChildByName("Panel_cont")
	-- 图片
	headCont:getChildByName("ImageView_build"):loadTexture(imgPath)
	-- 进度
	local progressBg = headCont:getChildByName("ImageView_progressBg")
	progressBg:getChildByName("LoadingBar_progress"):setPercent((researchInfo.level*100)/maxLv)
	progressBg:getChildByName("Label_progress"):setString(string.format("%d/%d", researchInfo.level, maxLv))
	-- 时间
	headCont:getChildByName("Label_oTimeName"):setString(hp.lang.getStrByID(2018))
	headCont:getChildByName("Label_oTime"):setString(hp.datetime.strTime(researchInfo.cd))
	headCont:getChildByName("Label_rTimeName"):setString(hp.lang.getStrByID(2019))
	local realCD = player.helper.getResearchRealCD(researchInfo.cd)
	headCont:getChildByName("Label_rTime"):setString(hp.datetime.strTime(realCD))
	-- 升级
	local btnNow = headCont:getChildByName("ImageView_now")
	local btnUpgrade = headCont:getChildByName("ImageView_upgrade")
	-- 请求加速队列
	local function onSpeedQueue()
		require("ui/item/speedItem")
		local ui  = UI_speedItem.new(cdBox.CDTYPE.RESEARCH)
		self:addUI(ui)
	end

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnUpgrade then
				if self.disableNum>0 then
					if self.disableNum==1 then
					-- 如果只是建筑在cd中
						local iTime = cdBox.getCD(cdBox.CDTYPE.RESEARCH)
						if iTime>0 then
							require("ui/msgBox/msgBox")
							local msgBox = UI_msgBox.new(hp.lang.getStrByID(2706), 
								hp.lang.getStrByID(2707), 
								hp.lang.getStrByID(2414), 
								hp.lang.getStrByID(2412),  
								onSpeedQueue
								)
							self:addModalUI(msgBox)
						end
					end
					return
				end
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 8
				oper.type = 1
				oper.sid = researchInfo.sid
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
				self:showLoading(cmdSender, sender)
			elseif sender==btnNow then
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 8
				oper.type = 2
				oper.sid = researchInfo.sid
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 2)
				self:showLoading(cmdSender, sender)
			end
		end
	end
	btnNow:addTouchEventListener(onBtnTouched)
	btnUpgrade:addTouchEventListener(onBtnTouched)
	btnNow:getChildByName("Label_now"):setString(hp.lang.getStrByID(2701))
	btnUpgrade:getChildByName("Label_upgrade"):setString(hp.lang.getStrByID(2702))

	-- list
	----------
	local listView = wigetRoot:getChildByName("ListView_info")
	self.listView = listView
	local itemTitle = listView:getItem(0)
	local itemQueue = listView:getItem(1)
	local itemRes = listView:getItem(2)
	local itemAward = listView:getItem(3)
	local itemMore = listView:getItem(4)
	local itemCont = nil
	local item = nil

	-- 研究条件
	local upTitle = itemTitle:getChildByName("Panel_cont"):getChildByName("ImageView_bg"):getChildByName("Label_title")
	upTitle:setString(hp.lang.getStrByID(2703))

	-- 建造队列
	local iIndex = 1
	local iTime = cdBox.getCD(cdBox.CDTYPE.RESEARCH)
	if iTime>0 then
		local queueDesc = itemQueue:getChildByName("Panel_cont"):getChildByName("Label_desc")
		self.queueDesc = queueDesc
		queueDesc:setString(string.format(hp.lang.getStrByID(2705), hp.datetime.strTime(iTime)))
		iIndex = iIndex+1
		self.disableNum = self.disableNum+1
	else
		listView:removeItem(iIndex)
	end

	-- 学院等级
	item = itemRes
	itemCont = item:getChildByName("Panel_cont")
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. "building_icon.png")
	itemCont:getChildByName("Label_desc"):setString(bInfo.name .. " " .. string.format(hp.lang.getStrByID(2017), researchInfo.buildLv))
	itemCont:getChildByName("ImageView_buy"):setVisible(false)
	itemCont:getChildByName("Label_buy"):setVisible(false)

	if buildLv<researchInfo.buildLv then
		itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "wrong.png")
		self.disableNum = self.disableNum+1
		mustBuildComp = false
	else
		itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "right.png")
	end
	iIndex = iIndex+1

	-- 前续科技
	for i, sidMust in ipairs(researchInfo.mustSid) do
		if sidMust~=-1 then
			local infoMust = hp.gameDataLoader.getInfoBySid("research", sidMust)
			local idMust = math.floor(sidMust/100)
			local lvMust = sidMust%100
			item = itemRes:clone()
			listView:insertCustomItem(item, iIndex)

			itemCont = item:getChildByName("Panel_cont")
			local imgNode = itemCont:getChildByName("ImageView_icon")
			imgNode:loadTexture(config.dirUI.research .. idMust .. ".png")
			imgNode:setScale(0.3)
			itemCont:getChildByName("Label_desc"):setString(infoMust.name .. " " .. string.format(hp.lang.getStrByID(2017), lvMust))
			itemCont:getChildByName("ImageView_buy"):setVisible(false)
			itemCont:getChildByName("Label_buy"):setVisible(false)

			if researchMgr.getResearchLv(idMust)<lvMust then
				itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "wrong.png")
				self.disableNum = self.disableNum+1
				mustBuildComp = false
			else
				itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "right.png")
			end
			iIndex = iIndex+1
		end
	end

	-- 资源需求
	local function onBuyBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/resourceItem")
			local ui = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
		end
	end
	local function setCostItem(itemNode)
		local i = itemNode:getTag()
		local needNum = researchInfo.costs[i]
		itemCont = itemNode:getChildByName("Panel_cont")
		itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. game.data.resType[i][1] .. "_big.png")
		local resNum = player.getResource(game.data.resType[i][1])
		itemCont:getChildByName("Label_desc"):setString(string.format("%d / %d", resNum, needNum))
		if resNum>=needNum then
			itemCont:getChildByName("ImageView_isOK"):setVisible(true)
			itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "right.png")
			itemCont:getChildByName("ImageView_buy"):setVisible(false)
			itemCont:getChildByName("Label_buy"):setVisible(false)
			return true
		else
			itemCont:getChildByName("ImageView_isOK"):setVisible(false)
			local buyBtn = itemCont:getChildByName("ImageView_buy")
			local buyTxt = itemCont:getChildByName("Label_buy")
			buyBtn:setVisible(true)
			buyTxt:setVisible(true)
			buyBtn:setTag(i-1)
			buyBtn:addTouchEventListener(onBuyBtnTouched)
			buyTxt:setString(hp.lang.getStrByID(2028))
		end

		return false
	end
	self.costItem = {}
	self.setCostItem = setCostItem
	for i,v in ipairs(researchInfo.costs) do 
		if v>0 then
			if bFlag then
				item = itemRes
				bFlag = false
			else
				item = itemRes:clone()
				listView:insertCustomItem(item, iIndex)
			end
			item:setTag(i)
			self.costItem[i] = {}
			self.costItem[i].item = item
			self.costItem[i].disableFlag = false
			if setCostItem(item)==false then
				self.costItem[i].disableFlag = true
				self.disableNum = self.disableNum+1
			end
			
			iIndex = iIndex+1
		end
	end

	-- 建造 - 升级奖励
	item = itemTitle:clone()
	listView:insertCustomItem(item, iIndex)
	iIndex = iIndex+1
	upTitle = item:getChildByName("Panel_cont"):getChildByName("ImageView_bg"):getChildByName("Label_title")
	upTitle:setString(hp.lang.getStrByID(2704))
	-- 经验
	local itemCont = itemAward:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(2031), researchInfo.addExp))
	iIndex = iIndex+1
	-- 战力
	item = itemAward:clone()
	listView:insertCustomItem(item, iIndex)
	itemCont = item:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(2032), researchInfo.point))
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. "attack_icon.png")
	iIndex = iIndex+1
	-- 更多信息
	itemCont = itemMore:getChildByName("Panel_cont")
	local btnMore = itemCont:getChildByName("ImageView_titleBg")
	btnMore:getChildByName("Label_title"):setString(hp.lang.getStrByID(2033))
	local function onBtnMoreTouched(sender, eventType)  
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
		end
	end
	btnMore:addTouchEventListener(onBtnMoreTouched)

	local function checkUpdateEnabled()
		if self.disableNum<=0 or (self.disableNum==1 and cdBox.getCD(cdBox.CDTYPE.RESEARCH)>0)then
			btnUpgrade:loadTexture(config.dirUI.common .. "button_green.png")
			btnUpgrade:setTouchEnabled(true)
		else
			btnUpgrade:loadTexture(config.dirUI.common .. "button_gray.png")
			btnUpgrade:setTouchEnabled(false)
		end

		if mustBuildComp == true then
			btnNow:loadTexture(config.dirUI.common .. "button_blue.png")
			btnNow:setTouchEnabled(true)
		else
			btnNow:loadTexture(config.dirUI.common .. "button_gray.png")
			btnNow:setTouchEnabled(false)
		end
	end
	checkUpdateEnabled()
	self.checkUpdateEnabled = checkUpdateEnabled


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	self:registMsg(hp.MSG.RESOURCE_CHANGED)
end

-- onMsg
function UI_research:onMsg(msg_, itemInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		local item = nil
		if itemInfo_.name=="rock" then
			item = self.costItem[5]
		elseif itemInfo_.name=="wood" then
			item = self.costItem[4]
		elseif itemInfo_.name=="mine" then
			item = self.costItem[6]
		elseif itemInfo_.name=="food" then
			item = self.costItem[3]
		elseif itemInfo_.name=="silver" then
			item = self.costItem[2]
		end

		if item~=nil then
			local bTmp = self.setCostItem(item.item)
			if bTmp and item.disableFlag then
				item.disableFlag = false
				self.disableNum = self.disableNum-1
				self.checkUpdateEnabled()
			elseif (not bTmp) and (not item.disableFlag) then
				item.disableFlag = true
				self.disableNum = self.disableNum+1
				self.checkUpdateEnabled()
			end
		end
	end
end

function UI_research:heartbeat(dt)
	local iTime = cdBox.getCD(cdBox.CDTYPE.RESEARCH)
	if self.queueDesc~=nil then
		if iTime>0 then
			self.queueDesc:setString(string.format(hp.lang.getStrByID(2705), hp.datetime.strTime(iTime)))
		else
			self.queueDesc = nil
			self.listView:removeItem(1)
			self.disableNum = self.disableNum-1
		end
	end
end