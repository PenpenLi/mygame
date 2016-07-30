--
-- ui/guidance/affairsItems/researchItem.lua
-- 研究
--===================================
local ResearchItem = {}

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
local haveAcademy
local isRun
local time
local total_time

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8175)), 
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
		if haveAcademy then
			if isRun then
				parent:addUI(UI_speedItem.new(cdBox.CDTYPE.RESEARCH))
			else
				haveAcademy:onClicked()
			end
		else
			parent:closeAll()
			if game.curScene.mapLevel==3 then
			-- 在城内地图
				local block = game.curScene:getBlock(1)
				block:Scroll2Here(0.5)
				block:addGuide()
			else
			-- 不在城内地图，切入到城内
				require("scene/cityMap")
				local map = cityMap.new()
				map:enter()
				local block = map:getBlock(1)
				block:Scroll2Here(0.5)
				block:addGuide()
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
function ResearchItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_research.png"

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
	ResearchItem.setData()
end

-- 设置数据
function ResearchItem.setData()
	timeLabel:setString("")

	haveAcademy = player.buildingMgr.getBuildingObjBySid(1007)
	if haveAcademy then
		isRun = cdBox.getCDInfo(cdBox.CDTYPE.RESEARCH).cd > 0
		if isRun then
			priority = 2
			text:setString(hp.lang.getStrByID(3103))
			btnText:setString(hp.lang.getStrByID(8138))
			time = cdBox.getCDInfo(cdBox.CDTYPE.RESEARCH).cd
			total_time = cdBox.getCDInfo(cdBox.CDTYPE.RESEARCH).total_cd
			timeLabel:setString(hp.datetime.strTime(time))
			progressBar:setPercent((1 - time / total_time) * 100)
		else
			priority = 1
			text:setString(hp.lang.getStrByID(8140))
			btnText:setString(hp.lang.getStrByID(8141))
		end
	else
		priority = 1
		text:setString(hp.lang.getStrByID(8165))
		btnText:setString(hp.lang.getStrByID(8157))
	end
	progress:setVisible(isRun)
end

function ResearchItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.RESEARCH).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			ResearchItem.setData()
		end
	end
end

function ResearchItem.getItem()
	return item
end

function ResearchItem.getPriority()
	return priority
end

function ResearchItem.getCheckIndex()
	return index
end

function ResearchItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function ResearchItem.removeBtnLight()
	btn:removeAllChildren()
end

function ResearchItem.onRemove()
	item:release()
end

return ResearchItem