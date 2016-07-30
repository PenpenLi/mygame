--
-- ui/guidance/affairsItems/builderItem.lua
-- 建筑
--===================================
local BuilderItem = {}

local parent
local item
local iconUrl

-- 控件
local content
local text
local btn
local btnText
local checked
local progress
local progressBar
local timeLabel

local index
local priority
local isCheck
local isRun
local time
local total_time

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8189)), 
		hp.lang.getStrByID(1209), hp.lang.getStrByID(2412), msgIsFunc)
	parent:addModalUI(msgbox)
end

local function checkedDone()
	local checkTbl = player.checkedPMTbl.getCheckedTbl()
	checkTbl[index] = isCheck
	checked:setVisible(isCheck==0)
	player.checkedPMTbl.setCheckedTbl(checkTbl)
	hp.msgCenter.sendMsg(hp.MSG.PM_CHECK_CHANGE, index)
end

local function onCheckTouch(sender, eventType)
	hp.uiHelper.btnImgTouched(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if isCheck == 0 then
			local function msgIsFunc()
				isCheck = 1
				checkedDone()
			end
			checkedWarn(msgIsFunc)
		else
			isCheck = 0
			checkedDone()
		end
	end
end

local function onBtnTouch(sender, eventType)
	hp.uiHelper.btnImgTouched(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if isRun then
			parent:addUI(UI_speedItem.new(cdBox.CDTYPE.BUILD))
		else
			-- 前往建造（根据主线任务提示）
			local questId = player.questManager.getDoingMainQuestInfo()
			if questId == nil then
				parent:closeAll()
			else
				local questInfo = hp.gameDataLoader.getInfoBySid("quests", questId)
				local buildingId = questInfo.parameter1
				local buidingInfo = hp.gameDataLoader.getInfoBySid("building", buildingId)
				local questType = questInfo.showtype
				parent:closeAll()
				-- 进入地图
				if game.curScene.mapLevel ~= 3 then
					require("scene/cityMap")
					local map = cityMap.new()
					map:enter()
					buiding = player.buildingMgr.getBuildingObjBySid(buildingId)
				end
				if questType == 1 then
					local buiding = player.buildingMgr.getBuildingObjBySid(buildingId)
					if buiding == nil then
						local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(11511), hp.lang.getStrByID(1209))
						parent:addModalUI(msgbox)
					else
						buiding:Scroll2Here(0.5)
						buiding:addGuide()
					end
				elseif questType == 2 then
					local buiding = game.curScene:getBlock(buidingInfo.type)
					buiding:Scroll2Here(0.5)
					buiding:addGuide()
				end
			end
		end
	end
end

-- 设置外观
local function setExterior()
	local iconBg = content:getChildByName("Image_iconBg")
	iconBg:getChildByName("Image_icon"):loadTexture(config.dirUI.common .. iconUrl)

	isCheck = player.checkedPMTbl.getCheckedTbl()[index]
	checked:setVisible(isCheck==0)
end

-- 设置监听
local function setListener()
	local checkbox = content:getChildByName("Image_checkBox")
	checkbox:addTouchEventListener(onCheckTouch)
	local btn = content:getChildByName("Image_btnGet")
	btn:addTouchEventListener(onBtnTouch)
end

-- 初始化
function BuilderItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_build.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")
	progress = item:getChildByName("Panel_frame"):getChildByName("Progress_bg")
	progressBar = progress:getChildByName("Progress_bar")
	timeLabel = content:getChildByName("Label_time")

	priority = 0
	isCheck = 0
	haveAcademy = false
	isRun = false
	time = 0
	total_time = 0

	setExterior()
	setListener()
	BuilderItem.setData()
end

-- 设置数据
function BuilderItem.setData()
	timeLabel:setString("")

	isRun = cdBox.getCDInfo(cdBox.CDTYPE.BUILD).cd > 0
	if isRun then
		priority = 2
		text:setString(hp.lang.getStrByID(3101))
		btnText:setString(hp.lang.getStrByID(8138))
		time = cdBox.getCDInfo(cdBox.CDTYPE.BUILD).cd
		total_time = cdBox.getCDInfo(cdBox.CDTYPE.BUILD).total_cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
	else
		priority = 1
		text:setString(hp.lang.getStrByID(8135))
		btnText:setString(hp.lang.getStrByID(8157))
	end	
	progress:setVisible(isRun)
end

function BuilderItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.BUILD).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			BuilderItem.setData()
		end
	end
end

function BuilderItem.getItem()
	return item
end

function BuilderItem.getItemBtn()
	return btn
end

function BuilderItem.getPriority()
	return priority
end

function BuilderItem.getCheckIndex()
	return index
end

function BuilderItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function BuilderItem.removeBtnLight()
	btn:removeAllChildren()
end

function BuilderItem.onRemove()
	item:release()
end

return BuilderItem