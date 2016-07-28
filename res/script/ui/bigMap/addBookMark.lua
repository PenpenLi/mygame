--
-- ui/bigMap/addBookMark.lua
-- 添加书签
--===================================
require "ui/frame/popFrame"


UI_addBookMark = class("UI_addBookMark", UI)


--init
function UI_addBookMark:init(position_, type_, index_)
	-- data
	-- ===============================
	self.position = position_
	self.selectType = 2
	if self.position.k == nil then
		self.position.k = position_.kx.."_"..position_.ky
	end

	-- ui
	-- ===============================
	
	-- 初始化界面
	self:initUI()

	-- call back
	local function OnChooseTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			self.selectType = sender:getTag()
			for i = 1, 3 do
				if i == sender:getTag() then
					self.ChooseContainer[i]:getChildByName("ImageView_7957"):setVisible(true)
				else
					self.ChooseContainer[i]:getChildByName("ImageView_7957"):setVisible(false)
				end
			end
		end
	end

	local function OnAddBookMarkRespond(status, response, tag)
		if status ~= 200 then
			return
		end

		local data = hp.httpParse(response)
		if data.result == 0 then
			if type_ == 1 then
				local pos_ = self.position
				player.addBookMark({self.textField:getString(), pos_.k, pos_.x, pos_.y, self.selectType})
			elseif type_ == 3 then
				player.editBookMark(index_, self.selectType, self.textField:getString())
			end
			self:close()
		end
	end

	local function OnConfirmTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local cmdData={operation={}}
			local oper = {}
			oper.channel = 11
			oper.type = type_
			oper.subtype = self.selectType
			oper.id = self.position.k
			oper.x = self.position.x
			oper.y = self.position.y
			oper.name = self.textField:getString()
			cmdData.operation[1] = oper
			local cmdSender = hp.httpCmdSender.new(OnAddBookMarkRespond)
			cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
		end
	end

	for i = 1, 3 do
		self.ChooseContainer[i]:getChildByName("ImageView_7954"):addTouchEventListener(OnChooseTouched)
	end
	self.confirm:addTouchEventListener(OnConfirmTouched)

	local popFrame = UI_popFrame.new(self.wigetRoot, hp.lang.getStrByID(1202))
	-- addCCNode
	-- ===============================
	self:addChildUI(popFrame)
	self:addCCNode(self.wigetRoot)
end

function UI_addBookMark:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bookMark.json")
	local Content = self.wigetRoot:getChildByName("Panel_7950")

	-- 选择类型
	local editAxis = Content:getChildByName("ImageView_7951"):getChildByName("Label_7952"):setString(hp.lang.getStrByID(1203))

	self.ChooseContainer = {}
	for i = 1, 3 do
		self.ChooseContainer[i] = Content:getChildByName("ImageView_795"..(i + 2))
		self.ChooseContainer[i]:getChildByName("ImageView_7955"):getChildByName("Label_7956"):setString(hp.lang.getStrByID(1205 + i))
	end	

	-- 确定
	self.confirm = Content:getChildByName("ImageView_7968")
	self.confirm:getChildByName("Label_7969"):setString(hp.lang.getStrByID(1209))

	-- 坐标
	local position_ = self.position
	local coor = string.format("K:%s X:%d Y:%d", position_.k, position_.x, position_.y)
	Content:getChildByName("Label_7970"):setString(hp.lang.getStrByID(1204)..":"..coor)

	-- 点击进行编辑
	Content:getChildByName("Label_8065"):setString(hp.lang.getStrByID(1210))

	-- 文本框
	local label_ = Content:getChildByName("Label_8065_0")
	self.textField = hp.uiHelper.labelBind2EditBox(label_)
end
