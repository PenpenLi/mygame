--
-- ui/guidance/affairsItems/maketrapItem.lua
-- 城墙
--===================================
local MaketrapItem = {}

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
local canMake
local isRun
local time
local total_time

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8174)), 
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
			parent:addUI(UI_speedItem.new(cdBox.CDTYPE.TRAP))
		else
			player.buildingMgr.getBuildingObjBySid(1018):onClicked()
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

-- 获取最大陷阱数量
local function getTotalTrapCount()
	local barrackTrain_ = 0
	local barracklist = player.buildingMgr.getBuildingsBySid(1018)
	for i,v in ipairs(barracklist) do
		barrackTrain_ = barrackTrain_ + hp.gameDataLoader.getBuildingInfoByLevel("wall", v.lv, "deadfallMax")
	end
	return barrackTrain_
end

-- 初始化
function MaketrapItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_trap.png"

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
	canMake = true
	isRun = false
	time = 0
	total_time = 0

	setExterior()
	setListener()
	MaketrapItem.setData()
end

-- 播放文字动画
function MaketrapItem.playLabelAni()
	text:stopAllActions()
	setLabelAni(text, hp.lang.getStrByID(3105), cdBox.getDescInfo(cdBox.CDTYPE.TRAP))
end

-- 停止文字动画
function MaketrapItem.stopLabelAni()
	text:stopAllActions()
end

-- 设置数据
function MaketrapItem.setData()
	timeLabel:setString("")
	text:setOpacity(255)
	text:stopAllActions()
	
	isRun = cdBox.getCDInfo(cdBox.CDTYPE.TRAP).cd > 0
	if isRun then
		priority = 2
		btnText:setString(hp.lang.getStrByID(8138))
		time = cdBox.getCDInfo(cdBox.CDTYPE.TRAP).cd
		total_time = cdBox.getCDInfo(cdBox.CDTYPE.TRAP).total_cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		MaketrapItem.playLabelAni()
	else
		canMake = getTotalTrapCount() - player.trapManager.getTrapNum() > 0
		if canMake then
			priority = 1
			text:setString(hp.lang.getStrByID(8162))
			btnText:setString(hp.lang.getStrByID(8157))
		else
			priority = 4
			text:setString(hp.lang.getStrByID(8164))
		end
	end
	btn:setVisible(canMake)
	btn:setTouchEnabled(canMake)
	btnText:setVisible(canMake)
	progress:setVisible(isRun)
end

function MaketrapItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.TRAP).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			MaketrapItem.setData()
		end
	end
end

function MaketrapItem.getItem()
	return item
end

function MaketrapItem.getPriority()
	return priority
end

function MaketrapItem.getCheckIndex()
	return index
end

function MaketrapItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function MaketrapItem.removeBtnLight()
	btn:removeAllChildren()
end

function MaketrapItem.onRemove()
	item:release()
end

return MaketrapItem