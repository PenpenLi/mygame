--------------------------
-- file:marchMgr.lua
-- 描述:行军管理器
-- =======================

ARMY_TYPE = {
	MARCH_TO = 1,
	CAMP_ING = 2,
	SOURCE_ING = 3,
	SCOUT_TO = 4,
	SOURCE_TO = 5,
	REINFORCE_TO = 6,
	MARCH_BACK = 7,
	LEAGUECITY = 8,
	RALLYING = 9,
}

-- obj
-- =======================
local marchMgr = {}
marchMgr.armys = {}
marchMgr.armyNum = 0
marchMgr.viewNum = 0
local requestData_ = false
local interval = 0

-- 本地数据
-- =======================
local index_ = 0
local MARCH_TYPE_MAP = {
	1,1,7,3,5,6,1,4,7,1,2
}

-- 本地方法
-- =======================
local function parseOneArmy(info_)
	local armyInfo = marchMgr.parseArmyInfo(info_)
	-- 部队数量
	armyInfo.number = 0
	for i, v in ipairs(armyInfo.soldier) do
		armyInfo.number = armyInfo.number + v
	end
	-- 行军类型
	armyInfo.marchType = MARCH_TYPE_MAP[armyInfo.type + 1]
	if (armyInfo.type == 0) and (armyInfo.pStart.x == armyInfo.pEnd.x) and (armyInfo.pStart.y == armyInfo.pEnd.y) then
		armyInfo.marchType = ARMY_TYPE.CAMP_ING
	end

	if (armyInfo.marchType == ARMY_TYPE.REINFORCE_TO) and (armyInfo.pStart.x == armyInfo.pEnd.x) and (armyInfo.pStart.y == armyInfo.pEnd.y) then
		armyInfo.marchType = ARMY_TYPE.LEAGUECITY
	end

	-- 工会战
	if (armyInfo.type == 6) then
		if armyInfo.tStart > player.getServerTime() then
			armyInfo.marchType = ARMY_TYPE.RALLYING
			armyInfo.temp1 = armyInfo.tEnd
			armyInfo.temp2 = armyInfo.pEnd
			armyInfo.pEnd = armyInfo.pStart
			armyInfo.tEnd = armyInfo.tStart
			armyInfo.tStart = armyInfo.createArmyTime
		end
	end

	-- 总时间
	armyInfo.totalTime = armyInfo.tEnd - armyInfo.tStart
	return armyInfo
end

local function parseArmyData(info_)
	marchMgr.armys = {}
	for i, v in ipairs(info_[1]) do
		local army_ = parseOneArmy(v)
		marchMgr.armys[army_.id] = army_
	end

	for i, v in ipairs(info_[2]) do
		local army_ = parseOneArmy(v)
		marchMgr.armys[army_.id] = army_
	end
end

local function onHttpResponse(status, response)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result ==0 then
		parseArmyData(data.army)
		hp.msgCenter.sendMsg(hp.MSG.MARCH_MANAGER)
		-- Scene.showMsg({1004, player.getAlliance():getBaseInfo().name, name_})
	end
	requestData_ = false
end

local function onCancelRallyWarResponse(status, response)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result ==0 then
		marchMgr.sendCmd(8)
		-- Scene.showMsg({1004, player.getAlliance():getBaseInfo().name, name_})
	end
	requestData_ = false
end

-- 全局方法
-- =======================
function marchMgr.sendCmd(type_, param_)
	local cmdData={operation={}}
	local oper = {}
	local cmdSender = nil
	requestData_ = true
	print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	oper.channel = 5
	oper.type = type_
	cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function marchMgr.cancelRallyWar(id_)
	local cmdData={operation={}}
	local oper = {}
	local cmdSender = nil
	oper.channel = 6
	oper.type = 10
	oper.id = id_
	cmdSender = hp.httpCmdSender.new(onCancelRallyWarResponse)
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function marchMgr.initData(info_)
	local change_ = false
	if info_.armyNum ~= nil then
		marchMgr.armyNum = info_.armyNum
		change_ = true
	end

	if info_.viewNum ~= nil then
		marchMgr.viewNum = info_.viewNum
		change_ = true
	end

	if change_ == true then
		hp.msgCenter.sendMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	end
end

function marchMgr.getFieldArmyNum()
	return (marchMgr.armyNum + marchMgr.viewNum)
end

function marchMgr.getFieldArmy()
	return marchMgr.armys
end

function marchMgr.parseArmyInfo(info_)
	armyInfo = {}
	armyInfo.id = info_[1]
	armyInfo.pid = info_[2]
	armyInfo.pStart = cc.p(info_[3], info_[4])
	armyInfo.pEnd = cc.p(info_[5], info_[6])
	armyInfo.tStart = info_[7]
	armyInfo.tEnd = info_[8]
	armyInfo.loaded = info_[9]
	armyInfo.state = info_[10]
	armyInfo.name1 = info_[11]
	armyInfo.name2 = info_[12]
	armyInfo.unionID = info_[13]	
	armyInfo.type = info_[14]
	armyInfo.soldier = {info_[15], info_[16], info_[17], info_[18]}
	armyInfo.createArmyTime = info_[25]
	return armyInfo
end

function marchMgr.heartBeat(dt_)
	if interval < 1 then
		interval = interval + dt_
		return
	end
	interval = 0

	for k, v in pairs(marchMgr.armys) do
		if requestData_ == true then
			return
		end

		if v.marchType == ARMY_TYPE.CAMP_ING then
			return
		end

		if v.marchType == ARMY_TYPE.LEAGUECITY then
			return
		end

		if v.tEnd < player.getServerTime() then
			if v.marchType == ARMY_TYPE.RALLYING then
				-- 转为出发
				marchMgr.armys[k].marchType = ARMY_TYPE.MARCH_TO
				marchMgr.armys[k].tStart = v.tEnd
				marchMgr.armys[k].tEnd = v.temp1
				marchMgr.armys[k].pEnd = v.temp2
				hp.msgCenter.sendMsg(hp.MSG.MARCH_MANAGER)
			else
				marchMgr.sendCmd(8)
			end
		end
	end
end

return marchMgr