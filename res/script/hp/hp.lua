--
-- file: hp/hp.lua
-- desc: hp功能扩展
--================================================

hp = hp or {}

require "hp/gameDataLoader"
require "hp/httpCmd"
require "hp/datetime"
require "hp/msgCenter"
require "hp/uiHelper"
require "hp/lang"
require "hp/common"
require "hp/sequenceAniHelper"
require "hp/uiEffect"

--
function hp.init()
	hp.httpCmdSequence.init()
	hp.msgCenter.init()
	hp.uiHelper.init()
	hp.lang.init()
	hp.uiEffect.init()
end

--
function hp.heartbeat(dt)
	hp.httpCmdSequence.heartbeat(dt)
end

