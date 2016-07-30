--
-- file: scene/assist/sourceUIHelper.lua
-- desc: 大地图资源界面辅助
--================================================
require "ui/bigMap/source/UISource"
require "ui/bigMap/source/mySource"
require "ui/bigMap/source/mySourceGold"
require "ui/bigMap/source/enemySource"
require "ui/bigMap/source/unionSource"

-- 全局数据
-- ==================

-- 对象
-- ==================
local sourceUIHelper = {}

-- 本地数据
-- ==================

local function registMsg(msg_)
	if hp.msgCenter.addMsgMgr(msg_, sourceUIHelper) then
		table.insert(sourceUIHelper.manageMsg, msg_)
	end
end

-- unregistMsg
local function unregistMsg(msg_)
	if hp.msgCenter.removeMsgMgr(msg_, sourceUIHelper) then
		for i,v in ipairs(sourceUIHelper.manageMsg) do
			if v==msg_ then
				table.remove(sourceUIHelper.manageMsg, i)
			end
		end
	end
end

-- unregistAllMsg
local function unregistAllMsg()
	for i,v in ipairs(sourceUIHelper.manageMsg) do
		hp.msgCenter.removeMsgMgr(v, sourceUIHelper)
	end

	sourceUIHelper.manageMsg = {}
end

local function createSourceUI(belong_, tileInfo_)
	if belong_ == globalData.ARMY_BELONG.ME then
		local resourceInfo = hp.gameDataLoader.getInfoBySid("resources", tileInfo_.objInfo.sid)		
		if resourceInfo.growth == 0 then
			-- 钻石
			return UI_mySourceGold.new(tileInfo_)
		else
			-- 一般资源
			return UI_mySource.new(tileInfo_)
		end
	elseif belong_ == globalData.ARMY_BELONG.ENEMY then
		return UI_enemySource.new(tileInfo_)
	elseif belong_ == globalData.ARMY_BELONG.ALLIANCE then
		return UI_unionSource.new(tileInfo_)
	elseif belong_ == globalData.ARMY_BELONG.NONE then
		return UI_source.new(tileInfo_)
	end
end

local function updateSourceUI()
	local ui_ = sourceUIHelper.sourceUI
	cclog_("updateSourceUI", ui_)
	if ui_ == nil then
		return
	end

	cclog_("game.curScene.mapLevel",game.curScene.mapLevel)
	if game.curScene.mapLevel ~= 2 then
		cclog("sourceUIHelper updateSourceUI,mapLevel is not 2!")
		return
	end

	local armyInfo_ = game.curScene.conflictManager.getArmyByMarchType(globalData.ARMY_TYPE.SOURCE_ING)[1]
	local goldArmyInfo_ = game.curScene.conflictManager.getArmyByMarchType(globalData.ARMY_TYPE.SOURCE_GOLD)[1]
	local belong_ = globalData.ARMY_BELONG.NONE
	if armyInfo_ ~= nil then
		belong_ = globalData.getArmyBelong(armyInfo_.pid, armyInfo_.unionID)
	elseif goldArmyInfo_ ~= nil then
		belong_ = globalData.getArmyBelong(goldArmyInfo_.pid, goldArmyInfo_.unionID)
		armyInfo_ = goldArmyInfo_
	end
	cclog_("armyInfo_",belong_, ui_:getType(), armyInfo_)
	if belong_ == ui_:getType() then
		ui_:updateInfo(armyInfo_)
	else
		local tileInfo_ = ui_.tileInfo
		tileInfo_.objInfo.armyInfo = armyInfo_
		newUI_ = createSourceUI(belong_, tileInfo_)
		ui_:close()
		sourceUIHelper.sourceUI = newUI_
		game.curScene:addModalUI(newUI_)
	end
end

-- 方法
-- ==================
function sourceUIHelper.init()
	sourceUIHelper.manageMsg = {}
	registMsg(hp.MSG.ARMY_CONFLICT)
	registMsg(hp.MSG.SOURCEUI_CLOSE)
end

function sourceUIHelper.openSourceUI(ui_)
	cclog_("sourceUIHelper.openSourceUI")
	sourceUIHelper.sourceUI = ui_
end

function sourceUIHelper.closeSourceUI()
	sourceUIHelper.sourceUI = nil
end

function sourceUIHelper.onMsg(obj_, msg_, param_)
	cclog_(sourceUIHelper.onMsg)
	if msg_ == hp.MSG.ARMY_CONFLICT then
		updateSourceUI()
	elseif msg_ == hp.MSG.SOURCEUI_CLOSE then
		sourceUIHelper.closeSourceUI()
	end
end

function sourceUIHelper.exit()
	unregistAllMsg()
	sourceUIHelper.sourceUI = nil
end

return sourceUIHelper