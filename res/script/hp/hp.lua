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
require "hp/rand"
require "hp/lang"
require "hp/mailCenter"
require "hp/chatRoom"
require "hp/common"
require "hp/sequenceAniHelper"

--
function hp.init()
	hp.httpCmdSequence.init()
	hp.httpBufferCmd.init()
	hp.msgCenter.init()
	hp.uiHelper.init()
	hp.lang.init()
	hp.mailCenter.init()
	hp.chatRoom.init()
end

--
function hp.heartbeat(dt)
	hp.httpCmdSequence.heartbeat(dt)
	hp.httpBufferCmd.heartbeat(dt)
end

