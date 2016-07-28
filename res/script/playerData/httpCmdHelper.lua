-- file:playerData/httpCmdHelper.lua
-- desc:数据请求
-- ==================================

httpCmdHelper = {}

local function onUnionInfoResponse(status, response, tag)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result==0 then

	end
end

-- public
-- ==================================
function httpCmdHelper.sendUnionInfoRequest(param_, callBack_)
	oper.channel = channel_
	oper.type = type_
	for i, v in pairs(param_) do
		oper[i] = v
	end
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onUnionInfoResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end