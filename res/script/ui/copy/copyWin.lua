--
-- ui/copy/copyWin.lua
-- 副本战斗胜利
--===================================
require "ui/UI"

UI_copyWin = class("UI_copyWin", UI)

local ITEM_ANI_INTERVAL = 0.1

--init
function UI_copyWin:init(result_, info_, battleUI_)
	-- data
	-- ===============================
	self.result = result_
	local copies_ = player.copyManager.getCopies()
	self.copyInfo = copies_[result_.id].info
	self.info = info_
	self.battleUI = battleUI_

	-- ui data

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)
end

function UI_copyWin:initCallBack()
	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			self.battleUI:close()
			--player.guide.checkGetGift() --检查领取新手礼包
			player.guide.stepEx({7006})
		end
	end

	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender:getTag() == 1 then
				self.moreInfoCon:setVisible(true)
				self.infoCon:setVisible(false)
				sender:getChildByName("Label_56"):setString(hp.lang.getStrByID(5218))
				sender:setTag(2)
			else
				self.moreInfoCon:setVisible(false)
				self.infoCon:setVisible(true)
				sender:getChildByName("Label_56"):setString(hp.lang.getStrByID(5295))
				sender:setTag(1)
			end
		end
	end

	self.onConfirmTouched = onConfirmTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_copyWin:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "copyWin.json")
	local content_ = self.wigetRoot:getChildByName("Panel_57")

	-- 星级
	if self.result.jihadS == nil then
		self.result.jihadS = 0
	end
	
	for i = 1, self.result.jihadS do
		content_:getChildByName(tostring(i)):loadTexture(config.dirUI.common.."copy_3.png")
	end

	-- 确定
	local confirm_ = content_:getChildByName("Image_20")
	confirm_:getChildByName("Label_21"):setString(hp.lang.getStrByID(1209))
	confirm_:addTouchEventListener(self.onConfirmTouched)

	-- 详情
	local moreInfo_ = content_:getChildByName("Image_55")
	moreInfo_:addTouchEventListener(self.onMoreInfoTouched)
	moreInfo_:getChildByName("Label_56"):setString(hp.lang.getStrByID(5295))	

	-- 播放特效
	local pos_ = content_:getChildByName("Panel_35")
	local ani_ = hp.sequenceAniHelper.createAnimSprite("copy", "win", 13, 0.12, 2)
	ani_:setScale(2)
	pos_:addChild(ani_)

	-- 信息
	local content_ = self.wigetRoot:getChildByName("Panel_5")
	self.infoCon = content_

	-- 经验
	if self.copyInfo.exp ~= 0 then
		content_:getChildByName("Image_4_1"):getChildByName("Label_52"):setString(hp.lang.getStrByID(5293)..":"..self.copyInfo.exp)
	end

	local index_ = 1
	local image_ = {}
	local label_ = {}
	for i = 1, 4 do
		image_[i] = content_:getChildByName("Image_"..i)
		label_[i] = content_:getChildByName("Label_"..i)
	end

	-- 掉落资源
	for i, v in ipairs(self.copyInfo.res) do
		if v ~= 0 then
			local info_ = hp.gameDataLoader.getInfoBySid("resInfo", i)
			-- 图片
			local image_ = image_[index_]:getChildByName("Image_12")
			image_:setVisible(true)
			image_:loadTexture(config.dirUI.common..info_.image)
			itemAni_ = hp.sequenceAniHelper.createAnimSprite("copy", "item", 14, ITEM_ANI_INTERVAL, 1)
			itemAni_:setPosition(image_:getSize().width/2, image_:getSize().height/2)
			image_:addChild(itemAni_)
			-- 名称
			local label_ = label_[index_]
			label_:setVisible(true)
			label_:setString(info_.name.."x"..self.result.res)
			index_ = index_ + 1
			break
		end
	end

	-- 机率道具
	if self.result.prop ~= nil then
		local info_, path_ = hp.gameDataLoader.getItemByID(self.result.prop)
		if info_ ~= nil then
			-- 图片
			local image_ = image_[index_]:getChildByName("Image_12")
			image_:setVisible(true)
			image_:loadTexture(config.dirUI[path_]..self.result.prop..".png")
			itemAni_ = hp.sequenceAniHelper.createAnimSprite("copy", "item", 14, ITEM_ANI_INTERVAL, 1)
			itemAni_:setPosition(image_:getSize().width/2, image_:getSize().height/2)
			image_:addChild(itemAni_)
			-- 名称
			local label_ = label_[index_]
			label_:setVisible(true)
			label_:setString(info_.name.."x1")
			index_ = index_ + 1
		end
	end

	-- 通关道具
	if self.result.items ~= nil then
		local info_, path_ = hp.gameDataLoader.getItemByID(self.result.items)
		if info_ ~= nil then
			-- 图片
			local image_ = image_[index_]:getChildByName("Image_12")
			image_:setVisible(true)
			image_:loadTexture(config.dirUI[path_]..self.result.items..".png")
			itemAni_ = hp.sequenceAniHelper.createAnimSprite("copy", "item", 14, ITEM_ANI_INTERVAL, 1)
			itemAni_:setPosition(image_:getSize().width/2, image_:getSize().height/2)
			image_:addChild(itemAni_)
			-- 名称
			local label_ = label_[index_]
			label_:setVisible(true)
			label_:setString(info_.name.."x1")
			index_ = index_ + 1
		end
	end

	-- 隐藏多余的
	local MAX_ = 4
	for i = index_, MAX_ do
		image_[i]:setVisible(false)
		label_[i]:setVisible(false)
	end

	-- 调整位置
	local x_1, y_1 = image_[1]:getPosition()
	local x_2, y_2 = label_[1]:getPosition()
	local x_3, y_3 = image_[MAX_]:getPosition()
	local delta_ = (x_3 - x_1 + image_[1]:getSize().width*2) / index_
	-- 起点
	local x_ = x_1 - image_[1]:getSize().width
	if (index_ - 1) < MAX_ then
		for i = 1, (index_ - 1) do
			cclog_("x_1 + delta_ * i",x_1 + delta_ * i)
			image_[i]:setPosition(x_ + delta_ * i, y_1)
			label_[i]:setPosition(x_ + delta_ * i, y_2)
		end
	end

	-- 损失战力
	local lostPer_ = hp.common.round(self.info.powerLoss/self.info.power*100)
	local lost_ = self.info.powerLoss.."("..lostPer_.."%)"

	-- 详情
	local content_ = self.wigetRoot:getChildByName("Panel_58")
	self.moreInfoCon = content_
	local index_ = 1
	local times_ = self.result.attackTimes
	if (times_ > 1) and (times_ <= 3) then
		index_ = 2
	elseif times_ >= 4 then
		index_ = 3
	end

	for i = 1, 3 do
		-- 说明
		local desc_ = content_:getChildByName("Label_"..i.."_1")
		desc_:setString(hp.lang.getStrByID(5390+i))

		-- 星级
		local star_ = content_:getChildByName("Label_"..i.."_2")
		star_:setString(hp.lang.getStrByID(5393+i))

		if i == index_ then
			-- 图标
			content_:getChildByName("Image_"..i):loadTexture(config.dirUI.common.."copy_41.png")
			desc_:setColor(cc.c3b(255,80,81))
			star_:setColor(cc.c3b(255,80,81))
			local label_ = content_:getChildByName("Label_"..i.."_3")
			label_:setVisible(true)
			label_:setString(string.format(hp.lang.getStrByID(5397), times_))
			label_:setColor(cc.c3b(255,80,81))
		end
	end
end