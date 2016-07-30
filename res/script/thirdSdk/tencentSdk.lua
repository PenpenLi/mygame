--
-- thirdSdk/tencentSdk.lua
-- 腾讯SDK
--================================================


-- 对象
-- ================================
-- ********************************
local tencentSdk = {}


-- 私有数据
-- ================================
-- ********************************
local loginInfo = nil
local buyItemID = 0

local luaj = nil
local className = "com/tencent/tmgp/sanguoyanyi/AppActivity"


-- 私有函数
-- ================================
-- ********************************

local function tencentSdkLog( ... )
	cclog_("tencentSdk--): ", ...)
end

--
-- onLogin
-- 处理登录回调
--------------------------------
local function onLogin(jsonInfo)
	tencentSdkLog(jsonInfo)
	local info = json.decode(jsonInfo)

	loginInfo = {}
	if info.err_code==0 then
	-- 登录成功
		loginInfo.platform = info.platform
		loginInfo.uid = info.open_id
		loginInfo.pf = info.pf
		loginInfo.pfkey = info.pf_key
		loginInfo.xgtoken = info.xgToken

		if loginInfo.platform==1 then
		-- 微信
			loginInfo.pwd = info.wx_access
			loginInfo.pay_token = info.wx_access
			loginInfo.wx_refresh = info.wx_refresh
		elseif loginInfo.platform==2 then
		-- QQ
			loginInfo.pwd = info.qq_access
			loginInfo.pay_token = info.qq_pay
		end

		require("scene/loading")
		local scene = Scene_loading.new(loginInfo)
		scene:enter()
	else
	-- 登录失败
		require("scene/loginTencent")
		local scene = Scene_loginTencent.new()
		scene:enter()
	end
end

--
-- onPayFinished
-- 处理支付回调
--------------------------------
local function onPayFinished( jsonInfo )
	tencentSdkLog(jsonInfo)
	tencentSdkLog("buyItemID=================", buyItemID)

	-- 这个暂时只处理了成功，不再做处理
	local info = json.decode(jsonInfo)

	player.goldShopMgr.httpReqFinishBuyItem(buyItemID)
	buyItemID = 0
end



-- 对外接口
-- ================================
-- ********************************

-- init
-- sdk初始化, 主要是注册lua回调给java
--------------------------------
function tencentSdk.init()
	luaj = require("luaj")

	loginInfo = {}
	buyItemID = 0

	luaj.callStaticMethod(className, "platformSetLoginLuaCallback", { onLogin })
	luaj.callStaticMethod(className, "unipaySetPayLuaCallback", { onPayFinished })
end


-- loginAuto
-- 自动登录
--------------------------------
function tencentSdk.loginAuto()
	luaj.callStaticMethod(className, "platformLogin", {0}, "(I)V")
end


-- login
-- 登录
--------------------------------
function tencentSdk.login(loginType_)
	luaj.callStaticMethod(className, "platformLogin", {loginType_}, "(I)V")
end

-- logout
-- 退出登录
--------------------------------
function tencentSdk.logout()
	luaj.callStaticMethod(className, "platformLogout", {})

	player.init()
	hp.httpCmdSequence.init()

	-- 进入选择登录界面
	require("scene/loginTencent")
	local scene = Scene_loginTencent.new()
	scene:enter()
end

-- onDisconnect
-- 断开连接的回调接口
--------------------------------
function tencentSdk.onDisconnect(param_)
	player.init()
	hp.httpCmdSequence.init()

	-- 进入选择登录界面
	require("scene/loginTencent")
	local scene = Scene_loginTencent.new()
	scene:enter()

	if param_ then
	-- 显示断开连接的原因
		local function relogin()
			tencentSdk.loginAuto()
		end

		local infoList = {
			[-4]   = {6034, 104012, 10603},	-- 角色创建失败
			[-5]   = {6034, 10408, 10414, relogin},	-- 服务器正在维护
			[-6]   = {6034, 10409, 10603},	-- 服务器异常
			[-7]   = {6034, 10410, 10603},	-- 服务器人数上限

			[-16]  = {10601, 10411, 10603},	-- 玩家数据异常
			[-17]  = {6034, 10607, 10603},	-- 验证超时
			[-21]  = {10601, 10413, 10603},	-- GM封号中

			[0]    = {6034, 10401, 10414, relogin},    -- 网络异常
			[1]  = {10601, 10602, 10603},	-- 被GM踢下线
			[2]  = {6034, 10607, 10603},	-- 第三方平台认证超时
			[3]  = {6034, 10606, 10603},	-- 服务器维护
			[69]  = {6034, 10416, 10414, relogin},	-- 与服务器连接已超时
		}

		local info = infoList[param_]
		require("ui/msgBox/msgBox")
		if info~=nil then
			local quitMsg =  UI_msgBox.new(hp.lang.getStrByID(info[1]), hp.lang.getStrByID(info[2]),
								hp.lang.getStrByID(info[3]), nil, info[4])
			scene:addModalUI(quitMsg, 99)
		else
		-- 数据异常
			local extMsg = string.format(hp.lang.getStrByID(10415), param_)
			local quitMsg =  UI_msgBox.new(hp.lang.getStrByID(6034), extMsg, hp.lang.getStrByID(10603))
			scene:addModalUI(quitMsg, 99)
		end
	end
end

-- getLoginInfo
-- 获取登录信息
--------------------------------
function tencentSdk.getLoginInfo()
	return loginInfo
end

-- getPlatformCode
-- 获取平台代码
--------------------------------
function tencentSdk.getPlatformCode()
	if loginInfo.platform==1 then
		return "wx"
	elseif loginInfo.platform==2 then
		return "qq"
	end

	return ""
end


-- getPlatformName
-- 获取平台名称
--------------------------------
function tencentSdk.getPlatformName()
	if loginInfo.platform==1 then
		return "微信"
	elseif loginInfo.platform==2 then
		return "QQ"
	end

	return ""
end


-- payBuy
-- 购买支付
--------------------------------
function tencentSdk.payBuy(itemSid_, num_)
	--public static void unipayPay(final String userId,final String userKey,final String sessionId,
	--		final String sessionType,final String zoneId,final String pf,final String pfKey,final String num) 
	local args = {
		loginInfo.uid, --1
		loginInfo.pay_token, --2
		"sessionId", --3
		"sessionType", --4
		"zoneId", --5
		loginInfo.pf, --6
		loginInfo.pfkey, --7
		"num" --8
	}

	if loginInfo.platform==1 then
	-- 微信
		args[3] = "hy_gameid"
		args[4] = "wc_actoken"
		args[5] = "2"
	elseif loginInfo.platform==2 then
	-- QQ
		args[3] = "openid"
		args[4] = "kp_actoken"
		args[5] = "1"
	end

	if num_>0 then
		args[8] = tostring(num_)
	else
		args[8] = ""
	end

	buyItemID = itemSid_
	luaj.callStaticMethod(className, "unipayPay", args)
end


return tencentSdk
