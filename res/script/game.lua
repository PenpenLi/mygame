--
-- game.lua
--
--================================================
require "player"


game = game or {}


-- public variables
------------------------------------

-- 
game.director = nil
game.visibleSize = nil
game.origin = nil
game.scheduler = nil
--
game.curScene = game.curScene --当前场景，必须记得，重启游戏的时候用到
game.startParam = game.startParam --游戏启动参数
--
game.data = {}

-- Private functions
------------------------------------
local heartbeat
local heartbeatEntryID = 0


-- Public functions
------------------------------------
--
-- init
--
function game.init()
	cclog("=========game.init")
	
	--
	game.data = hp.gameDataLoader.loadData()

	--
	game.application = cc.Application:getInstance()
	game.director = cc.Director:getInstance()
	game.visibleSize = game.director:getVisibleSize()
	game.origin = game.director:getVisibleOrigin()
	game.scheduler = game.director:getScheduler()
	--game.director:setDisplayStats(true)

	game.director:setAnimationInterval( 1.0/30 )

	--
	heartbeatEntryID = game.scheduler:scheduleScriptFunc(heartbeat, config.interval.gameHeartbeat, false)

	--
	hp.init()
	player.create()
	player.init()
	--gameUpdater.init()

	local targetPlatform = CCApplication:getInstance():getTargetPlatform()
--[[	if targetPlatform == cc.PLATFORM_OS_ANDROID then
		-- helper
		game.sdkHelper = require("thirdSdk/tencentSdk")
	else
		game.sdkHelper = require("thirdSdk/testSdk")
	end--]]
	game.sdkHelper = require("thirdSdk/testSdk")
	game.sdkHelper.init()

	cc.SimpleAudioEngine:getInstance():setMusicVolume(player.getMusicVol()/100)
	cc.SimpleAudioEngine:getInstance():setEffectsVolume(player.getEffectVol()/100)
end


--
-- start
-- 
function game.start()
	cclog("=========game.start")

	require("scene/logo")
	local scene = SceneLogo.new()
	scene:enter()

	-- require("scene/loginK")
	-- local loginScene = SceneLogin.new(game.startParam)
	-- loginScene:enter()

	-- require("scene/cityMap")
	-- local map = cityMap.new()
	-- map:enter()
end

--
-- game over
--
function game.over()
	cclog("=========game.over")
	
	game.director:endToLua()
	local platform = game.application:getTargetPlatform()
	if platform==cc.PLATFORM_OS_WINDOWS or platform==cc.PLATFORM_OS_MAC then
        os.exit()
    end
end

--
-- restart
-- 
function game.restart()
	-- 需要重新加载的lua文件
	local reloadFile = {
		"config",
		"game",
		"init",
		"main",
		"player",
		"gameUpdater",

		"AudioEngine",
		"CCBReaderLoad",
		"Cocos2d",
		"Cocos2dConstants",
		"CocoStudio",
		"Deprecated",
		"DeprecatedClass",
		"DeprecatedEnum",
		"DeprecatedOpenglEnum",
		"DrawPrimitives",
		"extern",
		"GuiConstants",
		"json",
		"luaj",
		"luaoc",
		"Opengl",
		"OpenglConstants",
		"StudioConstants",
	}
	-- 需要重新加载的lua文件路径
	local reloadFilePath = {
		"hp/",
		"obj/",
		"dataMgr/",
		"playerData/",
		"thirdSdk/",
		"scene/",
		"ui/"
	}

	-- 清除需要重新加载的文件
	for i, v in ipairs(reloadFile) do
		package.loaded[v] = nil
		package.loaded[v .. ".lua"] = nil
	end
	for name, _ in pairs(package.loaded) do
		for _, path in ipairs(reloadFilePath) do
			if string.find(name, path)==1 then
				package.loaded[name] = nil
				break
			end
		end
	end
	
	game.scheduler:unscheduleScriptEntry(heartbeatEntryID)

	--重新执行main文件
	require("main")
end

--
--================================================================
--
-- heartbeat
--
function heartbeat(dt)
	hp.heartbeat(dt)
	player.heartbeat(dt)
end

