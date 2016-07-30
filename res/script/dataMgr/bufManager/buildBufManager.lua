--
-- file: playerData/bufManager/buildBufManager.lua
-- desc: 建筑加成管理器
-- 目前建筑加成有三种：1-每级都加 2-固定等级奖励 3-特殊触发(祭坛和监狱，特殊条件)，依赖服务器
-- 其中3不在此管理器中处理，在特殊buff管理器中
-- 所以每个建筑有两个表，存放1和2这两种加成，而第一种表已经存为文件格式了，所以只要映射过去就行
--================================================

-- 全局数据
-- ==================

-- 加成管理器
-- ==================
local buildBufManager = {}

-- 本地数据
-- ==================
local local_buffList = {}

-- 建筑加成表:{buildSid_,table1,table2}
-- buildSid_:建筑sid
-- table1:{tableName_,{attrID_=field_,...}}
-- table2:{attrID_={level_=num_,level_=num_,...},...}
-- 学院
local academy = {
	1007,
	{"academy",{[106]="speedRate"}}
}

-- 钱庄
local villa = {
	1017,
	{"villa",{[109]="trainSpeedRate"}},
	{[41]={[21]=2}}
}

-- 兵营
local barrack = {
	1009,
	nil,
	{[42]={[5]=1,[10]=2,[15]=3,[20]=4,[21]=10}}
}

-- 医馆
local hospital = {
	1014,
	nil,
	{[43]={[21]=5}}
}

local_buffList[1] = academy
local_buffList[2] = villa
local_buffList[3] = barrack
local_buffList[4] = hospital

-- ==================
-- 全局方法
-- ==================
-- create
-- 构造函数，player对象构建时，加载此模块，并调用
-- 注: 如果需要引进其他模块，请放到此接口
function buildBufManager.create()
	-- body
end

function buildBufManager.init()
end

-- initData
-- 使用玩家登陆数据进行初始化
-- 注: 在此没有必要发消息，因为没有地方需要这个消息
function buildBufManager.initData(data_)
	-- body
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function buildBufManager.syncData(data_)
	-- body
end

-- heartbeat
-- 心跳操作
-- 注: 这个心跳间隔最少为1秒
function buildBufManager.heartbeat(dt_)
	-- body
end

-- ==================
-- 外部接口
-- ==================
-- 获取普通道具加成
function buildBufManager.getAttrAddn(attrType_)
	local addn_ = 0

	for i, v in ipairs(local_buffList) do
		-- 建筑加成
		if v[2] ~= nil then
			local table_ = v[2][2]
			if table_[attrType_] ~= nil then
				local builds_ = player.buildingMgr.getBuildingsBySid(v[1])
				for j, w in ipairs(builds_) do
					addn_ = addn_ + hp.gameDataLoader.getBuildingInfoByLevel(v[2][1],w.lv,table_[attrType_],0)
				end
			end
		end

		-- 等级奖励
		if v[3] ~= nil then
			local table_ = v[3][attrType_]
			if table_ ~= nil then
				local builds_ = player.buildingMgr.getBuildingsBySid(v[1])
				for j, w in ipairs(builds_) do
					local tmpAddn_ = 0
					for k=1,w.lv do
						if table_[k] ~= nil then
							tmpAddn_ = table_[k]
						end
					end
					addn_ = addn_ + tmpAddn_
				end
			end
		end
	end

	return addn_*100
end

return buildBufManager