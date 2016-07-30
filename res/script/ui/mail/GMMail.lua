--
-- ui/mail/GMMail.lua
-- GM邮件
--===================================
require "ui/fullScreenFrame"

UI_GMMail = class("UI_GMMail", UI)

-- getInfo
local function getInfo(sid)
	if sid > 20000 then
		return hp.gameDataLoader.getInfoBySid("item", sid), 3
	elseif sid > 1000 then
		return hp.gameDataLoader.getInfoBySid("equipMaterial", sid), 2
	elseif sid > 100 then
		return hp.gameDataLoader.getInfoBySid("gem", sid), 1
	end
end

-- init
function UI_GMMail:init(mailInfo, mailType_, mailIndex)

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "GMMail.json")

	local root = wigetRoot:getChildByName("ListView_root")
	local panel_info = root:getChildByName("Panel_info")
	local panel_oper = root:getChildByName("Panel_oper")
	local panel_input = panel_info:getChildByName("Panel_inputBg")
	local panel_cotent = panel_info:getChildByName("Panel_content")
	local frame_info = panel_info:getChildByName("Panel_framBg")

	local mail_content = panel_info:getChildByName("Panel_content"):getChildByName("Label_info")
	local goods_list = panel_info:getChildByName("ListView_items")
	local good_item = goods_list:getItem(0):clone()

	-- "GM的看好你，赐予你以下奖励。",							mailcontent
	-- [[100,200,300,400,500,600],[20004,10,104,5,2001,8]]		资源、材料宝石

	-- data
	local text = mailInfo.content
	local res = mailInfo.annex[1]
	local goods_ = mailInfo.annex[2]
	local goods = {}

	for i = 1, #goods_, 2 do
		local good = {}
		good.id = goods_[i]
		good.num = goods_[i+1]
		table.insert(goods, good)
	end

	-- base info
	panel_info:getChildByName("Panel_content"):getChildByName("Label_name"):setString(hp.lang.getStrByID(8301))
	panel_info:getChildByName("Panel_content"):getChildByName("Label_title"):setString(hp.lang.getStrByID(8302))
	panel_oper:getChildByName("Panel_content"):getChildByName("Label_delete"):setString(hp.lang.getStrByID(1221))

	-- set goodslist
	goods_list:removeAllItems()

	for i = 1, #res do
		if res[i] ~= 0 then
			local res_info = hp.gameDataLoader.getInfoBySid("resInfo", i)
			local temp_item = good_item:clone()
			local temp_cont = temp_item:getChildByName("Panel_content")
			temp_cont:getChildByName("Image_icon"):loadTexture(config.dirUI.common .. res_info.image)
			temp_cont:getChildByName("Label_text"):setString(res_info.name)
			temp_cont:getChildByName("Label_num"):setString(res[i])
			goods_list:pushBackCustomItem(temp_item)
		end
	end

	for i,v in ipairs (goods) do
		local good_info, good_type
		good_info, good_type = getInfo(v.id)
		local temp_item = good_item:clone()
		local temp_cont = temp_item:getChildByName("Panel_content")
		if good_type == 1 then
			temp_cont:getChildByName("Image_icon"):loadTexture(config.dirUI.gem .. good_info.type ..".png")
		elseif good_type == 2 then
			temp_cont:getChildByName("Image_icon"):loadTexture(config.dirUI.material .. good_info.type ..".png")
		elseif good_type == 3 then
			temp_cont:getChildByName("Image_icon"):loadTexture(config.dirUI.item .. good_info.sid ..".png")
		end
		temp_cont:getChildByName("Label_text"):setString(good_info.name)
		temp_cont:getChildByName("Label_num"):setString(v.num)
		goods_list:pushBackCustomItem(temp_item)
	end

	local addHeight = (#goods_list:getItems() - 1) * good_item:getSize().height

	-- change list size
	local size = goods_list:getSize()
	size.height = size.height + addHeight
	goods_list:setSize(size)

	-- change Y
	panel_input:setPositionY(panel_input:getPositionY() + addHeight)
	panel_cotent:setPositionY(panel_cotent:getPositionY() + addHeight)

	-- set mail content
	mail_content:setString(text)

	local lines = mail_content:getVirtualRenderer():getStringNumLines()
	local addHeight2 = 0
	if lines > 2 then
		addHeight2 = (lines - 2) * 20 * hp.uiHelper.RA_scale

		-- change Y
		mail_content:setPositionY(mail_content:getPositionY() + addHeight2)

		local heroIcon = panel_cotent:getChildByName("Image_heroIcon")
		local heroIconFrame = panel_cotent:getChildByName("img_heroIconFram")
		local name = panel_cotent:getChildByName("Label_name")

		heroIcon:setPositionY(heroIcon:getPositionY() + addHeight2)
		heroIconFrame:setPositionY(heroIconFrame:getPositionY() + addHeight2)
		name:setPositionY(name:getPositionY() + addHeight2)

		-- change input bg
		panel_input:setPositionY(panel_input:getPositionY() + addHeight2)
		local frame7 = panel_input:getChildByName("7")
		local frame8 = panel_input:getChildByName("8")
		local frame9 = panel_input:getChildByName("9")
		frame7:setPositionY(frame7:getPositionY() - addHeight2)
		frame8:setPositionY(frame8:getPositionY() - addHeight2)
		frame9:setPositionY(frame9:getPositionY() - addHeight2)

		local frame4 = panel_input:getChildByName("4")
		local frame5 = panel_input:getChildByName("5")
		local frame6 = panel_input:getChildByName("6")
		frame4:setPositionY(frame4:getPositionY() - addHeight2 / 2)
		frame5:setPositionY(frame5:getPositionY() - addHeight2 / 2)
		frame6:setPositionY(frame6:getPositionY() - addHeight2 / 2)

		local size = frame4:getSize()
		size.height = size.height + addHeight2
		frame4:setSize(size)
		frame6:setSize(size)

		local size = frame5:getSize()
		size.height = size.height + addHeight2
		frame5:setSize(size)	
	end

	-- change panel size
	local size = panel_info:getSize()
	size.height = size.height + addHeight + addHeight2
	panel_info:setSize(size)

	-- change frame Y
	local frame_title = frame_info:getChildByName("Image_titleBg")
	local frame_title2 = frame_info:getChildByName("Image_titleBg2")
	local frame1 = frame_info:getChildByName("1")
	local frame2 = frame_info:getChildByName("2")
	local frame3 = frame_info:getChildByName("3")
	frame_title:setPositionY(frame_title:getPositionY() + addHeight + addHeight2)
	frame_title2:setPositionY(frame_title2:getPositionY() + addHeight)
	frame1:setPositionY(frame1:getPositionY() + addHeight + addHeight2)
	frame2:setPositionY(frame2:getPositionY() + addHeight + addHeight2)
	frame3:setPositionY(frame3:getPositionY() + addHeight + addHeight2)

	local frame4 = frame_info:getChildByName("4")
	local frame5 = frame_info:getChildByName("5")
	local frame6 = frame_info:getChildByName("6")
	frame4:setPositionY(frame4:getPositionY() + (addHeight + addHeight2) / 2)
	frame5:setPositionY(frame5:getPositionY() + (addHeight + addHeight2) / 2)
	frame6:setPositionY(frame6:getPositionY() + (addHeight + addHeight2) / 2)

	-- change frame size
	local size = frame4:getSize()
	size.height = size.height + addHeight + addHeight2
	frame4:setSize(size)
	frame6:setSize(size)

	local size = frame5:getSize()
	size.height = size.height + addHeight + addHeight2
	frame5:setSize(size)

	-- delete mail
	local function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	panel_oper:getChildByName("Panel_content"):getChildByName("ImageView_delete"):addTouchEventListener(delBtnOnTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
