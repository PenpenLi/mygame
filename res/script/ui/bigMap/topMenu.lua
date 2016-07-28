--
-- ui//bigMap/topMenu.lua
-- 顶部菜单
--===================================
require "ui/UI"


UI_topMenu = class("UI_topMenu", UI)

local resList = {"rock", "wood", "mine", "food", "silver"}

--init
function UI_topMenu:init()
	-- data
	-- ===============================


	-- ui
	-- ===============================
	self:initUI()

	-- 资源加载
	for i, v in ipairs(resList) do
		if self[v] ~= nil then
			--local strNum = string.format("%d", player.getResource(v))
			self[v]:setString(player.getResourceShow(v))
		end
	end

	-- call back
	-- 回城
	function OnBackHomeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			game.curScene:gotoPosition("2-2", player.getPosition())
		end
	end

	-- 书签管理
	function OnBookMarkTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/UIbookMark"
			ui = UI_bookMark.new()
			self:addUI(ui)
		end
	end

	-- 查找
	function OnSearchTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require "ui/bigMap/search"
			ui_ = UI_search.new()
			self:addModalUI(ui_)
		end
	end

	-- 王国地图
	function OnKindomMapTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			print("kindomMap")
		end
	end

	-- 全屏/退出全屏
	function OnFullScreenTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			print("fullScreen")
		end
	end

	self.backHome:addTouchEventListener(OnBackHomeTouched)
	self.bookMark:addTouchEventListener(OnBookMarkTouched)
	self.search:addTouchEventListener(OnSearchTouched)
	self.kdMap:addTouchEventListener(OnKindomMapTouched)
	self.fullScreen:addTouchEventListener(OnFullScreenTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)

	-- registMsg
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
end

function UI_topMenu:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "topMenu.json")
	local content = self.wigetRoot:getChildByName("Panel_8268")

	self.backHome = content:getChildByName("ImageView_8269")
	self.bookMark = content:getChildByName("ImageView_8270")
	self.search = content:getChildByName("ImageView_8271")
	self.kdMap = content:getChildByName("ImageView_8272")
	self.fullScreen = content:getChildByName("ImageView_8273")

	-- 资源
	-- rock
	self.rock = content:getChildByName("Panel_8276"):getChildByName("Label_8277")
	-- wood
	self.wood = content:getChildByName("Panel_8277"):getChildByName("Label_8277")
	-- mine
	self.mine = content:getChildByName("Panel_8278"):getChildByName("Label_8277")
	-- food
	self.food = content:getChildByName("Panel_8279"):getChildByName("Label_8277")
	-- silver
	self.silver = content:getChildByName("Panel_8280"):getChildByName("Label_8277")
end

-- onMsg
function UI_topMenu:onMsg(msg_, resInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		local strNum = hp.common.changeNumUnit(resInfo_.num)
		if self[resInfo_.name] ~= nil then
			self[resInfo_.name]:setString(strNum)
		end 
	end
end