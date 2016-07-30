--
-- ui/union/shop/unionShopHistory.lua
-- 联盟商店历史
--===================================
require "ui/fullScreenFrame"

UI_unionShopHistory = class("UI_unionShopHistory", UI)

--init
function UI_unionShopHistory:init()
	-- data
	-- ===============================
	self.tab = 1

	-- ui data
	self.uiTab = {}
	self.uiTabText = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(818)
	uiFrame:setTitle(hp.lang.getStrByID(5442))
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiItem)
	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.uiDesc)

	self.sizeSelected = self.uiTab[1]:getScale()
	self.sizeUnselected = self.uiTab[2]:getScale()

	self:tabPage(self.tab)
end

function UI_unionShopHistory:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopHistory.json")
	local content_ = self.wigetRoot:getChildByName("Panel_29874_Copy0_0")
	local idList_ = {5434, 5435}
	for i = 1, 2 do
		self.uiTab[i] = content_:getChildByName("ImageView_801"..(i + 2))
		self.uiTab[i]:setTag(i)
		self.uiTab[i]:addTouchEventListener(self.onTabTouched)
		self.uiTabText[i] = self.uiTab[i]:getChildByName("Label_2987"..(6 + i))
		self.uiTabText[i]:setString(hp.lang.getStrByID(idList_[i]))
	end

	self.listView = self.wigetRoot:getChildByName("ListView_24")
	self.uiItem = self.listView:getChildByName("Panel_25"):clone()
	self.uiItem:retain()
	self.uiTitle = self.listView:getChildByName("Panel_26"):clone()
	self.uiTitle:retain()
	self.uiDesc = self.listView:getChildByName("Panel_27"):clone()
	self.uiDesc:retain()
	self.listView:removeAllItems()

	self.colorSelected = self.uiTab[1]:getColor()
	self.colorUnselected = self.uiTab[2]:getColor()
end

function UI_unionShopHistory:tabPage(id_)
	local scale_ = {self.sizeUnselected, self.sizeUnselected}	
	local color_ = {self.colorUnselected, self.colorUnselected}
	scale_[id_] = self.sizeSelected
	color_[id_] = self.colorSelected

	for i = 1, 2 do
		self.uiTab[i]:setColor(color_[i])
		self.uiTab[i]:setScale(scale_[i])
		self.uiTabText[i]:setColor(color_[i])
	end

	self.tab = id_
	self.uiLoadingBar = {}
	if id_ == 1 then
		if self.contributeRank == nil then
			self:requestRank()
		else
			self:refreshPage1()
		end
	elseif id_ == 2 then
		if self.shopHistory == nil then
			self:requestShopHistory()
		else
			self:refreshPage2()
		end
	end
end

function UI_unionShopHistory:requestRank()
	local function parseRank(info_)
		local rank_ = {}
		for i, v in ipairs(info_) do
			local one_ = {}
			one_[1] = v[1]
			one_[2] = v[2]
			one_[3] = v[3]
			rank_[i] = one_
		end
		return rank_
	end

	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.contributeRank = parseRank(data.member)
			self:refreshPage1()
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 58
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionShopHistory:requestShopHistory()
	local function parseHistory(info_)
		local history_ = {}
		for i, v in ipairs(info_) do
			local one_ = {}
			one_[1] = v[1]
			one_[2] = v[2]
			one_[3] = v[3]
			one_[4] = v[4]
			history_[i] = one_
		end
		return history_
	end

	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.shopHistory = parseHistory(data.notice)
			-- 排序
			local function sortFun(t1, t2)
				if t1[4] > t2[4] then
					return true
				end

				return false
			end
			table.sort(self.shopHistory, sortFun)
			self:refreshPage2()
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 59
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	self:showLoading(cmdSender)
end

function UI_unionShopHistory:initCallBack()
	-- 切换标签
	local function onTabTouched(sender, eventType)
		if self.tab == sender:getTag() then
			return
		end
		
		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(self.colorSelected)
			self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(self.colorSelected)
				self.uiTabText[sender:getTag()]:setColor(self.colorSelected)
			else
				sender:setColor(self.colorUnselected)
				self.uiTabText[sender:getTag()]:setColor(self.colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			self:tabPage(sender:getTag())
		end
	end

	self.onTabTouched = onTabTouched
end

function UI_unionShopHistory:onRemove()
	self.uiItem:release()
	self.uiTitle:release()
	self.uiDesc:release()
	self.super.onRemove(self)
end

function UI_unionShopHistory:refreshPage1()
	self.listView:removeAllItems()

	if self.contributeRank == nil then
		return
	end

	-- 描述
	local desc_ = self.uiDesc:clone()
	self.listView:pushBackCustomItem(desc_)
	desc_:getChildByName("Panel_33"):getChildByName("Label_51"):setString(hp.lang.getStrByID(5436))

	-- 标题
	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	local content_ = title_:getChildByName("Panel_33")
	-- 成员名称
	content_:getChildByName("Label_51"):setString(hp.lang.getStrByID(5437))
	-- 联盟资金
	content_:getChildByName("Label_51_0"):setString(hp.lang.getStrByID(5438))
	-- 消耗贡献
	content_:getChildByName("Label_51_1"):setString(hp.lang.getStrByID(5439))

	for i, v in ipairs(self.contributeRank) do
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		if i%2 == 0 then
			item_:getChildByName("Panel_26"):getChildByName("Image_27"):setVisible(false)
		end
		local content_ = item_:getChildByName("Panel_33")
		-- 成员名称
		content_:getChildByName("Label_51"):setString(v[1])
		-- 联盟资金
		content_:getChildByName("Label_51_0"):setString(v[2])
		-- 消耗贡献
		content_:getChildByName("Label_51_1"):setString(v[3])
	end
	self.listView:jumpToTop()
end

function UI_unionShopHistory:refreshPage2()
	self.listView:removeAllItems()

	if self.shopHistory == nil then
		return
	end

	-- 标题
	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	local content_ = title_:getChildByName("Panel_33")
	-- 成员名称
	content_:getChildByName("Label_51"):setString(hp.lang.getStrByID(5437))
	-- 道具
	content_:getChildByName("Label_51_0"):setString(hp.lang.getStrByID(5440))
	-- 时间
	content_:getChildByName("Label_51_1"):setString(hp.lang.getStrByID(5441))

	for i, v in ipairs(self.shopHistory) do
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		if i%2 == 0 then
			item_:getChildByName("Panel_26"):getChildByName("Image_27"):setVisible(false)
		end
		local content_ = item_:getChildByName("Panel_33")
		-- 成员名称
		content_:getChildByName("Label_51"):setString(v[1])
		-- 道具
		local itemInfo_ = hp.gameDataLoader.getInfoBySid("item", v[2])
		content_:getChildByName("Label_51_0"):setString(itemInfo_.name.."("..v[3]..")")
		-- 时间
		-- content_:getChildByName("Label_51_1"):setString(hp.datetime.strTime(player.getServerTime() - v[4]))
		content_:getChildByName("Label_51_1"):setString(os.date("%Y-%m-%d %H:%M:%S", v[4]))
	end
	self.listView:jumpToTop()
end