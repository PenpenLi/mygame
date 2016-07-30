--------------------------------------
-- dataMgr/mansionMgr/signinMgr.lua
-- 签到状态管理器
-- ===================================

-- 对象
-- ================================
local signinMgr = {}

-- 私有数据
-- ================================
local data

-- 构造函数
function signinMgr.create()
	data = {}
end

-- 初始化
function signinMgr.init()
	data = {}
end

-- 网络数据初始化
function signinMgr.initData(data_)
	-- 当前天数
	data.day = data_.sign[1]
	-- 本月天数
	data.max = data_.sign[2]
	-- 连续签到天数
	data.signinDay = data_.sign[3]
	-- 签到信息
	data.signinInfo = data_.sign[4]
	-- 新服开始时间
	data.startTime = data_.sign[5]
	-- 新服结束时间
	data.endTime = data_.sign[6]
	-- 当日是否签到
	data.isSign = (data.day == data.signinInfo[#data.signinInfo])
end

-- 数据同步
function signinMgr.syncData(data_)
	if data_.sign then
		signinMgr.initByData(data_)
	end
end

-- 心跳
function signinMgr.heartbeat(dt)
	
end

-- 对外接口
-- ================================

-- 获取data
function signinMgr.getData()
	return data
end

-- 是否签到
function signinMgr.isSign()
	return data.isSign
end

return signinMgr