--------------------------
-- file:playerData/conflictManager.lua
-- 描述:2级地图指定地点的信息管理
-- =======================

-- obj
-- =======================
local conflictManager = {}

-- 本地数据
-- =======================

local local_armys = {}
local local_interval = 0
local local_requestData = false
local local_x = 0
local local_y = 0

local myPosServerInfo = nil

-- 本地方法
-- =======================
local function parseArmyData(info_)
	local_armys = {}
	for i, v in ipairs(info_) do
		hp.msgCenter.sendMsg(hp.MSG.MAP_ARMY_ATTACK, {army=v,byClick=true})		
	end

	for i, v in ipairs(info_) do
		local army_ = player.marchMgr.parseOneArmy(v)
		local_armys[army_.id] = army_
	end
	cclog_("++++++++++++++++++++ARMY_CONFLICT,x,y")
end

-- 网络消息处理
local function sendHttpCmd(type_, param_, notify_, callBack_)
	if local_requestData then
		return
	end

	local cmdData={}
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			if type_ == 3 then
				local_x = cmdData.x
				local_y = cmdData.y
				parseArmyData(data.army)
				if notify_ then
					hp.msgCenter.sendMsg(hp.MSG.ARMY_CONFLICT, {msgType=1})
				end
			end

			if callBack_ ~= nil then
				callBack_()
			end
		end	
		local_requestData = false
	end

	local_requestData = true	
	cmdData.type = type_
	for k, v in pairs(param_) do
		cmdData[k] = v
	end

	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, myPosServerInfo.url)
	cclog_("++++++++++++++++++++sendHttpCmd,x,y")
	-- self:showLoading(cmdSender, sender)
end

-- =======================
-- 全局方法
-- =======================
-- 初始化
function conflictManager.init()
	local_x = 0
	local_y = 0
	local_armys = {}
	local_interval = 0
	local_requestData = false
	myPosServerInfo = player.serverMgr.getMyPosServer()
end

function conflictManager.httpReqRequestData(x, y, notify_, callBack_)
	local param_ = {}
	param_.x = x
	param_.y = y
	sendHttpCmd(3, param_, notify_, callBack_)
end

-- 数据初始化
function conflictManager.initData(data_)
end

function conflictManager.getArmyByMarchType(marchType_)
	local armys_ = {}
	for k, v in pairs(local_armys) do
		if v.marchType == marchType_ then
			table.insert(armys_, v)
		end
	end
	return armys_
end

function conflictManager.heartBeat(dt_)
	if local_interval < 1 then
		local_interval = local_interval + dt_
		return
	end
	local_interval = 0
	
	if local_requestData == true then
		return
	end

	for k, v in pairs(local_armys) do
		if globalData.ARMY_FUNC[v.marchType].loadingBar then
			if v.tEnd < player.getServerTime() then
				-- if v.marchType == globalData.ARMY_TYPE.RALLYING then
				-- 	-- 转为出发
				-- 	local_armys[k].marchType = globalData.ARMY_TYPE.MARCH_TO
				-- 	local_armys[k].tStart = v.tEnd
				-- 	local_armys[k].tEnd = v.temp1
				-- 	local_armys[k].pEnd = v.temp2
				-- elseif v.marchType == globalData.ARMY_TYPE.KING_BATTLE_RALLY then
				-- 	-- 转为出发
				-- 	marchMgr.armys[k].marchType = globalData.ARMY_TYPE.KING_BATTLE_TO
				-- 	marchMgr.armys[k].tStart = v.tEnd
				-- 	marchMgr.armys[k].tEnd = v.temp1
				-- 	marchMgr.armys[k].pEnd = v.temp2
				-- 	hp.msgCenter.sendMsg(hp.MSG.MARCH_MANAGER)
				-- else
					conflictManager.httpReqRequestData(local_x, local_y, true)
					return
				-- end
			end
		end
	end
end

function conflictManager.exit()
	local_armys = {}
end

return conflictManager