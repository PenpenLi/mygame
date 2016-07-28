--
-- file: hp/chatRoom.lua
-- desc: 聊天室 -- 管理聊天信息
--================================================

-- channel=17 邮件操作网络请求
-- @type=1: 获取
-- @type=2: 发送区域聊天
-- @type=3: 发送国家聊天
-- @type=4: 发送世界聊天
-- @type=5: 发送公会聊天
-- @type=6: 发送私聊
-- ================================================

hp.chatRoom = {}


-- private variables
-------------------------
local maxNum = 50
local areaChatBox = {chatList = {}} --区域聊天
local unionChatBox = {chatList = {}} --公会聊天
local privateChatBoxs = {} --私聊
local chatId = 1

local channelType = 1			--聊天频道：1区域 2公会 3私聊
local lastChatInfo = nil		--最后一个要在主界面显示的聊天
local penultChatInfo = nil		--倒数第二要在主界面显示的聊天

local heartbeatTick = 0
local gettingChat = false
local cmdSender = nil

-- private functions
------------------------- 
-- getChatBoxByType
-- @chatType_：1区域 2公会 3私聊
-- @playerId_: 私聊对应的玩家id
local function getChatBoxByType(chatType_, playerId_)
	if chatType_==1 then
		return areaChatBox
	elseif chatType_==2 then
		return unionChatBox
	end

	if privateChatBoxs[playerId_]==nil then
		privateChatBoxs[playerId_] = {chatList = {}}
	end
	return privateChatBoxs[playerId_]
end

-- createChatInfo
local function createChatInfo(chatData)
	local chatInfo = {}
	chatInfo.id = chatId
	chatId = chatId+1

	chatInfo.type = chatData[1]		--类型 
	chatInfo.srcId = chatData[2]	--发送者id
	chatInfo.srcName = chatData[3]	--发送者name
	chatInfo.srcIcon = chatData[4]	--发送者Icon
	chatInfo.srcUnion = chatData[5]	--发送者公会
	chatInfo.srcArea = chatData[6]	--发送者区域
	chatInfo.destId = chatData[7]	--接收者id
	chatInfo.text = chatData[8]		--聊天内容
	chatInfo.vipLv = chatData[9]	--vip等级
	chatInfo.gmFlag = chatData[10]	--gm
	chatInfo.time = chatData[11]	--time

	return chatInfo
end

-- onHttpResponse
local function onHttpResponse(status, response, tag_)
	if tag_==1 then
		gettingChat = false
	end

	if status==200 then
		local data = hp.httpParse(response)
		if data.result~=nil and data.result==0 then
			if tag_==1 then
			-- 获取聊天
				for i,v in ipairs(data.msg) do
					hp.chatRoom.addChatInfo(v)
				end
			end
		end
	end
end

-- sendHttpOper
local function sendHttpOper(oper)
	local cmdData={operation={}}
	oper.channel = 17
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, oper.type)
	return true
end

-- public functions
-------------------------
-- init
function hp.chatRoom.init()
	cmdSender = hp.httpCmdSender.new(onHttpResponse)
end

-- initByData
function hp.chatRoom.initByData()
	areaChatBox = {chatList = {}} --区域聊天
	unionChatBox = {chatList = {}} --公会聊天
	privateChatBoxs = {} --私聊
	chatId = 1

	channelType = 1
	lastChatInfo = nil
	penultChatInfo = nil

	heartbeatTick = 0
	gettingChat = false
end

-- heartbeat
function hp.chatRoom.heartbeat(dt)
	if gettingChat then
		return
	end

	heartbeatTick = heartbeatTick+dt
	if heartbeatTick>=config.interval.chatRoomSync then
		gettingChat = true
		heartbeatTick = 0
		local oper = {}
		oper.type = 1
		sendHttpOper(oper)
	end
end

-- addChatInfo
-- 添加一个聊天
function hp.chatRoom.addChatInfo(chatData_)
	local chatInfo = createChatInfo(chatData_)
	local playerId = nil
	local chatType = 0
	if chatInfo.type==1 or chatInfo.type==2 or chatInfo.type==3 or chatInfo.type==6 then
		chatType = 1
	elseif chatInfo.type==4 then
		chatType = 2
	else
		chatType = 3
		if chatInfo.srcId~=player.getID() then
			playerId = chatInfo.srcId
		else
			playerId= chatInfo.destId
		end
	end
	local chatBox = getChatBoxByType(chatType, playerId)
	local chatList = chatBox.chatList
	if table.getn(chatList)>=maxNum then
		table.remove(chatList, 1)
	end
	table.insert(chatList, chatInfo)

	-- 当前聊天频道和私聊信息记录
	if chatType==channelType or chatType==3 then
		penultChatInfo = lastChatInfo
		lastChatInfo = chatInfo
	end
	hp.msgCenter.sendMsg(hp.MSG.CHATINFO_NEW, {type=chatType, id=playerId, chat=chatInfo})
end

-- getChatInfos
-- 获取聊天
function hp.chatRoom.getChatInfos(chatType_, playerId_)
	local chatBox = getChatBoxByType(chatType_, playerId_)
	return chatBox.chatList
end

-- getChatInfoByID
function hp.chatRoom.getChatInfoByID(chatType_, playerId_, id_)
	local chatBox = getChatBoxByType(chatType_, playerId_)
	local chatList = chatBox.chatList

	for i,v in ipairs(chatList) do
		if id_==v.id then
			return v
		end
	end
	return nil
end

-- setChannelType
-- 设置聊天频道
function hp.chatRoom.setChannelType(type_)
	channelType = type_
end

-- getChannelType
-- 获取聊天频道
function hp.chatRoom.getChannelType()
	return channelType
end

-- getLastChatInfo
function hp.chatRoom.getLastChatInfo()
	return lastChatInfo
end

-- getPenultChatInfo
function hp.chatRoom.getPenultChatInfo()
	return penultChatInfo
end

-- sendAreaChat
function hp.chatRoom.sendChat(text_, chatType_, playerId_)
	local oper = {}
	local chatData = {}
	oper.msg = text_

	if chatType_==1 then
		oper.type = 2
		chatData[1] = 1
	elseif chatType_==2 then
		oper.type = 5
		chatData[1] = 4
	elseif chatType_==3 then
		oper.type = 6
		oper.id = playerId_
		chatData[1] = 5
	end

	local alliance = player.getAlliance()
	chatData[2] = player.getID()	--发送者id
	chatData[3] = player.getName()	--发送者name
	chatData[4] = tostring(player.hero.getBaseInfo().sid)	--发送者Icon
	if alliance:getUnionID()==0 then
		chatData[5] = ""
	else
		chatData[5] = alliance:getBaseInfo().name	--发送者公会
	end
	chatData[6] = ""	--发送者区域
	chatData[7]	= playerId_ or 0--接收者id
	chatData[8] = text_		--聊天内容
	if player.vipStatus.isActive() then
		chatData[9] = player.vipStatus.getLv()	--vip等级
	else
		chatData[9] = 0
	end
	chatData[10] = false	--gm
	chatData[11] = player.getServerTime()	--time
	hp.chatRoom.addChatInfo(chatData)

	return sendHttpOper(oper)
end
