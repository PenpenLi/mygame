--------------------------
-- file:embassyMgr.lua
-- 描述:使馆
-- =======================

embassyOperType = {
	REQUESTDATA = 38,
	REPATRIATE = 52,
}

embassyMsgType = {
	DATARESPONSE = 1,
}

-- obj
-- =======================
local embassyMgr = {}
embassyMgr.armys = {}
embassyMgr.totalNum = 0

-- 本地数据
-- =======================
local repatrieteID = 0

-- 本地方法
-- =======================
local function parseOneEmbassy(info_)
	army_ = {}
	army_.id = info_[1]
	army_.name = info_[2]
	army_.num = info_[3]
	return army_
end

local function parseEmbassyData(info_)
	embassyMgr.armys = {}
	embassyMgr.totalNum = 0
	for i, v in ipairs(info_) do
		local army_ = parseOneEmbassy(v)
		embassyMgr.totalNum = embassyMgr.totalNum + army_.num
		embassyMgr.armys[army_.id] = army_
	end
end

local function onRequestResponse(status, response)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result ==0 then
		parseEmbassyData(data.support)
	end
	hp.msgCenter.sendMsg(hp.MSG.EMBASSY, {embassyMsgType.DATARESPONSE})
end

local function onRepatrieteResponse(status, response)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result ==0 then
		local name_ = embassyMgr.armys[repatrieteID].name
		embassyMgr.armys[repatrieteID] = nil
		hp.msgCenter.sendMsg(hp.MSG.EMBASSY, {embassyMsgType.DATARESPONSE})
		Scene.showMsg({1004, player.getAlliance():getBaseInfo().name, name_})
	end	
end

-- 全局方法
-- =======================
function embassyMgr.sendCmd(type_, param_)
	local cmdData={operation={}}
	local oper = {}
	local cmdSender = nil
	oper.channel = 16
	oper.type = type_
	if type_ == embassyOperType.REQUESTDATA then
		oper.id = player.getID()
		cmdSender = hp.httpCmdSender.new(onRequestResponse)
	elseif type_ == embassyOperType.REPATRIATE then
		repatrieteID = param_[1]
		oper.id = param_[1]
		cmdSender = hp.httpCmdSender.new(onRepatrieteResponse)
	end
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

return embassyMgr