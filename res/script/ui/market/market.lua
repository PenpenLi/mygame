--
-- ui/market/market.lua
-- 市场主界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_market = class("UI_market", UI)

--init
function UI_market:init(building_)
	-- data
	-- ===============================
	local bInfo = building_.bInfo

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.item)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)

	player.getAlliance():prepareData(dirtyType.MEMBER, "UI_market")
end

function UI_market:initCallBack()

	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local resource_ = require "playerData/resourceHelpMgr"
			local playerInfo_ = player.getAlliance():getMemberByLocalID(sender:getTag())
			resource_.sendCmd(9, {playerInfo_:getID()})
		end
	end

	self.onHelpTouched = onHelpTouched
end

function UI_market:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "market.json")
	self.listView = self.widgetRoot:getChildByName("ListView_8344")

	self.item = self.listView:getChildByName("Panel_8345"):clone()
	self.item:retain()
	self.item:getChildByName("Panel_8351"):getChildByName("ImageView_8363"):getChildByName("Label_27736"):setString(hp.lang.getStrByID(5150))
	self.uiTitle = self.listView:getChildByName("Panel_30173_Copy0"):clone()
	self.uiTitle:retain()
	self.listView:removeAllItems()
end

function UI_market:close()
	player.getAlliance():unPrepareData(dirtyType.MEMBER, "UI_market")
	self.item:release()
	self.uiTitle:release()
	self.super.close(self)
end

function UI_market:refreshShow()
	local unionRank_ = hp.gameDataLoader.getTable("unionRank")
	if unionRank_ == nil then
		return
	end

	self.listView:removeAllItems()

	for i, v in ipairs(unionRank_) do
		local rankMembers_ = player.getAlliance():getMembersByRank(v.sid)
		local title_ = self.uiTitle:clone()
		self.listView:pushBackCustomItem(title_)
		local content_ = title_:getChildByName("Panel_30179")
		content_:getChildByName("ImageView_30180"):loadTexture(config.dirUI.common..v.image)
		content_:getChildByName("Label_30181"):setString(v.name)
		for j, w in ipairs(rankMembers_) do
			local item_ = self.item:clone()
			local content_ = item_:getChildByName("Panel_8351")
			content_:getChildByName("ImageView_27734"):getChildByName("Label_27735"):setString(tostring(v.sid))
			content_:getChildByName("Label_8358"):setString(w:getName())
			content_:getChildByName("")

			-- 图片
			content_:getChildByName("ImageView_27733"):loadTexture(config.dirUI.common..v.image)

			local helpBtn = content_:getChildByName("ImageView_8363")
			helpBtn:setTag(w:getLocalID())			
			if w:getID() == player.getID() then
				helpBtn:setVisible(false)
			else
				helpBtn:addTouchEventListener(self.onHelpTouched)
			end
			self.listView:pushBackCustomItem(item_)
		end
	end
end

function UI_market:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if dirtyType.MEMBER == param_ then
			print("UI_market:onMsg")
			self:refreshShow()
		end
	end
end