--
-- file: dataMgr/itemBag.lua
-- desc: 道具包
--================================================


-- 对象
-- ================================
-- ********************************
local itemBag = {}


-- 私有数据
-- ================================
-- ********************************
local itemsMap = {} --道具映射表{道具sid: 道具个数}


-- 私有函数
-- ================================
-- ********************************

-- player调用接口函数
-- 以下函数必须实现(即使不被调用)，提供给player调用
-- 注: 这些接口尽量不在游戏的其他地方调用
-- ================================
-- ********************************

-- create
function itemBag.create()
	-- body
end

-- init
function itemBag.init()
	itemsMap = {}
end

-- initData
function itemBag.initData(data_)
	-- 道具
	local items = data_.items
	if items~=nil then
		for i=1, #items, 2 do
			itemsMap[items[i]] = items[i+1]
		end
	end
	--材料
	items = data_.items1
	if items~=nil then
		for i=1, #items, 2 do
			itemsMap[items[i]] = items[i+1]
		end
	end
	--宝石
	items = data_.items2
	if items~=nil then
		for i=1, #items, 2 do
			itemsMap[items[i]] = items[i+1]
		end
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function itemBag.syncData(data_)
	-- 道具
	local items = data_.items
	if items~=nil then
		for i=1, #items, 2 do
			itemBag.setItemNum(items[i], items[i+1])
		end
	end
	--材料
	items = data_.items1
	if items~=nil then
		for i=1, #items, 2 do
			itemBag.setItemNum(items[i], items[i+1])
		end
	end
	--宝石
	items = data_.items2
	if items~=nil then
		for i=1, #items, 2 do
			itemBag.setItemNum(items[i], items[i+1])
		end
	end
end

-- heartbeat
-- 心跳操作
-- 注: 这个心跳间隔最少为1秒
function itemBag.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- getItemList 
-- 获取道具列表
function itemBag.getItemList()
	return itemsMap
end
-- getItemNum 
-- 获取道具个数
function itemBag.getItemNum(itemSid_)
	return itemsMap[itemSid_] or 0
end
-- setItemNum 
-- 设置道具个数
function itemBag.setItemNum(itemSid_, num_)
	itemsMap[itemSid_] = num_

	hp.msgCenter.sendMsg(hp.MSG.ITEM_CHANGED, {sid=itemSid_, num=num_})
end
-- addItem
-- 添加道具
function itemBag.addItem(itemSid_, num_)
	if itemsMap[itemSid_]==nil then
		itemsMap[itemSid_] = 0
	end
	itemsMap[itemSid_] = itemsMap[itemSid_]+num_

	hp.msgCenter.sendMsg(hp.MSG.ITEM_CHANGED, {sid=itemSid_, num=itemsMap[itemSid_]})
end
-- expendItem
-- 消耗道具
function itemBag.expendItem(itemSid_, num_)
	if itemsMap[itemSid_]==nil then
		itemsMap[itemSid_] = 0
	end
	itemsMap[itemSid_] = itemsMap[itemSid_]-num_

	hp.msgCenter.sendMsg(hp.MSG.ITEM_CHANGED, {sid=itemSid_, num=itemsMap[itemSid_]})
end


return itemBag
