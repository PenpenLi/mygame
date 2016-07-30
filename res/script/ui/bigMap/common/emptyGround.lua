--
-- ui/bigMap/common/emptyGround.lua
-- 空地点击弹出UI 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_emptyGround = class("UI_emptyGround", UI)

local OCCUPY_FUNC = 1
local TRANSPORT_FUNC = 5

--init
function UI_emptyGround:init(tileInfo_)
	-- data
	-- ===============================
	local TileInfo = hp.gameDataLoader.getTable("fieldFunc")[tileInfo_.tileType]
	local tpos = tileInfo_.position
	local isMyServer = player.serverMgr.isMyPosServer(tpos.kx, tpos.ky)

	-- 是否为可用地块
	local isAvailable = true
	if tpos.x<=0 or tpos.x>=511 or tpos.y<=1 or tpos.y>=1022 then
	-- 边界不可用
		isAvailable = false
	end

	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "emptyGround.json")
	local popFrame = UI_popFrame.new(self.wigetRoot, TileInfo.name, tpos, TileInfo.name)
	local Panel_7934 = self.wigetRoot:getChildByName("Panel_7934")
	local teleport = Panel_7934:getChildByName("ImageView_7937")
	teleport:getChildByName("Label_7938"):setString(hp.lang.getStrByID(1200))
	local occupy = Panel_7934:getChildByName("ImageView_7938")
	if isMyServer then
		occupy:getChildByName("Label_7938"):setString(hp.lang.getStrByID(1201))
	else
		occupy:getChildByName("Label_7938"):setString(hp.lang.getStrByID(1227))
	end
	Panel_7934:getChildByName("Label_7936"):setString(player.serverMgr.formatPosition(tpos))
	Panel_7934:getChildByName("Label_7935"):setString(hp.lang.getStrByID(5494).."："..player.serverMgr.getCountryByPos(tpos.kx, tpos.ky))

	-- set call back
	local function OnTeleportTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/common/teleport"
			local ui = UI_teleport.new(tileInfo_, 1)
			self:addModalUI(ui)
		end
	end

	local function OnOccupyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if isMyServer then
				require "ui/march/march"
				UI_march.openMarchUI(self, tpos, globalData.MARCH_TYPE.OCCUPY_EMPTY)
				self:close()
			else
				require "ui/bigMap/common/teleport"
				local ui = UI_teleport.new(tileInfo_, 2)
				self:addModalUI(ui)
			end
		end
	end

	-- 是否具有某功能
	local function hasFunction(type_)
		for i, v in ipairs(TileInfo["function"]) do
			if v == type_ then
				return true
			end			
		end
		return false
	end


	if isAvailable and hasFunction(OCCUPY_FUNC) then
		occupy:addTouchEventListener(OnOccupyTouched)
	else
		occupy:setTouchEnabled(false)
		occupy:loadTexture(config.dirUI.common.."button_gray.png")
	end

	if isAvailable and hasFunction(TRANSPORT_FUNC) then
		teleport:addTouchEventListener(OnTeleportTouched)
	else
		teleport:setTouchEnabled(false)
		teleport:loadTexture(config.dirUI.common.."button_gray.png")
	end

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end