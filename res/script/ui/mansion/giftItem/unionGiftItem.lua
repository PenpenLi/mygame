--
-- ui/mansion/giftItem/unionGiftItem.lua
-- 联盟宝箱
--===================================

-- 类
--===================================
UnionGiftItem = class("UnionGiftItem")

-- 初始化
function UnionGiftItem:ctor(item_, data_, parent_)
	self.item = item_
	self.data = data_
	self.parent = parent_
	self:initTouchEvent()
	self:initUI()
end

-- 初始化事件
function UnionGiftItem:initTouchEvent()
	-- 领取
	local function onReceiveTouch(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function onBaseInfoResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)

				if data.result == 0 then
					player.getAlliance():receiveGift(self.receiveID)
					-- 弹框提示
					local str = "%s × %d "
					local info
					if data.type == 1 then
						-- 联盟贡献
						info = string.format(str, hp.lang.getStrByID(5110), data.num)
					elseif data.type == 2 then
						-- 钻石
						info = string.format(str, hp.lang.getStrByID(6018), data.num)
					elseif data.type == 3 then
						-- 具体物品
						info = string.format(str, hp.gameDataLoader.getInfoBySid("item", data.sid).name, data.num)
					end
					Scene.showMsg({4001, info})
					-- 移除
					local index = self.parent.list:getIndex(self.item)
					self.parent.list:removeItem(index)
					self.parent.unionGiftNum = self.parent.unionGiftNum - 1
					table.remove(self.parent.itemTbl, index + 1)
				end
			end
			
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 54
			oper.id = sender:getTag()
			self.receiveID = sender:getTag()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onBaseInfoResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self.parent:showLoading(cmdSender, sender)
		end
	end
	self.onReceiveTouch = onReceiveTouch
end

-- 初始化界面
function UnionGiftItem:initUI()
	-- 数据
	local info = hp.gameDataLoader.getInfoBySid("unionGift", self.data.sid)

	local content = self.item:getChildByName("Panel_content")
	content:getChildByName("Label_timeTitle"):setString(hp.lang.getStrByID(8125))
	content:getChildByName("Image_getBtn"):getChildByName("Label_info"):setString(hp.lang.getStrByID(8123))
	content:getChildByName("Label_nameTitle"):setString(hp.lang.getStrByID(8129))
	-- 图标
	content:getChildByName("Image_border"):getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.unionGift, info.type))
	-- 名称
	content:getChildByName("Label_title"):setString(info.name)
	-- 发放人
	content:getChildByName("Label_name"):setString(self.data.name)
	-- 时间
	self.timeLabel = content:getChildByName("Label_time")
	self.timeLabel:setString(hp.datetime.strTime(self.data.endTime - player.getServerTime()))
	-- 领取按钮
	local get = content:getChildByName("Image_getBtn")
	get:setTag(self.data.id)
	get:addTouchEventListener(self.onReceiveTouch)
	self.get = get
end

-- 心跳
function UnionGiftItem:heartbeat(dt)
	local cd = self.data.endTime - player.getServerTime()
	if cd > 0 then
		self.timeLabel:setString(hp.datetime.strTime(cd))
	else
		-- 已过期
		local size = self.item:getSize()
		size.height = 0
		self.item:setSize(size)
		self.item:setVisible(false)
	end
end