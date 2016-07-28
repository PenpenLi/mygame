--
-- ui/bigMap/emptyGround.lua
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

	-- ui
	-- ===============================
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "emptyGround.json")
	local popFrame = UI_popFrame.new(self.wigetRoot, TileInfo.name, tileInfo_.position)
	local Panel_7934 = self.wigetRoot:getChildByName("Panel_7934")
	local teleport = Panel_7934:getChildByName("ImageView_7937")
	teleport:getChildByName("Label_7938"):setString(hp.lang.getStrByID(1200))
	local occupy = Panel_7934:getChildByName("ImageView_7938")
	occupy:getChildByName("Label_7938"):setString(hp.lang.getStrByID(1201))
	local kCoor = tileInfo_.position.kx.."-"..tileInfo_.position.ky
	local coor = string.format("K:%s X:%d Y:%d", kCoor, tileInfo_.position.x, tileInfo_.position.y)
	Panel_7934:getChildByName("Label_7936"):setString(hp.lang.getStrByID(1204)..":"..coor)

	-- set call back
	local function OnTeleportTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/teleport"
			ui = UI_teleport.new(tileInfo_)
			self:addModalUI(ui)
		end
	end

	local function OnOccupyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/march/march"
			-- UI_march.openMarchUI(self, tileInfo_)
			ui_ = UI_march.new(tileInfo_.position, 2)
			self:addUI(ui_)
			self:close()
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

	if hasFunction(OCCUPY_FUNC) == true then
		occupy:addTouchEventListener(OnOccupyTouched)
	else
		occupy:setTouchEnabled(false)
		occupy:loadTexture(config.dirUI.common.."button_gray.png")
	end

	if hasFunction(TRANSPORT_FUNC) == true then		
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