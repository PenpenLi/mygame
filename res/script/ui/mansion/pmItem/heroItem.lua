--
-- ui/mansion/pmItem/heroItem.lua
-- 武将招募
--===================================
local heroItem = {}

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
local haveHero

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8194)), 
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
		player.buildingMgr.getBuildingObjBySid(1022):onClicked()
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
function heroItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_general.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")

	priority = 0
	haveHero = false

	setExterior()
	setListener()
	heroItem.setData()
end

-- 设置数据
function heroItem.setData()
	haveHero = player.takeInHeroMgr.getHeroNum() > 0
	if haveHero then
		priority = 1
		text:setString(hp.lang.getStrByID(8196))
		btnText:setString(hp.lang.getStrByID(8195))
	else
		priority = 4
		text:setString(hp.lang.getStrByID(8197))
		btn:setVisible(false)
		btnText:setVisible(false)
	end
end

function heroItem.heartbeat(dt)
	return
end

function heroItem.getItem()
	return item
end

function heroItem.getPriority()
	return priority
end

function heroItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function heroItem.removeBtnLight()
	btn:removeAllChildren()
end

function heroItem.onRemove()
	item:release()
end

return heroItem