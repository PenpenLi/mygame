--
-- ui/union/unionHelp.lua
-- 公会资源帮助
--===================================
require "ui/fullScreenFrame"

local nameID_ = {
	[cdBox.CDTYPE.BUILD] = {5165, "building"},
	[cdBox.CDTYPE.RESEARCH] = {5166, "research"},
	[cdBox.CDTYPE.REMEDY] = {5168, nil},
}

setmetatable(nameID_, {__index=function() print("this is not supported"); return {5167, nil} end})

UI_unionHelp = class("UI_unionHelp", UI)

--init
function UI_unionHelp:init()
	-- data
	-- ===============================
	self.helpInfoMap = {}
	self.index = 0

	-- ui data
	self.uiHelpTime = {}

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()	

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(5126))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.widgetRoot)

	hp.uiHelper.uiAdaption(self.uiItem)

	self:registMsg(hp.MSG.UNION_DATA_PREPARED)
	self:registMsg(hp.MSG.UNION_HELP_INFO_CHANGE)

	player.getAlliance():prepareData(dirtyType.HELP, "UI_unionHelp")
	self:updateInfo()
end

function UI_unionHelp:initCallBack()
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			
		end
	end

	local function onHelpResponse(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			Scene.showMsg({1015})
			player.getAlliance():helpOneMember(self.index)
		end
	end

	local function onHelpTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local help_ = self.helpInfoMap[sender:getTag()]
			local cmdData={operation={}}
			local oper = {}
			self.index = sender:getTag()
			oper.channel = 16
			oper.type = 32
			oper.id = help_.id
			oper.cd = help_.type
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onHelpResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	local function onHelpAllTouched(sender, eventType)		
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function onHelpAllResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					Scene.showMsg({1015})
					player.getAlliance():helpAll(data)
				end
			end

			local cmdData={operation={}}
			local oper = {}
			self.index = sender:getTag()
			oper.channel = 16
			oper.type = 41
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(onHelpAllResponse)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	self.onHelpTouched = onHelpTouched
	self.onHelpAllTouched = onHelpAllTouched
	self.onMoreInfoTouched = onMoreInfoTouched
end

function UI_unionHelp:initUI()
	self.widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionHelp.json")
	self.widgetRoot:getChildByName("Panel_2"):getChildByName("Image_11"):addTouchEventListener(self.onMoreInfoTouched)
	self.helpAll = self.widgetRoot:getChildByName("Panel_2"):getChildByName("Image_11_0")
	self.helpAll:addTouchEventListener(self.onHelpAllTouched)

	local content_ = self.widgetRoot:getChildByName("Panel_14")
	content_:getChildByName("Label_15"):setString(hp.lang.getStrByID(1156))
	content_:getChildByName("Label_15_0"):setString(hp.lang.getStrByID(1157))

	self.loadingBar = content_:getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
	self.loadingText = self.loadingBar:getChildByName("ImageView_1641"):getChildByName("Label_1643")

	content_:getChildByName("Label_29"):setString(hp.lang.getStrByID(1030))
	content_:getChildByName("Label_29_0"):setString(hp.lang.getStrByID(1158))

	self.listView = self.widgetRoot:getChildByName("ListView_32")
	self.uiItem = self.listView:getItem(0):clone()
	self.uiItem:retain()
	self.listView:removeAllItems()
end

function UI_unionHelp:close()
	self.uiItem:release()
	player.getAlliance():unPrepareData(dirtyType.HELP, "UI_unionHelp")
	self.super.close(self)
end

function UI_unionHelp:refreshShow()
	self.listView:removeAllItems()
	local helpInfo_ = player:getAlliance():getHelpInfo()

	for i, v in ipairs(helpInfo_) do
		local item_ = self.uiItem:clone()
		self.listView:pushBackCustomItem(item_)
		local content_ = item_:getChildByName("Panel_35")
		local member_ = player.getAlliance():getMemberByID(v.id)
		content_:getChildByName("Image_42"):loadTexture(config.dirUI.common..hp.gameDataLoader.getInfoBySid("unionRank", member_:getRank()).image)
		content_:getChildByName("Label_43"):setString(member_:getName())

		-- 帮助项目名称
		local helpLocalInfo_ = nameID_[v.type]
		local tempInfo_ = {}
		if helpLocalInfo_[2] ~= nil then
			tempInfo_ = hp.gameDataLoader.getInfoBySid(helpLocalInfo_[2], v.param[1])
		end
		content_:getChildByName("Label_43_0"):setString(string.format(hp.lang.getStrByID(helpLocalInfo_[1]), tempInfo_.name, v.param[2]))

		self.uiHelpTime = content_:getChildByName("ImageView_1644_0"):getChildByName("LoadingBar_1640")
		self.uiHelpTime:getChildByName("ImageView_1641"):getChildByName("Label_1642"):setString(hp.lang.getStrByID(5150))
		self.uiHelpTime:getChildByName("ImageView_1641"):getChildByName("Label_1643"):setString(string.format("%d/%d", v.number, v.total))
		local percent_ = hp.common.round(v.number / v.total * 100)
		self.uiHelpTime:setPercent(percent_)
		local help_ = content_:getChildByName("Image_56")
		if v.id == player.getID() then
			help_:setVisible(false)
		else
			help_:addTouchEventListener(self.onHelpTouched)
		end
		help_:setTag(i)
		self.helpInfoMap[i] = v
		help_:getChildByName("Label_57"):setString(hp.lang.getStrByID(5150))
	end

	if table.getn(helpInfo_) == 0 then
		self.helpAll:setTouchEnabled(false)
		self.helpAll:loadTexture(config.dirUI.common.."button_gray.png")
	else
		self.helpAll:setTouchEnabled(true)
		self.helpAll:loadTexture(config.dirUI.common.."ui_hero_skillpoint.png")
	end
end

function UI_unionHelp:updateInfo()
	local myUnionBaseInfo_ = player.getAlliance():getMyUnionInfoBase()
	self.loadingText:setString(string.format("%d/%d", myUnionBaseInfo_.todayContri, myUnionBaseInfo_.todayUp))
	local percent_ = hp.common.round(myUnionBaseInfo_.todayContri / myUnionBaseInfo_.todayUp * 100)
	self.loadingBar:setPercent(percent_)
end

function UI_unionHelp:onMsg(msg_, param_)
	if msg_ == hp.MSG.UNION_DATA_PREPARED then
		if param_ == dirtyType.HELP then
			self:refreshShow()
		end
	elseif msg_ == hp.MSG.UNION_HELP_INFO_CHANGE then
		self:updateInfo()
	end
end