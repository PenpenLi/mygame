--
-- ui/union/authorityDetail.lua
-- 公会资源帮助
--===================================
require "ui/fullScreenFrame"

UI_authorityDetail = class("UI_authorityDetail", UI)

local authorityMap = {invite=5010,apply=5011,promote=5012,
relegate=5013,kick=5014,transfer=5015,shopBuy=5016,changeInvite=5017,
changeName=5018,dissovle=5019,changeDesc=5020,mask=5021,changeIcon=5022,
changeColor=5023,receiveGift=5024,exit=5025,changeAnnounce=5498}

--init
function UI_authorityDetail:init(type_)
	-- data
	-- ===============================
	self.type = type_

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5132))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.item)
	hp.uiHelper.uiAdaption(self.uiTitle)

	self:refreshShow()
end

function UI_authorityDetail:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "authorityView.json")
	self.listView = self.widgetRoot:getChildByName("ListView_8344")

	self.item = self.listView:getChildByName("Panel_8345"):clone()
	self.item:retain()
	self.uiTitle = self.listView:getChildByName("Panel_30173_Copy0"):clone()
	self.uiTitle:retain()
	self.listView:removeLastItem()
end

function UI_authorityDetail:onRemove()
	self.item:release()
	self.uiTitle:release()
	self.super.onRemove(self)
end

function UI_authorityDetail:refreshShow()
	local unionRank_ = hp.gameDataLoader.getInfoBySid("unionRank", self.type)
	local allianceRank_ = hp.gameDataLoader.getInfoBySid("allienceRank", self.type)
	if unionRank_ == nil then
		return
	end

	if allianceRank_ == nil then
		return
	end

	self.listView:removeAllItems()

	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	local content_ = title_:getChildByName("Panel_30179")
	content_:getChildByName("ImageView_30180"):loadTexture(config.dirUI.common..unionRank_.image)
	content_:getChildByName("Label_30181"):setString(unionRank_.name)
	for j, w in pairs(allianceRank_) do
		cclog_(j)
		if j ~= "sid" and j~="loadList" then
			if w == 1 then
				local item_ = self.item:clone()
				local content_ = item_:getChildByName("Panel_8351")
				content_:getChildByName("Label_8358"):setString(hp.lang.getStrByID(authorityMap[j]))
				self.listView:pushBackCustomItem(item_)
			end
		end
	end
end