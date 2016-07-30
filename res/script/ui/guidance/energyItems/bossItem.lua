--
-- ui/guidance/energyItems/bossItem.lua
-- BOSS
--===================================
local BossItem = {}

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
local haveSoldier

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
		local function onBaseInfoResponse(status, response, tag)
			if status == 200 then
				local res = hp.httpParse(response)
				if res.result ~= nil and res.result == 0 then
					if res.x == 0 and res.y == 0 then
						local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(11509), hp.lang.getStrByID(1209))
						parent:addModalUI(msgbox)
						return
					end
					if game.curScene.mapLevel == 3 then
						require("scene/kingdomMap")
						local map = kingdomMap.new()
						map:enter()
					else
						parent:closeAll()
					end
					game.curScene:gotoPosition(cc.p(res.x, res.y))
					game.curScene:showGuidePoint(cc.p(res.x, res.y))
				end
				return
			else
				return
			end
		end
		local cmdData = {operation = {}}
		local oper = {}
		oper.channel = 6
		oper.type = 14
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		parent:showLoading(cmdSender, sender)
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
function BossItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_boss.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	btnText:setString(hp.lang.getStrByID(8198))
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")

	priority = 0
	isCheck = 0
	haveEnergy = false
	haveSoldier = false

	setExterior()
	setListener()
	BossItem.setData()
end

-- 设置数据
function BossItem.setData()
	local energy = player.getEnerge()
	haveEnergy = energy ~= nil and energy >= 20
	haveSoldier = player.soldierManager.getCityArmy():getSoldierTotalNumber() > 0

	if haveEnergy then
		if haveSoldier then
			priority = 1
			text:setString(string.format(hp.lang.getStrByID(8187), energy))
		else
			priority = 4
			text:setString(hp.lang.getStrByID(11510))
		end
	else
		priority = 4
		text:setString(hp.lang.getStrByID(8199))
	end
	btn:setVisible(haveEnergy and haveSoldier)
	btn:setTouchEnabled(haveEnergy and haveSoldier)
	btnText:setVisible(haveEnergy and haveSoldier)
end

function BossItem.heartbeat(dt)
	return
end

function BossItem.getItem()
	return item
end

function BossItem.getPriority()
	return priority
end

function BossItem.getCheckIndex()
	return index
end

function BossItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function BossItem.removeBtnLight()
	btn:removeAllChildren()
end

function BossItem.onRemove()
	item:release()
end

return BossItem