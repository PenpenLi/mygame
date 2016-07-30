--
-- ui/mansion/pmItem/marchItem.lua
-- 行军
--===================================

-- 出城采集
-- channel = 6
-- @type = 12
--===================================

local MarchItem = {}

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
local canMarch

local function checkedWarn(msgIsFunc)
	local msgbox = UI_msgBox.new(hp.lang.getStrByID(6034), 
		string.format(hp.lang.getStrByID(8167),hp.lang.getStrByID(8184)), 
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
						-- 附近没有资源点
						return
					end
					require("scene/kingdomMap")
					local map = kingdomMap.new()
					map:enter()
					map:gotoPosition(cc.p(res.x, res.y))
					map:showGuidePoint(cc.p(res.x, res.y))
				end
				return
			else
				return
			end
		end
		local cmdData = {operation = {}}
		local oper = {}
		oper.channel = 6
		oper.type = 12
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
function MarchItem.init(parent_, item_, index_)
	parent = parent_
	item = item_:clone()
	item:retain()
	index = index_

	iconUrl = "cd_icon_march.png"

	content = item:getChildByName("Panel_content")
	text = content:getChildByName("Label_txt")
	btn = content:getChildByName("Image_btnGet")
	btnText = content:getChildByName("Label_info")
	btnText:setString(hp.lang.getStrByID(8184))
	checked = content:getChildByName("Image_checkBox"):getChildByName("Image_checked")

	priority = 0
	isCheck = 0
	haveEnergy = false

	setExterior()
	setListener()
	MarchItem.setData()
end

-- 设置数据
function MarchItem.setData()
	local freeSoldier = player.soldierManager.getCityArmy():getSoldierTotalNumber()
	local canMarch_ = player.marchMgr.canMarch()
	canMarch = canMarch_ and freeSoldier > 0
	if canMarch then
		priority = 1
		text:setString(string.format(hp.lang.getStrByID(8180), freeSoldier))
		btnText:setString(hp.lang.getStrByID(8184))
	else
		priority = 4
		if freeSoldier <= 0 and not canMarch_ then
			text:setString(hp.lang.getStrByID(8183))
		elseif not canMarch_ then
			text:setString(hp.lang.getStrByID(8182))
		else
			text:setString(hp.lang.getStrByID(8181))
		end
	end
	btn:setVisible(canMarch)
	btn:setTouchEnabled(canMarch)
	btnText:setVisible(canMarch)
end

function MarchItem.heartbeat(dt)
	return
end

function MarchItem.getItem()
	return item
end

function MarchItem.getPriority()
	return priority
end

function MarchItem.setBtnLight()
	local light = inLight(btn:getVirtualRenderer(), 1)
	btn:addChild(light)
end

function MarchItem.removeBtnLight()
	btn:removeAllChildren()
end

function MarchItem.onRemove()
	item:release()
end

return MarchItem