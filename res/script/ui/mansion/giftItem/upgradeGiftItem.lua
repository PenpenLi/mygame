--
-- ui/mansion/giftItem/upgradeGiftItem.lua
-- 在线礼包
--===================================

-- 类
--===================================
UpgradeGiftItem = class("UpgradeGiftItem")

-- 初始化
function UpgradeGiftItem:ctor(item_, list_, parent_)
	self.item = item_
	self.list = list_
	self.parent = parent_
	self:initTouchEvent()
	self:initUI()
end

-- 初始化事件
function UpgradeGiftItem:initTouchEvent()
	-- 领取事件监听
	local function getUpgradeGift(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local function onBaseInfoResponse(status, response, tag)
				-- 服务器正常连接
				if status == 200 then
					local res = hp.httpParse(response)
					-- 成功
					if res.result ~= nil and res.result == 0 then
						-- 已领取等级 +1
						player.mansionUpgradeGift.setLevel(player.mansionUpgradeGift.getLevel() + 1)
						-- 发送消息
						hp.msgCenter.sendMsg(hp.MSG.UPGRADEGIFT_GET)
					end
				end
			end
			-- 准备请求
			local cmdData = {operation = {}}
			local oper = {}
			oper.channel = 22
			oper.type = 2
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			-- 发送请求
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			-- 等待相应
			self.parent:showLoading(cmdSender, sender)
		end
	end
	self.getUpgradeGift = getUpgradeGift
end

-- 初始化界面
function UpgradeGiftItem:initUI()

	-- 根据id获取itemInfo
	local function getItemInfoBySid(sid)
		for i, itemInfo in ipairs(game.data.item) do
			if sid == itemInfo.sid then
				return itemInfo
			end
		end
		return nil
	end

	-- 府邸升级礼包
	local upgradeGiftPanel = self.item
	-- 府邸升级礼包内容
	local upgradeGiftContent = upgradeGiftPanel:getChildByName("Panel_content")
	local con = upgradeGiftPanel:getChildByName("Panel_content")
	-- 奖励内容列表
	local itemList = upgradeGiftPanel:getChildByName("ListView_giftItems")
	-- 奖励内容背景
	local itemListFrame = upgradeGiftPanel:getChildByName("Panel_Frame")
	-- 表数据
	local data = game.data
	-- 自适应数据
	local panelHeight = upgradeGiftPanel:getSize().height
	local itemHeight = itemList:getItem(0):getSize().height
	local itemListHeight = itemList:getSize().height
	local listFrameHeight = itemListFrame:getSize().height
	local contentY = con:getPositionY()
	local lt = itemListFrame:getChildByName("Image_leftTop")
	local t = itemListFrame:getChildByName("Image_top")
	local rt = itemListFrame:getChildByName("Image_rightTop")
	local l = itemListFrame:getChildByName("Image_left")
	local r = itemListFrame:getChildByName("Image_right")
	local c = itemListFrame:getChildByName("Image_center")
	local borderHeight = c:getSize().height

	-- 根据内容自适应
	local function upgradeGiftPanelAdaption()
		local length = table.getn(itemList:getItems()) - 1
		local height = length * itemHeight
		-- 调整list高度
		local listSize = itemList:getSize()
		listSize.height = itemListHeight + height
		itemList:setSize(listSize)
		-- 调整frame高度
		local frameSize = itemListFrame:getSize()
		frameSize.height = listFrameHeight + height
		itemListFrame:setSize(frameSize)
		-- 调整边框高度
		local borderSize = l:getSize()
		borderSize.height = borderHeight + height / hp.uiHelper.RA_scaleY
		l:setSize(borderSize)
		r:setSize(borderSize)
		-- 调整中央高度
		local centerSize = c:getSize()
		centerSize.height = borderHeight + height / hp.uiHelper.RA_scaleY
		c:setSize(centerSize)
		-- 调整位置
		con:setPositionY(contentY + height)
		lt:setPositionY(frameSize.height)
		rt:setPositionY(frameSize.height)
		t:setPositionY(frameSize.height)
		l:setPositionY(frameSize.height / 2)
		r:setPositionY(frameSize.height / 2)
		c:setPositionY(frameSize.height / 2)
		-- 调整大小
		local panelSize = upgradeGiftPanel:getSize()
		panelSize.height = panelHeight + height
		upgradeGiftPanel:setSize(panelSize)
	end

	-- 已领取等级
	local serverLevel = player.mansionUpgradeGift.getLevel()
	-- 已经全部领取
	if serverLevel > 20 then
		self.priority = 4
		return
	end
	-- 获取府邸等级
	local mansionLevel = player.buildingMgr.getBuildingMaxLvBySid(1001)
	-- 礼包id
	local giftSid = data.main[player.mansionUpgradeGift.getLevel() + 1].giftSid
	-- 奖励图标
	upgradeGiftContent:getChildByName("Image_border"):getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.item, giftSid))
	-- 按钮
	local upgradeGiftGetBtn = upgradeGiftContent:getChildByName("Image_getBtn")
	-- 按钮文字
	upgradeGiftGetBtn:getChildByName("Label_info"):setString(hp.lang.getStrByID(8123))
	-- 标题
	upgradeGiftContent:getChildByName("Label_title"):setString(hp.lang.getStrByID(8127))
	-- 奖励信息（遍历获取）
	local itemTab = data.item
	local upgradeGiftInfo = nil
	for i, v in pairs(itemTab) do
		if v.sid == giftSid then
			-- 奖励描述
			upgradeGiftContent:getChildByName("Label_desc"):setString(v.desc)
			-- 取得数据
			upgradeGiftInfo = v
			break
		end
	end
	-- 奖励内容表
	local upgradeGiftGoodsId = upgradeGiftInfo.parmeter1
	local upgradeGiftGoodsNum = upgradeGiftInfo.parmeter2
	-- 添加至Ui
	local item = itemList:getItem(0):clone()
	for i, v in ipairs(upgradeGiftGoodsId) do
		tempItem = item:clone()
		if i == 1 then
			-- 清理工作
			itemList:removeAllItems()
		end
		itemList:pushBackCustomItem(tempItem)
		local subItemInfo = getItemInfoBySid(v)
		-- 设置item基本信息
		local content = tempItem:getChildByName("Panel_content")
		content:getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.item, subItemInfo.sid))
		content:getChildByName("Label_info"):setString(subItemInfo.name)
		content:getChildByName("Label_num"):setString(upgradeGiftGoodsNum[i])
	end
	-- 设置按钮
	if serverLevel >= mansionLevel then
		self.priority = 3
		upgradeGiftGetBtn:loadTexture(config.dirUI.common .. "button_gray1.png")
		upgradeGiftGetBtn:setTouchEnabled(false)
	else
		self.priority = 1
		upgradeGiftGetBtn:loadTexture(config.dirUI.common .. "button_blue1.png")
		upgradeGiftGetBtn:setTouchEnabled(true)
	end
	upgradeGiftGetBtn:addTouchEventListener(self.getUpgradeGift)
	-- 根据内容自适应
	upgradeGiftPanelAdaption()
end