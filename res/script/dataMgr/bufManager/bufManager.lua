--
-- file: playerData/bufManager/bufManager.lua
-- desc: 道具加成管理器
-- msgType: 1-buf刷新
-- 特殊buff：AGRBLE(1)混淆,IMPRISON(2)关押加成,KILL_ACK(3)杀英雄攻击加成,KILL_DEF(4)杀英雄防御加成,KILL_LIFE(5)杀英雄生命加成,
-- * KILL_SPEED(6)-杀死英雄速度加成,VIEW_DOUBLE(100)-侦察时候看到双倍数据*/

--================================================

-- 全局数据
-- ==================

-- 科技加成
-- ==================
local bufManager = {}

-- 本地数据
-- ==================
-- 静态数据
-- 特殊buff映射表
local specialBuffMap = {[6]={45},[41]={2,3},[42]={4},[43]={5},[45]={6}}
-- 变量
local local_bufByID = {}	-- 以属性为索引的列表
local local_specialBufByID = {} -- 特殊buff

-- 解析buf
local function parseOneBuf(info_)
	local buf_ = {}
	buf_.attrID = info_[2]
	buf_.addn = info_[3]
	buf_.endTime = info_[1] + player.getServerTime()
	buf_.total_cd = info_[4]
	return buf_
end

-- 添加普通buff
local function addNormalBuff(info_)
	local list_ = {}
	for i, v in ipairs(info_) do
		local buf_ = parseOneBuf(v)
		if list_[buf_.attrID] == nil then
			list_[buf_.attrID] = {}
		end
		table.insert(list_[buf_.attrID], buf_)
	end

	for i, v in pairs(list_) do
		local_bufByID[i] = v
	end
end

-- 添加特殊buff
local function addSpecialBuff(info_)
	local list_ = {}
	for i, v in ipairs(info_) do
		local buf_ = parseOneBuf(v)
		if list_[buf_.attrID] == nil then
			list_[buf_.attrID] = {}
		end
		table.insert(list_[buf_.attrID], buf_)
	end

	for i, v in pairs(list_) do
		local_specialBufByID[i] = v
	end
end

-- 更新数据
local function updateBufInfo(info_)
	-- 普通buff
	local_bufByID = {}
	for i, v in ipairs(info_[1]) do
		local buf_ = parseOneBuf(v)
		if local_bufByID[buf_.attrID] == nil then
			local_bufByID[buf_.attrID] = {}
		end
		table.insert(local_bufByID[buf_.attrID], buf_)
	end

	-- 特殊buff
	local_specialBufByID = {}
	for i, v in ipairs(info_[2]) do
		local buf_ = parseOneBuf(v)
		if local_specialBufByID[buf_.attrID] == nil then
			local_specialBufByID[buf_.attrID] = {}
		end
		table.insert(local_specialBufByID[buf_.attrID], buf_)
	end
end

-- ==================
-- 全局方法
-- ==================
function bufManager.create()
	-- body
end

function bufManager.init()
	local_bufByID = {}	-- 以属性为索引的列表
	local_specialBufByID = {} -- 特殊buff
end

--初始化数据
function bufManager.initData(info_)
	if info_.buff == nil then
		return
	end
	updateBufInfo(info_.buff)
end

-- 数据同步
function bufManager.syncData(info_)
	if info_.buff == nil then
		return
	end
	updateBufInfo(info_.buff)
	hp.msgCenter.sendMsg(hp.MSG.BUF_NOTITY, {msgType=1})
end

-- 心跳检测
function bufManager.heartbeat(dt_)
	for i, v in pairs(local_bufByID) do
		for j, w in ipairs(v) do
			if w.endTime < player.getServerTime() then
				table.remove(v, j)
			end
		end
	end
end

-- ==================
-- 外部接口
-- ==================
-- 添加buff
function bufManager.addBuff(info_)
	addNormalBuff(info_[1])

	addSpecialBuff(info_[2])
end

-- 获取普通道具加成
function bufManager.getAttrAddn(attrType_)
	local addn_ = 0

	if local_bufByID[attrType_] == nil then
		addn_ = 0
	else
		for i, v in ipairs(local_bufByID[attrType_]) do
			cclog_(v.addn)
			addn_ = addn_ + v.addn
		end
	end

	return addn_
end

-- 获取buf
function bufManager.getBufByAttrID(attrType_)
	return local_bufByID[attrType_]
end

-- 获取特殊加成
-- @attrType_:属性id，attr表中的
function bufManager.getSpecialAttrAddn(attrType_)
	local addn_ = 0
	local specialAttrID_ = specialBuffMap[attrType_]
	if specialAttrID_ == nil then
		return 0
	end

	for j, w in ipairs(specialAttrID_) do
		if local_specialBufByID[w] ~= nil then
			for i, v in ipairs(local_specialBufByID[w]) do
				addn_ = addn_ + v.addn
			end
		end
	end

	return addn_
end

-- 获取特殊加成，通过特殊id
function bufManager.getSpAddnBySpID(spID_)
	local addn_ = 0

	if local_specialBufByID[spID_] == nil then
		addn_ = 0
	else
		for i, v in ipairs(local_specialBufByID[spID_]) do
			cclog_(v.addn)
			addn_ = addn_ + v.addn
		end
	end

	return addn_
end

-- 获取特殊buf
function bufManager.getSpBufBySpID(spID_)
	return local_specialBufByID[spID_]
end

return bufManager