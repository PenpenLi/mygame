--
-- ui/union/embassy.lua
-- 公会战
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_embassy = class("UI_embassy", UI)

local interval = 0

--init
function UI_embassy:init(building_)
	-- data
	-- ===============================
	self.embassy = require "playerData/embassyMgr"
	self.building = building_

	-- ui date
	self.choodImg = {}
	self.chozenItem = nil
	self.repatriate = nil

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(building_.bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(self.wigetRoot)

	self:registMsg(hp.MSG.EMBASSY)

	hp.uiHelper.uiAdaption(self.item)

	self.embassy.sendCmd(embassyOperType.REQUESTDATA)
end

function UI_embassy:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "embassy.json")
	local content_ = self.wigetRoot:getChildByName("Panel_47")

	-- 更多信息
	local moreInfo_ = content_:getChildByName("Image_48")
	moreInfo_:getChildByName("Label_51"):setString(hp.lang.getStrByID(1030))
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)

	local content_ = self.wigetRoot:getChildByName("Panel_4")
	-- 遣返
	self.repatriate = content_:getChildByName("Image_49")
	self.repatriate:getChildByName("Label_50"):setString(hp.lang.getStrByID(5068))
	self.repatriate:addTouchEventListener(self.onRepatriateTouched)

	local content_ = self.wigetRoot:getChildByName("Panel_6")
	content_:getChildByName("Label_9"):setString(hp.lang.getStrByID(5069))
	content_:getChildByName("Label_10"):setString(hp.lang.getStrByID(5070))

	self.listView = self.wigetRoot:getChildByName("ListView_4")
	self.item1 = self.listView:getItem(0):clone()
	self.item1:getChildByName("Panel_6"):getChildByName("Label_7"):setString(hp.lang.getStrByID(1111))
	self.item1:retain()
	self.item = self.listView:getChildByName("Panel_8"):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_embassy:refreshShow()
	self.listView:removeAllItems()
	if hp.common.getTableTotalNum(self.embassy.armys) > 0 then
		self.wigetRoot:getChildByName("Panel_6"):setVisible(false)
		self.listView:setVisible(true)
		self.wigetRoot:getChildByName("Panel_4"):setVisible(true)		

		local desc_ = self.item1:clone()
		self.listView:pushBackCustomItem(desc_)
		for i, v in pairs(self.embassy.armys) do
			local item_ = self.item:clone()
			self.listView:pushBackCustomItem(item_)
			local content_ = item_:getChildByName("Panel_17")
			content_:setTag(v.id)
			-- 名称
			content_:getChildByName("Label_23"):setString(hp.lang.getStrByID(1205)..":"..v.name)
			-- 兵力
			content_:getChildByName("Label_23_0"):setString(hp.lang.getStrByID(1041)..":"..v.num)

			self.choodImg[v.id] = item_:getChildByName("Panel_13"):getChildByName("Image_11")
			self.choodImg[v.id]:setTag(v.id)

			content_:addTouchEventListener(self.onItemTouched)
		end
		local text_ = string.format("%s/%s", self.embassy.totalNum, hp.gameDataLoader.getBuildingInfoByLevel("embassy", self.building.build.lv, "alliedTroopDEFMax"))
		desc_:getChildByName("Panel_6"):getChildByName("Label_7"):setString(text_)
	else
		self.wigetRoot:getChildByName("Panel_6"):setVisible(true)
		self.listView:setVisible(false)
		self.wigetRoot:getChildByName("Panel_4"):setVisible(false)
	end
end

function UI_embassy:initCallBack()
	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/embassy/embassyInfo"
			local moreInfoBox = UI_embassyInfo.new(self.building)
			self:addModalUI(moreInfoBox)
		end
	end

	-- 遣返玩家
	local function onRepatriateTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self.embassy.sendCmd(embassyOperType.REPATRIATE, {self.chozenItem:getTag()})
		end
	end

	-- 玩家点击
	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			if self.chozenItem ~= self.choodImg[tag_] then
				self.choodImg[tag_]:setVisible(true)
				if self.chozenItem ~= nil then
					self.chozenItem:setVisible(false)
				end
				self.chozenItem = self.choodImg[tag_]
				self:updateChooseState()
			end
		end
	end

	self.onRepatriateTouched = onRepatriateTouched
	self.onMoreInfoTouched = onMoreInfoTouched
	self.onItemTouched = onItemTouched
end

function UI_embassy:onMsg(msg_, param_)
	if msg_ == hp.MSG.EMBASSY then
		if param_[1] == embassyMsgType.DATARESPONSE then
			self:refreshShow()
		end
	end
end

function UI_embassy:close()
	self.item:release()
	self.item1:release()
	self.super.close(self)
end

function UI_embassy:updateChooseState()
	if self.choodImg == nil then
		self.repatriate:loadTexture(config.dirUI.common.."button_gray.png")
		self.repatriate:setTouchEnabled(false)
	else
		self.repatriate:loadTexture(config.dirUI.common.."button_red.png")
		self.repatriate:setTouchEnabled(true)
	end
end

function UI_embassy:heartbeat(dt_)
	interval = interval + dt_
	if interval < 1 then
		return
	end

	interval = 0

	-- self:updateInfo()
end