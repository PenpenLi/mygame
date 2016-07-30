--
-- thirdSdk/testSdk.lua
-- 腾讯SDK
--================================================


-- 对象
-- ================================
-- ********************************
local testSdk = {}


-- 私有数据
-- ================================
-- ********************************
local loginInfo = nil


-- 私有函数
-- ================================
-- ********************************

local function testSdkLog( ... )
	cclog_("testSdk--): ", ...)
end

--
-- onLogin
-- 处理登录回调
--------------------------------
local function onLogin(loginInfo_)
	loginInfo = loginInfo_
	-- 进入登录loading界面
	require("scene/loading")
	local scene = Scene_loading.new(loginInfo)
	scene:enter()
end

--
-- onPayFinished
-- 处理支付回调
--------------------------------
local function onPayFinished( jsonInfo )
end



-- 对外接口
-- ================================
-- ********************************

-- init
-- sdk初始化, 主要是注册lua回调给java
--------------------------------
function testSdk.init()
end


-- loginAuto
-- 自动登录
--------------------------------
function testSdk.loginAuto()
	-- 进入开发用登录界面
	require("scene/loginTest")
	local scene = SceneLoginDev.new()
	scene:enter()
end


-- login
-- 登录
--------------------------------
function testSdk.login(loginInfo_)
	onLogin(loginInfo_)
end

-- logout
-- 退出登录
--------------------------------
function testSdk.logout()
	player.init()
	hp.httpCmdSequence.init()

	-- 进入开发用登录界面
	require("scene/loginTest")
	local scene = SceneLoginDev.new()
	scene:enter()
end



-- onDisconnect
-- 断开连接的回调接口
--------------------------------
function testSdk.onDisconnect(param_)
	player.init()
	hp.httpCmdSequence.init()

	-- 进入开发用登录界面
	require("scene/loginTest")
	local scene = SceneLoginDev.new()
	scene:enter()

	if param_ then
	-- 显示断开连接的原因
		local function relogin()
			testSdk.login(loginInfo)
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
function testSdk.getLoginInfo()
	return loginInfo
end

-- getPlatformCode
-- 获取平台代码
--------------------------------
function testSdk.getPlatformCode()
	return "test"
end


-- getPlatformName
-- 获取平台名称
--------------------------------
function testSdk.getPlatformName()
	return "测试平台"
end


-- payBuy
-- 购买支付
--------------------------------
function testSdk.payBuy(itemSid_, num_)
end


return testSdk
