--
-- main.lua
--
--================================================
cc.FileUtils:getInstance():addSearchPath("res");
cc.FileUtils:getInstance():addSearchPath("res/script");
cc.FileUtils:getInstance():addSearchPath("res/script/coco2d-x");
require "config"
require "init"
require "game"
require "gameUpdater"


-- cclog
cclog = function(...)
    if config.debug>=1 then
        print(string.format(...))
    end
end

cclog_ = function(...)
    if config.debug>=1 then
        print(...)
    end
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    if config.debug>=2 then
        cclog(debug.traceback())
    end
    cclog("----------------------------------------")
end

--
-- main
--
local function main()
	collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

	game.init()
	game.start()
end


xpcall(main, __G__TRACKBACK__)
