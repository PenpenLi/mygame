--------------------------
-- file:embassyMgr.lua
-- 描述:使馆
-- =======================

-- obj
-- =======================
local embassyMgr = {}

-- 本地数据
-- =======================
local local_armys = {}
local local_totalNum = 0

-- 本地方法
-- =======================
local function parseOneEmbassy(info_)
	local army_ = {}
	army_.id = info_[1]
	army_.name = info_[2]
	army_.num = info_[3]
	army_.endTime = info_[4]
	return army_
end

local function parseEmbassyData(info_)
	local_armys = {}
	local_totalNum = 0
	for i, v in ipairs(info_) do
		local army_ = parseOneEmbassy(v)
		local_totalNum = local_totalNum + army_.num
		local_armys[army_.id] = army_
	end
end

local function sendHttpCmd(type_, param_)
	local oper = {}

	local function onHttpResponse(status, response)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ==0 then
			if type_ == 38 then
				parseEmbassyData(data.support)
				hp.msgCenter.sendMsg(hp.MSG.EMBASSY, {1})
			elseif type_ == 52 then
				local name_ = local_armys[oper.id].name
				local_armys[oper.id] = nil
				hp.msgCenter.sendMsg(hp.MSG.EMBASSY, {1})
				Scene.showMsg({1004, player.getAlliance():getBaseInfo().name, name_})
			end
		end		
	end

	local cmdData={operation={}}
	local cmdSender = nil
	oper.channel = 16
	oper.type = type_
	for k, v in pairs(param_) do
		oper[k] = v
	end
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	return cmdSender
end

-- 全局方法
-- =======================
function embassyMgr.init()
	local_armys = {}
	local_totalNum = 0
end

-- 请求数据
function embassyMgr.httpReqReqestData()
	local param_ = {}
	param_.id = player.getID()
	return sendHttpCmd(38, param_)
end

-- 遣返
function embassyMgr.httpReqRepatriate(id_)
	local param_ = {}
	param_.id = id_
	return sendHttpCmd(52, param_)
end

-- 获取军队
function embassyMgr.getArmys()
	return local_armys
end

-- 获取数量
function embassyMgr.getTotalNumber()
	return local_totalNum
end

return embassyMgr