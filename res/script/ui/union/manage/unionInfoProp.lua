--
-- ui/union/manage/unionInfoProp.lua
-- 公会属性信息
--===================================
require "ui/fullScreenFrame"

UI_unionInfoProp = class("UI_unionInfoProp", UI)

local propList_ = {"killArmy","killedArmy","killArmyRate","destroyTrap","destroyCity","battleWin","battleFail",
	"winRate","captureHero","killHero","saveHero","killedHero","helpNum","helpRate","openGift"}

--init
function UI_unionInfoProp:init(id_, members_, url_)
	-- data
	-- ===============================
	self.id = id_
	self.members = members_
	self.url = url_

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(5415))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiTitle)
	hp.uiHelper.uiAdaption(self.uiItem)

	self:requestData()
end

function UI_unionInfoProp:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionInfoProp.json")

	self.listView = self.wigetRoot:getChildByName("ListView_24")
	self.uiTitle = self.listView:getChildByName("Panel_26"):clone()
	self.uiTitle:retain()
	self.uiItem = self.listView:getChildByName("Panel_25"):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
end

function UI_unionInfoProp:refreshShow()
	-- 战力排名
	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	title_:getChildByName("Panel_33"):getChildByName("Label_51_0"):setString(hp.lang.getStrByID(5416))

	local members_ = {}
	for i, v in ipairs(self.members) do
		for j, w in ipairs(v) do
			table.insert(members_, {name=w:getName(), power=w:getPower()})			
		end
	end
	-- 排序
	table.sort(members_, function(t1, t2)
			if t1.power > t2.power then
				return true
			end
		end)

	for i, v in ipairs(members_) do
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_33")
		if i%2 == 0 then
			item_:getChildByName("Panel_26"):getChildByName("Image_27"):setVisible(false)
		end
		-- 名字
		content_:getChildByName("Label_51"):setString(v.name)
		-- 战力
		content_:getChildByName("Label_51_1"):setString(v.power)
	end

	-- 联盟属性
	local title_ = self.uiTitle:clone()
	self.listView:pushBackCustomItem(title_)
	title_:getChildByName("Panel_33"):getChildByName("Label_51_0"):setString(hp.lang.getStrByID(5417))

	-- 时间
	local item_ = self.uiItem:clone()
	self.listView:pushBackCustomItem(item_)
	local content_ = item_:getChildByName("Panel_33")
	content_:getChildByName("Label_51"):setString(hp.lang.getStrByID(5418))
	self.uiKingTime = content_:getChildByName("Label_51_1")
	self.uiKingTime:setString(hp.datetime.strTime(self.unionInfo.kingTime))

	for i, v in ipairs(propList_) do
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		if i%2 == 1 then
			item_:getChildByName("Panel_26"):getChildByName("Image_27"):setVisible(false)
		end
		local content_ = item_:getChildByName("Panel_33")
		-- 名字
		content_:getChildByName("Label_51"):setString(hp.lang.getStrByID(5418 + i))
		-- 战力
		content_:getChildByName("Label_51_1"):setString(self.unionInfo[v])
	end

	-- self:tickUpdate()
end

function UI_unionInfoProp:requestData()
	local function onHttpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.unionInfo = Alliance.parseUnionDetailInfo(data.attain)
			self:refreshShow()
		end
	end

	local cmdData={}
	cmdData.type = 9
	cmdData.id = self.id
	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld, nil, nil, self.url)
	self:showLoading(cmdSender)
end

function UI_unionInfoProp:initCallBack()
end

function UI_unionInfoProp:onMsg(msg_, param_)
end

function UI_unionInfoProp:tickUpdate()
	if self.unionInfo == nil then
		return
	end

	local cd_ = 0
	if self.unionInfo.kingTime > 0 then
		cd_ = player.getServerTime() - self.unionInfo.kingTime
	end

	if cd_ < 0 then
		cd_ = 0
	end
	self.uiKingTime:setString(hp.datetime.strTime(cd_))
end

function UI_unionInfoProp:heartbeat(dt_)
	-- self:tickUpdate()
end

function UI_unionInfoProp:onRemove()
	self.uiTitle:release()
	self.uiItem:release()
	self.super.onRemove(self)
end