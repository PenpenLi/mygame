--
-- file: dataMgr/chatRoom.lua
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


-- 对象
-- ================================
-- ********************************
local chatRoom = {}


-- 私有数据
-- ================================
-- ********************************
local maxNum = 50

local areaChatBox = {} --区域聊天
local unionChatBox = {} --公会聊天
local privateChatBoxs = {} --私聊
local sysNoticeBox = {} -- 系统公告
local chatId = 1

local channelType = 1			--聊天频道：1区域 2公会 3私聊
local lastChatInfo = nil		--最后一个要在主界面显示的聊天
local penultChatInfo = nil		--倒数第二要在主界面显示的聊天

local curShowNoticeIndex = 1    -- 当前滚动显示的系统公告index

local heartbeatTick = 0
local gettingChat = false
local cmdSender = nil

-- 私有函数
-- ================================
-- ********************************

-- getChatBoxByType
-- @chatType_：1区域 2公会 3私聊
-- @playerId_: 私聊对应的玩家id
local function getChatBoxByType(chatType_, playerId_)
	if chatType_==1 then
		return areaChatBox
	elseif chatType_==2 then
		return unionChatBox
	elseif chatType_==6 then
		return sysNoticeBox
	end

	if privateChatBoxs[playerId_]==nil then
		privateChatBoxs[playerId_] = {}
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
	chatInfo.srcTitle = chatData[12] --发送者的称号
	chatInfo.srcServerId = chatData[13] --发送者所在服务器的id

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
				-- 一般聊天排序
				local function sortFun(msg1, msg2)
					return msg1[11]<msg2[11]
				end
				table.sort(data.msg, sortFun)

				if data.msg1 then
				-- 跨服聊天, 排序插入
					for _,msg1 in ipairs(data.msg1) do
						local index = 1
						for i,msg in ipairs(data.msg) do
							index = i
							if msg1[11]<msg[11] then
								break
							end
						end

						table.insert(data.msg, index, msg1)
					end
				end

				for i, v in ipairs(data.msg) do
					chatRoom.addChatInfo(v)
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



-- player调用接口函数
-- ================================
-- ********************************

-- create
-- 构造函数，player对象构建时，加载此模块，并调用
function chatRoom.create()
	maxNum = 50
	cmdSender = hp.httpCmdSender.new(onHttpResponse)
end

-- init
-- 初始化函数，player对象重新初始化时调用(如玩家重新登录)
function chatRoom.init()
	-- body
	areaChatBox = {} --区域聊天
	unionChatBox = {} --公会聊天
	privateChatBoxs = {} --私聊
	sysNoticeBox = {} -- 系统公告
	chatId = 1

	channelType = 1			--聊天频道：1区域 2公会 3私聊 6系统公告
	lastChatInfo = nil		--最后一个要在主界面显示的聊天
	penultChatInfo = nil	--倒数第二要在主界面显示的聊天

	curShowNoticeIndex = 1

	heartbeatTick = 0
	gettingChat = false
end

-- initData
-- 使用玩家登陆数据进行初始化
function chatRoom.initData(data_)
	-- body
end

-- syncData
-- 根据服务器心跳返回的数据，进行数据同步
function chatRoom.syncData(data_)
	-- body
end

-- heartbeat
-- 心跳操作
function chatRoom.heartbeat(dt_)
	-- body
	if gettingChat then
		return
	end

	heartbeatTick = heartbeatTick+dt_
	if heartbeatTick>=config.interval.chatRoomSync then
		gettingChat = true
		heartbeatTick = 0
		local oper = {}
		oper.type = 1
		sendHttpOper(oper)
	end
end


-- 对外接口
-- 在此添加对外提供的程序接口
-- ================================
-- ********************************

-- addChatInfo
-- 添加一个聊天
function chatRoom.addChatInfo(chatData_)
	local chatInfo = createChatInfo(chatData_)
	local playerId = nil
	local chatType = 0
	if chatInfo.type==1 or chatInfo.type==2 or chatInfo.type==3 then
		chatType = 1
	elseif chatInfo.type==4 then
		chatType = 2
	elseif chatInfo.type==6 then
	-- 系统公告
		chatType = 6
	else
		chatType = 3
		if chatInfo.srcId~=player.getID() then
			playerId = chatInfo.srcId
		else
			playerId= chatInfo.destId
		end
	end
	local chatList = getChatBoxByType(chatType, playerId)
	if table.getn(chatList)>=maxNum then
		table.remove(chatList, 1)
		if chatType==6 and curShowNoticeIndex>1 then
			curShowNoticeIndex = curShowNoticeIndex-1
		end
	end
	table.insert(chatList, chatInfo)

	-- 当前聊天频道和私聊信息记录
	if chatType~=6 then
		penultChatInfo = lastChatInfo
		lastChatInfo = chatInfo
	end

	-- 过滤不需要发送的消息
	hp.msgCenter.sendMsg(hp.MSG.CHATINFO_NEW, {type=chatType, id=playerId, chat=chatInfo})
end

-- getChatInfos
-- 获取聊天
function chatRoom.getChatInfos(chatType_, playerId_)
	return getChatBoxByType(chatType_, playerId_)
end

-- getChatInfoByID
function chatRoom.getChatInfoByID(chatType_, playerId_, id_)
	local chatList = getChatBoxByType(chatType_, playerId_)

	for i,v in ipairs(chatList) do
		if id_==v.id then
			return v
		end
	end
	return nil
end

-- setChannelType
-- 设置聊天频道
function chatRoom.setChannelType(type_)
	channelType = type_
end

-- getChannelType
-- 获取聊天频道
function chatRoom.getChannelType()
	return channelType
end

-- getLastChatInfo
function chatRoom.getLastChatInfo()
	return lastChatInfo
end

-- getPenultChatInfo
function chatRoom.getPenultChatInfo()
	return penultChatInfo
end

-- curShowNotice
function chatRoom.curShowNotice()
	return sysNoticeBox[curShowNoticeIndex]
end

-- nextShowNotice
function chatRoom.nextShowNotice()
	if sysNoticeBox[curShowNoticeIndex]~=nil then
		curShowNoticeIndex = curShowNoticeIndex+1
	end

	return sysNoticeBox[curShowNoticeIndex]
end

-- sendChat
function chatRoom.sendChat(text_, chatType_, playerId_)
	
	if player.stateMgr.getNospeak() == true then

		require("ui/msgBox/warningMsgBox")
		local quitMsg =  UI_warningMsgBox.new(hp.lang.getStrByID(10601), hp.lang.getStrByID(10604),
							hp.lang.getStrByID(10603))
		game.curScene:addModalUI(quitMsg, 1000)
		return
	end

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
	-- 称号
	local titleId = player.getTitle()
	local titleInfo = nil
	if titleId then
		titleInfo = hp.gameDataLoader.getInfoBySid("kingTitle", titleId)
	end
	if titleInfo~=nil then
		chatData[12] = titleInfo.name
	else
		chatData[12] = ""
	end
	chatData[13] = player.serverMgr.getMyServerID()
	chatRoom.addChatInfo(chatData)

	return sendHttpOper(oper)
end



return chatRoom

