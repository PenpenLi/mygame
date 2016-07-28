--
-- ui/guide/joinUnion.lua
-- 加入公会
--===================================
require "ui/UI"

UI_unionJoinDiamond = class("UI_unionJoinDiamond", UI)

local resNumber = 10
local showNumber = 3
local tabID = 2
local titleID_ = {1806, 1827, 1828}
local imageList_ = {"3", "4", "5"}

--init
function UI_unionJoinDiamond:init()
	-- data
	-- ===============================
	self.alliance = {}
	
	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	-- addCCNode
	-- ===============================
	self:addCCNode(self.wigetRoot)

	hp.uiHelper.uiAdaption(self.uiItem)

	self:requestData()
end

function UI_unionJoinDiamond:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionJoinGuide.json")

	local content_ = self.wigetRoot:getChildByName("Panel_4")

	-- 关闭
	content_:getChildByName("Image_5"):addTouchEventListener(self.onCloseTouched)

	content_:getChildByName("Label_31"):setString(hp.lang.getStrByID(1827))

	content_:getChildByName("Label_31_0"):setString(hp.lang.getStrByID(5117))

	self.listView = self.wigetRoot:getChildByName("ListView_29885")
	self.uiItem = self.listView:getChildByName("Panel_30322_Copy1"):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
end

-- 添加一个公会到列表
function UI_unionJoinDiamond:addOneUnion(v, index_)
	local item_ = self.uiItem:clone()
	local content_ = item_:getChildByName("Panel_30331")
	-- 头像
	content_:getChildByName("ImageView_30335"):loadTexture(string.format("%s%s.png", config.dirUI.icon, v.icon))
	-- 会长
	content_:getChildByName("Label_30337"):setString(hp.lang.getStrByID(1812)..":"..v.chairMan)
	-- 联盟名称
	content_:getChildByName("Label_30334"):setString(v.name)
	-- 公告
	content_:getChildByName("Label_30338"):setString(v.notice)
	-- 成员
	content_:getChildByName("Label_30341"):setString(string.format("%d/100", v.number))
	-- 战力
	content_:getChildByName("Label_30341_Copy0"):setString(tostring(v.power))
	-- 礼物等级
	content_:getChildByName("Label_30341_Copy1"):setString(string.format(hp.lang.getStrByID(1826), v.giftLevel))
	-- 杀敌
	content_:getChildByName("Label_30341_Copy2"):setString(string.format(hp.lang.getStrByID(1842), v.kill))	
	-- 加入
	local join_ = content_:getChildByName("ImageView_30345_Copy0")
	join_:setTag(index_)
	join_:addTouchEventListener(self.onJoinTouched)
	if v.join == 0 then
		join_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1827))
	else
		join_:getChildByName("Label_30346"):setString(hp.lang.getStrByID(1843))
	end
	self.listView:pushBackCustomItem(item_)
end

function UI_unionJoinDiamond:refreshShow()
	self.listView:removeAllItems()
	
	for i, v in ipairs(self.alliance) do
		self:addOneUnion(v, i)
	end
end

function UI_unionJoinDiamond:requestData(id_)
	local function onDataResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self.alliance = {}
			for i, v in ipairs(data.league) do
				local data_ = Alliance.parseUnionInfo(v)
				self.alliance[i] = data_
			end
			
			if self:isValid() then
				self:refreshShow()
			end
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 16
	oper.type = 55
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onDataResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_unionJoinDiamond:initCallBack()
	local function onCloseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
		end
	end

	local function onJoinResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if data.id ~= nil then
				player.getAlliance():setUnionID(data.id)
			end

			if tag == 0 then
				require "ui/union/unionMain"
				local uiMain_ = UI_unionMain.new()
				self:addUI(uiMain_)
				require "ui/union/invite/joinSuccess"
				local ui_ = UI_joinSuccess.new()
				self:addModalUI(ui_)
				player.clearFristLeague()
				hp.msgCenter.sendMsg(hp.MSG.UNION_JOIN_SUCCESS)
				self:close()
			elseif tag == 1 then
				require "ui/common/successBox"
				ui_ = UI_successBox.new(hp.lang.getStrByID(1888), hp.lang.getStrByID(5116))
				self:addModalUI(ui_)
			end			
		end
	end 

	local function onJoinTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local union_ = self.alliance[sender:getTag()]
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 16
			oper.type = 2
			oper.id = string.format("%.0f", union_.id)
			self.id = union_.id
			cmdData.operation[1] = oper
			local tag_ = 1
			if union_.join == 0 then
				tag_ = 0
			end
			local cmdSender = hp.httpCmdSender.new(onJoinResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, tag_)
		end
	end

	self.onCloseTouched = onCloseTouched
	self.onJoinTouched = onJoinTouched
end

function UI_unionJoinDiamond:onMsg(msg_, param_)
end

function UI_unionJoinDiamond:close()
	self.uiItem:release()
	self.super.close(self)
end