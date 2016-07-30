--
-- ui/bigMap/battle/fortressMgr.lua
-- 公会主界面
--===================================
require "ui/fullScreenFrame"

UI_fortressMgr = class("UI_fortressMgr", UI)

--init
function UI_fortressMgr:init()
	-- data
	-- ===============================
	self.info = player.fortressMgr.getFortressInfo()

	-- ui data
	self.uiItemList = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	if self.info.pid == 0 then		
		uiFrame:setTopShadePosY(770)
	else
		uiFrame:setTopShadePosY(570)
	end
	uiFrame:setTitle(hp.lang.getStrByID(5356))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)	

	self:registMsg(hp.MSG.KING_BATTLE)

	hp.uiHelper.uiAdaption(self.item)

	self.size1 = self.listView:getSize()
	self.size2 = self.listView:getSize()
	self.size2.height = self.size1.height + self.back:getSize().height

	player.fortressMgr.subscribeData("UI_fortressMgr")

	self:initShow()
end

function UI_fortressMgr:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fortressMgr.json")
	local content_ = self.wigetRoot:getChildByName("Panel_72")

	-- 联盟名
	self.unionName = content_:getChildByName("Label_73")
	-- 国王头像
	self.kingImg = content_:getChildByName("Image_74")
	self.kingImg:addTouchEventListener(self.onPlayerHeadTouched)
	-- 国王名称
	self.kingName = content_:getChildByName("Label_77")
	-- 联盟职位
	self.rank = content_:getChildByName("Image_76")
	-- 签名
	self.sign = content_:getChildByName("Label_78")
	self.content = content_
	self.back = self.wigetRoot:getChildByName("Panel_30")
	
	local content2_ = self.wigetRoot:getChildByName("Panel_7")
	-- 信息
	local infoBtn_ = content2_:getChildByName("Image_79")
	infoBtn_:addTouchEventListener(self.onMoreInfoTouched)
	infoBtn_:getChildByName("Label_80"):setString(hp.lang.getStrByID(5154))
	-- 头衔
	content2_:getChildByName("Label_82"):setString(hp.lang.getStrByID(5361))

	self.listView = self.wigetRoot:getChildByName("ListView_83")
	self.item = self.listView:getChildByName("Panel_84"):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_fortressMgr:initShow()
	self.uiItemList = {}
	self.listView:removeAllItems()
	local function createItemByindex(index_)
		local v = self.info.title[index_]
		if v == nil then
			return nil
		end
		local item_ = self.item:clone()
		item_:setTag(index_)
		item_:addTouchEventListener(self.onItemTouched)
		local content_ = item_:getChildByName("Panel_86")
		self.uiItemList[index_] = item_

		-- 图标
		content_:getChildByName("Image_90"):loadTexture(config.dirUI.title..v.sid..".png")
		-- 名称
		content_:getChildByName("Label_92"):setString(v.info.name)
		-- 效果
		local str_ = ""
		for j, w in ipairs(v.info.attrs) do
			local info_ = hp.gameDataLoader.getInfoBySid("attr", w)
			local tmp_ = v.info.value[j]/100
			if tmp_ > 0 then
				tmp_ = "+"..tmp_
			end

			if j == 1 then
				str_ = info_.desc..tmp_.."%"
			else
				str_ = str_..","..info_.desc..tmp_.."%"
			end
		end
		content_:getChildByName("Label_92_0"):setString(str_)

		-- 状态
		local btn_ = content_:getChildByName("Image_95")
		btn_:getChildByName("Label_96"):setString(hp.lang.getStrByID(5370))
		btn_:setTag(v.sid)

		if player.getID() == self.info.pid then
			if v.granted then
				btn_:setVisible(false)
			else
				content_:getChildByName("Image_91"):setVisible(false)
				btn_:addTouchEventListener(self.onGrantTitleTouched)
			end
		else
			btn_:setVisible(false)
		end

		-- 获得者
		if v.granted then
			content_:getChildByName("Label_92_1"):setString(v.playerName)
		else
			content_:getChildByName("Label_92_1"):setVisible(false)
		end
		return item_
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.item:getSize().height, 1)
	end
	self.listViewHelper.initShow()

	-- 调整大小
	if self.info.pid ~= 0 then
		self.unionName:setString(string.format(hp.lang.getStrByID(5382), self.info.unionName))
		self.kingImg:loadTexture(config.dirUI.heroHeadpic..self.info.image..".png")
		self.kingName:setString(hp.lang.getStrByID(5359).."："..hp.lang.getStrByID(21)..self.info.unionName..hp.lang.getStrByID(22)..self.info.king)
		self.rank:loadTexture(config.dirUI.common.."alliance_15.png")
		self.sign:setString(hp.lang.getStrByID(5458).."："..self.info.level)
		self.content:setVisible(true)
		self.back:setVisible(true)
		self.wigetRoot:getChildByName("Panel_6"):setPosition(0,0)
		self.wigetRoot:getChildByName("Panel_7"):setPosition(0,0)
		self.listView:setSize(self.size1)
		cclog_("not 0", self.size1.height,self.size1.width)
	else
		self.content:setVisible(false)
		self.back:setVisible(false)
		self.wigetRoot:getChildByName("Panel_6"):setPosition(0,self.back:getSize().height)
		self.wigetRoot:getChildByName("Panel_7"):setPosition(0,self.back:getSize().height)
		self.listView:setSize(self.size2)
	end
	self.listView:refreshView()
end

function UI_fortressMgr:initCallBack()
	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			cclog_("sender:getTag()",sender:getTag())
			local title = self.info.title[sender:getTag()]
			if title.granted then
				cclog_("view player info", title.pid)
			end
		end
	end

	-- 授予称号
	local function onGrantTitleTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/bigMap/battle/titleGrant"
			local ui_ = UI_titleGrant.new(sender:getTag())
			self:addModalUI(ui_)
		end
	end

	-- 查看信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/bigMap/battle/fortressMoreInfo"
			local ui_ = UI_fortressMoreInfo.new()
			self:addModalUI(ui_)
		end
	end

	-- 玩家信息
	local function onPlayerHeadTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/common/playerInfo"
			local ui_ = UI_playerInfo.new(self.info.pid)
			self:addUI(ui_)
		end
	end

	self.onItemTouched = onItemTouched
	self.onGrantTitleTouched = onGrantTitleTouched
	self.onMoreInfoTouched = onMoreInfoTouched
	self.onPlayerHeadTouched = onPlayerHeadTouched
end

function UI_fortressMgr:updateTitleByIndex(index_)
	local title_ = self.info.title[index_]
	if title_ == nil then
		return
	end

	local uiTitle_ = self.uiItemList[index_]
	if uiTitle_ == nil then
		return
	end

	if title_.granted then
		local content_ = uiTitle_:getChildByName("Panel_86")
		content_:getChildByName("Image_95"):setVisible(false)
		content_:getChildByName("Image_91"):setVisible(true)
		-- 获得者
		content_:getChildByName("Label_92_1"):setVisible(true)
		content_:getChildByName("Label_92_1"):setString(title_.playerName)
	end
end

function UI_fortressMgr:onMsg(msg_, param_)	
	if msg_ == hp.MSG.KING_BATTLE then
		if param_.msgType == 1 then
			self:initShow()
		elseif param_.msgType == 2 then
			self:updateTitleByIndex(param_.index)
		end
	end
end

function UI_fortressMgr:onRemove()
	player.fortressMgr.unSubscribeData("UI_fortressMgr")
	self.item:release()
	self.super.onRemove(self)
end