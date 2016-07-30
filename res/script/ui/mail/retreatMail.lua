--
-- ui/mail/retreatMail.lua
-- 要塞撤兵
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_retreatMail = class("UI_retreatMail", UI)

-- 初始化
function UI_retreatMail:init(mailInfo, mailType_, mailIndex)
	-- data
	-- ["习师印",100,0,0,0]

	local name = mailInfo.annex[1]
	local troops = {}
	troops[1] = mailInfo.annex[2]
	troops[2] = mailInfo.annex[3]
	troops[3] = mailInfo.annex[4]
	troops[4] = mailInfo.annex[5]
	local sum = troops[1] + troops[2] + troops[3] + troops[4]

	-- ui
	-- ======================
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "retreatMail.json")
	local list = widget:getChildByName("ListView_root")

	-- head
	local panel_head = list:getChildByName("Panel_head")
	panel_head:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(11401))

	-- desc
	local panel_desc = list:getChildByName("Panel_desc")
	panel_desc:getChildByName("Panel_content"):getChildByName("Label_text"):setString(string.format(hp.lang.getStrByID(11402), name, sum))

	-- troops
	local panel_troops = list:getChildByName("Panel_troops")
	local troops_type = panel_troops:getChildByName("Panel_content"):getChildByName("Label_type")
	local troops_num = panel_troops:getChildByName("Panel_content"):getChildByName("Label_num")
	troops_type:setString(hp.lang.getStrByID(11403))
	troops_num:setString(hp.lang.getStrByID(11404))

	local list_troops = panel_troops:getChildByName("ListView_troops")
	local baseItem = list_troops:getItem(0):clone()
	list_troops:removeAllItems()

	-- 11405
	for i,v in ipairs(troops) do
		if v ~= 0 then
			local item = baseItem:clone()
			if i%2 ~= 0 then
				item:getChildByName("Panel_frame"):getChildByName("Image_line"):setVisible(false)
			end
			item:getChildByName("Panel_content"):getChildByName("Label_type"):setString(hp.lang.getStrByID(11404 + i))
			item:getChildByName("Panel_content"):getChildByName("Label_num"):setString(v)
			list_troops:pushBackCustomItem(item)
		end
	end

	-- adaption
	local panel_frame = panel_troops:getChildByName("Panel_frame")
	local rt = panel_frame:getChildByName("Image_leftTop")
	local t = panel_frame:getChildByName("Image_top")
	local lt = panel_frame:getChildByName("Image_rightTop")
	local l = panel_frame:getChildByName("Image_left")
	local c = panel_frame:getChildByName("Image_center")
	local r = panel_frame:getChildByName("Image_right")

	local num = #list_troops:getItems()
	if num > 1 then
		local addHeight = (num - 1) * list_troops:getItem(0):getSize().height

		local size = panel_troops:getSize()
		size.height = size.height + addHeight
		panel_troops:setSize(size)

		local size = list_troops:getSize()
		size.height = size.height + addHeight
		list_troops:setSize(size)

		troops_type:setPositionY(troops_type:getPositionY() + addHeight)
		troops_num:setPositionY(troops_num:getPositionY() + addHeight)

		rt:setPositionY(rt:getPositionY() + addHeight)
		t:setPositionY(t:getPositionY() + addHeight)
		lt:setPositionY(lt:getPositionY() + addHeight)

		l:setPositionY(l:getPositionY() + addHeight / 2)
		c:setPositionY(c:getPositionY() + addHeight / 2)
		r:setPositionY(r:getPositionY() + addHeight / 2)

		local size = l:getSize()
		size.height = size.height + addHeight
		l:setSize(size)
		r:setSize(size)
		local size = c:getSize()
		size.height = size.height + addHeight
		c:setSize(size)
	end

	-- del
	local function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end

	local panel_oper = list:getChildByName("Panel_oper")
	panel_oper:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(1221))

	local button_del = panel_oper:getChildByName("Panel_content"):getChildByName("Image_delete")
	button_del:addTouchEventListener(delBtnOnTouched)

	-- addCCNode
	-- ======================
	self:addCCNode(widget)
end