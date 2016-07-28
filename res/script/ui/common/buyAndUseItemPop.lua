--
-- ui/common/buyAndUseItemPop.lua
-- 解锁战争槽
--===================================
require "ui/frame/popFrame"

UI_buyAndUseItem = class("UI_buyAndUseItem", UI)

--init
function UI_buyAndUseItem:init(itemID_, num_, callBack_, param_)
	-- data
	-- ===============================
	self.callBack = callBack_
	self.itemInfo = hp.gameDataLoader.getInfoBySid("item", itemID_)
	self.sid = itemID_
	self.num = num_
	self.buy = false
	self.param = param_
	self.gold = 0

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5064))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_buyAndUseItem:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "buyAndUseItem.json")
	local content_ = self.wigetRoot:getChildByName("Panel_1")

	-- image
	content_:getChildByName("Image_66_0_0"):getChildByName("Image_67"):loadTexture(string.format("%s%d.png", config.dirUI.item, self.itemInfo.sid))
	-- 数量
	local have_ = player.getItemNum(self.sid)
	content_:getChildByName("Image_66_0_0"):getChildByName("Label_219_2_3"):setString(string.format(hp.lang.getStrByID(5063), have_))
	-- 名字
	content_:getChildByName("Label_219_2"):setString(self.itemInfo.name)
	-- 描述
	content_:getChildByName("Label_219_1_0"):setString(self.itemInfo.desc)

	local button_ = content_:getChildByName("Image_10")
	if self.num - have_ > 0 then
		self.buy = true
		button_:addTouchEventListener(self.onGetTouched)
		button_:getChildByName("Label_11"):setString(hp.lang.getStrByID(5064))
		self.gold = self.itemInfo.sale * (self.num - have_)
		button_:getChildByName("ImageView_gold_0_0_0_0"):getChildByName("Label_goldCost"):setString(self.gold)
	else
		self.buy = false
		button_:addTouchEventListener(self.onGetTouched)
		button_:getChildByName("Label_11"):setString(hp.lang.getStrByID(2406))
		button_:getChildByName("ImageView_gold_0_0_0_0"):setVisible(false)
	end
end

function UI_buyAndUseItem:initCallBack()
	local function onGetTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.buy == true then
				if player.getResource("gold")<self.itemInfo.sale then
					-- 金币不够
					require("ui/msgBox/msgBox")
					local msgBox = UI_msgBox.new(hp.lang.getStrByID(2826), 
						hp.lang.getStrByID(2827), 
						hp.lang.getStrByID(1209), 
						hp.lang.getStrByID(2412)
						)
					self:addModalUI(msgBox)
					return
				end
			end
			
			if self.callBack ~= nil then
				self.callBack(self.gold, self.param)
			else
				local function onBuyItemHttpResponse(status, response, tag)
					if status ~= 200 then
						return
					end

					local data = hp.httpParse(response)
					if data.result == 0 then
						if tag == 1 then
							player.expendResource("gold", self.itemInfo.sale)
						elseif tag == 2 then
							player.expendItem(ITEM_SID, 1)
						end
						player.setPosition(data.x, data.y)

						if game.curScene.mapLevel == 2 then
							game.curScene:objAppearOnMap()
						end
						self:closeAll()
					end
				end

				local cmdData={operation={}}
				local oper = {}
				oper.channel = 14
				oper.type = 1
				oper.sid = ITEM_SID
				if self.buy == true then
					oper.gold = self.itemInfo.sale
				else
					oper.gold = 0
				end
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onBuyItemHttpResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
			end
			self:close()
		end
	end

	self.onGetTouched = onGetTouched
end