--
-- ui/common/pushConfig.lua
-- 推送设置
--===================================
require "ui/fullScreenFrame"

UI_pushConfig = class("UI_pushConfig", UI)

local statePercent_ = {0, 50, 100}

--init
function UI_pushConfig:init()
	-- data
	-- ===============================
	self.stateList = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(720)
	uiFrame:setTitle(hp.lang.getStrByID(10707), "title1")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiItem)

	self:registMsg(hp.MSG.PUSH_CONFIG)

	player.pushConfigMgr.httpReqRequestPushConfig()
end

function UI_pushConfig:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "pushConfig.json")

	local content_ = self.wigetRoot:getChildByName("Panel_4")
	content_:getChildByName("Label_17"):setString(hp.lang.getStrByID(5508))
	content_:getChildByName("Label_17_0"):setString(hp.lang.getStrByID(5509))
	content_:getChildByName("Label_17_1"):setString(hp.lang.getStrByID(5510))

	-- 功能
	self.listView = self.wigetRoot:getChildByName("ListView_21")
	self.uiItem = self.listView:getChildByName("Panel_22"):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
end

function UI_pushConfig:refreshShow()
	local pushConfig_ = player.pushConfigMgr.getPushConfig()
	for i, v in ipairs(hp.gameDataLoader.getTable("pushConfig")) do
		if pushConfig_[v.sid] ~= nil then
			local item_ = self.uiItem:clone()
			self.listView:pushBackCustomItem(item_)
			local content_ = item_:getChildByName("Panel_24")
			-- 名称
			content_:getChildByName("Label_45"):setString(v.name)
			-- 描述
			content_:getChildByName("Label_26"):setString(v.desc)
			content_:getChildByName("Label_35"):setString(hp.lang.getStrByID(5508))
			content_:getChildByName("Label_35_0"):setString(hp.lang.getStrByID(5509))
			content_:getChildByName("Label_35_1"):setString(hp.lang.getStrByID(5510))

			local slider_ = content_:getChildByName("Image_24_1"):getChildByName("Slider_25")
			slider_:setTag(v.sid)
			slider_:addEventListenerSlider(self.onSliderPercentChange)
			slider_:setPercent(statePercent_[pushConfig_[v.sid]])

			self.stateList[v.sid] = pushConfig_[v.sid]
		else
			cclog("UI_pushConfig:refreshShow no push sid=", v.sid)
		end
	end
end

function UI_pushConfig:initCallBack()
	local function onSliderPercentChange(sender, eventType)
		local per = sender:getPercent()
		local state_ = 0
		
		if per < 30 then
			per = 0
			state_ = 1
		elseif per < 70 then
			per = 50
			state_ = 2
		else
			per = 100
			state_ = 3
		end
		self.stateList[sender:getTag()] = state_
		sender:setPercent(per)
	end

	self.onSliderPercentChange = onSliderPercentChange
end

function UI_pushConfig:onRemove()
	local cmdSender = player.pushConfigMgr.httpReqChangePushConfig(self.stateList)
	if cmdSender ~= nil then
		self:showLoading(cmdSender, nil)
	end
	self.uiItem:release()
	self.super.onRemove(self)
end

function UI_pushConfig:onMsg(msg_, param_)
	if msg_ == hp.MSG.PUSH_CONFIG then
		if param_.msgType == 1 then
			self:refreshShow()
		end
	end
end