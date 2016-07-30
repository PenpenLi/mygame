--
-- ui/mail/crownMail.lua
-- 奖励邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_crownMail = class("UI_crownMail", UI)

function UI_crownMail:init(mailInfo, mailType, mailIndex)
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "crownMailUi.json")

	-- 控件
	local listview_root = wigetRoot:getChildByName("ListView_root")
	local panel_head = listview_root:getChildByName("Panel_head")
	local panel_desc = listview_root:getChildByName("Panel_desc")
	local panel_attribute = listview_root:getChildByName("Panel_attribute")
	local panel_oper = listview_root:getChildByName("Panel_oper")

	-- 查询表信息
	local function getInfo(tab, sid)
		for i, info in ipairs(tab) do
			if sid == info.sid then
				return info
			end
		end
		return nil
	end

	-- 自适应高度
	local function adaption(listview, frame, itemNum, itemHeight)
		if itemNum == 0 then
			return
		end

		local height = itemNum * itemHeight

		local panelSize = panel_attribute:getSize()
		panelSize.height = panelSize.height + height
		panel_attribute:setSize(panelSize)

		local content = panel_attribute:getChildByName("Panel_content")
		local contentSize = content:getSize()
		contentSize.height = contentSize.height + height
		content:setSize(contentSize)

		local frameSize = frame:getSize()
		frameSize.height = frameSize.height + height
		frame:setSize(frameSize)

		local listviewSize = listview:getSize()
		listviewSize.height = listviewSize.height + height
		listview:setSize(listviewSize)

		local borderSize = frame:getChildByName("Image_left"):getSize()
		borderSize.height = borderSize.height + height
		frame:getChildByName("Image_left"):setSize(borderSize)
		frame:getChildByName("Image_right"):setSize(borderSize)

		frame:getChildByName("Image_leftTop"):setPositionY((frameSize.height + borderSize.height) / 2)
		frame:getChildByName("Image_top"):setPositionY((frameSize.height + borderSize.height) / 2)
		frame:getChildByName("Image_rightTop"):setPositionY((frameSize.height + borderSize.height) / 2)

		local centerSize = frame:getChildByName("Image_center"):getSize()
		centerSize.height = centerSize.height + height
		frame:getChildByName("Image_center"):setSize(centerSize)

		frame:getChildByName("Image_left"):setPositionY(frameSize.height / 2)
		frame:getChildByName("Image_right"):setPositionY(frameSize.height / 2)
		frame:getChildByName("Image_center"):setPositionY(frameSize.height / 2)

		local title = content:getChildByName("Label_title")
		title:setPositionY(title:getPositionY() + height)

		frame:getChildByName("Image_titleBg"):setPositionY(frameSize.height)
	end

	-- 控件
	local title = panel_head:getChildByName("Panel_content"):getChildByName("Label_info")
	local title2 = panel_attribute:getChildByName("Panel_content"):getChildByName("Label_title")
	local desc = panel_desc:getChildByName("Panel_content"):getChildByName("Label_info")

	-- 获得国王 & 失去国王
	if mailInfo.type == 21 or mailInfo.type == 22 then

		-- Http response: {"rst":{"mail":[[2,21,0,"null","王位争夺战|获得王位！
		-- ","您获得了王位，拥有了国王的权利！",[],1408678076,1]],"len":"0","result":0},"he
		-- art":{}}

		-- 隐藏无用信息
		listview_root:removeItem(2)
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_info1"):setVisible(false)
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_info2"):setVisible(false)

		-- 设置信息
		if mailInfo.type == 21 then
			title:setString(hp.lang.getStrByID(10201))
		elseif mailInfo.type == 22 then
			title:setString(hp.lang.getStrByID(10202))
		end
		desc:setString(mailInfo.content)

		-- 设置位置
		desc:setAnchorPoint(cc.p(0.5, 0.5))
		desc:setPositionX(game.visibleSize.width / 2 * hp.uiHelper.RA_scaleX)

	-- 获得头衔 & 失去头衔
	elseif mailInfo.type == 23 or mailInfo.type == 24 then

		-- Http response: {"rst":{"mail":[[9,23,0,"null","mail_crown_title_titl
		-- e暗卫","您获得了国王授予的头衔:",[1003],1408691306,1]],"len":"0","result":0},"he
		-- art":{}}

		-- 解析数据
		local sid = mailInfo.annex[1]
		local rank = getInfo(game.data.kingTitle, sid)
		local attributeTab = rank.attrs
		local valueTab = rank.value

		-- 动态添加 item
		local listview = panel_attribute:getChildByName("ListView_content")
		local baseItem = listview:getItem(0):clone()
		listview:removeAllItems()

		for i,v in ipairs (attributeTab) do
			local item = baseItem:clone()
			local label_name = item:getChildByName("Panel_content"):getChildByName("Label_type")
			local label_percent = item:getChildByName("Panel_content"):getChildByName("Label_num")

			local attrsDesc = getInfo(game.data.attr, v).desc
			local percent = valueTab[i] / 100 .. "%"

			if valueTab[i] > 0 then
				percent = "+" .. percent
			else
				label_percent:setColor(cc.c3b(244, 66, 69))
			end

			-- 属性描述、属性百分比
			label_name:setString(attrsDesc)
			label_percent:setString(percent)
			listview:pushBackCustomItem(item)
		end
		adaption(listview, panel_attribute:getChildByName("Panel_frame"), table.getn(listview:getItems()) - 1, baseItem:getSize().height)

		-- 设置信息
		title2:setString(hp.lang.getStrByID(10205))
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_info1"):setString(rank.name)

		if mailInfo.type == 23 then
			title:setString(hp.lang.getStrByID(10203))
			panel_desc:getChildByName("Panel_content"):getChildByName("Label_info"):setString(mailInfo.content)
			panel_desc:getChildByName("Panel_content"):getChildByName("Label_info2"):setVisible(false)
		else
			title:setString(hp.lang.getStrByID(10204))
			local str1
			local str2
			str1, str2 = hp.common.splitString(mailInfo.content, "|")
			panel_desc:getChildByName("Panel_content"):getChildByName("Label_info"):setString(str1)
			panel_desc:getChildByName("Panel_content"):getChildByName("Label_info2"):setString(str2)
		end
	end

	-- 删除邮件
	local function deleteMail(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType, {mailIndex})
		end
	end
	panel_oper:getChildByName("Panel_content"):getChildByName("Image_delete"):addTouchEventListener(deleteMail)
	panel_oper:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(1221))

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end