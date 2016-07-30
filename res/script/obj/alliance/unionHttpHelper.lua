--------------------------
-- file:obj/alliance/unionHttpHelper.lua
-- 描述:公会网络消息处理

-- 通知消息:UNION_NOTIFY
-- 1-联盟图标修改
-- 2-离开联盟
-- 3-联盟基金改变
-- 4-个人贡献改变
-- 5-购买公会商品
-- =======================

-- obj
-- =======================
local unionHttpHelper = {}

-- 本地数据
-- =======================

-- 本地方法
-- =======================

-- 网络消息处理
local function sendHttpCmd(type_, param_, callBack_)
	local oper = {}
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			if type_ == 14 then
				hp.msgCenter.sendMsg(hp.MSG.UNION_NOTIFY, {msgType = 1, result = 0})
			elseif type_ == 2 then				
			end

			if callBack_ ~= nil then
				callBack_()
			end
		else
			if type_ == 14 then
				require "ui/common/successBox"
    			local box_ = UI_successBox.new(hp.lang.getStrByID(5192), hp.lang.getStrByID(5193), nil)
      			self:addModalUI(box_)
			end
		end	
	end

	local cmdData={operation={}}
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

-- =======================
-- 全局方法
-- =======================
-- 初始化
function unionHttpHelper.init()
end

function unionHttpHelper.changeUnionIcon(pic_)
	local param_ = {}
	param_.msg = pic_
	sendHttpCmd(14, param_, callBack_)
end

function unionHttpHelper.changeUnionAnnounce(text_, callBack_)
	local param_ = {}
	param_.msg = text_
	return sendHttpCmd(13, param_, callBack_)
end

return unionHttpHelper