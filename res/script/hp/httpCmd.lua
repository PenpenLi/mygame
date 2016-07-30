--
-- file: hp/httpCmd.lua
-- desc: http请求
-- 发送一个http请求的步骤：1. sender = hp.httpCmdSender.new(...) 
--						2. sender:send(...)
--
--================================================


hp.httpCmdType = 
{
	SEND_INTIME = 0,
	SEND_BUFFER = 1
}


--
-- obj: httpCmdSequence
-- desc: http请求序列 通过其心跳按顺序发送其中的请求
--=====================================
hp.httpCmdSequence = {}


-- 私有数据
-- ================================
-- ********************************
local sequenceID = 1 --ID

local httpCmdQueue = {} --请求队列
local queueHead = 1 --队列头
local queueTail = 1 --队列尾

local sendingCmd = nil --正在发送的 hp.httpCmd
local sendingXhr = nil --正在发送请求的 XMLHttpRequest

local RID = 0 --请求ID
local sendTimes = 0 --请求发送次数
local resendFlag = false --重新发送

local checkNetworkFlag = false--需要检查网络


-- 私有函数
-- ================================
-- ********************************

-- pushHttpCmd
-- push 一个httpCmd到队列
local function pushHttpCmd(httpCmd_)
	httpCmdQueue[queueTail] = httpCmd_
	queueTail = queueTail+1
end

-- popHttpCmd
-- 从队列中取出一个 httpCmd
local function popHttpCmd()
	local httpCmd = nil
	
	if queueHead==queueTail then
	-- 队列已空
		if queueHead~=1 then
			httpCmdQueue = {}
			queueHead = 1
			queueTail = 1
		end
	else
		httpCmd = httpCmdQueue[queueHead]
		httpCmdQueue[queueHead] = nil
		queueHead = queueHead + 1
	end
	
	return httpCmd
end

-- strEscape
-- 字符串url编码 - 对中文和特殊字符转码
local function strEscape(w)
	pattern="[^%w%d%._%-%* ]"
	s=string.gsub(w,pattern,function(c)
		local c=string.format("%%%02X",string.byte(c))
		return c
	end)
	s=string.gsub(s," ","+")
	return s
end

-- cmdDataEncode
-- 对发送请求的数据进行编码
local function cmdDataEncode(v)
	if v==nil then
		return "null"
	end

	local vtype = type(v)
	if vtype=='string' then
		return strEscape(v)
	end

	if vtype=='number' then
		if v>4294967295 then
			return string.format("%.0f", v)
		end
		return tostring(v)
	end
	if vtype=='boolean' then
		return tostring(v)
	end
	
	return json.encode(v)
end

--checkNetwork
--检查网络
local function checkNetwork()
	local netcheckURL = "http://1251205422.cdn.myqcloud.com/1251205422/yitongsanguo/netcheck.txt"
	local xhr = cc.XMLHttpRequest:new()
	local function onHttpResponse()
		local status = xhr.status
		local response = xhr.response

		if status~=200 then
		-- 网络异常
			game.sdkHelper.onDisconnect(0)
			return
		end

		-- 服务器在维护
		game.sdkHelper.onDisconnect(-5)
	end
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr.timeout = 0
	xhr:registerScriptHandler(onHttpResponse)

	xhr:open("GET", netcheckURL)
	xhr:send()
end

-- onResponseException
-- 处理网络异常
local function onResponseException( errCode )
	if not player.isLogined() and errCode==0 then
	-- 未登录，检查网络
		checkNetworkFlag = true
		return
	end

	game.sdkHelper.onDisconnect(errCode)
end

-- onHttpResponse
-- 请求响应
local function onHttpResponse()
	if sendingCmd==nil then
	-- 或许已经认为超时处理
		return
	end

	local httpCmd = sendingCmd
	if httpCmd.sequenceID~=sequenceID then
	-- 已经过期的响应，不处理
		sendingCmd = nil
		sendingXhr = nil
		return
	end

	-- 获取响应数据
	local status = sendingXhr.status
	local response = sendingXhr.response
	sendingXhr:unregisterScriptHandler()
	cclog("Http Status Code: %d", status)
	cclog("Http response: %s", response)

	if status~=200 or response==nil or string.len(response)<0 then
	-- 响应网络超时或者异常
		if player.isLogined() and sendTimes<3 then
			-- 如果用户已经登录，重新发送3次
			resendFlag = true
		else
			onResponseException(0)
			sendingCmd = nil
			sendingXhr = nil
		end
		return
	end

	sendingCmd = nil
	sendingXhr = nil

	-- 回调之前，关掉loading
	if httpCmd.loadingUI~=nil then
		httpCmd.loadingUI:hideLoading(httpCmd.loadingNode)
		httpCmd.loadingUI = nil
		httpCmd.loadingNode = nil
	end

	-- 解析json数据
	local dataResponse = json.decode(response, 1)
	local rstData = nil --网络请求返回数据
	local heartData = dataResponse.heart--网络请求携带心跳数据
	if dataResponse.rst~=nil then
		rstData = dataResponse.rst
	else
		rstData = dataResponse
	end
	rstData.result = tonumber(rstData.result)
	

	if not player.isLogined() and rstData.result~=0 then
	-- 如果玩家没有登录，一切异常都有onResponseException处理
		onResponseException(rstData.result)
		return
	end

	-- 调用回调
	if httpCmd.sender~=nil and httpCmd.sender.callback~=nil then
		httpCmd.sender.callback(status, rstData, httpCmd.tag)
	end

	if rstData.result==0 then
	-- 进行玩家数据同步
		if heartData~=nil then
			player.synData(heartData)
		end
	elseif rstData.result==69 then
	-- 网络cache超时
		onResponseException(69)
	else
	-- 错误提示
		if httpCmd.data.operation~=nil then
			local oper_ = httpCmd.data.operation[1]
			if oper_~=nil then
				Scene.showHttpErrorMsg({result=rstData.result, channel=oper_.channel, type=oper_.type})
			end
		end
	end
end


-- 对外接口
-- ================================
-- ********************************

-- init
function hp.httpCmdSequence.init()
	if sequenceID then
		sequenceID = sequenceID+1
	else
		sequenceID = 1
	end

	-- 清空队列
	httpCmdQueue = {}
	ueueHead = 1
	ueueTail = 1

	-- 
	sendingCmd = nil
	sendingXhr = nil

	RID = 0
	sendTimes = 0
	resendFlag = false

	checkNetworkFlag = false
end


-- heartbeat
function hp.httpCmdSequence.heartbeat(dt)
	if checkNetworkFlag then
		checkNetworkFlag = false
		checkNetwork()
		return
	end


	local httpCmd = nil
	if sendingCmd then
	-- 当前有一个正在发送的请求
		if resendFlag then
		-- 请求需要重新发送
			httpCmd = sendingCmd
		else
			return
		end
	else
		httpCmd = popHttpCmd()
		if httpCmd and httpCmd.data.operation then
			-- 如果是一个操作请求，为操作附加RID
			sendTimes = 0
			RID = RID+1
			if RID>=10 then
				RID = 0
			end
			httpCmd.data.RID = RID
		end
	end

	if httpCmd==nil then
	-- 请求队列为空
		return
	end

	-- 发送次数+1
	sendTimes = sendTimes+1
	resendFlag = false
	sendingCmd = httpCmd
	httpCmd.sequenceID = sequenceID

	-- create XMLHttpRequest
	sendingXhr = cc.XMLHttpRequest:new()
	sendingXhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	sendingXhr:setRequestHeader("Accept-Language", "zh-CN")
	sendingXhr:setRequestHeader("Accept-Encoding", "gzip, deflate")
	sendingXhr.timeout = httpCmd.timeout
	sendingXhr:registerScriptHandler(onHttpResponse)
	
	-- 拼接url
	local url = nil
	if httpCmd.url==nil then
		url = player.serverMgr.getMyServerAddress() .. httpCmd.cmd
	else
		url = httpCmd.url .. httpCmd.cmd
	end

	-- 编码 data
	local data = ""
	local bFirst = true
	if player.h_p_key()~=nil then
		data = "h_p_key=" .. player.h_p_key()
		bFirst = false
	end
	for k, v in pairs(httpCmd.data) do
		if bFirst then
			data = data .. k .. "=" .. cmdDataEncode(v)
			bFirst = false
		else
			data = data .. "&" .. k .. "=" .. cmdDataEncode(v)
		end
	end

	-- send XMLHttpRequest
	sendingXhr:open("POST", url)
	sendingXhr:send(data)
	cclog("HttpRequest.url === %s", url)
	cclog("HttpRequest.data === %s", data)
end

-- httpParse
-- 解析http响应
function hp.httpParse(httpResponse)
	return httpResponse
end




--
-- class: httpCmdSender
-- desc: 用于发送http请求
--=====================================
hp.httpCmdSender = class("httpCmdSender")


--
-- createHttpCmd
-- desc: 创建一个http请求
--=====================================

local function createHttpCmd( type_, cmd_, data_, sender_, tag_, timeout_, url_ )
	local httpCmd = {}

	httpCmd.type = type_
	httpCmd.cmd = cmd_
	httpCmd.data = data_
	httpCmd.sender = sender_
	httpCmd.tag = tag_
	httpCmd.url = url_
	if timeout_==nil then
		httpCmd.timeout = config.server.timeout
	else
		httpCmd.timeout = timeout_
	end
	
	httpCmd.loadingUI = nil
	httpCmd.loadingNode = nil

	return httpCmd
end

-- ctor
function hp.httpCmdSender:ctor(callback_)
	self.callback = callback_
end
-- delete
function hp.httpCmdSender:delete()
	self.callback = nil
end
-- send
function hp.httpCmdSender:send(type_, data_, cmd_, tag_, timeout_, url_)
	if type_==hp.httpCmdType.SEND_INTIME then
		-- 立即发送
		--hp.httpBufferCmd.flush() -- 先发送缓存请求
		local httpCmd = createHttpCmd(type_, cmd_, data_, self, tag_, timeout_, url_)
		self.curCmd = httpCmd
		pushHttpCmd(httpCmd)
	elseif type_==hp.httpCmdType.SEND_BUFFER then
		-- 缓冲发送
		-- hp.httpBufferCmd.addData(data_)
	end
end
-- bindLoadingUI
function hp.httpCmdSender:bindLoadingUI(ui_, loadingNode_)
	self.curCmd.loadingUI = ui_
	self.curCmd.loadingNode = loadingNode_
end




--[[

--
-- obj: httpBufferCmd
-- desc: http缓存请求
--=====================================
hp.httpBufferCmd = {}

-- init
function hp.httpBufferCmd.init()
	local function httpBufferCmdsCallback(status_, response_, tag_)
	end
	
	hp.httpBufferCmd.buffer = {}
	hp.httpBufferCmd.tick = 0
	hp.httpBufferCmd.cmdSender = hp.httpCmdSender.new(httpBufferCmdsCallback)
end
-- addData
function hp.httpBufferCmd.addData(data_)
	table.insert(hp.httpBufferCmd.buffer, data_)
end
-- flush
function hp.httpBufferCmd.flush()
	hp.httpBufferCmd.tick = 0
	
	if table.getn(hp.httpBufferCmd.buffer)>0 then
		local data = {}
		data.operation = clone(hp.httpBufferCmd.buffer)
		local httpCmd = hp.httpCmd.new(hp.httpCmdType.SEND_INTIME, 
			config.server.cmdOper, data, hp.httpBufferCmd.cmdSender, -1)
		hp.httpCmdSequence.pushCmd(httpCmd)
		
		hp.httpBufferCmd.buffer = {}
	end
end
-- heartbeat
function hp.httpBufferCmd.heartbeat(dt)
	hp.httpBufferCmd.tick = hp.httpBufferCmd.tick + dt
	
	if hp.httpBufferCmd.tick >= config.interval.bufferCmdSync then
		hp.httpBufferCmd.flush()
	end
end

]]--
