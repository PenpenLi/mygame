--
-- ui/bigMap/war/capturedHero.lua
-- 被关押的武将 
--===================================
require "ui/UI"
require "ui/frame/popFrame"

UI_capturedHero = class("UI_capturedHero", UI)

--init
function UI_capturedHero:init(tileInfo_)
	-- ===============================
	self.tileInfo = tileInfo_

	-- ui
	-- ===============================
	self:initUI()
	
	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(5290))

	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)

	-- call back

	-- 数据请求
	self:requestData()
end

function UI_capturedHero:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "capturedHero.json")
	local content = self.wigetRoot:getChildByName("Panel_3")

	-- 说明
	local name_ = self.tileInfo.objInfo.name
	if self.tileInfo.objInfo.unionID ~= 0 then
		name_ = hp.lang.getStrByID(21)..self.tileInfo.objInfo.unionName..hp.lang.getStrByID(22)..name_
	end
	content:getChildByName("Label_4"):setString(string.format(hp.lang.getStrByID(5291), name_))
	-- 武将
	content:getChildByName("Label_7"):setString(hp.lang.getStrByID(6001))
	-- 主公
	content:getChildByName("Label_8"):setString(hp.lang.getStrByID(6013))

	self.listView = self.wigetRoot:getChildByName("ListView_20")
	self.item = self.listView:getChildByName("Panel_21"):clone()
	self.item:retain()
	self.listView:removeAllItems()
end

function UI_capturedHero:refreshShow()
	local index_ = 1
	for i, v in ipairs(self.captives) do
		local item_ = self.item:clone()
		local content_ = item_:getChildByName("Panel_23")

		if index_%2 == 0 then
			item_:getChildByName("Panel_22"):getChildByName("Image_24"):setVisible(false)
		end

		content_:getChildByName("Label_26"):setString(v.name)

		local name_ = v.lordName
		if v.unionName ~= "" then
			name_ = hp.lang.getStrByID(21)..v.unionName..hp.lang.getStrByID(22)..name_
		end

		content_:getChildByName("Label_26_0"):setString(name_)

		self.listView:pushBackCustomItem(item_)
		index_ = index_ + 1
	end
end

function UI_capturedHero:requestData()
	local function parseOneCaptive(info_)
		hero_ = {}
		hero_.name = info_[1]
		hero_.lordName = info_[2]
		hero_.unionName = info_[3]
		return hero_
	end

	local function parseCaptives(info_)
		self.captives = {}
		if info_ == nil then
			return
		end

		for i, v in ipairs(info_) do
			self.captives[i] = parseOneCaptive(v)
		end
	end

	local function onHttpResponse(status, response, tag)
		if status~=200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result ~= nil and data.result == 0 then
			parseCaptives(data.impri)
			self:refreshShow()
		end	
	end

	local cmdData={}
	cmdData.type = 4
	cmdData.id = string.format("%0.f",self.tileInfo.objInfo.id)

	local cmdSender = hp.httpCmdSender.new(onHttpResponse)
	cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdWorld)
end