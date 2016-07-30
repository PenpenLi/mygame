--
-- ui/union/unionShopCatalogBuyPop.lua
-- 公会商店目录弹出界面
--===================================
require "ui/frame/popFrame"

UI_unionShopCatalogBuyPop = class("UI_unionShopCatalogBuyPop", UI)

local starImage_ = {"alliance_69.png", "alliance_70.png"}

--init
function UI_unionShopCatalogBuyPop:init(sid_, closeCallBack_)
	-- data
	-- ===============================
	self.item = hp.gameDataLoader.getInfoBySid("item", sid_)
	self.sid = sid_
	self.starred = 2
	self.closeCallBack = closeCallBack_

	-- call back
	self:initCallBack()

	-- ui
	self:initUI()
	local popFrame = UI_popFrame.new(self.widgetRoot)
	popFrame:setIsModalUI(false)

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.widgetRoot)

	self:refreshShow()	
	self:requestData()
end

function UI_unionShopCatalogBuyPop:initCallBack()
	local function onStarResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then		
			local idList_ = {}	
			local num_ = 0
			if self.starred == 2 then
				self.starred = 1
				idList_[1] = 1199
				idList_[2] = 1251
				num_ = 1
			else
				self.starred = 2
				idList_[1] = 1250
				idList_[2] = 1252
				num_ = -1
			end
			hp.msgCenter.sendMsg(hp.MSG.UNION_SHOP_STAR_CLICK, {self.sid, num_})
			self:changeFavorite()
			require "ui/common/successBox"
			local ui_ = UI_successBox.new(hp.lang.getStrByID(idList_[1]), hp.lang.getStrByID(idList_[2]))
			self:addModalUI(ui_)
		end
	end

	local function onStarTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 13
			if self.starred == 2 then
				oper.type = 3
			else
				oper.type = 4
			end
			oper.sid = self.sid
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onStarResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
			self:showLoading(cmdSender, sender)
		end
	end

	self.onStarTouched = onStarTouched
end

function UI_unionShopCatalogBuyPop:requestData()
	local function onApplicantResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			self:updateInfo(data.shop)
		end
	end

	local cmdData={operation={}}
	local oper = {}
	oper.channel = 13
	oper.type = 6
	oper.sid = self.sid
	cmdData.operation[1] = oper
	local cmdSender = hp.httpCmdSender.new(onApplicantResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
end

function UI_unionShopCatalogBuyPop:updateInfo(info_)
	local content_ = self.widgetRoot:getChildByName("Panel_214_0_0")
	-- 拥有
	content_:getChildByName("Label_219_0"):setString(string.format(hp.lang.getStrByID(1181), info_[2]))
	-- 多少成员申请
	content_:getChildByName("Label_219_0_0"):setString(string.format(hp.lang.getStrByID(1180), table.getn(info_[3])))
	-- 申请成员列表
	local nameList_ = ""
	local myName_ = player.getAlliance():getMyUnionInfo():getName()
	self.starred = 2
	for i, v in ipairs(info_[3]) do
		if i == 1 then
			nameList_ = v
		else
			nameList_ = nameList_..","..v
		end
		if v == myName_ then
			self.starred = 1
		end
	end
	content_:getChildByName("Label_219_0_1"):setString(hp.lang.getStrByID(1178)..nameList_)

	-- 自己是否申请过
	self:changeFavorite()
end

function UI_unionShopCatalogBuyPop:changeFavorite()
	self.starBtn:getChildByName("ImageView_20459"):loadTexture(config.dirUI.common..starImage_[self.starred])
end

function UI_unionShopCatalogBuyPop:changeItem(sid_)
	if sid_ == self.sid then
		return
	end

	self.sid = sid_
	self.item = hp.gameDataLoader.getInfoBySid("item", sid_)
	self:refreshShow()
	self:requestData()
end

function UI_unionShopCatalogBuyPop:refreshShow()
	local content_ = self.widgetRoot:getChildByName("Panel_214_0_0")

	-- 图片
	content_:getChildByName("Image_66_0"):getChildByName("Image_67"):loadTexture(string.format("%s%s.png", config.dirUI.item, tostring(self.sid)))
	-- 名称
	content_:getChildByName("Label_219"):setString(self.item.name)
	-- 描述
	content_:getChildByName("Label_219_1"):setString(self.item.desc)
end

function UI_unionShopCatalogBuyPop:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionShopCatalogBuyPop.json")
	local content_ = self.widgetRoot:getChildByName("Panel_214_0_0")

	-- 求购
	self.starBtn = content_:getChildByName("ImageView_20457_0")
	self.starBtn:addTouchEventListener(self.onStarTouched)

	content_:getChildByName("Label_219_0_1"):setString(hp.lang.getStrByID(1178))
end

function UI_unionShopCatalogBuyPop:onRemove()
	self.closeCallBack()
	self.super.onRemove(self)
end