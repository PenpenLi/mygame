--
-- scene/loading.lua
--
--================================================
require "scene/Scene"


SceneLoading = class("SceneLoading", Scene)


function SceneLoading:init()
	local bg = cc.Sprite:create(config.dirUI.root .. "login/farm.jpg")
	local loadingBar = ccui.LoadingBar:create()
	
	loadingBar:loadTexture(config.dirUI.root .. "login/loadingbar.png")
	loadingBar:setPercent(50)
	loadingBar:setScale(2*hp.uiHelper.RA_scale)
	bg:setScale(hp.uiHelper.RA_scale)
	bg:setPosition(game.origin.x + game.visibleSize.width/2, game.origin.y + game.visibleSize.height/2)
	loadingBar:setPosition(game.origin.x + game.visibleSize.width/2, game.origin.y + game.visibleSize.height/2)
	
	self:addCCNode(bg)
	self:addCCNode(loadingBar)
	
	self.loadingBar = loadingBar
	
	self.loadingEnd = false
end

function SceneLoading:onEnter()
	local function onHttpResponse(status, response, tag)
		if status==-1 then
			require "scene/login"
			loginScene = SceneLogin.new()
			loginScene.loginErr = "登录失败，网络超时"
			loginScene:enter()
		elseif status~=200 then
			require "scene/login"
			loginScene = SceneLogin.new()
			loginScene.loginErr = "登录失败，网络错误"   
			loginScene:enter()
		else
			local data = hp.httpParse(response)
			if data.result==nil or data.result~=0 then
				require "scene/login"
				loginScene = SceneLogin.new()
				loginScene.loginErr = "用户信息错误"   
				loginScene:enter()
				return
			end

			if data.serverAddress~=nil and data.serverAddress~="null" then
				-- 登录地址更改
				player.setServerAddress(data.serverAddress)

				local userInfo = self:getLoginInfo()
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				if data.haveRole=="false" then
					-- 未创建角色
					cmdSender:send(hp.httpCmdType.SEND_INTIME, userInfo, config.server.cmdCreate)
				else
					-- 已创建角色
					cmdSender:send(hp.httpCmdType.SEND_INTIME, userInfo, config.server.cmdLogin)
				end
				return
			end

			if data.haveRole=="false" then
				-- 未创建角色
				local userInfo = self:getLoginInfo()
				local cmdSender = hp.httpCmdSender.new(onHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, userInfo, config.server.cmdCreate)
				return
			end

			player.initData(data)
			self.loadingEnd = true
		end
	end
	
	local userInfo = self:getLoginInfo()
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, userInfo, config.server.cmdLogin)
end

function SceneLoading:heartbeat(dt)
	local loadingPercent = self.loadingBar:getPercent()
	if self.loadingEnd then
		if loadingPercent == 100 then
			self.loadingEnd = false
			player.flushUserDefualt()
			
			--cc.SimpleAudioEngine:getInstance():playMusic("sound/background.mp3", true)
			require("scene/cityMap")
			local map = cityMap.new()
			map:enter()
			return
		else
			loadingPercent = 100
		end
	elseif loadingPercent ~= 100 then
		loadingPercent = loadingPercent+10
	end
	
	self.loadingBar:setPercent(loadingPercent)
end

function SceneLoading:getLoginInfo()
	local userInfo = {}
	local defInfo = player.getUserDefault()
	userInfo.uid = defInfo.uid
	userInfo.pwd = defInfo.pwd
	userInfo.name = defInfo.name
	userInfo.param = defInfo.param
	userInfo.platform = 4
	return userInfo
end