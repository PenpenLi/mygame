--------------------------
-- file:marchMgr.lua
-- 描述:行军管理器
-- =======================

local SCOUT_MAX = 2
local MARCH_ICON = {"march_3", "march_7", "march_7", "kd_5", "alliance_27", "march_3", "march_8", "march_3", "march_3", "march_3", "march_7", "march_3", "march_7"}
local MARCH_LIST_TYPE = {8211, 5094, 8214, 8211, 8211, 5095, 8212, 5095, 8215, 8211, 8215, 8215, 8214}
local MARCH_TYPE_MAP = {
	1,1,7,3,5,6,1,4,7,10,11
}

-- obj
-- =======================
local marchMgr = {}

-- 本地数据
-- =======================
local local_armys = {}
local local_enemyArmys = {}
local local_armyNum = 0
local local_viewNum = 0
local local_requestData = false
local local_interval = 0
local local_conflict = false

-- 本地方法
-- =======================
local function parseArmyData(info_)
	local_armys = {}
	local_enemyArmys = {}
	for i, v in ipairs(info_[1]) do
		local army_ = marchMgr.parseOneArmy(v)
		local_armys[army_.id] = army_
	end
	local_armyNum = table.getn(info_[1])

	for i, v in ipairs(info_[2]) do
		local army_ = marchMgr.parseOneArmy(v)
		local_armys[army_.id] = army_
	end
	local_viewNum = table.getn(info_[2])

	cclog_("parse enemy")

	for i, v in ipairs(info_[3]) do
		local army_ = marchMgr.parseOneArmy(v)
		cclog_(army_.pEnd.x,army_.pEnd.y)
		for j, w in pairs(local_armys) do
			-- 位置判断
			cclog_("my",w.pEnd.x,w.pEnd.y)
			if w.pEnd.x == army_.pEnd.x and w.pEnd.y == army_.pEnd.y then
				table.insert(w.enemyIndex, i)
			end
		end
		table.insert(local_enemyArmys, army_)
	end

	if table.getn(info_[3]) > 0 then
		local_conflict = true
	else
		local_conflict = false
	end
	hp.msgCenter.sendMsg(hp.MSG.MARCH_MANAGER, {msgType = 1})
	hp.msgCenter.sendMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
end

local function onHttpResponse(status, response)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result ==0 then
		parseArmyData(data.army)
		-- Scene.showMsg({1004, player.getAlliance():getBaseInfo().name, name_})
	end
	local_requestData = false
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
	local_requestData = false
end

-- =======================
-- 全局方法
-- =======================
function marchMgr.create()
	-- body
end

function marchMgr.init()
	local_conflict = false
	local_armys = {}
	local_enemyArmys = {}
	local_armyNum = 0
	local_viewNum = 0
	local_requestData = false
	local_interval = 0
end

function marchMgr.initData(info_)
	local change_ = false
	if info_.armyNum ~= nil then
		local_armyNum = info_.armyNum
		change_ = true
	end

	if info_.viewNum ~= nil then
		local_viewNum = info_.viewNum
		change_ = true
	end

	if info_.army ~= nil then
		parseArmyData(info_.army)
	end

	if change_ == true then
		hp.msgCenter.sendMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	end
end

function marchMgr.syncData(info_)
	local change_ = false
	if info_.armyNum ~= nil then
		local_armyNum = info_.armyNum
		change_ = true
	end

	if info_.viewNum ~= nil then
		local_viewNum = info_.viewNum
		change_ = true
	end

	if info_.army ~= nil then
		parseArmyData(info_.army)
	end

	if change_ == true then
		marchMgr.sendCmd(8)
		hp.msgCenter.sendMsg(hp.MSG.MARCH_ARMY_NUM_CHANGE)
	end
end

function marchMgr.heartbeat(dt_)
	cclog_("local_interval",dt_,local_interval,hp.common.getTableTotalNum(local_armys))
	-- 处理间隔
	if local_interval < 1 then
		local_interval = local_interval + dt_
		return
	end
	local_interval = 0

	-- 正在请求
	if local_requestData == true then
		cclog_("armys local_requestData is true")
		return
	end

	for k, v in pairs(local_armys) do
		cclog_("marchMgr.heartbeat", k, v.marchType)

		if globalData.ARMY_FUNC[v.marchType].loadingBar then
			if v.tEnd < player.getServerTime() then
				-- if v.marchType == globalData.ARMY_TYPE.RALLYING then
				-- 	-- 转为出发
				-- 	local_armys[k].marchType = globalData.ARMY_TYPE.MARCH_TO
				-- 	local_armys[k].tStart = v.tEnd
				-- 	local_armys[k].tEnd = v.temp1
				-- 	local_armys[k].pEnd = v.temp2
				-- 	hp.msgCenter.sendMsg(hp.MSG.MARCH_MANAGER)
				-- elseif v.marchType == globalData.ARMY_TYPE.KING_BATTLE_RALLY then
				-- 	-- 转为出发
				-- 	local_armys[k].marchType = globalData.ARMY_TYPE.KING_BATTLE_TO
				-- 	local_armys[k].tStart = v.tEnd
				-- 	local_armys[k].tEnd = v.temp1
				-- 	local_armys[k].pEnd = v.temp2
				-- 	hp.msgCenter.sendMsg(hp.MSG.MARCH_MANAGER)
				-- else
					marchMgr.sendCmd(8)
					return
				-- end
			end
		end
	end

	for i, v in ipairs(local_enemyArmys) do
		if v.tEnd < player.getServerTime() then
			marchMgr.sendCmd(8)
			return
		end
	end
end

-- =======================
-- 外部接口
-- =======================
-- 解析军队信息
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
	armyInfo.image = info_[22]
	armyInfo.createArmyTime = info_[25]
	armyInfo.resCanLoaded = info_[26]
	armyInfo.hero = info_[27]
	return armyInfo
end

function marchMgr.sendCmd(type_, param_)
	if local_requestData then
		return
	end

	local cmdData={operation={}}
	local oper = {}
	local cmdSender = nil
	local_requestData = true
	oper.channel = 5
	oper.type = type_
	cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

-- 取消公会战
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
	return cmdSender
end

-- 能否侦查
function marchMgr.canScout()
	if local_viewNum > SCOUT_MAX then
		return false
	else
		return true
	end
end

-- 能否再派出部队
function marchMgr.canMarch()
	local level_ = player.buildingMgr.getMaxLvBuildingBySid(1001).lv
	local max_ = hp.gameDataLoader.getBuildingInfoByLevel("main", level_, "troopMax", 0)
	if local_armyNum >= max_ then
		return false
	else
		return true
	end
end

-- 是否冲突
function marchMgr.getConflict()
	return local_conflict
end

-- 获取野外部队数量
function marchMgr.getFieldArmyNum()
	return (local_armyNum + local_viewNum)
end

-- 获取野外部队
function marchMgr.getFieldArmy()
	return local_armys
end

-- 根据下标获取敌军信息
function marchMgr.getEnemyArmyByIndex(index_)
	return local_enemyArmys[index_]
end

-- 获取行军图标
function marchMgr.getMarchIcon(marchType_)
	return config.dirUI.common..MARCH_ICON[marchType_]..".png"
end

-- 获取行军队列类型名称
function marchMgr.getMarchListType(marchType_)
	return hp.lang.getStrByID(MARCH_LIST_TYPE[marchType_])
end

-- 解析一支队伍，附加了一些数据
function marchMgr.parseOneArmy(info_)
	local armyInfo = marchMgr.parseArmyInfo(info_)
	-- 部队数量
	armyInfo.number = 0
	for i, v in ipairs(armyInfo.soldier) do
		armyInfo.number = armyInfo.number + v
	end
	-- 行军类型
	armyInfo.marchType = MARCH_TYPE_MAP[armyInfo.type + 1]
	if (armyInfo.type == 0) and (armyInfo.pStart.x == armyInfo.pEnd.x) and (armyInfo.pStart.y == armyInfo.pEnd.y) then
		armyInfo.marchType = globalData.ARMY_TYPE.CAMP_ING
	end

	if (armyInfo.marchType == globalData.ARMY_TYPE.REINFORCE_TO) and (armyInfo.pStart.x == armyInfo.pEnd.x) and (armyInfo.pStart.y == armyInfo.pEnd.y) then
		armyInfo.marchType = globalData.ARMY_TYPE.LEAGUECITY
	end

	if (armyInfo.type == 9) and (armyInfo.pStart.x == armyInfo.pEnd.x) and (armyInfo.pStart.y == armyInfo.pEnd.y) then
		armyInfo.marchType = globalData.ARMY_TYPE.KING_BATTLE_OCCUPY
	end

	if (armyInfo.type == 3) then
		local resInfo_ = hp.gameDataLoader.getInfoBySid("resources", armyInfo.name2)
		if resInfo_.growth == 0 then
			-- 钻石
			armyInfo.marchType = globalData.ARMY_TYPE.SOURCE_GOLD
		end
	end

	-- 工会战
	if (armyInfo.type == 6) then
		if armyInfo.tStart > player.getServerTime() then
			armyInfo.marchType = globalData.ARMY_TYPE.RALLYING
			armyInfo.temp1 = armyInfo.tEnd
			armyInfo.temp2 = armyInfo.pEnd
			armyInfo.pEnd = armyInfo.pStart
			armyInfo.tEnd = armyInfo.tStart
			armyInfo.tStart = armyInfo.createArmyTime
		end
	end

	-- 国王工会战
	if armyInfo.type == 9 then
		if armyInfo.tStart > player.getServerTime() then
			armyInfo.marchType = globalData.ARMY_TYPE.KING_BATTLE_RALLY
			armyInfo.temp1 = armyInfo.tEnd
			armyInfo.temp2 = armyInfo.pEnd
			armyInfo.pEnd = armyInfo.pStart
			armyInfo.tEnd = armyInfo.tStart
			armyInfo.tStart = armyInfo.createArmyTime
		end
	end

	-- 敌军id列表
	armyInfo.enemyIndex = {}

	-- 总时间
	armyInfo.totalTime = armyInfo.tEnd - armyInfo.tStart
	return armyInfo
end

return marchMgr