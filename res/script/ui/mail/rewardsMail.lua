--
-- ui/mail/rewardsMail.lua
-- 奖励邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_rewardsMail = class("UI_rewardsMail", UI)

function UI_rewardsMail:init(mailInfo, mailType, mailIndex)

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "rewardsMailUi.json")

	-- 控件
	local listviewRoot = wigetRoot:getChildByName("ListView_root")
	local panel_head = listviewRoot:getChildByName("Panel_head")
	local panel_desc = listviewRoot:getChildByName("Panel_desc")
	local panel_rewards = listviewRoot:getChildByName("Panel_rewards")
	local panel_oper = listviewRoot:getChildByName("Panel_oper")

	-- 信息设置
	panel_desc:getChildByName("Panel_content"):getChildByName("Label_title"):setString(hp.lang.getStrByID(10104))
	panel_desc:getChildByName("Panel_content"):getChildByName("Label_info2"):setString(hp.lang.getStrByID(10106))
	panel_rewards:getChildByName("Panel_content"):getChildByName("Label_title"):setString(hp.lang.getStrByID(10105))
	panel_oper:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(1221))

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

		local panelSize = panel_rewards:getSize()
		panelSize.height = panelSize.height + height
		panel_rewards:setSize(panelSize)

		local content = panel_rewards:getChildByName("Panel_content")
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

	if mailInfo.type == 19 then

		-- 积分奖励

		--	[LUA-cclog_] Http response: {"rst":{"mail":[[25,19,0,"null","个人活动|积分奖励","
		--	",[1408449600000,1408532400000,8000,[20001,1],1408522242,1]],"len":"0","result"
		--	:0},"heart":{}}
		
		panel_head:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(10101) .. hp.lang.getStrByID(10102))
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_info1"):setString(hp.lang.getStrByID(10108))

		-- 积分
		local score = mailInfo.annex[3]
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_score"):setString(score)

		-- 日期
		local start_time = os.date("%Y/%m/%d", mailInfo.annex[1] / 1000)
		local end_time = os.date("%Y/%m/%d", mailInfo.annex[2] / 1000)
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_time"):setString(start_time .. " - " .. end_time)

		-- 奖励
		local rewards =  {}
		local index = 1
		for i,v in ipairs (mailInfo.annex[4]) do
			-- 每一组数据
			if i % 2 == 0 then
				local res = {}
				res.content = mailInfo.annex[4][i - 1]
				res.num = mailInfo.annex[4][i]
				rewards[index] = res 
				index = index + 1
			end
		end

		-- 动态添加 item
		local listview = panel_rewards:getChildByName("ListView_content")
		local baseItem = listview:getItem(0):clone()
		listview:removeAllItems()

		for i,v in ipairs (rewards) do
			local item = baseItem:clone()
			-- 三种不同奖励类型
			local info
			local url
			if v.content > 20000 then
				info = getInfo(game.data.item, v.content)
				url = config.dirUI.item
			elseif v.content > 10000 then
				info = getInfo(game.data.equipMaterial, v.content)
				url = config.dirUI.material
			elseif v.content > 100 then
				info = getInfo(game.data.gem, v.content)
				url = config.dirUI.gem
			end
			-- 设置信息
			item:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", url, v.content))
			item:getChildByName("Panel_content"):getChildByName("Label_type"):setString(info.name)
			item:getChildByName("Panel_content"):getChildByName("Label_num"):setString(v.num)
			listview:pushBackCustomItem(item)
		end

		-- 自适应高度
		adaption(listview, panel_rewards:getChildByName("Panel_frame"), table.getn(listview:getItems()) - 1, baseItem:getSize().height)

	elseif mailInfo.type == 20 then
		-- 排名奖励

		-- [LUA-cclog_] Http response: {"rst":{"mail":[[40,20,0,"null","个人活动|排名奖励","
		-- ",[1408881600000,1408964400000,61,500,[20001,20052]],1408532406,1]],"len":"0","r
		-- esult":0},"heart":{}}

		panel_head:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(10101) .. hp.lang.getStrByID(10103))
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_info1"):setString(hp.lang.getStrByID(10107))

		-- 排名
		local ranking = mailInfo.annex[3] + 1
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_score"):setString(ranking)

		-- 日期
		local start_time = os.date("%Y/%m/%d", mailInfo.annex[1] / 1000)
		local end_time = os.date("%Y/%m/%d", mailInfo.annex[2] / 1000)
		panel_desc:getChildByName("Panel_content"):getChildByName("Label_time"):setString(start_time .. " - " .. end_time)

		-- 动态添加 item
		local listview = panel_rewards:getChildByName("ListView_content")
		local baseItem = listview:getItem(0):clone()
		listview:removeAllItems()

		-- 钻石
		local goldItem = baseItem:clone()
		goldItem:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(config.dirUI.common .. "gold2.png")
		goldItem:getChildByName("Panel_content"):getChildByName("Label_type"):setString(hp.lang.getStrByID(6018))
		goldItem:getChildByName("Panel_content"):getChildByName("Label_num"):setString(mailInfo.annex[4])
		listview:pushBackCustomItem(goldItem)

		-- 奖励
		for i,v in ipairs (mailInfo.annex[5]) do
			local item = baseItem:clone()
			-- 三种不同奖励类型
			local info
			local url
			if v > 20000 then
				info = getInfo(game.data.item, v)
				url = config.dirUI.item
			elseif v > 10000 then
				info = getInfo(game.data.equipMaterial, v)
				url = config.dirUI.material
			elseif v > 100 then
				info = getInfo(game.data.gem, v)
				url = config.dirUI.gem
			end
			-- 设置信息
			item:getChildByName("Panel_content"):getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", url, v))
			item:getChildByName("Panel_content"):getChildByName("Label_type"):setString(info.name)
			item:getChildByName("Panel_content"):getChildByName("Label_num"):setString(1)
			listview:pushBackCustomItem(item)
		end

		-- 自适应高度
		adaption(listview, panel_rewards:getChildByName("Panel_frame"), table.getn(listview:getItems()) - 1, baseItem:getSize().height)
	end

	local function deleteMail(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType, {mailIndex})
		end
	end
	panel_oper:getChildByName("Panel_content"):getChildByName("Image_delete"):addTouchEventListener(deleteMail)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end