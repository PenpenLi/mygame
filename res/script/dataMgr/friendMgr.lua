--
-- file: dataMgr/friendMgr.lua
-- desc: 玩家好友管理
--================================================

-- channel=18 好友操作网络请求
-- @type=1: 获取状态变化的好友
-- @type=2: 邀请好友
-- @type=3: 接受邀请
-- @type=4: 拒绝邀请
-- @type=5: 删除好友
-- @type=6: 搜索好友
-- ================================================

-- hp.MSG.FRIEND_MGR 好友管理消息
-- param {oper=1, type=1|2|3, fInfo=friendInfo} --向列表添加一个好友
-- param {oper=2, type=1|2|3, fInfo=friendInfo} --向列表删除一个好友
-- param {oper=3, rst=0|errNum} --邀请好友返回
--===================================================


-- 对象
-- ================================
-- ********************************
local friendMgr = {}


-- 私有数据
-- ================================
-- ********************************
local maxSize = 100			--好友最大容量
local cmdSender = nil

local friends = {}			--好友列表
local recvInvites = {}		--接收到的邀请
local sendInvites = {}		--发送的邀请
local localID = 1


-- 私有函数
-- ================================
-- ********************************
local function decodeFriendData(friendData_)
	local friendInfo = {}
	-- 设置本地id
	friendInfo.localId = localID
	localID = localID+1

	friendInfo.id = friendData_[1]
	friendInfo.name = friendData_[2]
	friendInfo.icon = friendData_[3]
	friendInfo.union = friendData_[4]
	friendInfo.onlineFlag = friendData_[5]
	friendInfo.time = friendData_[6]
	return friendInfo
end

local function checkAddFriend(friendInfo_, type_)
	local fList = friendMgr.getFriends(type_)
	for i, friendInfo in ipairs(fList) do
		if friendInfo_.id==friendInfo.id then
			return
		end
	end

	table.insert(fList, friendInfo_)
	hp.msgCenter.sendMsg(hp.MSG.FRIEND_MGR, {oper=1, type=type_, fInfo=friendInfo_})
end
local function checkDeleteFriend(id_, type_)
	local fList = friendMgr.getFriends(type_)
	for i, friendInfo in ipairs(fList) do
		if id_==friendInfo.id then
			table.remove(fList, i)
			hp.msgCenter.sendMsg(hp.MSG.FRIEND_MGR, {oper=2, type=type_, fInfo=friendInfo})
			return friendInfo
		end
	end

	return nil
end
-- onHttpResponse
local function onHttpResponse(status, response, tag)
	if status==200 then
		local data = hp.httpParse(response)
		if data.result==nil then
			return
		end

		if tag==1 then
		-- 数据同步
			if data.result==0 and data.friend~=nil then
				-- 好友
				------------------------------
				for i, v in ipairs(data.friend[1]) do
				-- 在线状态变化
					local fInfo = checkDeleteFriend(v, 1)
					if fInfo~=nil then
						fInfo.onlineFlag = not fInfo.onlineFlag
						checkAddFriend(fInfo, 1)
					end
				end
				for i, v in ipairs(data.friend[2]) do
				-- 添加
					local fInfo = decodeFriendData(v)
					checkAddFriend(fInfo, 1)
				end
				for i, v in ipairs(data.friend[3]) do
				-- 移除的
					checkDeleteFriend(v, 1)
				end

				-- 接收请求
				------------------------------
				for i, v in ipairs(data.friend[4]) do
				-- 添加
					local fInfo = decodeFriendData(v)
					checkAddFriend(fInfo, 2)
				end
				for i, v in ipairs(data.friend[5]) do
				-- 移除的
					checkDeleteFriend(v, 2)
				end

				-- 发送请求
				------------------------------
				for i, v in ipairs(data.friend[6]) do
				-- 添加
					local fInfo = decodeFriendData(v)
					checkAddFriend(fInfo, 3)
				end
				for i, v in ipairs(data.friend[7]) do
				-- 移除的
					checkDeleteFriend(v, 3)
				end
			end
		elseif tag==2 then
		-- 邀请好友
			if data.result==0 then
				hp.msgCenter.sendMsg(hp.MSG.FRIEND_MGR, {oper=3, rst=0})
				for i,v in ipairs(data.fSentInvites) do
					local fInfo = decodeFriendData(v)
					checkAddFriend(fInfo, 3)
				end
			else
				hp.msgCenter.sendMsg(hp.MSG.FRIEND_MGR, {oper=3, rst=data.result})
			end
		elseif tag==3 then
		-- 接收邀请
			if data.result==0 then
				local fInfo = checkDeleteFriend(data.id, 2)
				if fInfo~=nil then
					checkAddFriend(fInfo, 1)
				end
			end
		elseif tag==4 then
		-- 拒绝邀请
			if data.result==0 then
				checkDeleteFriend(data.id, 2)
			end
		elseif tag==5 then
		-- 删除好友
			if data.result==0 then
				checkDeleteFriend(data.id, 1)
			end
		end
	end
end

-- sendHttpOper
local function sendHttpOper(oper)
	local cmdData={operation={}}
	oper.channel = 18
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, oper.type)
	return true
end


-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function friendMgr.create()
	maxSize = 100
	cmdSender = hp.httpCmdSender.new(onHttpResponse)
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function friendMgr.init()
	localID = 1
	friends = {}
	recvInvites = {}
	sendInvites = {}
end

-- initData
-- 使用玩家登陆数据进行初始化
function friendMgr.initData(data_)
	local friend = data_.friend
	local fRecvInvites = data_.fRecvInvites
	local fSentInvites = data_.fSentInvites

	if friend~=nil then
		for i,v in ipairs(friend) do
			friendMgr.addFriendByData(v, 1)
		end
	end
	if fRecvInvites~=nil then
		for i,v in ipairs(fRecvInvites) do
			friendMgr.addFriendByData(v, 2)
		end
	end
	if fSentInvites~=nil then
		for i,v in ipairs(fSentInvites) do
			friendMgr.addFriendByData(v, 3)
		end
	end
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function friendMgr.syncData(data_)
	-- body
end

-- heartbeat
-- 心跳操作
function friendMgr.heartbeat(dt_)
	-- body
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- getFriends
-- 获取好友列表
-- type: 1--好友、2--接收的邀请、3--发送的邀请
--==============================================
function friendMgr.getFriends(type_)
	if type_==1 then
		return friends
	elseif type_==2 then
		return recvInvites
	elseif type_==3 then
		return sendInvites
	end

	return friends
end

--getMaxSize
--获取好友最大容量
function friendMgr.getMaxSize()
	return maxSize
end

-- addFriend
-- 添加好友
function friendMgr.addFriend(friendInfo_, type_)
	local fList = friendMgr.getFriends(type_)
	table.insert(fList, friendInfo_)
end

-- addFriendByData
-- 添加好友-ByData
function friendMgr.addFriendByData(friendData_, type_)
	local friendInfo = decodeFriendData(friendData_)
	friendMgr.addFriend(friendInfo, type_)
end

-- deleteFriend
-- 删除好友
function friendMgr.deleteFriend(localId_, type_)
	local fList = friendMgr.getFriends(type_)

	for i,v in ipairs(fList) do
		if localId_==v.localId then
			table.remove(fList, i)
			return
		end
	end
end

-- getFriendInfo
-- 获取好友信息
function friendMgr.getFriendInfo(localId_, type_)
	local fList = friendMgr.getFriends(type_)

	for i,v in ipairs(fList) do
		if localId_==v.localId then
			return v
		end
	end

	return nil
end

-- getFriendInfoByID 
-- 获取好友信息
function friendMgr.getFriendInfoByID(id_, type_)
	local fList = friendMgr.getFriends(type_)
	
	for i,v in ipairs(fList) do
		if id_==v.id then
			return v
		end
	end

	return nil
end


-- 好友操作网络请求
--======================================
-- sendInvite
-- 发送好友邀请
function friendMgr.sendInvite( playerName_ )
	local oper = {}
	oper.type = 2
	oper.name = playerName_
	sendHttpOper(oper)
end

-- acceptInvite
-- 接受好友邀请
function friendMgr.acceptInvite( playerId_ )
	local oper = {}
	oper.type = 3
	oper.id = playerId_
	sendHttpOper(oper)
end

-- refuseInvite
-- 拒绝好友邀请
function friendMgr.refuseInvite( playerId_ )
	local oper = {}
	oper.type = 4
	oper.id = playerId_
	sendHttpOper(oper)
end

-- sendDelete
-- 删除好友
function friendMgr.sendDelete( playerId_ )
	local oper = {}
	oper.type = 5
	oper.id = playerId_
	sendHttpOper(oper)
end

-- searchFriend
-- 查找好友
function friendMgr.searchFriend( playerName_ )
	local oper = {}
	oper.type = 6
	oper.name = playerName_
	sendHttpOper(oper)
end

-- friendSync
-- 同步好友信息
function friendMgr.friendSync()
	local oper = {}
	oper.type = 1
	sendHttpOper(oper)
end


return friendMgr
