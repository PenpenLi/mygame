--------------------------
-- file:playerData/activity/goldShopMgr.lua
-- 描述:商城管理器
-- MSG: GOLD_SHOP {msgType:1-请求数据}
-- =======================

-- obj
-- =======================
local goldShopMgr = {}

-- 本地数据
-- =======================
-- 变量
local local_shopItem = {{},{},{}}
local local_requestMark = false
local local_itemBuying = false
local local_buyCountTime = 0

-- 本地方法
-- =======================
local function getDealLine()
	local curTime_ = player.getServerTime()
	curTime_ = curTime_ + 86400
	local date_ = os.date("*t", curTime_)
	date_.hour = 0
	date_.min = 0
	date_.sec = 1
	return os.time(date_)
end

local function parseOneItem(sid_)
	local item_ = {}
	item_.sid = sid_		-- sid
	item_.info = hp.gameDataLoader.getInfoBySid("recharge", item_.sid)	-- 基本信息
	return item_
end

local function updateData(info_)
	cclog_("updateData")
	local_shopItem = {{},{},{}}

	-- 无限售卖,3
	for i, v in ipairs(info_[1]) do
		local item_ = parseOneItem(v)
		item_.endTime = -1
		table.insert(local_shopItem[3], item_)
	end

	-- 每日售卖,2
	for i, v in ipairs(info_[2]) do
		local item_ = parseOneItem(v[1])
		item_.valid = v[2]
		item_.endTime = getDealLine()
		table.insert(local_shopItem[2], item_)
	end

	-- 一次性,1
	for i, v in ipairs(info_[3]) do
		local item_ = parseOneItem(v)
		item_.endTime = -1
		item_.valid = 0
		table.insert(local_shopItem[1], item_)
	end

	-- 限时礼包
	for i, v in ipairs(info_[4]) do
		local item_ = {}
		item_.sid = v[1]
		item_.endTime = v[9]
		item_.valid = v[10]
		local info_ = {}
		info_.sid = v[1]
		info_.bg_pic = v[2]
		info_.icon_pic = v[3]
		info_.name = v[4]
		info_.desc = v[5]
		info_.showTime = v[6]
		info_.money = v[7]
		info_.gold = v[8]
		info_.propId = clone(v[11])
		info_.propNum = clone(v[12])
		item_.info = info_
		table.insert(local_shopItem[1], item_)
	end

	-- 排序
	local func = function(t1, t2) if t1.sid < t2.sid then return true end end
	for i = 1, 3 do
		table.sort(local_shopItem[i], func)
	end
end

-- 网络消息处理
local function sendHttpCmd(type_, param_, callBack_)
	local oper = {}
	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			if type_ == 1 then
				updateData(data.mall)
				local_requestMark = false
				hp.msgCenter.sendMsg(hp.MSG.GOLD_SHOP, {msgType=1})
			elseif type_ == 2 then
			elseif type_ == 3 then
				goldShopMgr.httpReqRequestData()
			end			
		end

		if callBack_ ~= nil then
			callBack_(data)
		end
	end

	local cmdData={operation={}}
	oper.channel = 27
	oper.type = type_
	for k, v in pairs(param_) do
		oper[k] = v
	end	
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	-- self:showLoading(cmdSender, sender)
end

-- 尝试购买道具
local function tryBuyItem(sid_, callBack_)
	local param_ = {}
	param_.sid = sid_
	local_itemBuying = true
	sendHttpCmd(2, param_, callBack_)
end

-- =======================
-- 全局方法
-- =======================
function goldShopMgr.create()
	-- body
end

-- 初始化
function goldShopMgr.init()
	local local_shopItem = {{},{},{}}
	local_requestMark = false
	local_itemBuying = false
	local_buyCountTime = 0
end

-- 数据初始化
function goldShopMgr.initData(info_)
	goldShopMgr.httpReqRequestData()
end

-- 数据同步
function goldShopMgr.syncData(data_)
	
end

-- 定时检测
function goldShopMgr.heartbeat(dt_)
	if local_buyCountTime > 0 then
		local_buyCountTime = local_buyCountTime - dt_
		if local_buyCountTime <= 0 then
			local_itemBuying = false
		end
	end

	for i, v in ipairs(local_shopItem) do
		for j, w in ipairs(v) do
			if w.endTime ~= -1 then
				if w.endTime < player.getServerTime() then
					goldShopMgr.httpReqRequestData()
				end
			end
		end
	end
end

-- =======================
-- 外部接口
-- =======================
-- 历史请求
function goldShopMgr.httpReqRequestData()
	if local_requestMark == true then
		return
	end
	local_requestMark = true
	sendHttpCmd(1, {})
end

-- 完成购买道具
function goldShopMgr.httpReqFinishBuyItem(sid_)
	local param_ = {}
	param_.sid = sid_
	sendHttpCmd(3, param_)
end

-- 购买道具
function goldShopMgr.buyItem(sid_)
	local function checkCallBack(param_)
		local_buyCountTime = 3
		if param_.result == 0 then
			-- 可以买
			local info_ = goldShopMgr.getItemInfo(sid_)
			if info_ == nil then
				return
			end
			game.sdkHelper.payBuy(info_.sid, info_.money * globalData.CHARGE_COEF)
		else
			goldShopMgr.httpReqRequestData()
		end
	end
	
	if not local_itemBuying then	
		-- 检查
		tryBuyItem(sid_, checkCallBack)
	else
		cclog_("multi buy item!")
	end
end

-- 获取商品
function goldShopMgr.getShopItem()
	return local_shopItem
end

-- 获取商品信息
function goldShopMgr.getItemInfo(sid_)
	for i, v in ipairs(local_shopItem) do
		for j, w in ipairs(v) do
			if w.sid == sid_ then
				return w.info
			end
		end
	end

	return nil
end

return goldShopMgr