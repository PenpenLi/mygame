--
-- ui/guidance/energyItems/battleItem.lua
-- 战役
--===================================
local BattleItem = {}

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
local haveEnergy

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8185)), 
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
		require "ui/copy/copyMainNew"
		local ui_ = UI_copyMainNew.new()
		parent:addUI(ui_)
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
function BattleItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_energy.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	btnText:setString(hp.lang.getStrByID(8188))
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")

	priority = 0
	isCheck = 0
	haveEnergy = false

	setExterior()
	setListener()
	BattleItem.setData()
end

-- 设置数据
function BattleItem.setData()
	local energy = player.getEnerge()
	haveEnergy = energy ~= nil and energy > 0
	if haveEnergy then
		priority = 1
		text:setString(string.format(hp.lang.getStrByID(8187), energy))
	else
		priority = 4
		text:setString(hp.lang.getStrByID(8186))
	end
	btn:setVisible(haveEnergy)
	btn:setTouchEnabled(haveEnergy)
	btnText:setVisible(haveEnergy)
end

function BattleItem.heartbeat(dt)
	return
end

function BattleItem.getItem()
	return item
end

function BattleItem.getPriority()
	return priority
end

function BattleItem.getCheckIndex()
	return index
end

function BattleItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function BattleItem.removeBtnLight()
	btn:removeAllChildren()
end

function BattleItem.onRemove()
	item:release()
end

return BattleItem