--
-- ui/copy/copyFail.lua
-- 副本战斗失败
--===================================
require "ui/UI"

UI_copyFail = class("UI_copyFail", UI)

local ITEM_ANI_INTERVAL = 0.1

--init
function UI_copyFail:init(result_, info_, battleUI_)
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

function UI_copyFail:initCallBack()
	local function onConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			self.battleUI:close()
		end
	end

	self.onConfirmTouched = onConfirmTouched
end

function UI_copyFail:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "copyFail.json")
	local content_ = self.wigetRoot:getChildByName("Panel_5")

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

	-- 确定
	local confirm_ = content_:getChildByName("Image_20")
	confirm_:getChildByName("Label_21"):setString(hp.lang.getStrByID(1209))
	confirm_:addTouchEventListener(self.onConfirmTouched)

	-- 失败了
	content_:getChildByName("Label_3"):setString(hp.lang.getStrByID(5314))

	-- 播放特效
	-- local pos_ = content_:getChildByName("Panel_35")
	-- local ani_ = hp.sequenceAniHelper.createAnimSprite("copy", "fail", 13, 0.12, 2)
	-- pos_:addChild(ani_)

	-- 战力
	content_:getChildByName("Label_44_0"):setString(hp.lang.getStrByID(5043)..":")
	local totalPower = 0
	for i, v in ipairs(self.copyInfo.branchNums) do
		if v ~= 0 then
			local solInfo_ = nil
			local point_ = 0
			if i == 5 then
				solInfo_ = hp.gameDataLoader.getInfoBySid("trap", self.copyInfo.branchSids[i])
				point_ = solInfo_.point
			else
				solInfo_ = hp.gameDataLoader.getInfoBySid("army", self.copyInfo.branchSids[i])
				point_ = solInfo_.addPoint
			end

			-- 战力计算
			local power_ = v * point_
			totalPower = totalPower + power_
		end
	end
	local copies_ = player.copyManager.getCopies()
	local copy_ = copies_[self.result.id]
	content_:getChildByName("Label_5_0"):setString(copy_.remainPower.."/"..totalPower)
	local per_ = (copy_.remainPower/totalPower) * 100
	self.wigetRoot:getChildByName("Panel_2"):getChildByName("ImageView_1644"):getChildByName("LoadingBar_1640"):setPercent(per_)
end