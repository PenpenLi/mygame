--
-- ui/mansion/pmItem/vipforceItem.lua
-- vip任务
--===================================
local VipforceItem = {}

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
local isVip
local haveMission
local haveRewards
local isRun
local time
local total_time
local refreshTime

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8172)), 
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
		if isVip then
			if isRun then
				parent:addUI(UI_speedItem.new(cdBox.CDTYPE.VIPTASK))
			else
				if haveRewards or haveMission then
					require "ui/quest/dailyQuest.lua"
					local ui = UI_dailyQuest.new(3)
					parent:addUI(ui)
				else
					require "ui/common/buyAndUseItemPop"
					local ui_ = UI_buyAndUseItem.new(20253, 1, player.questManager.refreshQuest, {type=3,id=20253})
					parent:addModalUI(ui_)
				end
			end
		else
			require("ui/item/commonItem")
			local ui = UI_commonItem.new(20000, hp.lang.getStrByID(3703))
			parent:addUI(ui)
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
function VipforceItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_viptask.png"

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
	haveUnion = false
	haveMission = true
	haveRewards = true
	isRun = false
	time = 0
	total_time = 0
	refreshTime = 0

	setExterior()
	setListener()
	VipforceItem.setData()
end

-- 播放文字动画
function VipforceItem.playLabelAni()
	text:stopAllActions()
	setLabelAni(text, hp.lang.getStrByID(3113), cdBox.getDescInfo(cdBox.CDTYPE.VIPTASK))
end

-- 停止文字动画
function VipforceItem.stopLabelAni()
	text:stopAllActions()
end

-- 设置数据
function VipforceItem.setData()
	timeLabel:setString("")
	text:setOpacity(255)
	text:stopAllActions()

	isVip = player.vipStatus.isActive()
	if isVip then
		isRun = cdBox.getCDInfo(cdBox.CDTYPE.VIPTASK).cd > 0
		if isRun then
			priority = 2
			btnText:setString(hp.lang.getStrByID(8138))
			time = cdBox.getCDInfo(cdBox.CDTYPE.VIPTASK).cd
			total_time = cdBox.getCDInfo(cdBox.CDTYPE.VIPTASK).total_cd
			timeLabel:setString(hp.datetime.strTime(time))
			progressBar:setPercent((1 - time / total_time) * 100)
			VipforceItem.playLabelAni()
		else
			haveRewards = player.questManager.rewardNotCollected(3)
			if haveRewards then
				priority = 1
				text:setString(hp.lang.getStrByID(8143))
				btnText:setString(hp.lang.getStrByID(1426))
			else
				haveMission = #player.questManager.getDailyTasks(3) > 0
				if haveMission then
					priority = 1
					text:setString(hp.lang.getStrByID(8150))
					btnText:setString(hp.lang.getStrByID(8145))
				else
					priority = 3
					text:setString(hp.lang.getStrByID(8144))
					btnText:setString(hp.lang.getStrByID(8146))
					time = player.questManager.getResetTime(3) - player.getServerTime()
					if time < 0 then
						time = 0
					end
					timeLabel:setString(hp.datetime.strTime(time))
				end
			end
		end
	else
		priority = 1
		text:setString(hp.lang.getStrByID(8151))
		btnText:setString(hp.lang.getStrByID(8152))
	end
	progress:setVisible(isRun)
end

function VipforceItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.VIPTASK).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			VipforceItem.setData()
		end
		if refreshTime >= 3 and priority == 2 then
			VipforceItem.setData()
			refreshTime = 0
		end
		refreshTime = refreshTime + dt
	elseif not haveMission then
		time = time - dt
		if time <= 0 then
			time = 0
			VipforceItem.setData()
		end
		timeLabel:setString(hp.datetime.strTime(time))
	end
end

function VipforceItem.getItem()
	return item
end

function VipforceItem.getPriority()
	return priority
end

function VipforceItem.getCheckIndex()
	return index
end

function VipforceItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function VipforceItem.removeBtnLight()
	btn:removeAllChildren()
end

function VipforceItem.onRemove()
	item:release()
end

return VipforceItem