--
-- ui/guidance/armyItems/hospitalItem.lua
-- 医馆
--===================================
local HospitalItem = {}

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
local haveHospital
local haveSoldier
local isRun
local time
local total_time

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8169)), 
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
		if haveHospital then
			if isRun then
				parent:addUI(UI_speedItem.new(cdBox.CDTYPE.REMEDY))
			else
				player.buildingMgr.getBuildingObjBySid(1014):onClicked()
			end
		else
			parent:closeAll()
			-- 进入地图
			if game.curScene.mapLevel ~= 3 then
				require("scene/cityMap")
				local map = cityMap.new()
				map:enter()
			end
			local block = game.curScene:getBlock(1)
			block:Scroll2Here(0.5)
			block:addGuide()
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
function HospitalItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_hospital.png"

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
	haveHospital = false
	haveSoldier = false
	isRun = false
	time = 0
	total_time = 0

	setExterior()
	setListener()
	HospitalItem.setData()
end

-- 设置数据
function HospitalItem.setData()
	timeLabel:setString("")
	text:setOpacity(255)
	
	local hospitalBuild = player.buildingMgr.getBuildingNumBySid(1014)
	haveHospital = hospitalBuild ~= nil and hospitalBuild > 0
	if haveHospital then
		isRun = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY).cd > 0
		if isRun then
			priority = 2
			btnText:setString(hp.lang.getStrByID(8138))
			time = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY).cd
			total_time = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY).total_cd
			timeLabel:setString(hp.datetime.strTime(time))
			progressBar:setPercent((1 - time / total_time) * 100)
			text:setString(hp.lang.getStrByID(3114))
		else
			haveSoldier = player.soldierManager.getHurtArmy():getSoldierTotalNumber() > 0
			if haveSoldier then
				priority = 1
				text:setString(hp.lang.getStrByID(8158))
				btnText:setString(hp.lang.getStrByID(8159))
			else
				priority = 4
				text:setString(hp.lang.getStrByID(8161))
			end
		end
	else
		priority = 1
		text:setString(hp.lang.getStrByID(8160))
		btnText:setString(hp.lang.getStrByID(8157))
	end
	btn:setVisible((not haveHospital) or isRun or haveSoldier)
	btn:setTouchEnabled((not haveHospital) or isRun or haveSoldier)
	btnText:setVisible((not haveHospital) or isRun or haveSoldier)
	progress:setVisible(isRun)
end

function HospitalItem.heartbeat(dt)
	if isRun then
		time = cdBox.getCDInfo(cdBox.CDTYPE.REMEDY).cd
		timeLabel:setString(hp.datetime.strTime(time))
		progressBar:setPercent((1 - time / total_time) * 100)
		if time <= 0 then
			HospitalItem.setData()
		end
	end
end

function HospitalItem.getItem()
	return item
end

function HospitalItem.getPriority()
	return priority
end

function HospitalItem.getCheckIndex()
	return index
end

function HospitalItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function HospitalItem.removeBtnLight()
	btn:removeAllChildren()
end

function HospitalItem.onRemove()
	item:release()
end

return HospitalItem