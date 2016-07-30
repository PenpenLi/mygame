
--
-- ui/mansion/pmItem/unionhelpItem.lua
-- 联盟帮助
--===================================
local UnionhelpItem = {}

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
local haveUnion
local haveHelp

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8168)), 
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
		if not haveUnion then
			require "ui/union/invite/unionJoin.lua"
			local ui_ = UI_unionJoin.new()
			parent:addUI(ui_)
		else
			require("ui/union/mainFunc/unionHelp.lua")
			local ui = UI_unionHelp.new()
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
function UnionhelpItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "fight_18.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")

	priority = 0
	haveUnion = false
	haveHelp = false

	setExterior()
	setListener()
	UnionhelpItem.setData()
end

-- 设置数据
function UnionhelpItem.setData()
	haveUnion = player.getAlliance() ~= nil and player.getAlliance():getUnionID() ~= 0
	if haveUnion then
		local helpNum = player.getAlliance():getUnionHomePageInfo()["help"]
		haveHelp = helpNum ~= nil and helpNum > 0
		if haveHelp then
			priority = 1
			text:setString(string.format(hp.lang.getStrByID(8132), helpNum))
			btnText:setString(hp.lang.getStrByID(8134))
		else
			priority = 4
			text:setString(hp.lang.getStrByID(8133))
		end
	else
		priority = 1
		text:setString(hp.lang.getStrByID(8148))
		btnText:setString(hp.lang.getStrByID(8149))
	end
	btn:setVisible((not haveUnion) or haveHelp)
	btn:setTouchEnabled((not haveUnion) or haveHelp)
	btnText:setVisible((not haveUnion) or haveHelp)
end

function UnionhelpItem.heartbeat(dt)
	return
end

function UnionhelpItem.getItem()
	return item
end

function UnionhelpItem.getPriority()
	return priority
end

function UnionhelpItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function UnionhelpItem.removeBtnLight()
	btn:removeAllChildren()
end

function UnionhelpItem.onRemove()
	item:release()
end

return UnionhelpItem