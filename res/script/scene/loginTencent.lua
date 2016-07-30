--
-- scene/loginTencent.lua
--
--================================================
require "scene/Scene"


Scene_loginTencent = class("Scene_loginTencent", Scene)

--
-- init
--
function Scene_loginTencent:init(param_)
	-- 加载json
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "loginTencent.json")
	-- 屏幕适配
	hp.uiHelper.uiAdaption(widget)

	-- 获取内容节点
	local content = widget:getChildByName("Panel_content")
	local loginByWX_ = content:getChildByName("Image_logByWX")
	local loginByQQ_ = content:getChildByName("Image_loginByQQ")

	-- 微信登录
	local function loginByWeiXinClick(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)

		if eventType == ccui.TouchEventType.ended then
			game.sdkHelper.login(1)
			self.selectLogin = true
		end
	end
	-- QQ登录
	local function loginByQQClick(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)

		if eventType == ccui.TouchEventType.ended then
			game.sdkHelper.login(2)
		end
	end
	loginByWX_:addTouchEventListener(loginByWeiXinClick)
	loginByQQ_:addTouchEventListener(loginByQQClick)


	--
	--==========
	self:addCCNode(widget)


	-- 播放音乐
	cc.SimpleAudioEngine:getInstance():playMusic("sound/login.mp3", true)
end
