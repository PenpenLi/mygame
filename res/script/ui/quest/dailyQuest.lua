--
-- ui/quest/dailyQuest.lua
-- 日常任务 type: 1-日常 2-联盟 3-vip
--===================================
require "ui/fullScreenFrame"

UI_dailyQuest = class("UI_dailyQuest", UI)

local qualityImage = {"quest_12.png", "quest_11.png", "quest_13.png", "quest_14.png", "quest_15.png", "quest_16.png"}
local startImage = {"button_blue1.png", "button_gray1.png"}
local startTouchEnabled_ = {true, false}
local interval = 0
local speedupcode = {11,12,13}
local itemID = {20251,20252,20253}
local qualityName = {1425,1424,1423,1422,1421,1420}

--init
function UI_dailyQuest:init(type_)
	-- data
	-- ===============================
	self.type = type_
	self.showState = false

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(1400 + self.type))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	-- 调整控件大小
	hp.uiHelper.uiAdaption(self.foldContainer)
	hp.uiHelper.uiAdaption(self.unfoldContainer)
	self.rewardItem = self.unfoldContainer:getChildByName("ListView_20465"):getChildByName("Panel_20467"):clone()
	self.rewardItem:retain()
	self.unfoldContainer:getChildByName("ListView_20465"):removeLastItem()

	self:initCallBack()

	self.speedUp:addTouchEventListener(self.onSpeedUpTouched)
	self.moreInfo:addTouchEventListener(self.onMoreInfoTouched)
	self.change:addTouchEventListener(self.onChangeTouched)

	-- 更新UI显示
	self:changeShowPanel()

	-- 注册消息
	self:registMsg(hp.MSG.MISSION_DAILY_CHANGE)
	self:registMsg(hp.MSG.MISSION_DAILY_COMPLETE)
	self:registMsg(hp.MSG.MISSION_DAILY_COLLECTED)
	self:registMsg(hp.MSG.MISSION_DAILY_REFRESH)

	self:refreshUIShow()
	self:updateTickInfo()
end

function UI_dailyQuest:refreshUIShow()
	local countTime_ = hp.datetime.strTime(player.getResetTime(self.type) - player.getServerTime())
	self.refreshTime:setString(countTime_)
end

function UI_dailyQuest:initCallBack()
	local function onSpeedUpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/speedItem")
			local ui  = UI_speedItem.new(speedupcode[self.type])
			self:addUI(ui)
			-- self.speedUp:setTouchEnabled(false)
			-- local cmdData={operation={}}
			-- local oper = {}
			-- oper.channel = 3
			-- oper.type = 1
			-- oper.cd = speedupcode[self.type]
			-- cmdData.operation[1] = oper
			-- local cmdSender = hp.httpCmdSender.new(onSpeedUpResponse)
			-- cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/quest/dailyInfo"
			ui_ = UI_dailyInfo.new(self.type)
			self:addModalUI(ui_)
		end
	end

	local function onChangeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", itemID[self.type])

			local function onChangeResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					-- 更新资源
					if tag == 1 then -- 消耗道具
						player.expendItem(itemID[self.type], 1)
					elseif tag == 2 then -- 消耗元宝
						player.expendResource("gold", itemInfo_.sale)
					end
					player.initTasks(data)
				end
			end

			local function sendChangeCmd(gold_)
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 2
				oper.type = 4
				oper.task = self.type
				oper.gold = gold_
				local tag_ = 1
				if gold_ > 0 then
					tag_ = 2
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onChangeResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
			end			

			require "ui/common/buyAndUseItemPop"
			ui_ = UI_buyAndUseItem.new(itemID[self.type], 1, sendChangeCmd)
			self:addModalUI(ui_)
		end
	end

	local function onCollectResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			-- 更新资源
			local taskInfo_ = player.getDailyTaskInfo(self.type, data.id)
			for j, w in ipairs(taskInfo_.resource) do
				if w ~= 0 then
					local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", j)
					player.addResource(resourceInfo_.code, w)
				end
			end

			player.dailyTaskCollected(self.type)
			-- 更新物品
		end
	end

	local function onCollectTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 2
			oper.type = 6
			oper.task = self.type
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onCollectResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onStartResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then			
			player.startDailyTask(self.type, data.id)
			self:setShowState(true)
			self:updateCDTime()
		end
	end

	local function onStartTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 2
			oper.type = 3
			oper.task = self.type
			oper.id = self.taskInfo[sender:getTag()].info_.id
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onStartResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onRewardTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			local taskInfo_ = self.taskInfo[tag_]
			local index_ = self.listView:getIndex(sender)
			self.listView:removeChild(sender)
			if taskInfo_.fold == 0 then
				local rewardItem = self:createPanelDetail(taskInfo_.info_, tag_)
				self.listView:insertCustomItem(rewardItem, index_)
			elseif taskInfo_.fold == 1 then
				local rewardItem = self:createPanel(taskInfo_.info_, tag_)
				self.listView:insertCustomItem(rewardItem, index_)
			end
			local totalHeight = 0
			local size_ = self.listView:getSize()
            for i, v in ipairs(self.listView:getChildren()) do
            
                totalHeight = totalHeight + v:getSize().height
            end
			self.listView:refreshView()
		end
	end
	self.onSpeedUpTouched = onSpeedUpTouched
	self.onMoreInfoTouched = onMoreInfoTouched
	self.onChangeTouched = onChangeTouched
	self.onCollectTouched = onCollectTouched
	self.onStartTouched = onStartTouched
	self.onRewardTouched = onRewardTouched
end

-- 初始化UI
function UI_dailyQuest:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "dailyQuest.json")
	local content_ = self.wigetRoot:getChildByName("Panel_20409")

	-- 刷新时间
	self.refreshTime = content_:getChildByName("Label_20411")
	content_:getChildByName("Label_20412"):setString(hp.lang.getStrByID(1414))

	-- 进度条
	self.loadingContainer_ = content_:getChildByName("Panel_23009")
	self.speedUp = self.loadingContainer_:getChildByName("ImageView_1645")
	self.loadingBar = self.loadingContainer_:getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640")
	self.loadingText = self.loadingBar:getChildByName("ImageView_1641"):getChildByName("Label_1642")

	-- 底部按钮
	local bottomContainer = content_:getChildByName("Panel_20473")
	self.moreInfo = bottomContainer:getChildByName("ImageView_20476")
	self.change = bottomContainer:getChildByName("ImageView_20477")
	self.moreInfo:getChildByName("Label_20478"):setString(hp.lang.getStrByID(1030))
	self.change:getChildByName("Label_20479"):setString(hp.lang.getStrByID(1416))

	self.listView = self.wigetRoot:getChildByName("ListView_20422")
	-- 未展开信息
	self.foldContainer = self.listView:getChildByName("Panel_20440"):clone()
	self.foldContainer:retain()
	self.listView:removeLastItem()

	-- 展开信息
	self.unfoldContainer = self.listView:getChildByName("Panel_20425"):clone()
	self.unfoldContainer:retain()
	self.listView:removeLastItem()

	-- 
	self.countTimeContainer = self.wigetRoot:getChildByName("Panel_23194")
	self.countTimeContainer:getChildByName("Label_23195"):setString(hp.lang.getStrByID(1427))
	self.countTime = self.countTimeContainer:getChildByName("Label_23196")
end

-- 更新UI显示
function UI_dailyQuest:updateUIShow()
	self.listView:removeAllItems()
	self.taskInfo = {}

	local dailyTask_ = player.getDailyTasks(self.type)
	for i, v in ipairs(dailyTask_) do
		local rewardItem = self:createPanel(v, i)
		self.listView:pushBackCustomItem(rewardItem)
	end
	self.listView:refreshView()
end

-- 切换显示面板
function UI_dailyQuest:changeShowPanel()
	if table.getn(player.getDailyTasks(self.type)) == 0 then
		self.countTimeContainer:setVisible(true)
		self.listView:setVisible(false)
	else
		self.countTimeContainer:setVisible(false)
		self.listView:setVisible(true)
		self:updateUIShow()
	end
end

function UI_dailyQuest:createPanel(info_, tag_)
	local rewardItem = self.foldContainer:clone()
	local rewardContent_ = rewardItem:getChildByName("Panel_20426")
	rewardContent_:getChildByName("ImageView_20455"):loadTexture(config.dirUI.common..qualityImage[info_.quality])
	rewardContent_:getChildByName("Label_20462"):setString(hp.lang.getStrByID(qualityName[info_.quality]))

	if info_.flag == 1 then
		local getReward_ = rewardContent_:getChildByName("ImageView_22897")
		getReward_:getChildByName("Label_22898"):setString(hp.lang.getStrByID(1426))
		getReward_:setTouchEnabled(true)
		getReward_:setVisible(true)
		getReward_:addTouchEventListener(self.onCollectTouched)
	elseif info_.flag == 2 then
		local warning_ = rewardContent_:getChildByName("ImageView_20464")
		warning_:setVisible(true)
	elseif info_.flag == 3 then
		local start_ = rewardContent_:getChildByName("ImageView_20457")
		start_:getChildByName("Label_20458"):setString(hp.lang.getStrByID(1415))
		start_:getChildByName("ImageView_20459"):getChildByName("Label_20460"):setString(hp.datetime.strTime(info_.time))
		start_:setVisible(true)
		start_:setTag(tag_)
		start_:loadTexture(config.dirUI.common..startImage[info_.enabled])
		start_:setTouchEnabled(startTouchEnabled_[info_.enabled])
		start_:addTouchEventListener(self.onStartTouched)
	end
	rewardItem:addTouchEventListener(self.onRewardTouched)
	rewardItem:setTag(tag_)
	self.taskInfo[tag_] = {fold=0, info_=info_}
	return rewardItem
end

function UI_dailyQuest:createPanelDetail(info_, tag_)
	local rewardItem = self.unfoldContainer:clone()
	local rewardContent_ = rewardItem:getChildByName("Panel_20426")
	rewardContent_:getChildByName("ImageView_20455"):loadTexture(config.dirUI.common..qualityImage[info_.quality])
	rewardContent_:getChildByName("Label_20462"):setString(hp.lang.getStrByID(qualityName[info_.quality]))
	rewardContent_:getChildByName("Label_20463"):setString(hp.lang.getStrByID(5169))

	-- 奖励内容
	local num_ = 0
	-- 道具
	local itemType = 1
	local itemInfo_ = hp.gameDataLoader.getInfoBySid("gem", info_.item)
	if itemInfo_ == nil then
		itemInfo_ = hp.gameDataLoader.getInfoBySid("equipMaterial", info_.item)
		itemType = 2
	end

	if itemInfo_ ~= nil then
		local rewardItem_ = self.rewardItem:clone()
		local content_ = rewardItem_:getChildByName("Panel_20470")
		if itemType == 1 then
			content_:getChildByName("ImageView_20471"):loadTexture(config.dirUI.gem..itemInfo_.sid..".png")
		elseif itemType == 2 then
			content_:getChildByName("ImageView_20471"):loadTexture(config.dirUI.material..itemInfo_.type..".png")
		end
		content_:getChildByName("Label_20472"):setString(itemInfo_.name)
		rewardItem:getChildByName("ListView_20465"):pushBackCustomItem(rewardItem_)
		num_ = 1
	end

	-- 公会贡献度
	if self.type == 2 then
		local rewardItem_ = self.rewardItem:clone()
		local content_ = rewardItem_:getChildByName("Panel_20470")
		content_:getChildByName("ImageView_20471"):loadTexture(config.dirUI.common.."rock.png")
		content_:getChildByName("Label_20472"):setString(hp.lang.getStrByID(5110)..":"..info_.contribute)
		rewardItem:getChildByName("ListView_20465"):pushBackCustomItem(rewardItem_)
		num_ = num_ + 1

		local rewardItem_ = self.rewardItem:clone()
		local content_ = rewardItem_:getChildByName("Panel_20470")
		content_:getChildByName("ImageView_20471"):loadTexture(config.dirUI.common.."rock.png")
		content_:getChildByName("Label_20472"):setString(hp.lang.getStrByID(5120)..":"..info_.contribute)
		rewardItem:getChildByName("ListView_20465"):pushBackCustomItem(rewardItem_)
		num_ = num_ + 1
	end

	-- 资源	
	for i, v in ipairs(info_.resource) do
		if v ~= 0 then
			local resourceInfo_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
			local rewardItem_ = self.rewardItem:clone()
			local content_ = rewardItem_:getChildByName("Panel_20470")
			content_:getChildByName("ImageView_20471"):loadTexture(config.dirUI.common..resourceInfo_.image)
			content_:getChildByName("Label_20472"):setString(resourceInfo_.name..":"..v)
			rewardItem:getChildByName("ListView_20465"):pushBackCustomItem(rewardItem_)
			num_ = num_ + 1
		end
	end
	local listView_ = rewardItem:getChildByName("ListView_20465")
	local height_ = num_ * listView_:getChildByName("Panel_20467"):getSize().height
	height_ = height_ + listView_:getItem(0):getSize().height
	x_, y_ = listView_:getPosition()

	-- content的高度调高
	rewardItem:getChildByName("Panel_20426"):setPosition(0, y_ + height_)

	-- 列表高度调整
	local size_ = listView_:getSize()
	size_.height = height_
	listView_:setSize(size_)

	-- 容器高度调整
	size_ = rewardItem:getSize()
	size_.height = y_ + height_ + rewardItem:getChildByName("Panel_20426"):getSize().height
	rewardItem:setSize(size_)

	-- 背景高度调整
	local back_ = rewardItem:getChildByName("Panel_15291")
	for i = 1, 3 do
		local x_, y_ = back_:getChildByName(tostring(i)):getPosition()		
		back_:getChildByName(tostring(i)):setPosition(x_, size_.height)
	end

	for i = 4, 6 do
		local temp = back_:getChildByName(tostring(i))
		local x_, y_ = temp:getPosition()		
		temp:setPosition(x_, size_.height / 2)
		local size1_ = temp:getSize()
		size1_.height = (size_.height - back_:getChildByName(tostring(1)):getSize().height) / hp.uiHelper.RA_scaleY
		temp:setSize(size1_)
	end
	local x_, y_ = back_:getChildByName(tostring(10)):getPosition()
	back_:getChildByName(tostring(10)):setPosition(x_, size_.height)

	if info_.flag == 1 then
		local getReward_ = rewardContent_:getChildByName("ImageView_22897")
		getReward_:getChildByName("Label_22898"):setString(hp.lang.getStrByID(1426))
		getReward_:setTouchEnabled(true)
		getReward_:setVisible(true)
		getReward_:addTouchEventListener(self.onCollectTouched)
	elseif info_.flag == 2 then
		local warning_ = rewardContent_:getChildByName("ImageView_20464")
		warning_:setVisible(true)
	elseif info_.flag == 3 then
		local start_ = rewardContent_:getChildByName("ImageView_20457")
		start_:getChildByName("Label_20458"):setString(hp.lang.getStrByID(1415))
		start_:getChildByName("ImageView_20459"):getChildByName("Label_20460"):setString(hp.datetime.strTime(info_.time))
		start_:setVisible(true)
		start_:setTag(tag_)
		start_:loadTexture(config.dirUI.common..startImage[info_.enabled])
		start_:setTouchEnabled(startTouchEnabled_[info_.enabled])
		start_:addTouchEventListener(self.onStartTouched)
	end

	rewardItem:addTouchEventListener(self.onRewardTouched)
	rewardItem:setTag(tag_)
	self.taskInfo[tag_] = {fold=1, info_=info_}
	return rewardItem
end

function UI_dailyQuest:onMsg(msg_, param_)
	if msg_ == hp.MSG.MISSION_DAILY_CHANGE then
		self:updateUIShow()
	elseif msg_ == hp.MSG.MISSION_DAILY_COMPLETE then
		if param_ == self.type then
			self:onMissionComplete()
		end
	elseif msg_ == hp.MSG.MISSION_DAILY_COLLECTED then
		if param_ == self.type then
			self:onRewardCollected()
			self:changeShowPanel()
		end
	elseif msg_ == hp.MSG.MISSION_DAILY_REFRESH then
		self:changeShowPanel()
	end
end

function UI_dailyQuest:onMissionComplete()
	local item_ = self.listView:getItem(0)
	if item_ ~= nil then
		local content_ = item_:getChildByName("Panel_20426")
		content_:getChildByName("ImageView_20464"):setVisible(false)
		content_:getChildByName("ImageView_22897"):setTouchEnabled(true)
		content_:getChildByName("ImageView_22897"):setVisible(true)
		content_:getChildByName("ImageView_22897"):addTouchEventListener(self.onCollectTouched)
		content_:getChildByName("ImageView_22897"):getChildByName("Label_22898"):setString(hp.lang.getStrByID(1426))
		self:setShowState(false)
	end
end

function UI_dailyQuest:onRewardCollected()
	self.listView:removeItem(0)
	local nodes = self.listView:getChildren()
	for i, v in ipairs(nodes) do
		local start_ = v:getChildByName("Panel_20426"):getChildByName("ImageView_20457")
		start_:loadTexture(config.dirUI.common..startImage[1])
		start_:setTouchEnabled(startTouchEnabled_[1])
	end
end

function UI_dailyQuest:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	self:updateTickInfo()
end

function UI_dailyQuest:updateTickInfo()
	local countTime_ = player.getResetTime(self.type) - player.getServerTime()
	if countTime_ < 0 then
		countTime_ = 0
	end
	local info_ = cdBox.getCDInfo(speedupcode[self.type])
	if info_ ~= nil then
		if info_.cd > 0 then
			self:setShowState(true)
			self:updateCDTime()
		else
			self:setShowState(false)
		end
	else
		self:setShowState(false)
	end
	self.refreshTime:setString(hp.datetime.strTime(countTime_))

	self.countTime:setString(hp.datetime.strTime(countTime_))
end

function UI_dailyQuest:setShowState(show_)
	if self.showState == show_ then
		return
	end
	self.showState = show_

	if show_ then
		self.speedUp:setTouchEnabled(true)
		self.loadingContainer_:setVisible(true)
		size_ = self.listView:getSize()
		size_.height = size_.height - self.loadingContainer_:getSize().height
		self.listView:setSize(size_)
	else
		self.speedUp:setTouchEnabled(false)
		self.loadingContainer_:setVisible(false)
		size_ = self.listView:getSize()
		size_.height = size_.height + self.loadingContainer_:getSize().height
		self.listView:setSize(size_)
	end
end

function UI_dailyQuest:updateCDTime()
	local cdInfo_ = cdBox.getCDInfo(speedupcode[self.type])
	self.loadingText:setString(hp.datetime.strTime(cdInfo_.cd))
	local percent_ = hp.common.round(100 - cdInfo_.cd / cdInfo_.total_cd * 100)
	self.loadingBar:setPercent(percent_)
end

function UI_dailyQuest:close()
	self.foldContainer:release()
	self.unfoldContainer:release()
	self.rewardItem:release()
	self.super.close(self)
end