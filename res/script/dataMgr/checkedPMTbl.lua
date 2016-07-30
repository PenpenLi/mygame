----------------------------
-- dataMgr/checkedPMTbl.lua
-- 府邸丞相选择标记状态列表
-- =======================

-- 对象
-- ================================
local checkedPMTbl = {}

-- 私有数据
-- ================================
local checkedTblNum

-- 构造函数
function checkedPMTbl.create()

end

-- 初始化
function checkedPMTbl.init()
	checkedTblNum = 0
end

-- 初始化网络数据
function checkedPMTbl.initData(data)
	checkedTblNum = data.userSys
	if checkedTblNum == nil then
		checkedTblNum = 0
	end
end

-- 同步数据
function checkedPMTbl.syncData(data)

end

-- 同步数据
function checkedPMTbl.heartbeat(dt)

end

-- 对外接口
-- ================================

-- 获取表
function checkedPMTbl.getCheckedTbl()
	local checkedTbl = {}
	for i=1,13 do
		local checked = hp.common.band(checkedTblNum, math.pow(2,i-1))
		checkedTbl[i] = checked
	end
	return checkedTbl
end

-- 设置表（同步至服务器）
function checkedPMTbl.setCheckedTbl(checkedTbl_)
	local result_ = 0
	for i,v in ipairs(checkedTbl_) do
		result_ = result_ + v * math.pow(2,i-1)
	end
	checkedTblNum = result_
	
	-- 网络请求回调
	local function onBuyHeroHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--成功
			end
			
		end
	end

	--send quest
	local function sendQuest()
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 22
		oper.type = 1
		oper.param = result_
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onBuyHeroHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	
	sendQuest()
	
end

return checkedPMTbl