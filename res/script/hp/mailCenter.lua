--
-- file: hp/mailCenter.lua
-- desc: 邮件管理中心
--================================================

--
-- hp.MSG.MAIL_CHANGED 邮件变化的消息
-- @param.type=4: 邮件被读取 param.mailType--邮件类型 | param.index--邮件索引
-- @param.type=5: 邮件队列变化 param.mailType--邮件类型
-- @param.type=6: 未读邮件个数变化 param.mailType--邮件类型 | param.num--未读个数
-- @param.type=7: 总未读邮件个数变化 
------------------------------------------------------------------------------------

--
-- channel=10 邮件操作网络请求
-- @type=1: 发送邮件 @name--收件人, @title--标题, @text--内容
-- @type=2: 删除邮件
-- @type=3: 读邮件
-- @type=4: 收藏邮件
-- @type=5: 获取邮件
-- @type=6: 批量删除邮件
-- @type=7: 取消收藏
-- @type=8: 获取最新邮件
------------------------------------------------------------------------------------


hp.mailCenter = {}


-- 邮件信息
hp.mail = class("hp.mail")
function hp.mail:ctor(mailInfo_)
	self.id = mailInfo_[1]
	self.type = mailInfo_[2]
	self.sendId = mailInfo_[3]
	self.sendName = mailInfo_[4]
	self.title = mailInfo_[5]
	self.content = mailInfo_[6]
	self.annex = mailInfo_[7]
	self.datetime = mailInfo_[8]
	--mailInfo_[9]: 个位标示是否已读，后面标示被收藏邮件的原始类型
	self.state = mailInfo_[9]%10
	self.mailBoxType = math.floor(mailInfo_[9]/10)+1

	self.removedFlag = false
end

-- private variables
------------------------------------
local typeNum = 4
local typeMailBox = {}
local cmdSender = nil
local curOper = nil

-- private functions
------------------------------------
local function onHttpResponse(status, response, mailType_)
	local oper = curOper
	curOper = nil

	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result==nil or data.result~=0 then
		--网络出错
		return
	end

	if oper.type==5 then
	--接收邮件
		local mailType = oper.mailtype+1
		local mailBox = typeMailBox[mailType]
		local startIndex = #mailBox.queue+1
		for i, v in ipairs(data.mail) do
			local mailInfo = hp.mail.new(v)
			table.insert(mailBox.queue, mailInfo)

			if mailBox.minId==0 or mailInfo.id<mailBox.minId then
			--如果box最小id为0，或者邮件id小于box最小id
				mailBox.minId = mailInfo.id
			end
			if mailBox.maxId==0 or mailInfo.id>mailBox.maxId then
			--如果box最大id为0，或者邮件id大于box最大id
				mailBox.maxId = mailInfo.id
			end
		end
		if data.len~=nil then
			-- 邮件加载已完
			mailBox.loadFinished = true
		end
		hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=mailType})
	elseif oper.type==8 then
		--接收最新邮件
		local mailType = oper.mailtype+1
		local mailBox = typeMailBox[mailType]
		local startIndex = #mailBox.queue+1
		for i, v in ipairs(data.mail) do
			local mailInfo = hp.mail.new(v)
			table.insert(mailBox.queue, i, mailInfo)
			if mailBox.maxId==0 or mailInfo.id>mailBox.maxId then
			--如果box最大id为0，或者邮件id大于box最大id
				mailBox.maxId = mailInfo.id
			end
		end
		mailBox.newerFlag = false --最新邮件加载完成
		hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=mailType})
	end
end

local function sendHttpMailOper(oper, mailType_)
	if curOper~=nil then
		-- 当前操作未完成
		return
	end

	local cmdData={operation={}}
	oper.channel = 10
	oper.mailtype = oper.mailtype-1		--服务器使用时，索引减一
	cmdData.operation[1] = oper
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	curOper = oper
end




-- init
-- 初始化
-------------------------------
function hp.mailCenter.init()
	for i=1, typeNum do
		typeMailBox[i] = {}
		typeMailBox[i].queue = {}		--邮件队列
		typeMailBox[i].unreadNum = 0	--未读个数
		typeMailBox[i].minId = 0		--最小id
		typeMailBox[i].maxId = 0		--最大id
		typeMailBox[i].newerFlag = false --有更新的邮件到来
		typeMailBox[i].loadFinished = false	--是否已从服务器加载完
	end

	cmdSender = hp.httpCmdSender.new(onHttpResponse)
end
-- 
-- init
-- 初始化
-------------------------------
function hp.mailCenter.initUnreadInfo(unreadInfo_)
	for i=1, typeNum do
		typeMailBox[i].unreadNum = unreadInfo_[i]	--未读个数
	end
end

-- getMailQueue
-- 获取指定类型的邮件队列
-------------------------------
function hp.mailCenter.getMailQueue(mailType_)
	local mailBox = typeMailBox[mailType_]

	return mailBox.queue
end

-- getUnreadMailNum
-- 获取指定类型的未读邮件个数
-------------------------------
function hp.mailCenter.getUnreadMailNum(mailType_)
	local mailBox = typeMailBox[mailType_]

	return mailBox.unreadNum
end

-- getAllUnreadMailNum
-- 获取所有未读邮件个数
-------------------------------
function hp.mailCenter.getAllUnreadMailNum()
	local num = 0
	for i=1, typeNum do
		num = num+typeMailBox[i].unreadNum
	end

	return num
end

-- isLoadFinished
-- 获取指定类型的邮件是否从服务器加载完
-------------------------------
function hp.mailCenter.isLoadFinished(mailType_)
	local mailBox = typeMailBox[mailType_]

	return mailBox.loadFinished
end

-- loadMail
-- 从服务器加载邮件
-------------------------------
function hp.mailCenter.loadMail(mailType_)
	local mailBox = typeMailBox[mailType_]

	if mailBox.loadFinished and mailBox.newerFlag==false then
		-- 已经加载完了
		return
	end

	local loadOper = {}
	if mailBox.newerFlag then
	-- 加载最新邮件
		loadOper.type = 8
		loadOper.id = mailBox.maxId
	else
		loadOper.type = 5
		loadOper.id = mailBox.minId
	end
	loadOper.mailtype = mailType_
	sendHttpMailOper(loadOper)
end

-- deleteMail
-- 删除邮件
-------------------------------
function hp.mailCenter.deleteMail(mailType_, indexList_)
	local mailBox = typeMailBox[mailType_]
	local mailQueue = mailBox.queue
	local deleteId = {}
	local unreadChanged = false

	for i,v in ipairs(indexList_) do
		mailQueue[v].removedFlag = true

		table.insert(deleteId, mailQueue[v].id)
		if mailQueue[v].state==0 then
		--未读邮件
			mailBox.unreadNum = mailBox.unreadNum-1
			unreadChanged = true
		end
	end

	local newQueue = {}
	for i,v in ipairs(mailQueue) do
		if v.removedFlag==false then
			table.insert(newQueue, v)
		end
	end
	mailBox.queue = newQueue


	-- 向服务器发送删除请求
	local loadOper = {}
	loadOper.type = 6
	loadOper.mailtype = mailType_
	loadOper.id = deleteId
	sendHttpMailOper(loadOper)

	-- 发送未读邮件变化的消息
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=mailType_, num=mailBox.unreadNum})
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=7})
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=mailType_})
end


-- saveMail
-- 收藏邮件
-------------------------------
function hp.mailCenter.saveMail(mailType_, mailIndex_)
	local mailBox = typeMailBox[mailType_]
	local savedMailBox = typeMailBox[3]
	local mailInfo = mailBox.queue[mailIndex_]

	table.remove(mailBox.queue, mailIndex_)
	table.insert(savedMailBox.queue, 1, mailInfo)
	if savedMailBox.minId==0 or mailInfo.id<savedMailBox.minId then
		savedMailBox.minId = mailInfo.id
	end

	-- 向服务器发送收藏请求
	local loadOper = {}
	loadOper.type = 4
	loadOper.mailtype = mailType_
	loadOper.id = mailInfo.id
	sendHttpMailOper(loadOper)

	-- 如果邮件未读
	if mailInfo.state==0 then
		mailBox.unreadNum = mailBox.unreadNum-1
		savedMailBox.unreadNum = savedMailBox.unreadNum+1
		hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=mailType_, num=mailBox.unreadNum})
		hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=3, num=savedMailBox.unreadNum})
	end
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=mailType_})
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=3})
end


-- unsaveMail
-- 收藏邮件
-------------------------------
function hp.mailCenter.unsaveMail(mailIndex_)
	local savedMailBox = typeMailBox[3]
	local mailInfo = savedMailBox.queue[mailIndex_]
	local mailBox = typeMailBox[mailInfo.mailBoxType]

	table.remove(savedMailBox.queue, mailIndex_)
	table.insert(mailBox.queue, 1, mailInfo)

	-- 向服务器发送收藏请求
	local loadOper = {}
	loadOper.type = 7
	loadOper.mailtype = mailInfo.mailBoxType
	loadOper.id = mailInfo.id
	sendHttpMailOper(loadOper)

	-- 如果邮件未读
	if mailInfo.state==0 then
		mailBox.unreadNum = mailBox.unreadNum+1
		savedMailBox.unreadNum = savedMailBox.unreadNum-1
		hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=mailInfo.mailBoxType, num=mailBox.unreadNum})
		hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=3, num=savedMailBox.unreadNum})
	end
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=mailInfo.mailBoxType})
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=5, mailType=3})
end

-- readMail
-- 读取邮件
-------------------------------
function hp.mailCenter.readMail(mailType_, mailIndex_)
	local mailBox = typeMailBox[mailType_]
	local mailInfo = mailBox.queue[mailIndex_]

	if mailInfo.state~=0 then
	-- 邮件已读
		return
	end

	-- 向服务器发送收藏请求
	local loadOper = {}
	loadOper.type = 3
	loadOper.mailtype = mailType_
	loadOper.id = mailInfo.id
	sendHttpMailOper(loadOper)

	-- 发送未读邮件数量变化的消息
	mailInfo.state = 1
	mailBox.unreadNum = mailBox.unreadNum-1
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=4, mailType=mailType_, index=mailIndex_})
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=mailType_, num=mailBox.unreadNum})
	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=7})
end



-- haveNewer
-- 是否有未获取的最新新邮件
-------------------------------
function hp.mailCenter.haveNewer(mailType_)
	local mailBox = typeMailBox[mailType_]

	return mailBox.newerFlag
end


-- 
-- synNewMail
-- 同步新邮件
-------------------------------
function hp.mailCenter.synNewMail(unreadInfo_)
	for i=1, typeNum do
		if typeMailBox[i].unreadNum ~= unreadInfo_[i] then
			typeMailBox[i].unreadNum = unreadInfo_[i]	--未读个数
			if typeMailBox[i].minId~=0 or typeMailBox[i].loadFinished then
			-- 如果接收过邮件，加载最新的邮件
				typeMailBox[i].newerFlag = true
				hp.mailCenter.loadMail(i)
			end
			hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=6, mailType=i, num=unreadInfo_[i]})
		end
	end

	hp.msgCenter.sendMsg(hp.MSG.MAIL_CHANGED, {type=7})
end
