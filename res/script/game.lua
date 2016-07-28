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
game.curScene = nil
--
game.data = {}


-- Private functions
------------------------------------
local heartbeat


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

	--
	game.scheduler:scheduleScriptFunc(heartbeat, config.interval.gameHeartbeat, false)
	cc.SimpleAudioEngine:getInstance():setMusicVolume(0.3)
	cc.SimpleAudioEngine:getInstance():setEffectsVolume(1.0)

	game.director:setDisplayStats(false);
	game.director:setAnimationInterval(1/30);
	--
	hp.init()
	player.init()
end


--
-- start
-- 
function game.start()
	cclog("=========game.start")
	
	-- require("scene/logo")
	-- logoScene = SceneLogo.new()
	-- logoScene:enter()

	require("scene/login")
	loginScene = SceneLogin.new()
	loginScene:enter()
	
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
end


--
-- getData
--
function game.getDataBySid(dataName_, sid_)
	local d = game.data[dataName_]

	if d~=nil then
		for i,v in ipairs(d) do
			if v.sid==sid_ then
				return v
			end
		end
	end

	return nil
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
