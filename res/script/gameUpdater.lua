--
-- gameUpdater.lua
-- 在线更新器
--================================================


-- obj
-- ==========================
gameUpdater = {}


-- private data
-- ==========================
-- local packagesUrl = "http://183.61.164.53:8090/update/packages/"
-- local versionFileUrl = "http://183.61.164.53:8090/update/version/"
-- local packagesUrl = "http://127.0.0.1/packages/"
-- local versionFileUrl = "http://127.0.0.1/version/"

local updateUrl = "http://1251205422.cdn.myqcloud.com/1251205422/yitongsanguo/update/" .. config.baseVersion
local packagesUrl = updateUrl .. "/packages/"
local versionFileUrl = updateUrl .. "/version.txt"
if config.debug>0 then
-- 测试版本
	versionFileUrl = updateUrl .. "/versionT.txt"
end
local storagePath = cc.FileUtils:getInstance():getWritablePath() .. "res1.2__/"

local assetsMgr = nil

local callback = nil

-- 版本号
local cacheVersion = nil

--
-- 状态，
-- 1:检查更新
-- 2:检查更新完成
-- 3:正在更新
-- 4:更新完成
local status = 0 

-- private function
-- ==========================

--
-- getPackageUrl
-- 获取升级包的Url
local function getPackageUrl()
	local curVersion = gameUpdater:getCurVersion()
	local lastVersion = gameUpdater:getLatestVersion() --最新版本号

	--                 url/            1.0.0          /     1.0.1.zip
	local packageUrl = packagesUrl ..  curVersion .. "/" .. lastVersion .. ".zip"

	cclog_("packageUrl===============", packageUrl)
	return packageUrl
end

--
-- onError
-- 更新出错回调
-- @errorCode :错误代码 0:无错误 1:创建文件错误 2: 网络错误 3:版本已最新 4:解压更新出错
local function onError(errorCode)
	errorCode = errorCode+1
	if errorCode==3 then
	--版本已最新
		cacheVersion = gameUpdater.getLatestVersion()
		cc.UserDefault:getInstance():setStringForKey("curVersion"..config.versionCode, cacheVersion)
		cc.UserDefault:getInstance():flush()
		status = 2
		errorCode = 0
	end

	if callback~=nil then
		callback(errorCode, status)
	end
end

-- 
-- onProgress
-- 下载进度回调
-- @percent :进度百分比
local function onProgress(percent)
	if callback~=nil then
		callback(0, status, percent)
	end
end

--
-- onSuccess
-- 更新成功回调
local function onSuccess()
	status = 4
	if callback~=nil then
		cacheVersion = gameUpdater.getLatestVersion()
		cc.UserDefault:getInstance():setStringForKey("curVersion"..config.versionCode, cacheVersion)
		cc.UserDefault:getInstance():flush()
		callback(0, status)
	end
end


-- public function
-- ==========================

--
-- init
-- 初始化
function gameUpdater.init()
	if assetsMgr then
	-- 已经初始化
		return
	end

	assetsMgr = cc.AssetsManager:new("", versionFileUrl, storagePath)
	assetsMgr:retain()
	assetsMgr:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
	assetsMgr:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
	assetsMgr:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    assetsMgr:setConnectionTimeout(config.server.timeout)
    callback = nil

end

--
-- uninit
-- 反初始化，使用完之后需要调用
function gameUpdater.uninit()
	if assetsMgr==nil then
		return
	end

	assetsMgr:release()
	assetsMgr = nil
	callback = nil
end


--
-- run
-- 运行更新程序
-- @callback_(errCode_, status_, ...)
function gameUpdater.run(callback_)
	callback = callback_
	status = 1 --检查更新
	callback(0, status)
	if assetsMgr:checkUpdate() then
	-- 需要更新
		status = 3 --正在更新
		assetsMgr:setPackageUrl(getPackageUrl())
		assetsMgr:update()
	else
	-- 不需要更新，逻辑通过onError处理
	end
end

--
-- checkUpdate
-- 检查是否需要更新
function gameUpdater.checkUpdate()
	callback = nil
	if assetsMgr:checkUpdate() then
	-- 需要更新
		if gameUpdater.getLatestVersion() ~= gameUpdater.getCurVersion() then
			return true
		end
	end

	return false
end

--
-- getCurVersion
-- 获取当前版本号
function gameUpdater.getCurVersion()
	local ver = assetsMgr:getVersion()
	cclog_("version1: ", ver)
	if ver==nil or ver=="" then
		ver = cc.UserDefault:getInstance():getStringForKey("curVersion"..config.versionCode, "")
		cclog_("version2: ", ver)
		if ver==nil or ver=="" then
		-- 未获取到当前版本，取缓存版本or配置版本
			return cacheVersion or config.version
		end
	end
	
	cacheVersion = ver --缓存版本号，修正二次获取版本号错误的问题
	return ver
end

--
-- getLatestVersion
-- 获取服务器最新版本号, 需要在checkUpdate之后才有效
function gameUpdater.getLatestVersion()
	--return assetsMgr:getLatestVersion()
	return gameUpdater.getCurVersion();
end
