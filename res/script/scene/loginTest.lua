--
-- scene/loginDev.lua
-- 开发登录界面
--================================================
require "scene/Scene"


SceneLoginDev = class("SceneLoginDev", Scene)

--
-- init
--
function SceneLoginDev:init()
	-- 加载json
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "loginUi.json")

	-- 屏幕适配
	hp.uiHelper.uiAdaption(widget)
	
	-- 获取数据
	local userInfo = player.getUserDefault()
	-- 获取内容节点
	local content = widget:getChildByName("Panel_content")
		
	-- 内容节点下获取错误提示
	self.error = content:getChildByName("Label_error")
	-- 内容节点下获取账号、密码
	self.accountLabel = content:getChildByName("Image_inputBg1"):getChildByName("Label_account")
	self.pwdLabel = content:getChildByName("Image_inputBg2"):getChildByName("Label_password")
	-- 账号、密码绑定
	local accountCtrl = hp.uiHelper.labelBind2EditBox(self.accountLabel)
	local pwdCtrl = hp.uiHelper.labelBind2EditBox(self.pwdLabel, true)
	-- 账号、密码设置最大输入限制
	accountCtrl.setMaxLength(8)
	pwdCtrl.setMaxLength(12)
	-- 账号、密码设置默认值
	accountCtrl.setString(userInfo.uid)
	pwdCtrl.setString(userInfo.pwd)

	local function loginBtnOnClick(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)

		if eventType == ccui.TouchEventType.ended then
			-- 获取账号密码
			local account = accountCtrl.getString()
			local pwd = pwdCtrl.getString()
			-- 客户端验证（判空）
			if string.len(account) <= 0 then
				self.error:setString(hp.lang.getStrByID(10402))
				self.error:setVisible(true)
				return
			end
			if string.len(pwd) <= 0 then
				self.error:setString(hp.lang.getStrByID(10403))
				self.error:setVisible(true)
				return
			end
			-- 保存账号、密码
			if account ~= userInfo.uid then
				userInfo.uid = account
				userInfo.name = account
			end
			userInfo.pwd = pwd
			player.flushUserDefualt()

			local loginInfo = {}
			loginInfo.uid = userInfo.uid
			loginInfo.pwd = userInfo.pwd
			loginInfo.platform = 4

			game.sdkHelper.login(loginInfo)
		end
	end
	content:getChildByName("Image_loginBtn"):addTouchEventListener(loginBtnOnClick)
	
	-- 注册事件
	local function RegistBtnOnClick(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
		end
	end
	content:getChildByName("Image_regBtn"):addTouchEventListener(RegistBtnOnClick)

	-- 加入场景
	-- ===============
	self:addCCNode(widget)

	-- 播放音乐
	cc.SimpleAudioEngine:getInstance():playMusic("sound/login.mp3", true)
end
