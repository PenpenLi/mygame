--
-- ui/mansion/pmItem/kingactItem.lua
-- 国王争夺战活动
--===================================
local KingactItem = {}

local parent
local item
local iconUrl

-- 控件
local content
local text
local btn
local btnText
local checked

local index
local priority
local isCheck
local isOpen
local time

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8193)), 
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
		player.mansionMgr.primeMinisterMgr.kingActivityClick()
		require("scene/kingdomMap")
		local map = kingdomMap.new()
		map:enter()
		map:gotoPosition(cc.p(255, 511))
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
function KingactItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_kingAct.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	btnText:setString(hp.lang.getStrByID(8192))
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")

	priority = 0
	isCheck = 0
	isOpen = false
	time = 0

	setExterior()
	setListener()
	KingactItem.setData()
end

-- 设置数据
function KingactItem.setData()
	local info = player.fortressMgr.getFortressInfo()
	if info == nil then
		isOpen = false
	else
		isOpen = info.open == 0
	end
	if isOpen then
		if not player.mansionMgr.primeMinisterMgr.getKingActivityIsClick() then
			priority = 1
		else
			priority = 4
		end
		text:setString(hp.lang.getStrByID(8190))
	else
		priority = 4
		time = player.fortressMgr.getFortressInfo().startTime - player.getServerTime()
		text:setString(hp.lang.getStrByID(8191) .. hp.datetime.strTime(time))
	end
	btn:setTouchEnabled(isOpen)
	btn:setVisible(isOpen)
	btnText:setVisible(isOpen)
end

function KingactItem.heartbeat(dt)
	if isOpen == false then
		time = time - dt
		text:setString(hp.lang.getStrByID(8191) .. hp.datetime.strTime(time))
		if time <= 0 then
			KingactItem.setData()
		end
	end
end

function KingactItem.getItem()
	return item
end

function KingactItem.getPriority()
	return priority
end

function KingactItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function KingactItem.removeBtnLight()
	btn:removeAllChildren()
end

function KingactItem.onRemove()
	item:release()
end

return KingactItem