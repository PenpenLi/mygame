--
-- file: playerData/resourceHelpMgr.lua
-- desc: 资源帮助
--================================================

-- obj
-- =======================
local resourceHelpMgr = {}

-- 本地数据
-- =======================
local callBack_ = nil
local id_ = nil

-- 本地方法
-- =======================
local function onHttpResponse(status, response)
	if status~=200 then
		return
	end

	local data = hp.httpParse(response)
	if data.result ==0 then
		if data.num > 0 then
			require "ui/market/sourceHelp"
			ui_ = UI_sourceHelp.new(id_)
			game.curScene:addUI(ui_)
			if callBack_ ~= nil then
				callBack_()
			end
		else
			require "ui/common/noBuildingNotice"
			ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1253), 1015, 1)
			game.curScene:addModalUI(ui_)
		end
	end
end

-- 全局方法
-- =======================
function resourceHelpMgr.sendCmd(type_, param_)
	local marketLv = player.buildingMgr.getBuildingMaxLvBySid(1015)
	if marketLv>0 then
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 6
		oper.type = type_
		oper.id = param_[1]
		oper.sid = 1015
		id_ = param_[1]
		callBack_ = param_[2]
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)			
	else
		require "ui/common/noBuildingNotice"
		ui_ = UI_noBuildingNotice.new(hp.lang.getStrByID(1256), 1015, 1)
		game.curScene:addModalUI(ui_)
	end
end

return resourceHelpMgr