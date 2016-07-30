--
-- ui/copy/copyMainNew.lua
-- 副本新主界面
--===================================
require "ui/fullScreenFrame"

UI_copyMainNew = class("UI_copyMainNew", UI)

local CLEAR_IMAGE = {"copy_31.png", "copy_32.png"}
local FIGHT_INTERVER = 0.1

--init
function UI_copyMainNew:init()
	-- data
	-- ===============================
	self.itemStatus = {}
	self.firstGroupBtn = nil
	self.uiItemList = {}
	self.giftMap = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new(true)
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5296))
	uiFrame:hideTopBackground()
	uiFrame:setBackEnabled(false)
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiItem1)
	hp.uiHelper.uiAdaption(self.uiItem2)

	self:registMsg(hp.MSG.COPY_DATA_REQUEST)
	self:registMsg(hp.MSG.COPY_NOTIFY)

	local cmdSender_ = player.copyManager.prepareData()
	if cmdSender_ ~= nil then
		self:showLoading(cmdSender_)
	end

	self:updateInfo()

	-- 和新手指引界面绑定
	self:registMsg(hp.MSG.GUIDE_STEP)
	local function bindGuideUI(step)
		if step==7004 then --选择章节
			self.listView:visit()
			player.guide.bind2Node(step, self.firstGroupBtn, self.onEnterTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

function UI_copyMainNew:updateInfo()
	self.uiEnerge:setString(player.getEnerge().."/"..100)
end

function UI_copyMainNew:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "copyMainNew.json")
	self.listView = self.wigetRoot:getChildByName("ListView_20422_0")

	local content_ = self.wigetRoot:getChildByName("Panel_2")
	self.energyImg = content_:getChildByName("Image_147")
	self.uiEnerge = self.energyImg:getChildByName("Label_148")
	self.energyImg:addTouchEventListener(self.onEnergyTouched)	

	self.touchHintBg = self.wigetRoot:getChildByName("Panel_48")
	self.touchHint = self.wigetRoot:getChildByName("Panel_52"):getChildByName("Label_4")
	self.touchHint:setString(hp.lang.getStrByID(5379))

	self.uiItem1 = self.listView:getChildByName("Panel_20425"):clone()
	self.uiItem1:retain()
	self.uiItem2 = self.listView:getChildByName("Panel_20440"):clone()
	self.uiItem2:retain()
	self.listView:removeAllItems()
	self.listView:setClippingType(1)
end

function UI_copyMainNew:createSimplePanel(group_)
	local item_ = self.uiItem1:clone()
	item_:setTag(group_.id)
	-- item_:addTouchEventListener(self.onItemTouched)
	self.itemStatus[group_.id] = 1
	local content_ = item_:getChildByName("Panel_20426")

	-- 章节图标
	local image_ = content_:getChildByName("ImageView_20455")
	-- 名称
	content_:getChildByName("Label_20462"):setString(group_.info.name)
	-- 按钮
	local button_ = content_:getChildByName("ImageView_22897")
	button_:setTag(group_.id)
	button_:getChildByName("Label_22898"):setString(hp.lang.getStrByID(5297))
	if group_.open == true then
		if group_.clear then
			image_:loadTexture(config.dirUI.common..CLEAR_IMAGE[1])
		else
			image_:loadTexture(config.dirUI.common..CLEAR_IMAGE[2])
			local ani_ = hp.sequenceAniHelper.createAnimSprite("copy", "fight", 11, FIGHT_INTERVER)
			ani_:setPosition(image_:getSize().width/2, image_:getSize().height/2)
			image_:addChild(ani_)
		end
		button_:addTouchEventListener(self.onEnterTouched)

		if self.firstGroupBtn==nil then
			self.firstGroupBtn = button_
		end
	else
		-- 锁
		image_:loadTexture(config.dirUI.common.."copy_29.png")
		
		button_:loadTexture(config.dirUI.common.."button_gray.png")
	end
	return item_
end

function UI_copyMainNew:createDetailPanel(group_)
	local item_ = self.uiItem2:clone()
	item_:setTag(group_.id)
	-- item_:addTouchEventListener(self.onItemTouched)
	self.itemStatus[group_.id] = 2
	local content_ = item_:getChildByName("Panel_20426")

	-- 章节图标
	local image_ = content_:getChildByName("ImageView_20455")
	-- 名称
	content_:getChildByName("Label_20462"):setString(group_.info.name)
	-- 按钮
	local button_ = content_:getChildByName("ImageView_22897")
	button_:setTag(group_.id)
	-- 描述
	content_:getChildByName("Label_20462_1"):setString(group_.info.description)
	button_:getChildByName("Label_22898"):setString(hp.lang.getStrByID(5297))
	if group_.open == true then
		button_:addTouchEventListener(self.onEnterTouched)	
		if group_.clear then
			image_:loadTexture(config.dirUI.common..CLEAR_IMAGE[1])
		else
			image_:loadTexture(config.dirUI.common..CLEAR_IMAGE[2])
			local ani_ = hp.sequenceAniHelper.createAnimSprite("copy", "fight", 11, FIGHT_INTERVER)
			ani_:setPosition(image_:getSize().width/2, image_:getSize().height/2)
			image_:addChild(ani_)
		end
		if self.firstGroupBtn==nil then
			self.firstGroupBtn = button_
		end
	else
		-- 锁
		image_:loadTexture(config.dirUI.common.."copy_29.png")
		
		button_:loadTexture(config.dirUI.common.."button_gray.png")
	end

	local proBack = item_:getChildByName("Panel_15291"):getChildByName("Image_29_0")
	local loadingBar = proBack:getChildByName("ProgressBar_30")

	local starNum = {}
	starNum[1] = content_:getChildByName("Image_17"):getChildByName("Label_18")
	starNum[2] = content_:getChildByName("Image_17_0"):getChildByName("Label_18")
	starNum[3] = content_:getChildByName("Image_17_1"):getChildByName("Label_18")

	local gift = {}
	gift[1] = content_:getChildByName("Image_1")
	gift[2] = content_:getChildByName("Image_2")
	gift[3] = content_:getChildByName("Image_3")

	-- 星星数
	for i, v in ipairs(starNum) do
		v:setString(group_.info.giftStar[i])
	end

	-- 箱子状态
	for i, v in ipairs(gift) do
		local state_ = group_.gift[i]
		v:setTag(group_.id * 10 + i)
		v:removeAllChildren()
		if state_ == 0 then
			v:loadTexture(config.dirUI.common.."copy_22.png")
		elseif state_ == 1 then
			v:addTouchEventListener(self.onGiftTouched)
			v:setTouchEnabled(true)
			v:loadTexture(config.dirUI.common.."copy_22.png")
			local x_, y_ = v:getPosition()
			local light_ = outLight2(config.dirUI.common.."copy_38.png")
			light_:setTag(990 + i)
			light_:setPosition(x_, y_)
			light_:setScale(hp.uiHelper.RA_scale)
			content_:addChild(light_, 0)
		else
			v:loadTexture(config.dirUI.common.."copy_23.png")
		end
	end

	-- 进度条
	local percent_ = group_.star / group_.info.giftStar[3] * 100
	loadingBar:setPercent(percent_)

	return item_
end

function UI_copyMainNew:refreshShow()
	if self.group == nil then
		self.group = {}
		local group_ = player.copyManager.getFirstCopyGroup()
		while group_ ~= nil do
			table.insert(self.group, group_)
			group_ = player.copyManager.getCopyGroup(group_.info.nextSid)
		end
	end
	
	self.listView:removeAllItems()
	local function createItemByindex(index_)
		cclog_("createItemByindex",index_)
		local groupTmp_ = self.group[index_]
		if groupTmp_ == nil then
			return nil
		end
		local groups_ = player.copyManager.getCopyGroups()
		local group_ = groups_[groupTmp_.id] or groupTmp_
		local panel_ = nil
		if group_ ~= nil then
			if group_.open then
				panel_ = self:createDetailPanel(group_)
			else
				panel_ = self:createSimplePanel(group_)
			end
			self.uiItemList[group_.id] = panel_
		end
		return panel_
	end

	if self.listViewHelper == nil then
		self.listViewHelper = hp.uiHelper.listViewLoadHelper(self.listView, createItemByindex, self.uiItem1:getSize().height, 3)
	end
	
	self.listViewHelper.initShow(player.copyManager.getGroupNum())

	self:locatePos()
	
	player.guide.stepEx({7003})
end

function UI_copyMainNew:initCallBack()
	local function onEnergyTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/item/energyItem"
			local ui = UI_energyItem.new()
			self:addUI(ui)
		end
	end

	local function onEnterTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local group_ = player.copyManager.getCopyGroup(sender:getTag())
			if group_.open == false then
				require "ui/common/successBox"
				local box_ = UI_successBox.new(hp.lang.getStrByID(5298), hp.lang.getStrByID(5299))
	  			self:addModalUI(box_)				
			else
				require "ui/copy/copyBattlePlace"
				local ui_ = UI_copyBattlePlace.new(group_)
				self:addUI(ui_)
				player.guide.stepEx({7004})
			end
		end
	end

	local function onItemTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			cclog_("onItemTouched",tag_)
			local group_ = player.copyManager.getCopyGroup(tag_)
			local index_ = self.listView:getIndex(sender)
			self.listView:removeItem(index_)
			if self.itemStatus[tag_] == 2 then
				local rewardItem = self:createSimplePanel(group_)
				self.listView:insertCustomItem(rewardItem, index_)
			elseif self.itemStatus[tag_] == 1 then
				local rewardItem = self:createDetailPanel(group_)
				self.listView:insertCustomItem(rewardItem, index_)
			end
		end
	end

	local function onGiftTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag_ = sender:getTag()
			local id_ = math.floor(tag_/10)
			local index_ = tag_%10
			self:showLoading(player.copyManager.httpReqGetTreasure(id_, index_), sender)
		end
	end

	self.onEnergyTouched = onEnergyTouched
	self.onItemTouched = onItemTouched
	self.onEnterTouched = onEnterTouched
	self.onGiftTouched = onGiftTouched
end

function UI_copyMainNew:onMsg(msg_, param_)
	if msg_ == hp.MSG.COPY_DATA_REQUEST then
		self:refreshShow()
	elseif msg_==hp.MSG.GUIDE_STEP then
	-- 新手指引
		self.bindGuideUI(param_)
	elseif msg_ == hp.MSG.COPY_NOTIFY then
		if param_.msgType == 7 then
			self:updateGroupState(param_.gsid, param_.openGsids)
		elseif param_.msgType == 6 then
			self:updateInfo()
		elseif param_.msgType == 2 then
			self:updateStar(param_.id)
		elseif param_.msgType == 4 or param_.msgType == 5 then
			self:updateGift(param_.index, param_.gsid)
		end
	end
end

function UI_copyMainNew:updateStar(id_)
	local copies_ = player.copyManager.getCopies()
	local gsid_ = copies_[id_].groupID
	local item_ = self.uiItemList[gsid_]
	if item_ ~= nil then
		local proBack = item_:getChildByName("Panel_15291"):getChildByName("Image_29_0")
		local loadingBar = proBack:getChildByName("ProgressBar_30")
		local groups_ = player.copyManager.getCopyGroups()
		local group_ = groups_[gsid_]
		local percent_ = group_.star / group_.info.giftStar[3] * 100
		loadingBar:setPercent(percent_)
	end
end

function UI_copyMainNew:updateGift(index_ , gsid_)
	cclog_("updateGift",index_)
	local groups_ = player.copyManager.getCopyGroups()
	local group_ = groups_[gsid_]
	if group_ ~= nil then
		local state_ = group_.gift[index_]
		local content_ = self.uiItemList[group_.id]:getChildByName("Panel_20426")
		local uiGift_ = content_:getChildByName("Image_"..index_)
		uiGift_:removeAllChildren()
		if content_:getChildByTag(990 + index_) ~= nil then
			cclog_("updateGift not nil",index_)
			content_:removeChildByTag(990 + index_)
		end

		uiGift_:setTouchEnabled(false)
		if state_ == 0 then
			uiGift_:loadTexture(config.dirUI.common.."copy_22.png")
		elseif state_ == 1 then
			uiGift_:addTouchEventListener(self.onGiftTouched)
			uiGift_:setTouchEnabled(true)
			uiGift_:loadTexture(config.dirUI.common.."copy_22.png")
			local x_, y_ = uiGift_:getPosition()
			local light_ = outLight2(config.dirUI.common.."copy_38.png")
			light_:setTag(990 + index_)
			light_:setPosition(x_, y_)
			light_:setScale(hp.uiHelper.RA_scale)
			content_:addChild(light_, 0)
		else
			uiGift_:loadTexture(config.dirUI.common.."copy_23.png")
		end
	end
end

function UI_copyMainNew:updateGroupState(gsid_, openGsids_)
	-- 通关的副本
	local content_ = self.uiItemList[gsid_]:getChildByName("Panel_20426")
	local image_ = content_:getChildByName("ImageView_20455")
	image_:removeAllChildren()
	image_:loadTexture(config.dirUI.common..CLEAR_IMAGE[1])

	local groups_ = player.copyManager.getCopyGroups()
	-- 开启的副本
	for i, v in ipairs(openGsids_) do
		local item_ = self.uiItemList[v]
		if item_ ~= nil then
			local index_ = self.listView:getIndex(item_)
			local group_ = groups_[v]
			if group_ ~= nil then
				self.listView:removeItem(index_)
				local newItem_ = self:createDetailPanel(group_)
				self.listView:insertCustomItem(newItem_, index_)
				self.uiItemList[v] = newItem_
			end
		end
	end

	self:locatePos()
end

function UI_copyMainNew:onRemove()
	self.uiItem1:release()
	self.uiItem2:release()
	self.super.onRemove(self)
end

function UI_copyMainNew:locatePos()
	local index_ = 1
	if self.group == nil then
		return
	end
	local groups_ = player.copyManager.getCopyGroups()
	for i, v in ipairs(self.group) do
		local group_ = groups_[v.id] or v
		if not group_.clear then
			index_ = i
			break
		end
	end
	local totalHeight_ = index_ * self.uiItem2:getSize().height + (player.copyManager.getGroupNum() - index_) * self.uiItem1:getSize().height
	local posHeight_ = (index_ - 1) * self.uiItem2:getSize().height
	local per_ = posHeight_ / (totalHeight_ - self.listView:getSize().height) * 100
	if per_ > 100 then
		per_ = 100
	end
	self.per = per_
	self.listView:visit()
	self.listView:jumpToPercentVertical(self.per)
end

function UI_copyMainNew:onAdd(parent_)
	cclog_("onAdd+++++++++++++++++++++++++++")
	self.super.onAdd(self, parent_)
	
	self:locatePos()
end