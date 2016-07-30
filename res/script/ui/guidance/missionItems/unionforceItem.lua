--
-- ui/mansion/pmItem/unionforceItem.lua
-- 联盟军
--===================================
local UnionforceItem = {}

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
local haveUnion
local haveMission
local haveRewards
local isRun
local time
local total_time
local refreshTime

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8171)), 
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
		if haveUnion then
			if isRun then
				parent:addUI(UI_speedItem.new(cdBox.CDTYPE.LEAGUETASK))
			else
				if haveMission or haveRewards then
					require "ui/quest/dailyQuest.lua"
					local ui = UI_dailyQuest.new(2)
					parent:addUI(ui)
				else
					require "ui/common/buyAndUseItemPop"
					local ui_ = UI_buyAndUseItem.new(20252, 1, player.questManager.refreshQuest, {type=2,id=20252})
					parent:addModalUI(ui_)
				end
			end
		else
			require "ui/union/invite/unionJoin.lua"
			local ui_ = UI_unionJoin.new()
			parent:addUI(ui_)
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
function UnionforceItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_leaguetask.png"

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
	UnionforceItem.setData()
end

-- 播放文字动画
function UnionforceItem.playLabelAni()
	text:stopAllActions()
	setLabelAni(text, hp.lang.getStrByID(3112), cdBox.getDescInfo(cdBox.CDTYPE.LEAGUETASK))
end

-- 停止文字动画
function UnionforceItem.stopLabelAni()
	text:stopAllActions()
end

-- 设置数据
function UnionforceItem.setData()
	timeLabel:setString("")
	text:setOpacity(255)
	text:stopAllActions()

	haveUnion = player.getAlliance() ~= nil and player.getAlliance():getUnionID() ~= 0
	if haveUnion then
		isRun = cdBox.getCDInfo(cdBox.CDTYPE.LEAGUETASK).cd > 0
		if isRun then
			priority = 2
			btnText:setString(hp.lang.getStrByID(8138))
			time = cdBox.getCDInfo(cdBox.CDTYPE.LEAGUETASK).cd
			total_time = cdBox.getCDInfo(cdBox.CDTYPE.LEAGUETASK).total_cd
			timeLabel:setString(hp.datetime.strTime(time))
			progressBar:setPercent((1 - time / total_time) * 100)
			UnionforceItem.playLabelAni()
		else
			haveRewards = player.questManager.rewardNotCollected(2)
			if haveRewards then
				priority = 1
				text:setString(hp.lang.getStrByID(8143))
				btnText:setString(hp.lang.getStrByID(1426))
			else
				haveMission = #player.questManager.getDailyTasks(2) > 0
				if haveMission then
					priority = 1
					text:setString(hp.lang.getStrByID(8147))
					btnText:setString(hp.lang.getStrByID(8145))
				else
					priority = 3
					text:setString(hp.lang.getStrByID(8144))
					btnText:setString(hp.lang.getStrByID(8146))
					time = player.questManager.getResetTime(2) - player.getServerTime()
					if time < 0 then
						time = 0
					end
					timeLabel:setString(hp.datetime.strTime(time))
				end
			end
		end
	else
		priority = 1
		text:setString(hp.lang.getStrByID(8148))
		btnText:setString(hp.lang.getStrByID(8149))
	end
	progress:setVisible(isRun)
end

function UnionforceItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.LEAGUETASK).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			UnionforceItem.setData()
		end
		if refreshTime >= 3 and priority == 2 then
			UnionforceItem.setData()
			refreshTime = 0
		end
		refreshTime = refreshTime + dt
	elseif not haveMission then
		time = time - dt
		if time <= 0 then
			time = 0
			UnionforceItem.setData()
		end
		timeLabel:setString(hp.datetime.strTime(time))
	end
end

function UnionforceItem.getItem()
	return item
end

function UnionforceItem.getPriority()
	return priority
end

function UnionforceItem.getCheckIndex()
	return index
end

function UnionforceItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function UnionforceItem.removeBtnLight()
	btn:removeAllChildren()
end

function UnionforceItem.onRemove()
	item:release()
end

return UnionforceItem