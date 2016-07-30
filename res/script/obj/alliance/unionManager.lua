--
-- obj/alliance/unionManager.lua
-- 公会信息管理器
--================================================

UnionManager = class("UnionManager")

--
-- ctor
-------------------------------
function UnionManager:ctor(info_)
	self.unionList = {}
	self.allData = false
	self.interval = 10

	self.indexBegin = 0
	self.indexEnd = 0
end

function UnionManager:setInterval(interval_)
	self.interval = interval_
end

function UnionManager:insertUnion(info_)
	table.insert(self.unionList, info_)
	info_.index = table.getn(self.unionList)
end

function UnionManager:setAllData(all_)
	self.allData = all_
end

function UnionManager:getData(type_)
	cclog_("getData", type_)
	cclog_(table.getn(self.unionList))
	if type_ == 1 then
		return self:getFirstUnions()
	elseif type_ == 2 then
		return self:getPreUnions()
	elseif type_ == 3 then
		return self:getNextUnions()
	else
		return {}
	end
end

function UnionManager:getFirstUnions()
	if self.interval <= 0 then
		return {}
	end

	if table.getn(self.unionList) == 0 then
		return {}
	end

	self.indexBegin = 1
	self.indexEnd = self.indexBegin + self.interval - 1

	if self.indexEnd > table.getn(self.unionList) then
		if self.allData == false then
			return nil
		else
			self.indexEnd = table.getn(self.unionList)
		end
	end

	local temp_ = {}
	for i = self.indexBegin, self.indexEnd do
		table.insert(temp_, self.unionList[i])
	end
	cclog_("indexBegin",self.indexBegin)
	cclog_("indexEnd",self.indexEnd)
	return temp_
end

function UnionManager:getLastUnions()
	-- local 
end

function UnionManager:getNextUnions()
	if self.interval <= 0 then
		return {}
	end

	if table.getn(self.unionList) == 0 then
		return {}
	end

	if self.indexEnd + self.interval > table.getn(self.unionList) then
		if self.allData == false then
			return nil
		else
			self.indexEnd = table.getn(self.unionList)
		end
	else
		self.indexEnd = self.indexEnd + self.interval
	end

	if self.indexBegin + self.interval <= table.getn(self.unionList) then
		self.indexBegin = self.indexBegin + self.interval
	end
	
	local temp_ = {}
	for i = self.indexBegin, self.indexEnd do
		table.insert(temp_, self.unionList[i])
	end
	cclog_("indexBegin",self.indexBegin)
	cclog_("indexEnd",self.indexEnd)
	return temp_
end

function UnionManager:getPreUnions()
	if self.interval <= 0 then
		return {}
	end

	if table.getn(self.unionList) == 0 then
		return {}
	end

	if self.indexBegin - self.interval <= 0 then
		self.indexBegin = 1
	else
		self.indexBegin = self.indexBegin - self.interval
	end

	self.indexEnd = self.indexBegin + self.interval - 1
	if self.indexEnd >= table.getn(self.unionList) then
		self.indexEnd = table.getn(self.unionList)
	end

	local temp_ = {}
	for i = self.indexBegin, self.indexEnd do
		table.insert(temp_, self.unionList[i])
	end
	cclog_("indexBegin",self.indexBegin)
	cclog_("indexEnd",self.indexEnd)
	return temp_
end

function UnionManager:getLastID()
	local index_ = table.getn(self.unionList)
	return self.unionList[index_].id
end

function UnionManager:getUnionInfoByIndex(index_)
	return self.unionList[index_]
end

function UnionManager:getCurPage()
	return math.ceil(self.indexEnd / self.interval)
end

-- 清空数据
function UnionManager:clearData()
	self.unionList = {}
	self.allData = false

	self.indexBegin = 0
	self.indexEnd = 0
end