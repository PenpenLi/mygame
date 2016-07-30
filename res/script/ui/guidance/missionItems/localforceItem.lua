--
-- ui/mansion/pmItem/localforceItem.lua
-- 城卫军
--===================================
local LocalforceItem = {}

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
local haveMission
local haveRewards
local isRun
local time
local total_time
local refreshTime

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8170)), 
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
			parent:addUI(UI_speedItem.new(cdBox.CDTYPE.DAILYTASK))
		else
			if haveRewards or haveMission then
				require "ui/quest/dailyQuest.lua"
				local ui = UI_dailyQuest.new(1)
				parent:addUI(ui)
			else
				require "ui/common/buyAndUseItemPop"
				local ui_ = UI_buyAndUseItem.new(20251, 1, player.questManager.refreshQuest, {type=1,id=20251})
				parent:addModalUI(ui_)
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
function LocalforceItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_dailytask.png"

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
	haveMission = true
	haveRewards = true
	isRun = false
	time = 0
	total_time = 0
	refreshTime = 0

	setExterior()
	setListener()
	LocalforceItem.setData()
end

-- 播放文字动画
function LocalforceItem.playLabelAni()
	text:stopAllActions()
	setLabelAni(text, hp.lang.getStrByID(3111), cdBox.getDescInfo(cdBox.CDTYPE.DAILYTASK))
end

-- 停止文字动画
function LocalforceItem.stopLabelAni()
	text:stopAllActions()
end

-- 设置数据
function LocalforceItem.setData()
	timeLabel:setString("")
	text:setOpacity(255)
	text:stopAllActions()

	isRun = cdBox.getCDInfo(cdBox.CDTYPE.DAILYTASK).cd > 0
	if isRun then
		priority = 2
		btnText:setString(hp.lang.getStrByID(8138))
		time = cdBox.getCDInfo(cdBox.CDTYPE.DAILYTASK).cd
		total_time = cdBox.getCDInfo(cdBox.CDTYPE.DAILYTASK).total_cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		LocalforceItem.playLabelAni()
	else
		haveRewards = player.questManager.rewardNotCollected(1)
		if haveRewards then
			priority = 1
			text:setString(hp.lang.getStrByID(8143))
			btnText:setString(hp.lang.getStrByID(1426))
		else
			haveMission = #player.questManager.getDailyTasks(1) > 0
			if haveMission then
				priority = 1
				text:setString(hp.lang.getStrByID(8142))
				btnText:setString(hp.lang.getStrByID(8145))
			else
				priority = 3
				text:setString(hp.lang.getStrByID(8144))
				btnText:setString(hp.lang.getStrByID(8146))
				time = player.questManager.getResetTime(1) - player.getServerTime()
				if time < 0 then
					time = 0
				end
				timeLabel:setString(hp.datetime.strTime(time))
			end
		end
	end
	progress:setVisible(isRun)
end

function LocalforceItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.DAILYTASK).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			LocalforceItem.setData()
		end
		if refreshTime >= 3 and priority == 2 then
			LocalforceItem.setData()
			refreshTime = 0
		end
		refreshTime = refreshTime + dt
	elseif not haveMission then
		time = time - dt
		if time <= 0 then
			time = 0
			LocalforceItem.setData()
		end
		timeLabel:setString(hp.datetime.strTime(time))
	end
end

function LocalforceItem.getItem()
	return item
end

function LocalforceItem.getPriority()
	return priority
end

function LocalforceItem.getCheckIndex()
	return index
end

function LocalforceItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function LocalforceItem.removeBtnLight()
	btn:removeAllChildren()
end

function LocalforceItem.onRemove()
	item:release()
end

return LocalforceItem