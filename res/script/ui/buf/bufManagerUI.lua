--
-- ui/buf/bufManagerUI.lua
-- buf管理器UI
--===================================
require "ui/fullScreenFrame"

UI_bufManagerUI = class("UI_bufManagerUI", UI)

--init
function UI_bufManagerUI:init()
	-- data
	-- ===============================

	-- ui data
	self.uiLoadingBar = {}
	self.uiLoadingText = {}
	self.uiLoadingImage = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:hideTopBackground()
	uiFrame:setTitle(hp.lang.getStrByID(5282))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)	

	hp.uiHelper.uiAdaption(self.uiItem1)
	hp.uiHelper.uiAdaption(self.uiItem2)

	self:refreshShow()
end

function UI_bufManagerUI:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bufManager.json")

	-- 功能
	self.listView = self.wigetRoot:getChildByName("ListView_1")
	content_ = self.listView:getChildByName("Panel_10"):getChildByName("Panel_12")
	content_:getChildByName("Label_14"):setString(hp.lang.getStrByID(5283))
	self.uiItem1 = self.listView:getChildByName("Panel_2"):clone()
	self.uiItem1:retain()
	self.uiItem2 = self.listView:getChildByName("Panel_2_0"):clone()
	self.uiItem2:retain()
	self.listView:removeLastItem()
	self.listView:removeLastItem()
end

function UI_bufManagerUI:refreshShow()
	self.uiLoadingBar = {}
	self.uiLoadingText = {}
	self.uiLoadingImage = {}
	bufUIConfig_ = hp.gameDataLoader.getTable("uiBufManager")

	local function createItemByindex(index_)
		v = bufUIConfig_[index_]
		if v == nil then
			return nil
		end

		local item_ = self.uiItem2:clone()
		self.uiLoadingImage[v.sid] = item_:getChildByName("Panel_21"):getChildByName("ImageView_1644")
		self.uiLoadingBar[v.sid] = self.uiLoadingImage[v.sid]:getChildByName("LoadingBar_1640")
		self.uiLoadingText[v.sid] = item_:getChildByName("Panel_3"):getChildByName("Label_22")

		local content_ = item_:getChildByName("Panel_3")
		-- 图片
		content_:getChildByName("Image_4"):loadTexture(config.dirUI.item..v.id..".png")
		-- 名称
		content_:getChildByName("Label_5"):setString(v.name)
		-- 描述
		content_:getChildByName("Label_5_0"):setString(v.desc)

		item_:setTag(v.sid)
		item_:addTouchEventListener(self.onItemTouched)
		self:updateInfo(v.sid)
		return item_
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.uiItem2:getSize().height, 3)
	end
	self.listViewHelper.initShow()
end

function UI_bufManagerUI:changeVisible(index_, show_)
	if self.uiLoadingImage[index_]:isVisible() == show_ then
		return
	end

	self.uiLoadingImage[index_]:setVisible(show_)
	self.uiLoadingText[index_]:setVisible(show_)
end

function UI_bufManagerUI:updateInfo(index_)
	local info_ = hp.gameDataLoader.getInfoBySid("uiBufManager", index_)
	local cd_ = 0
	local percent_ = 0

	if info_.position == 0 then
		-- buf
		local buf_ = player.bufManager.getBufByAttrID(info_.attrID)
		if buf_ ~= nil then
			for i, v in pairs(buf_) do
				if v.endTime - player.getServerTime() > cd_ then
					cd_ = v.endTime - player.getServerTime()
					if v.total_cd ~= 0 then
						percent_ = cd_ / v.total_cd * 100
					end
				end
			end
		end
	elseif info_.position == 1 then
		-- cdBox
		-- 剩余时间		
		local cdInfo_ = cdBox.getCDInfo(info_.cdType)
		cd_ = cdInfo_.cd
		if cd_ > 0 then
			if cdInfo_.total_cd > 0 then
				percent_ = cd_ / cdInfo_.total_cd * 100
			end
		end
	elseif info_.position == 2 then
		-- 特殊buff
		local buf_ = player.bufManager.getSpBufBySpID(info_.attrID)
		if buf_ ~= nil then
			for i, v in pairs(buf_) do
				if v.endTime - player.getServerTime() > cd_ then
					cd_ = v.endTime - player.getServerTime()
					if v.total_cd ~= 0 then
						percent_ = cd_ / v.total_cd * 100
					end
				end
			end
		end
	end

	if cd_ <= 0 then
		self:changeVisible(index_, false)
	else
		self:changeVisible(index_, true)
		self.uiLoadingBar[index_]:setPercent(percent_)
		self.uiLoadingText[index_]:setString(hp.lang.getStrByID(5284)..hp.datetime.strTime(cd_))
	end	
end

function UI_bufManagerUI:initCallBack()
	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/commonItemByType"
			local info_ = hp.gameDataLoader.getInfoBySid("uiBufManager", sender:getTag())
			local item_ = hp.gameDataLoader.getInfoBySid("item", info_.id)
			local ui_ = UI_commonItemByType.new(item_.itemType, info_.name, info_.hint, info_.salePos)
			self:addUI(ui_)
		end
	end

	self.onItemTouched = onItemTouched
end

function UI_bufManagerUI:onRemove()
	self.uiItem1:release()
	self.uiItem2:release()
	self.super.onRemove(self)
end

function UI_bufManagerUI:heartbeat(dt_)
	for i, v in pairs(self.uiLoadingBar) do
		self:updateInfo(i)
	end
end