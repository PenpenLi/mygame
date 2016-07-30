--
-- ui/bigMap/func/bookMark.lua
-- 书签管理
--===================================
require "ui/fullScreenFrame"


UI_bookMark = class("UI_bookMark", UI)

local selectTab = {1, 1, 1, 1}
local image = {"mail_button_center.png", "mail_button_center.png", "mail_button_right.png", "mail_button_left.png"}
local changeNum = {1, -1}
local textColor = {}
local typeIcon = {"kd_favorite.png", "kd_friend.png", "kd_enemy.png"}

--init
function UI_bookMark:init()
	-- data
	-- ===============================
	selectTab = {0, 0, 0, 0}

	-- ui
	-- ===============================
	
	self:initCallBack()

	-- 初始化界面
	self:initUI()

	-- addCCNode
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(828)
	uiFrame:setTitle(hp.lang.getStrByID(5122))
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)

	self.bookMark = self.bookMarkContainer:clone()
	self.bookMark:retain()
	self.listView:removeAllItems()

	-- call back
	local function tapPage(page_)
		cclog_("page_",page_)
		local allSelect = 1

		if page_ == 4 then
			local st = selectTab[4]
			selectTab[4] = st + changeNum[st + 1]
			st = selectTab[4]
			for i = 1, 4 do
				selectTab[i] = st
				if st == 1 then
					self.tab[i]:loadTexture(config.dirUI.common.."mail_button_checked.png")
				else
					self.tab[i]:loadTexture(config.dirUI.common..image[i])
				end
				self.text[i]:setColor(textColor[st + 1])
			end
		else
			for i = 1, 3 do
				if i == page_ then
					local st = selectTab[i]
					selectTab[i] = st + changeNum[st + 1]
					if selectTab[i] == 1 then
						self.tab[i]:loadTexture(config.dirUI.common.."mail_button_checked.png")
					else
						self.tab[i]:loadTexture(config.dirUI.common..image[i])
					end
					self.text[i]:setColor(textColor[selectTab[i] + 1])
				end

				if selectTab[i] == 0 then
					allSelect = 0
				end					
			end

			if allSelect ~= selectTab[4] then
				selectTab[4] = allSelect
				if allSelect == 1 then
					self.tab[4]:loadTexture(config.dirUI.common.."mail_button_checked.png")
				else
					self.tab[4]:loadTexture(config.dirUI.common..image[4])
				end
				self.text[4]:setColor(textColor[allSelect + 1])
			end
		end
		self:listBookMark()
	end

	local function OnBookMarkRespond(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			player.parseBookMark(data.coordinate)
			tapPage(4)
		end
	end

	local function OnTabTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			tapPage(sender:getTag())
		end
	end

	for i = 1, 4 do
		self.tab[i]:addTouchEventListener(OnTabTouched)
	end	

	if player.getBookMark() == nil then
		-- 发送请求
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 11
		oper.type = 0
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(OnBookMarkRespond)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		self:showLoading(cmdSender)
	else
		tapPage(4)
	end

	self:registMsg(hp.MSG.BIGMAP_BOOKMARK)
end

function UI_bookMark:initCallBack()
	local function onEditTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local info_ = player.getBookMarkByIndex(sender:getTag())
			require "ui/bigMap/func/addBookMark"
			local ui = UI_addBookMark.new({k=info_:getPosK(),x=info_:getPosX(),y=info_:getPosY()}, 3, info_:getName(), sender:getTag())
			self:addModalUI(ui)
		end
	end

	local function onDeleteTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function onDeleteResponse(status, response, tag)
				if status ~= 200 then
					return
				end

				local data = hp.httpParse(response)
				if data.result == 0 then
					player.deleteBookMark(sender:getTag())
				end
			end

			local function onConfirmTouched()
				local info_ = player.getBookMarkByIndex(sender:getTag())
				local cmdData={operation={}}
				local oper = {}
				oper.channel = 11
				oper.type = 2
				oper.id = info_:getPosK()
				oper.x = info_:getPosX()
				oper.y = info_:getPosY()
				cmdData.operation[1] = oper
				local cmdSender = hp.httpCmdSender.new(onDeleteResponse)
				cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
				self:showLoading(cmdSender, sender)
			end

			require "ui/msgBox/msgBox"
			local ui_ = UI_msgBox.new(hp.lang.getStrByID(5073), hp.lang.getStrByID(5074), hp.lang.getStrByID(1209),
			hp.lang.getStrByID(2412), onConfirmTouched)
			self:addModalUI(ui_)						
		end
	end

	local function onGoToTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local info_ = player.getBookMarkByIndex(sender:getTag())
			game.curScene:gotoPosition(cc.p(info_:getPosX(), info_:getPosY()), nil, info_:getPosK())
			self:close()
		end
	end

	self.onGoToTouched = onGoToTouched
	self.onDeleteTouched = onDeleteTouched
	self.onEditTouched = onEditTouched
end

function UI_bookMark:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bookMarkMgr.json")
	local tabContent = self.wigetRoot:getChildByName("Panel_8020")
	self.listView = self.wigetRoot:getChildByName("ListView_8017")
	local tabBack = self.wigetRoot:getChildByName("Panel_8012")

	-- 标签
	self.tab = {}
	self.tab[4] = tabBack:getChildByName("ImageView_8013")
	self.tab[1] = tabBack:getChildByName("ImageView_8014")
	self.tab[2] = tabBack:getChildByName("ImageView_8015")
	self.tab[3] = tabBack:getChildByName("ImageView_8016")

	self.text = {}
	self.text[4] = tabContent:getChildByName("Label_8059")
	self.text[1] = tabContent:getChildByName("Label_8060")
	self.text[2] = tabContent:getChildByName("Label_8061")
	self.text[3] = tabContent:getChildByName("Label_8062")
	self.text[4]:setString(hp.lang.getStrByID(1219))
	self.text[1]:setString(hp.lang.getStrByID(1206))
	self.text[2]:setString(hp.lang.getStrByID(1207))
	self.text[3]:setString(hp.lang.getStrByID(1208))
	textColor[1] = self.text[1]:getColor()
	textColor[2] = self.text[4]:getColor()

	-- 书签容器
	self.bookMarkContainer = self.listView:getChildByName("Panel_8018")
end

-- 列出书签
function UI_bookMark:listBookMark()
	-- 清空
	self.listView:removeAllItems()

	-- 添加书签
	local bookMarks_ = player.getBookMark()
	for i,v in ipairs(bookMarks_) do
		local type_ = v:getType()
		if selectTab[type_] == 1 then
			local mark_ = self.bookMark:clone()
			mark_:setTag(v:getIndex())
			local content_ = mark_:getChildByName("Panel_8024")
			-- 图标
			content_:getChildByName("ImageView_8025"):loadTexture(string.format("%s%s", config.dirUI.common, typeIcon[type_]))
			
			-- 描述
			content_:getChildByName("Label_8026"):setString(v:getName())

			-- 坐标
			local kInfo = player.serverMgr.getServerBySid(v:getPosK())
			content_:getChildByName("Label_8027"):setString(string.format(hp.lang.getStrByID(1220), kInfo.name, v:getPosX(), v:getPosY()))

			-- 按钮
			local btnDelete = content_:getChildByName("ImageView_8028")
			local btnEdit = content_:getChildByName("ImageView_8029")
			local btnMove = content_:getChildByName("ImageView_8030")
			btnDelete:setTag(v:getIndex())
			btnEdit:setTag(v:getIndex())
			btnMove:setTag(v:getIndex())

			btnDelete:getChildByName("Label_8031"):setString(hp.lang.getStrByID(1221))
			btnEdit:getChildByName("Label_8032"):setString(hp.lang.getStrByID(1222))
			btnMove:getChildByName("Label_8033"):setString(hp.lang.getStrByID(1223))

			btnDelete:addTouchEventListener(self.onDeleteTouched)
			btnEdit:addTouchEventListener(self.onEditTouched)
			btnMove:addTouchEventListener(self.onGoToTouched)
			self.listView:pushBackCustomItem(mark_)
		end
	end
end

function UI_bookMark:onRemove()
	self.bookMark:release()
	self.super.onRemove(self)
end

function UI_bookMark:deleteBookMark(index_)
	local itemNode = self.listView:getChildByTag(index_)
	if itemNode then
		self.listView:removeItem(self.listView:getIndex(itemNode))
	end
end

function UI_bookMark:updateBookMark(index_, info_)
	for i, v in ipairs(self.listView:getChildren()) do
		if v:getTag() == index_ then
			local content_ = v:getChildByName("Panel_8024")
			-- 图标
			content_:getChildByName("ImageView_8025"):loadTexture(string.format("%s%s", config.dirUI.common, typeIcon[info_:getType()]))
			
			-- 描述
			content_:getChildByName("Label_8026"):setString(info_:getName())
			break
		end
	end
end

function UI_bookMark:onMsg(msg_, param_)
	if msg_ == hp.MSG.BIGMAP_BOOKMARK then
		if param_[1] == 1 then
			self:deleteBookMark(param_[2])
		elseif param_[1] == 2 then
			self:updateBookMark(param_[2], param_[3])
		end
	end
end