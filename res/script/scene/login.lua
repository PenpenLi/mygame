--
-- scene/login.lua
--
--================================================
require "scene/Scene"


SceneLogin = class("SceneLogin", Scene)


--
-- ctor
--
function SceneLogin:init()
	--

	local bg = cc.Sprite:create(config.dirUI.root .. "login/farm.jpg")
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "login/login.json")
	widget:setAnchorPoint(0.5, 0.5)
	widget:setScale(hp.uiHelper.RA_scale)
	widget:setPosition(game.origin.x + game.visibleSize.width/2, game.origin.y + game.visibleSize.height/2)
	bg:setAnchorPoint(0.5, 0.5)
	bg:setScale(hp.uiHelper.RA_scale)
	bg:setPosition(game.origin.x + game.visibleSize.width/2, game.origin.y + game.visibleSize.height/2)

	local loginRoot = widget:getChildByName("Panel_Login")
	local RegistRoot = widget:getChildByName("Panel_Regist")

	self.labelLoginErr = loginRoot:getChildByName("Label_l_err")
	self.labeltRegistErr = RegistRoot:getChildByName("Label_r_err")


	RegistRoot:setVisible(false)
	loginRoot:setVisible(true)


	local userInfo = player.getUserDefault()
	local accountLabel = loginRoot:getChildByName("Label_account")
	local pwdLabel = loginRoot:getChildByName("Label_pwd")
	local accountCtrl = hp.uiHelper.labelBind2EditBox(accountLabel)
	local pwdCtrl = hp.uiHelper.labelBind2EditBox(pwdLabel, true)
	accountCtrl.setMaxLength(8)
	pwdCtrl.setMaxLength(12)
	accountCtrl.setString(userInfo.uid)
	pwdCtrl.setString(userInfo.pwd)

	--
	--
	--
	local function onLoginLogin(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			local account = accountCtrl.getString()
			local pwd = pwdCtrl.getString()
			if string.len(account)<=0 then
				self.labelLoginErr:setString("用户名不能为空！")
				self.labelLoginErr:setVisible(true)
				return
			end
			if string.len(pwd)<=0 then
				self.labelLoginErr:setString("密码不能为空！")
				self.labelLoginErr:setVisible(true)
				return
			end

			if account~=userInfo.uid then
				userInfo.uid = account
				userInfo.name = account
			end
			userInfo.pwd = pwd
			require "scene/loading"
			loadingScene = SceneLoading.new()
			loadingScene:enter()
        end
	end

	local function onLoginTrial(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			-- enter loading scene
			require "scene/loading"
			loadingScene = SceneLoading.new()
			loadingScene:enter()
        end
	end

	local function onLoginRegist(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			loginRoot:setVisible(false)
			RegistRoot:setVisible(true)
			self.labeltRegistErr:setVisible(false)
        end
	end

	--
	--
	--
	local function onRegistLogin(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RegistRoot:setVisible(false)
			loginRoot:setVisible(true)
			self.labelLoginErr:setVisible(false)
        end
	end

	local function onRegistRegist(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
        end
	end

	loginRoot:getChildByName("Button_l_login"):addTouchEventListener(onLoginLogin)
	--loginRoot:getChildByName("Button_l_trial"):addTouchEventListener(onLoginTrial)
	loginRoot:getChildByName("Button_l_regist"):addTouchEventListener(onLoginRegist)
	RegistRoot:getChildByName("Button_r_login"):addTouchEventListener(onRegistLogin)
	RegistRoot:getChildByName("Button_r_regist"):addTouchEventListener(onRegistRegist)

	self:addCCNode(bg)
	self:addCCNode(widget)


	cc.SimpleAudioEngine:getInstance():playMusic("sound/login.mp3", true)
end


--
-- onEnter
--
function SceneLogin:onEnter()
	if self.loginErr == nil then
		self.labelLoginErr:setVisible(false)
	else
		self.labelLoginErr:setString(self.loginErr)
		self.labelLoginErr:setVisible(true)
	end
end
