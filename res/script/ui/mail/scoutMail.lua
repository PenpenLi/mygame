--
-- ui/mail/scoutMail.lua
-- 侦察
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_scoutMail = class("UI_scoutMail", UI)


--init
function UI_scoutMail:init(mailInfo, mailType_, mailIndex)

	-- 设置数据
	local function setInfo(wiget, data)
		for i,v in ipairs(data) do
			-- 测试
			if v.id > 10000 then
				v.id = 5
			end
			local name
			if v.id <= 5 then
				name = hp.gameDataLoader.getInfoBySid("armyType", v.id).name
			else
				name = hp.gameDataLoader.getInfoBySid("army", v.id).name
			end
			wiget[i]:setString(string.format(hp.lang.getStrByID(8011), name) .. v.num)
		end
	end
	
	-- 自适应
	local function adaption(panel, frame, content, list)
		local len = table.getn(list:getItems()) - 1
		-- 未改变
		if len == 0 then
			return
		end
		-- 高度增量
		local height = len * list:getItem(0):getSize().height
		local size
		-- 面板大小
		size = panel:getSize()
		size.height = size.height + height
		panel:setSize(size)
		-- 列表大小
		size = list:getSize()
		size.height = size.height + height
		list:setSize(size)
		-- 背景大小
		local left = frame:getChildByName("Image_left")
		local right = frame:getChildByName("Image_right")
		local center = frame:getChildByName("Image_center")
		size = left:getSize()
		size.height = size.height + height
		left:setSize(size)
		right:setSize(size)
		size = center:getSize()
		size.height = size.height + height
		center:setSize(size)
		-- 改变位置
		local y 
		y = left:getPositionY() + height / 2
		left:setPositionY(y)
		right:setPositionY(y)
		center:setPositionY(y)
		y = y + size.height / 2
		frame:getChildByName("Image_leftTop"):setPositionY(y)
		frame:getChildByName("Image_top"):setPositionY(y)
		frame:getChildByName("Image_rightTop"):setPositionY(y)
		frame:getChildByName("Image_titleBg"):setPositionY(y + 8)
		content:getChildByName("Label_title"):setPositionY(y + 5)
	end

	-- 服务器数据格式

	-- 侦查城市
	-- [0,5,"邰却牧","骆谢燕帮","不足1000",	-- 1~5
	-- [846271,685841,685841,685841],  -- 资源 6
	-- "351041",  -- 银币 7
	-- [2001,"不足1000",10004,"不足1000"], -- 兵种 （lv>=5, lv>=2, lv<2）8
	-- "尧焘",0,0,"",[],[], -- 英雄，等级(0不能侦查),援军数量，援军兵力，增援兵种，增援玩家 9~14
	-- [1001,9,1002,9,1007,9,1016,1,1018,9,1019,5,1021,1,1022,1], -- 建筑，等级 15
	-- [52,3,1,3,11,3,21,3] -- buff, 16

	-- 侦查野外部队
	-- 1,5,"hw7","","不足1000", -- 1~5
	-- [1001,"不足1000",2001,"不足1000"], -- 兵种 6
	-- "蔡文姬",0,[] -- 英雄，等级，buff 7~9
	
	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "scoutMail.json")
	local listRoot = wigetRoot:getChildByName("ListView_root")

	-- 标题信息设置
	-- ===============================
	local panel_title = listRoot:getChildByName("Panel_title")
	panel_title:getChildByName("Panel_content"):getChildByName("Label_info"):setString(hp.lang.getStrByID(8001))

	-- 描述信息设置
	-- ===============================
	local panel_desc = listRoot:getChildByName("Panel_desc")
	local content_desc = panel_desc:getChildByName("Panel_content")

	-- 数据准备
	local annex = mailInfo.annex
	-- 侦查失败
	if annex == nil or table.getn(annex) == 0 then
		-- 反向移除 or 移除后项递减
		listRoot:removeItem(5)
		listRoot:removeItem(4)
		listRoot:removeItem(3)
		listRoot:removeItem(2)

		content_desc:getChildByName("Label_text1"):setString(hp.lang.getStrByID(8018))
	else
		local scoutType = annex[1]
		local scoutLv = annex[2]

		content_desc:getChildByName("Label_text1"):setString(hp.lang.getStrByID(8008))
		content_desc:getChildByName("Label_text2"):setString(string.format(hp.lang.getStrByID(8011) ,hp.lang.getStrByID(8009)))
		local descInfo
		if annex[4] == nil or annex[4] == "" then
			descInfo = annex[3]
		else
			descInfo = string.format(hp.lang.getStrByID(8010), annex[4]) .. annex[3]
		end
		content_desc:getChildByName("Label_info"):setString(descInfo)

		-- 军队信息设置
		-- ===============================
		local panel_army = listRoot:getChildByName("Panel_army")
		-- 数据准备
		local heroName
		local heroLv
		local heroState
		local army1Data
		local units1Data
		if scoutType == 0 then
			heroName = annex[9]
			heroLv = annex[10]
			heroState = annex[17]
			army1Data = annex[5]
			units1Data = annex[8]
		else
			heroName = annex[7]
			heroLv = annex[8]
			army1Data = annex[5]
			units1Data = annex[6]
			heroState = annex[10]
		end
		-- 敌军信息
		local content_enemy = panel_army:getChildByName("Panel_enemyContent")
		content_enemy:getChildByName("Label_title"):setString(hp.lang.getStrByID(8002))
		-- 武将
		local heroInfo = string.format(hp.lang.getStrByID(8011), hp.lang.getStrByID(8031))
		if heroName == nil or heroName == "" then
			if scoutLv < 5 then
				heroInfo = heroInfo .. hp.lang.getStrByID(7956)
			else
				heroInfo = heroInfo .. hp.lang.getStrByID(8019)
			end
		else
			heroInfo =  heroInfo .. heroName
			if heroLv ~= nil and heroLv ~= 0 then
				heroInfo = heroInfo .. " " .. string.format(hp.lang.getStrByID(2017), heroLv)
			end
			if heroState == 1 then
				heroInfo = heroInfo .. hp.lang.getStrByID(8020)
			end
		end
		
		content_enemy:getChildByName("Label_heroText"):setString(heroInfo)
		-- 兵力
		content_enemy:getChildByName("Label_armyText"):setString(hp.lang.getStrByID(5250) .. army1Data)
		-- 兵种
		if scoutLv >= 2 then
			-- 控件表
			local list_units = {}
			list_units[1] = content_enemy:getChildByName("Label_army1Text")
			list_units[2] = content_enemy:getChildByName("Label_army2Text")
			list_units[3] = content_enemy:getChildByName("Label_army3Text")
			list_units[4] = content_enemy:getChildByName("Label_army4Text")
			list_units[5] = content_enemy:getChildByName("Label_army5Text")
			-- 数据表
			local units = {}
			for i = 1, table.getn(units1Data), 2 do
				local unit = {}
				unit.id = units1Data[i]
				unit.num = units1Data[i + 1]
				units[table.getn(units) + 1] = unit
			end
			-- 添加数据
			setInfo(list_units, units)
		end
		-- 援军信息
		local content_reinforcements = panel_army:getChildByName("Panel_reinforcementsContent")
		local frame_reinforcements = panel_army:getChildByName("Panel_reinforcementsFrame")
		content_reinforcements:getChildByName("Label_title"):setString(hp.lang.getStrByID(8003))

		if scoutLv >= 3 and scoutType == 0 then
			if annex[11] ~= nil and annex[11] > 0 then
				-- 军队数量
				content_reinforcements:getChildByName("Label_troopsText"):setString(string.format(hp.lang.getStrByID(8011), hp.lang.getStrByID(8012)) .. annex[11])
				-- 玩家
				local playerName = string.format(hp.lang.getStrByID(8011), hp.lang.getStrByID(8014))
				if #annex[14] == 0 then
					content_reinforcements:getChildByName("Label_lordText"):setString(playerName .. hp.lang.getStrByID(7956))
				else
					for i,v in ipairs(annex[14]) do
						playerName = playerName .. v
						if i ~= #annex[14] then
							playerName = playerName .. hp.lang.getStrByID(8021)
						end
					end
					if #playerName > 22 then
						content_reinforcements:getChildByName("Label_lordText"):setString(hp.common.utf8_strSub(playerName, 22) .. hp.lang.getStrByID(8022))
					else
						content_reinforcements:getChildByName("Label_lordText"):setString(playerName)
					end
				end
				-- 兵力
				if annex[12] == nil or annex[12] == "" then
					content_reinforcements:getChildByName("Label_armyText"):setString(hp.lang.getStrByID(5250) .. hp.lang.getStrByID(7956))
				else
					content_reinforcements:getChildByName("Label_armyText"):setString(hp.lang.getStrByID(5250) .. annex[12])
				end
				-- 兵种
				if scoutLv >= 4 then
					-- 控件表
					local list_units = {}
					list_units[1] = content_reinforcements:getChildByName("Label_army1Text")
					list_units[2] = content_reinforcements:getChildByName("Label_army2Text")
					list_units[3] = content_reinforcements:getChildByName("Label_army3Text")
					list_units[4] = content_reinforcements:getChildByName("Label_army4Text")
					-- 数据表
					local units = {}
					for i = 1, table.getn(annex[13]), 2 do
						local unit = {}
						unit.id = annex[13][i]
						if scoutLv >= 6 then
							unit.num = annex[13][i + 1]
						else
							unit.num = hp.lang.getStrByID(7956)
						end
						units[table.getn(units) + 1] = unit
					end
					-- 添加数据
					setInfo(list_units, units)
				end
			else
				content_reinforcements:getChildByName("Label_troopsText"):setString(hp.lang.getStrByID(8015))
			end
		else
			if scoutType == 1 then
				content_reinforcements:getChildByName("Label_troopsText"):setString(hp.lang.getStrByID(8015))
			else
				content_reinforcements:getChildByName("Label_troopsText"):setString(hp.lang.getStrByID(8013))
			end
		end

		-- buff信息设置
		-- ===============================
		local panel_buff = listRoot:getChildByName("Panel_buff")
		if scoutLv < 10  then
			listRoot:removeItem(listRoot:getIndex(panel_buff))
		else
			local content_buff = panel_buff:getChildByName("Panel_content")
			local listview_buff = panel_buff:getChildByName("ListView_buffList")
			local item_buff = listview_buff:getChildByName("Panel_item"):clone()
			content_buff:getChildByName("Label_title"):setString(hp.lang.getStrByID(8004))
			-- 数据准备
			local buffData
			if scoutType == 0 then
				buffData = annex[16]
			else
				buffData = annex[9]
			end
			if buffData ~= nil and table.getn(buffData) > 0 then
				local buff = {}
				for i = 1, table.getn(buffData), 2 do
					local aBuff = {}
					aBuff.name = hp.gameDataLoader.getInfoBySid("attr", buffData[i]).desc
					aBuff.attr = string.format(hp.lang.getStrByID(8016), buffData[i + 1]) .. "%"
					buff[table.getn(buff) + 1] = aBuff
				end
				-- 动态添加数据
				listview_buff:removeAllItems()
				for i = 1, table.getn(buff), 2 do
					local temp_item = item_buff:clone()
					temp_item:getChildByName("Panel_content"):getChildByName("Label_text1"):setString(string.format(hp.lang.getStrByID(8011), buff[i].name))
					temp_item:getChildByName("Panel_content"):getChildByName("Label_info1"):setString(buff[i].attr)
					-- 尝试添加
					if buff[i + 1] ~= nil then
						temp_item:getChildByName("Panel_content"):getChildByName("Label_text2"):setString(string.format(hp.lang.getStrByID(8011), buff[i + 1].name))
						temp_item:getChildByName("Panel_content"):getChildByName("Label_info2"):setString(buff[i + 1].attr)
					end
					listview_buff:pushBackCustomItem(temp_item)
				end
				-- 自适应
				adaption(panel_buff, panel_buff:getChildByName("Panel_frame"), content_buff, listview_buff)
			else
				content_buff:getChildByName("Label_tips"):setString(hp.lang.getStrByID(8017))
			end
		end

		-- 资源信息设置
		-- ===============================
		local panel_res = listRoot:getChildByName("Panel_resource")
		if scoutType == 0 then
			local content_res = panel_res:getChildByName("Panel_content")
			content_res:getChildByName("Label_title"):setString(hp.lang.getStrByID(8005))
			content_res:getChildByName("Label_stoneText"):setString(hp.lang.getStrByID(5265))
			content_res:getChildByName("Label_woodText"):setString(hp.lang.getStrByID(5264))
			content_res:getChildByName("Label_ironText"):setString(hp.lang.getStrByID(5266))
			content_res:getChildByName("Label_foodText"):setString(hp.lang.getStrByID(5262))
			content_res:getChildByName("Label_silverText"):setString(hp.lang.getStrByID(5263))
			-- 食物、木头、石头、铁
			content_res:getChildByName("Label_stoneInfo"):setString(annex[6][3])
			content_res:getChildByName("Label_woodInfo"):setString(annex[6][2])
			content_res:getChildByName("Label_ironInfo"):setString(annex[6][4])
			content_res:getChildByName("Label_foodInfo"):setString(annex[6][1])
			if annex[7] == nil or annex[7] == "" then
				content_res:getChildByName("Label_silverInfo"):setString(hp.lang.getStrByID(8013))
			else
				content_res:getChildByName("Label_silverInfo"):setString(annex[7])
			end
		else
			listRoot:removeItem(listRoot:getIndex(panel_res))
		end

		-- 建筑信息设置
		-- ===============================
		local panel_building = listRoot:getChildByName("Panel_building")
		if scoutLv < 9 then
			listRoot:removeItem(listRoot:getIndex(panel_building))
		else
			if scoutType == 0 then
				local content_building = panel_building:getChildByName("Panel_content")
				local list_building = panel_building:getChildByName("ListView_buildingList")
				local item_building = list_building:getItem(0):clone()
				content_building:getChildByName("Label_title"):setString(hp.lang.getStrByID(8007))

				-- 动态添加数据
				list_building:removeAllItems()
				for i = 1, table.getn(annex[15]), 2 do
					local temp_item = item_building:clone()
					local temp_content = temp_item:getChildByName("Panel_content")
					temp_content:getChildByName("Label_buidingText"):setString(hp.gameDataLoader.getInfoBySid("building", annex[15][i]).name)
					temp_content:getChildByName("Label_buidingInfo"):setString(string.format(hp.lang.getStrByID(2017), annex[15][i + 1]))
					if i + 1 == table.getn(annex[15]) then
						-- 隐藏下划线
						temp_item:getChildByName("Panel_frame"):setVisible(false)
					end
					list_building:pushBackCustomItem(temp_item)
				end
				-- 自适应
				adaption(panel_building, panel_building:getChildByName("Panel_frame"), content_building, list_building)
			else
				listRoot:removeItem(listRoot:getIndex(panel_building))
			end
		end
	-- 侦查是否成功 end
	end

	-- 删除按钮设置
	-- ===============================
	local panel_oper = listRoot:getChildByName("Panel_oper")
	panel_oper:getChildByName("Panel_content"):getChildByName("Label_deleteText"):setString(hp.lang.getStrByID(1221))
	
	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end

	local button_del = panel_oper:getChildByName("Panel_content"):getChildByName("Image_delete")
	button_del:addTouchEventListener(delBtnOnTouched)

	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end