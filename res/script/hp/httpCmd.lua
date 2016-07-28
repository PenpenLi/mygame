--
-- file: hp/httpCmd.lua
-- desc: http请求
-- 发送一个http请求的步骤：1. sender = hp.httpCmdSender.new(...) 
--						2. sender:send(...)
--
--================================================

--
-- class: httpCmd
-- desc: http请求对象
--=====================================
hp.httpCmd = class("httpCmd")

hp.httpCmdType = 
{
	SEND_INTIME = 0,
	SEND_BUFFER = 1
}

-- ctor
function hp.httpCmd:ctor(type_, cmd_, data_, sender_, tag_, timeout_)
	self.type = type_
	self.cmd = cmd_
	self.data = data_
	self.sender = sender_
	self.tag = tag_
	if timeout_==nil then
		self.timeout = config.server.timeout
	else
		self.timeout = timeout_
	end
	
	self.sendingTime = 0
	self.loadingUI = nil
	self.loadingNode = nil
end


--
-- class: httpCmdSender
-- desc: 用于发送http请求
--=====================================
hp.httpCmdSender = class("httpCmdSender")

-- ctor
function hp.httpCmdSender:ctor(callback_)
	self.callback = callback_
end
-- delete
function hp.httpCmdSender:delete()
	self.callback = nil
end
-- send
function hp.httpCmdSender:send(type_, data_, cmd_, tag_, timeout_)
	if type_==hp.httpCmdType.SEND_INTIME then
		-- 立即发送
		hp.httpBufferCmd.flush() -- 先发送缓存请求
		local httpCmd = hp.httpCmd.new(type_, cmd_, data_, self, tag_, timeout_)
		self.curCmd = httpCmd
		hp.httpCmdSequence.pushCmd(httpCmd)
	elseif type_==hp.httpCmdType.SEND_BUFFER then
		-- 缓冲发送
		hp.httpBufferCmd.addData(data_)
	end
end
-- bindLoadingUI
function hp.httpCmdSender:bindLoadingUI(ui_, loadingNode_)
	self.curCmd.loadingUI = ui_
	self.curCmd.loadingNode = loadingNode_
end

--
-- obj: httpCmdSequence
-- desc: http请求序列 通过其心跳按顺序发送其中的请求
--=====================================
hp.httpCmdSequence = {}

-- init
function hp.httpCmdSequence.init()
	local sequence = {}
	sequence.sequence = {}
	sequence.head = 1
	sequence.tail = 1
	hp.httpCmdSequence.sequence = sequence
	
	hp.httpCmdSequence.xhr = nil
	hp.httpCmdSequence.sendingCmd = nil
end
-- pushCmd
function hp.httpCmdSequence.pushCmd(httpCmd_)
	local sequence = hp.httpCmdSequence.sequence
	
	sequence.sequence[sequence.tail] = httpCmd_
	sequence.tail = sequence.tail + 1
end
-- popCmd
function hp.httpCmdSequence.popCmd()
	local sequence = hp.httpCmdSequence.sequence
	local httpCmd = nil
	
	if sequence.head==sequence.tail then
		if sequence.head~=1 then
			sequence.sequence = {}
			sequence.head = 1
			sequence.tail = 1
		end
	else
		httpCmd = sequence.sequence[sequence.head]
		sequence.head = sequence.head + 1
	end
	
	return httpCmd
end
-- heartbeat
function hp.httpCmdSequence.heartbeat(dt)
	local httpCmd = hp.httpCmdSequence.sendingCmd
	
	if httpCmd~=nil then
		-- 上一个请求还未返回
		httpCmd.sendingTime = httpCmd.sendingTime+dt
		if httpCmd.sendingTime>httpCmd.timeout then
			-- 超时
			hp.httpCmdSequence.sendingCmd = nil
			
			--if httpCmd.sender~=nil and httpCmd.sender.callback~=nil then
			--	httpCmd.sender.callback(-1, nil, httpCmd.tag)
			--end
			cclog("Http Status Code: %d", -1)
			cclog("Http response: timeout")

			hp.httpCmdSequence.exception()
			--hp.httpCmdSequence.xhr:unregisterScriptHandler()
			--hp.httpCmdSequence.xhr = nil
		end
		return
	end
	
	httpCmd = hp.httpCmdSequence.popCmd()
	if httpCmd==nil then
		-- 请求队列为空
		return
	end
	
	-- send XMLHttpRequest
	local xhr = cc.XMLHttpRequest:new()
	hp.httpCmdSequence.sendingCmd = httpCmd
	hp.httpCmdSequence.xhr = xhr
	
	-- 请求响应
	local function onHttpResponse()
		local httpCmd = hp.httpCmdSequence.sendingCmd
		local xhr = hp.httpCmdSequence.xhr
		if xhr then
			local status = xhr.status
			local response = xhr.response
			cclog("Http Status Code: %d", status)
			cclog("Http response: %s", response)
			
			hp.httpCmdSequence.sendingCmd = nil
			hp.httpCmdSequence.xhr = nil
			
			if httpCmd.loadingUI~=nil then
			-- 回调之前，关掉loading
				httpCmd.loadingUI:hideLoading(httpCmd.loadingNode)
				httpCmd.loadingUI = nil
				httpCmd.loadingNode = nil
			end
			if httpCmd.sender~=nil and httpCmd.sender.callback~=nil then
				httpCmd.sender.callback(status, response, httpCmd.tag)
			end

			-- 进行玩家数据同步
			local data = json.decode(response, 1)
			if data.heart~=nil then
				player.synData(data.heart)
			end
		end
	end
	
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	xhr:setRequestHeader("Accept-Language", "zh-CN")
	xhr:setRequestHeader("Accept-Encoding", "gzip, deflate")
	xhr.timeout = httpCmd.timeout
	xhr:registerScriptHandler(onHttpResponse)
	
	local url = player.getServerAddress() .. httpCmd.cmd
	local data = ""
	local bFirst = true
	if player.h_p_key()~=nil then
		data = "h_p_key=" .. hp.httpCmdSequence.encode(player.h_p_key())
		bFirst = false
	end
	for k, v in pairs(httpCmd.data) do
		if bFirst then
			data = data .. k .. "=" .. hp.httpCmdSequence.encode(v)
			bFirst = false
		else
			data = data .. "&" .. k .. "=" .. hp.httpCmdSequence.encode(v)
		end
	end
	xhr:open("POST", url)
	xhr:send(data)
	cclog("HttpRequest.url === %s", url)
	cclog("HttpRequest.data === %s", data)
end

function hp.httpCmdSequence.exception()
	hp.httpCmdSequence.init()

	require "scene/login"
	loginScene = SceneLogin.new()
	loginScene.loginErr = "网络异常，请重新登录"   
	loginScene:enter()
	player.init()
end


local function escape(w)
	pattern="[^%w%d%._%-%* ]"
	s=string.gsub(w,pattern,function(c)
		local c=string.format("%%%02X",string.byte(c))
		return c
	end)
	s=string.gsub(s," ","+")
	return s
end
-- encode
function hp.httpCmdSequence.encode(v)
	if v==nil then
		return "null"
	end

	local vtype = type(v) 
	
	if vtype=='string' then
		return escape(v)
	end

	-- Handle booleans
	if vtype=='number' or vtype=='boolean' then
		return tostring(v)
	end
	
	return json.encode(v)
end


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


-- httpParse
-- 解析http响应
function hp.httpParse(httpResponse)
	local data = json.decode(httpResponse, 1)
	
	if data.rst~=nil then
		data = data.rst
	end
	data.result = tonumber(data.result)

	if data.result==69 then
		hp.httpCmdSequence.exception()
	end

	return data
end
