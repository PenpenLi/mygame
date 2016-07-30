--
-- file: dataMgr/researchMgr.lua
-- desc: 玩家科技管理
--================================================

-- 对象
-- ================================
-- ********************************
local  researchMgr = {}


-- 私有数据
-- ================================
-- ********************************
local researchList = {} --科技列表


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function researchMgr.create()
	-- body
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function researchMgr.init()
	-- body
	researchList = {}
end

-- initData
-- 使用玩家登陆数据进行初始化
function researchMgr.initData(data_)
	local data = data_.ability
	if data~=nil then
		researchList = data
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function researchMgr.syncData(data_)
	-- body
end

-- heartbeat
-- 心跳操作
function researchMgr.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- getResearchList
-- 获取已经学习的科技列表
function researchMgr.getResearchList()
	return researchList
end

-- getResearchLv
-- 获取科技等级
-- research存放技能sid数组，sid前3位代表技能id，后2位代表技能等级
function researchMgr.getResearchLv(researchId)
	for i,v in ipairs(researchList) do
		if math.floor(v/100)==researchId then
			return v%100
		end
	end
	return 0
end

-- getResearchCurLvInfo
-- 获取技能当前等级信息
function researchMgr.getResearchCurLvInfo(researchId)
	local iTmp = 1
	local sid = researchId*100 +1
	for i,v in ipairs(researchList) do
		iTmp = math.floor(v/100)
		if iTmp==researchId then
			sid = v
			break
		end
	end

	for i, researchInfo in ipairs(game.data.research) do
		if researchInfo.sid==sid then
			return researchInfo
		end
	end

	return nil
end

-- getResearchNextLvInfo
-- 获取技能下一等级信息
function researchMgr.getResearchNextLvInfo(researchId)
	local iTmp = 1
	local sid = researchId*100 +1
	for i,v in ipairs(researchList) do
		iTmp = math.floor(v/100)
		if iTmp==researchId then
			sid = v+1
			break
		end
	end

	for i, researchInfo in ipairs(game.data.research) do
		if researchInfo.sid==sid then
			return researchInfo
		end
	end

	return nil
end

-- getResearchMaxLv
-- 获取技能最大等级
function researchMgr.getResearchMaxLv( researchId )
	local maxLv = 0
	local iTmp = 1
	for i, researchInfo in ipairs(game.data.research) do
		iTmp = math.floor(researchInfo.sid/100)
		if iTmp==researchId and researchInfo.level>maxLv then
			maxLv = researchInfo.level
		end
	end
	return maxLv
end

-- addResearch
-- 添加科技
function researchMgr.addResearch( researchSid )
	-- 先删除上一级技能
	local researchId = math.floor(researchSid/100)
	for i,v in ipairs(researchList) do
		if math.floor(v/100)==researchId then
			table.remove(researchList, i)
			break
		end
	end

	table.insert(researchList, researchSid)
end

-- isTechResearch
-- 查询科技是否研究
function researchMgr.isTechResearch(researchSid)
	local ret = false
	for i,v in ipairs(researchList) do
		if v==researchSid then
			ret = true
			break
		end
	end
	return ret
end

-- getAttrAddn
-- 获取属性加成
-- @attrType_: 加成属性类型
function researchMgr.getAttrAddn(attrType_)
	local addn = 0

	for i, sid in ipairs(researchList) do
		local researchInfo = hp.gameDataLoader.getInfoBySid("research", sid)
		if researchInfo~=nil then
			if attrType_==researchInfo.type1 then
				addn = addn+researchInfo.value1
			end
			if attrType_==researchInfo.type2 then
				addn = addn+researchInfo.value2
			end
		end
	end

	return addn
end

return researchMgr