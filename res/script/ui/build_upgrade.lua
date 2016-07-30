--
-- ui/build_upgrade.lua
-- 建筑建造升级界面
--===================================
require "ui/fullScreenFrame"


UI_buildUpgrade = class("UI_buildUpgrade", UI)


--init
function UI_buildUpgrade:init(param_)
	-- data
	-- ===============================
	local uiType = param_.type
	local building = param_.building
	local block = building.block
	local b = nil
	local bInfo = nil
	local upInfo = nil
	local imgPath = nil
	local mustBuildComp = true
	local buildingMgr = player.buildingMgr

	local nextLv = 1
	if uiType==1 then
		-- 建造
		nextLv = 1
		b = {sid=param_.sid, bsid=block.sid, lv=1}
		for i,v in ipairs(game.data.building) do
			if b.sid==v.sid then
				bInfo = v
				break
			end
		end

		for i,v in ipairs(game.data.upgrade) do
			if b.sid==v.buildSid and 0==v.level then
				upInfo = v
				imgPath = config.dirUI.building .. v.img
				break
			end
		end
	else
		--升级
		b = building.build
		bInfo = building.bInfo
		upInfo = building.upInfo
		imgPath = building.imgPath
		uiType = 2
		nextLv = b.lv + 1
	end
	self.upInfo = upInfo

	--
	self.disableNum = 0
	self.listView = nil
	self.queueDesc = nil

	-- 网络请求回调
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				if tag == 0 then
					-- 更新建筑cd
					cdBox.initCDInfo(cdBox.CDTYPE.BUILD, {data.cd, data.cd, uiType, b.sid, nextLv})
				end
				-- 消耗资源
				for i,v in ipairs(upInfo.costs) do
					if v>0 then
						player.expendResource(game.data.resType[i][1], v)
					end
				end
				-- 消耗道具
				for i, v in ipairs(upInfo.costSids) do 
					if v>0 and upInfo.costNums[i]>0 then
						player.expendItem(v, upInfo.costNums[i])
					end
				end
				-- 升级、建造建筑
				if uiType==1 then
					building:buildBuilding(b.sid)
				else
					building:upgradeBuilding()
				end
				
				-- 新手指引--建造农场
				self:closeAll()
				player.guide.stepEx({2010, 4008})
				return
			end
		end

		self:closeAll()
	end

	-- ui
	-- ===============================  
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "build_upgrade.json")

	-- head
	----------
	local headCont = wigetRoot:getChildByName("Panel_cont")
	-- 建筑图片
	if bInfo.showtype==1 then
		imgPath = config.dirUI.building .. "fudi_icon.png"
		headCont:getChildByName("ImageView_build"):setScale(0.8)
	elseif bInfo.showtype==15 then
		imgPath = config.dirUI.building .. "wall_icon.png"
		headCont:getChildByName("ImageView_build"):setScale(0.8)
	end
	headCont:getChildByName("ImageView_build"):loadTexture(imgPath)
	-- 建筑进度
	local progressBg = headCont:getChildByName("ImageView_progressBg")
	progressBg:getChildByName("LoadingBar_progress"):setPercent((b.lv*100)/bInfo.maxLv)
	progressBg:getChildByName("Label_progress"):setString(string.format("%d/%d", b.lv, bInfo.maxLv))
	-- 建筑时间
	headCont:getChildByName("Label_oTimeName"):setString(hp.lang.getStrByID(2018))
	headCont:getChildByName("Label_oTime"):setString(hp.datetime.strTime(upInfo.cd))
	local freeCD = player.helper.getFreeCD()
	if freeCD>0 then
		headCont:getChildByName("Label_vipName"):setString(hp.lang.getStrByID(2057))
		headCont:getChildByName("Label_vipTime"):setString("-"..hp.datetime.strTime(freeCD))
	else
		headCont:getChildByName("Label_vipName"):setVisible(false)
		headCont:getChildByName("Label_vipTime"):setVisible(false)
	end
	headCont:getChildByName("Label_rTimeName"):setString(hp.lang.getStrByID(2019))
	local realTime = player.helper.getBuildRealCD(upInfo.cd) - freeCD
	if realTime<0 then
		realTime = 0
	end
	headCont:getChildByName("Label_rTime"):setString(hp.datetime.strTime(realTime))
	
	-- 升级
	local btnNow = headCont:getChildByName("ImageView_now")
	local btnUpgrade = headCont:getChildByName("ImageView_upgrade")
	-- 升级特效
	local upgradeEff = hp.uiEffect.innerGlow(btnUpgrade, 1)
	
	
	-- 请求加速队列
	local function onSpeedQueue()
		require("ui/item/speedItem")
		local ui  = UI_speedItem.new(cdBox.CDTYPE.BUILD)
		self:addUI(ui)
	end

	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==btnUpgrade then
				if self.disableNum>0 then
					if self.disableNum==1 then
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
					end
				end

				local cmdData={operation={}}
				local oper = {}
				local tag_ = 0
				oper.channel = 1
				oper.index = b.bsid
				if uiType==1 then
					--建造
					oper.type = 1
					oper.sid = b.sid
				else
					--升级
					oper.type = 4
					oper.side = block.type
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
				self:showLoading(cmdSender, sender)
			elseif sender==btnNow then
				-- if self.disableNum>0 then
				-- 	if self.disableNum==1 then
				-- 	-- 如果只是建筑在cd中
				-- 		local iTime = cdBox.getCD(cdBox.CDTYPE.BUILD)						
				-- 		if iTime>0 then
				-- 			require("ui/msgBox/msgBox")
				-- 			local msgBox = UI_msgBox.new(hp.lang.getStrByID(2413), 
				-- 				hp.lang.getStrByID(2411), 
				-- 				hp.lang.getStrByID(2414), 
				-- 				hp.lang.getStrByID(2412),  
				-- 				onSpeedQueue
				-- 				)
				-- 			self:addModalUI(msgBox)
				-- 			return
				-- 		end
				-- 	end
				-- end

				local cmdData={operation={}}
				local oper = {}
				local tag_ = 1
				oper.channel = 1
				oper.index = b.bsid
				if uiType==1 then
					--建造，没有立即，还是原来的建造
					oper.type = 1
					oper.sid = b.sid
					tag_ = 0
				else
					--立即升级
					oper.type = 6
					oper.side = block.type
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
				self:showLoading(cmdSender, sender)
			end
		end
	end
	btnUpgrade:addTouchEventListener(onBtnTouched)
	if uiType==1 then
		--btnNow:getChildByName("Label_now"):setString(hp.lang.getStrByID(2022))
		btnUpgrade:getChildByName("Label_upgrade"):setString(hp.lang.getStrByID(2023))
		btnNow:setVisible(false)
	else
		btnNow:getChildByName("Label_now"):setString(hp.lang.getStrByID(2020))
		btnUpgrade:getChildByName("Label_upgrade"):setString(hp.lang.getStrByID(2058))
		btnNow:addTouchEventListener(onBtnTouched)
	end
	-- 花费钻石
	local function calcDiamondCost()
		local costItems_ = {}
		for i, v in ipairs(upInfo.costSids) do
			if v == -1 then
				break
			end
			costItems_[i] = {v, upInfo.costNums[i]}
		end
		btnNow:getChildByName("ImageView_goldNum"):getChildByName("Label_num"):setString(player.quicklyMgr.getDiamondCost(upInfo.costs, realTime, costItems_))
	end
	calcDiamondCost()
	self.calcDiamondCost = calcDiamondCost

	-- list
	----------
	local listView = wigetRoot:getChildByName("ListView_info")
	self.listView = listView
	local itemDesc = listView:getItem(0)
	local itemTitle = listView:getItem(1)
	local itemQueue = listView:getItem(2)
	local itemRes = listView:getItem(3)
	local itemAward = listView:getItem(4)
	local itemMore = listView:getItem(5)
	local itemCont = nil

	local bFlag = true
	local item = nil

	-- desc / 升级条件
	local buildDesc = itemDesc:getChildByName("Panel_cont"):getChildByName("Label_desc")
	local upTitle = itemTitle:getChildByName("Panel_cont"):getChildByName("ImageView_bg"):getChildByName("Label_title")
	if uiType==1 then
		buildDesc:setString(bInfo.buildDesc)
		upTitle:setString(hp.lang.getStrByID(2026))
	else
		buildDesc:setString(bInfo.upDesc)
		upTitle:setString(hp.lang.getStrByID(2025))
	end
	-- 建造队列
	local iIndex = 2
	local iTime = cdBox.getCD(cdBox.CDTYPE.BUILD)
	if iTime>0 then
		local queueDesc = itemQueue:getChildByName("Panel_cont"):getChildByName("Label_desc")
		self.queueDesc = queueDesc
		queueDesc:setString(string.format(hp.lang.getStrByID(2027), hp.datetime.strTime(iTime)))
		iIndex = iIndex+1
		self.disableNum = self.disableNum+1
	else
		listView:removeItem(iIndex)
	end

	-- 前续建筑
	local function goUpdateBuilding(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local building = game.curScene:getBuildingBySid(sender:getTag())
			if building==nil then
				require("ui/msgBox/msgBox")
				local msgBox = UI_msgBox.new(hp.lang.getStrByID(1191), 
					hp.lang.getStrByID(2060), 
					hp.lang.getStrByID(1209)
					)
				self:addModalUI(msgBox)
				return
			else
				local ui = UI_buildUpgrade.new({type=2, building=building})
				self:closeAll()
				self:addUI(ui)
				ui:moveIn(2, 0.2)
			end
		end
	end
	if upInfo.mustBuildSid[1]~=-1 then
		for i, mustSid in ipairs(upInfo.mustBuildSid) do
			if mustSid~=-1 then
				local bTmp = hp.gameDataLoader.getInfoBySid("building", mustSid)
				local maxLv = buildingMgr.getBuildingMaxLvBySid(mustSid)

				item = itemRes:clone()
				listView:insertCustomItem(item, iIndex)
				itemCont = item:getChildByName("Panel_cont")
				itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. "building_icon.png")
				itemCont:getChildByName("Label_desc"):setString(bTmp.name .. " " .. string.format(hp.lang.getStrByID(2017), upInfo.mustBuildLv[i]))

				if uiType==1 then
				-- 建造
					itemCont:getChildByName("ImageView_buy"):setVisible(false)
					itemCont:getChildByName("Label_buy"):setVisible(false)
					if maxLv>=upInfo.mustBuildLv[i] then
						itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "right.png")
					else
						itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "wrong.png")
						self.disableNum = self.disableNum+1
						mustBuildComp = false
					end
				else
				-- 升级
					if maxLv>=upInfo.mustBuildLv[i] then
						itemCont:getChildByName("ImageView_isOK"):loadTexture(config.dirUI.common .. "right.png")
						itemCont:getChildByName("ImageView_buy"):setVisible(false)
						itemCont:getChildByName("Label_buy"):setVisible(false)
					else
						itemCont:getChildByName("ImageView_isOK"):setVisible(false)
						itemCont:getChildByName("Label_buy"):setString(hp.lang.getStrByID(2059))
						local updateBtn = itemCont:getChildByName("ImageView_buy")
						updateBtn:setTag(mustSid)
						updateBtn:addTouchEventListener(goUpdateBuilding)
						hp.uiEffect.innerGlow(updateBtn, 1)
						self.disableNum = self.disableNum+1
						mustBuildComp = false
					end
				end

				--判断是否应该加底背景
				if iIndex%2==0 then
					item:getChildByName("Panel_frame"):setVisible(false)
				else
					item:getChildByName("Panel_frame"):setVisible(true)
				end
				iIndex = iIndex+1
			end
		end
	end

	local function onBuyBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/resourceItem")
			local ui = UI_resourceItem.new(sender:getTag())
			self:addUI(ui)
		end
	end
	local function onItemBuyBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/buildingItem")
			local ui = UI_buildingItem.new(upInfo.costSids[sender:getTag()], hp.lang.getStrByID(2839))
			self:addUI(ui)
		end
	end
	-- 资源需求
	self.costItem = {}
	local function setCostItem(itemNode)
		local i = itemNode:getTag()
		local needNum = upInfo.costs[i]
		itemCont = itemNode:getChildByName("Panel_cont")
		itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. game.data.resType[i][1] .. "_big.png")
		itemCont:getChildByName("ImageView_icon"):setScale(0.8)
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
			if not self.costItem[i].effFlag then
			-- 如果没有添加特效，添加特效
				hp.uiEffect.innerGlow(buyBtn, 1)
				self.costItem[i].effFlag = true
			end
			buyTxt:setString(hp.lang.getStrByID(2028))
		end

		return false
	end
	for i,v in ipairs(upInfo.costs) do 
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
			self.costItem[i].effFlag = false
			if setCostItem(item)==false then
				self.costItem[i].disableFlag = true
				self.disableNum = self.disableNum+1
			end
			
			--判断是否应该加底背景
			if iIndex%2==0 then
				item:getChildByName("Panel_frame"):setVisible(false)
			else
				item:getChildByName("Panel_frame"):setVisible(true)
			end
			iIndex = iIndex+1
		end
	end
	self.setCostItem = setCostItem

	-- 道具
	self.itemItem = {}
	local function setItemItem(itemNode)
		local i = itemNode:getTag()
		local needNum = upInfo.costNums[i]
		itemCont = itemNode:getChildByName("Panel_cont")
		local imgNode = itemCont:getChildByName("ImageView_icon")
		imgNode:loadTexture(config.dirUI.item .. upInfo.costSids[i] .. ".png")
		imgNode:setScale(0.4)
		local resNum = player.getItemNum(upInfo.costSids[i])
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
			buyBtn:setTag(i)
			buyBtn:addTouchEventListener(onItemBuyBtnTouched)
			if not self.itemItem[i].effFlag then
			-- 如果没有添加特效，添加特效
				hp.uiEffect.innerGlow(buyBtn, 1)
				self.itemItem[i].effFlag = true
			end
			buyTxt:setString(hp.lang.getStrByID(2028))
		end

		return false
	end
	for i,v in ipairs(upInfo.costSids) do 
		if v>0 and upInfo.costNums[i]>0 then
			if bFlag then
				item = itemRes
				bFlag = false
			else
				item = itemRes:clone()
				listView:insertCustomItem(item, iIndex)
			end
			item:setTag(i)
			self.itemItem[i] = {}
			self.itemItem[i].item = item
			self.itemItem[i].disableFlag = false
			self.itemItem[i].effFlag = false
			if setItemItem(item)==false then
				self.itemItem[i].disableFlag = true
				self.disableNum = self.disableNum+1
			end
			
			--判断是否应该加底背景
			if iIndex%2==0 then
				item:getChildByName("Panel_frame"):setVisible(false)
			else
				item:getChildByName("Panel_frame"):setVisible(true)
			end
			iIndex = iIndex+1
		end
	end
	self.setItemItem = setItemItem

	-- 建造 - 升级奖励
	item = itemTitle:clone()
	listView:insertCustomItem(item, iIndex)
	iIndex = iIndex+1
	upTitle = item:getChildByName("Panel_cont"):getChildByName("ImageView_bg"):getChildByName("Label_title")
	if uiType==1 then
		upTitle:setString(hp.lang.getStrByID(2029))
	else
		upTitle:setString(hp.lang.getStrByID(2030))
	end
	-- 经验
	local itemCont = itemAward:getChildByName("Panel_cont")
	itemAward:getChildByName("Panel_frame"):setVisible(false)
	itemCont:getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(2031), upInfo.addExp))
	iIndex = iIndex+1
	-- 战力
	item = itemAward:clone()
	item:getChildByName("Panel_frame"):setVisible(true)
	listView:insertCustomItem(item, iIndex)
	itemCont = item:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_desc"):setString(string.format(hp.lang.getStrByID(2032), upInfo.point))
	itemCont:getChildByName("ImageView_icon"):loadTexture(config.dirUI.common .. "attack_icon.png")
	iIndex = iIndex+1
	-- 更多信息
	itemCont = itemMore:getChildByName("Panel_cont")
	local btnMore = itemCont:getChildByName("ImageView_titleBg")
	btnMore:getChildByName("Label_title"):setString(hp.lang.getStrByID(2033))
	local function onBtnMoreTouched(sender, eventType)  
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			local building_ = {}
			
			 building_.build = b
			 building_.bInfo = bInfo
			 building_.upInfo = upInfo
			
			if	bInfo.showtype == 1 then
				require "ui/mainBuildingInfo"
				local moreInfoBox = UI_mainBuildingInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 2 then
				require "ui/productionBuildingInfo.lua"
				local moreInfoBox = UI_productionBuildingInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 3 then
				require "ui/storage/storeInfo"
				local moreInfoBox = UI_storeInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 4 then
				require "ui/academy/moreInfoBox"
				local moreInfoBox = UI_moreInfoBox.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 5 then
				require("ui/altar/alterInfo")
				local ui = UI_altarInfo.new(building_)
				self:addUI(ui)
			elseif bInfo.showtype == 6 then
				require "ui/barrack/barrackInfo"
				local ui_ = UI_barrackInfo.new(building_)
				self:addModalUI(ui_)
			elseif bInfo.showtype == 7 then
				require "ui/embassy/embassyInfo"
				local moreInfoBox = UI_embassyInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 8 then
				require "ui/smith/smithInfo"
				local moreInfoBox = UI_smithInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 10 then
				require "ui/hallOfWar/hallOFWarInfo"
				local moreInfoBox = UI_hallOfWarInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 11 then
				require "ui/hospital/hospitalInfo"
				local ui_ = UI_hospitalInfo.new(building_)
				self:addModalUI(ui_)
			elseif bInfo.showtype == 12 then
				require "ui/market/marketInfo"
				local ui_ = UI_marketInfo.new(building_)
				self:addModalUI(ui_)
			elseif bInfo.showtype == 13 then
				require "ui/prison/prisonInfoBox"
				prisonInfo = UI_prisonInfo.new(building_)
				self:addModalUI(prisonInfo)
			elseif bInfo.showtype == 14 then
				require "ui/villa/villaInfo"
				prisonInfo = UI_villaInfo.new(building_)
				self:addModalUI(prisonInfo)
			elseif bInfo.showtype == 15 then
				require "ui/wall/wallInfo"
				local ui_ = UI_wallInfo.new(building_)
				self:addModalUI(ui_)
			elseif bInfo.showtype == 16 then
				require "ui/watchtower/watchtowerInfo"
				local moreInfoBox = UI_watchtowerInfo.new(building_)
				self:addModalUI(moreInfoBox)
			elseif bInfo.showtype == 17	then	
				require "ui/gymnos/gymnosInfo"
				local moreInfoBox = UI_gymnosInfo.new(building_)
				self:addModalUI(moreInfoBox)
			end
		end
	end
	btnMore:addTouchEventListener(onBtnMoreTouched)


	local function checkUpdateEnabled()
		if self.disableNum<=0 or (self.disableNum==1 and cdBox.getCD(cdBox.CDTYPE.BUILD)>0)then
			btnUpgrade:loadTexture(config.dirUI.common .. "button_blue.png")
			btnUpgrade:setTouchEnabled(true)
			upgradeEff:setVisible(true)
		else
			btnUpgrade:loadTexture(config.dirUI.common .. "button_gray.png")
			btnUpgrade:setTouchEnabled(false)
			upgradeEff:setVisible(false)
		end

		if mustBuildComp == true then
			btnNow:loadTexture(config.dirUI.common .. "button_green.png")
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

	-- registMsg
	-- =====================
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
	self:registMsg(hp.MSG.ITEM_CHANGED)
	self:registMsg(hp.MSG.GUIDE_STEP)

	-- 进行新手引导绑定
	-- ================================
	local function bindGuideUI( step )
		if step==2010 or step==4008 then
			player.guide.bind2Node(step, btnUpgrade, onBtnTouched)
			player.guide.getUI().uiLayer:runAction(cc.MoveBy:create(0.2, cc.p(-game.visibleSize.width, 0)))
		end
	end
	self.bindGuideUI = bindGuideUI
end

-- onMsg
function UI_buildUpgrade:onMsg(msg_, itemInfo_)
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
		self.calcDiamondCost()
	elseif msg_==hp.MSG.ITEM_CHANGED then
		for k, item in pairs(self.itemItem) do
			local itemNode = item.item
			local itemId = itemNode:getTag()
			if itemInfo_.sid==self.upInfo.costSids[itemId] then
				local bTmp = self.setItemItem(itemNode)
				if bTmp and item.disableFlag then
					item.disableFlag = false
					self.disableNum = self.disableNum-1
					self.checkUpdateEnabled()
				elseif (not bTmp) and (not item.disableFlag) then
					item.disableFlag = true
					self.disableNum = self.disableNum+1
					self.checkUpdateEnabled()
				end
				break
			end
		end
		self.calcDiamondCost()
	elseif msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(itemInfo_)
	end
end


function UI_buildUpgrade:heartbeat(dt)
	local iTime = cdBox.getCD(cdBox.CDTYPE.BUILD)
	if self.queueDesc~=nil then
		if iTime>0 then
			self.queueDesc:setString(string.format(hp.lang.getStrByID(2027), hp.datetime.strTime(iTime)))
		else
			self.queueDesc = nil
			self.listView:removeItem(2)
			self.disableNum = self.disableNum-1
		end
	end
end
