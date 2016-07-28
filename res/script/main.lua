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


-- cclog
cclog = function(...)
    print(string.format(...))
end

cclog_ = function(...)
    print(...)
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
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
