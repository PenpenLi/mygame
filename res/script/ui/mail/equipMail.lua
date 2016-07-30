--
-- ui/mail/equipMail.lua
-- 装备邮件
--===================================
require "ui/frame/popFrame"
require "ui/UI"

UI_equipMail = class("UI_equipMail", UI)


--init
function UI_equipMail:init(Info, mailType_, mailIndex)

	-- ui
	-- ===============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipMail.json")
	
	-- 基本信息设置
	local Panel_item = wigetRoot:getChildByName("ListView"):getChildByName("Panel_item")
	
	Panel_item:getChildByName("Panel_cont_0"):getChildByName("Label_info"):setString(Info.content)
	
	local Panel_cont_1 = Panel_item:getChildByName("Panel_cont_1")
	Panel_cont_1:getChildByName("Label_equipInfo"):setString(hp.gameDataLoader.getInfoBySid("equip", Info.equipSid).name)
	Panel_cont_1:getChildByName("Label_equipDesc"):setString(hp.gameDataLoader.getInfoBySid("equip", Info.equipSid).desc)
	Panel_cont_1:getChildByName("Image_equip"):loadTexture(config.dirUI.equip .. Info.equipSid .. ".png")
	Panel_cont_1:getChildByName("Image_fram"):loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, Info.quality))

	local Panel_cont_2 = Panel_item:getChildByName("Panel_cont_2")
	Panel_cont_2:getChildByName("Label_attri"):setString(hp.lang.getStrByID(7911))
	Panel_cont_2:getChildByName("Label_value"):setString(hp.lang.getStrByID(7912))

	local Panel_cont_3 = Panel_item:getChildByName("Panel_cont_3")
	Panel_cont_3:getChildByName("Label_reward"):setString(hp.lang.getStrByID(7913))
	Panel_cont_3:getChildByName("Label_heroXP"):setString(hp.lang.getStrByID(7914))
	Panel_cont_3:getChildByName("Label_heroXPNum"):setString("+" .. hp.gameDataLoader.getInfoBySid("equip", Info.equipSid).exp)

	Panel_item:getChildByName("Panel_cont_3"):getChildByName("Label_viewItem"):setString(hp.lang.getStrByID(7915))
	Panel_item:getChildByName("Panel_cont_3"):getChildByName("Label_delete"):setString( hp.lang.getStrByID(1221))

	-- 装备属性信息设置
	local equipInfo = hp.gameDataLoader.getInfoBySid("equip", Info.equipSid)
	local equipAttr = {}

	-- 装备属性获取
	if equipInfo.type1 > 0 then
		equipAttr[1] = {}
		equipAttr[1].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type1).desc
		equipAttr[1].value = "+" .. equipInfo.value1[Info.quality] / 100 .. "%"
	end

	if equipInfo.type2 > 0 then
		equipAttr[2] = {}
		equipAttr[2].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type2).desc
		equipAttr[2].value = "+" .. equipInfo.value2[Info.quality] / 100 .. "%"
	end

	if equipInfo.type3 > 0 then
		equipAttr[3] = {}
		equipAttr[3].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type3).desc
		equipAttr[3].value = "+" .. equipInfo.value3[Info.quality] / 100 .. "%"
	end

	if equipInfo.type4 > 0 then
		equipAttr[4] = {}
		equipAttr[4].type = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type4).desc
		equipAttr[4].value = "+" .. equipInfo.value4[Info.quality] / 100 .. "%"
	end

	-- 动态添加装备属性数据
	local baseItem = Panel_item:getChildByName("Panel_contItem2")
	local baseLine = Panel_item:getChildByName("Panel_framItem2")
	local addHeight = (table.getn(equipAttr) - 1) * baseItem:getSize().height

	for i,v in ipairs(equipAttr) do
		if i == 1 then
			baseItem:getChildByName("Label_name"):setString(equipAttr[i].type)
			baseItem:getChildByName("Label_col"):setString(equipAttr[i].value)
		else
			-- 数据
			local item = baseItem:clone()
			item:getChildByName("Label_name"):setString(equipAttr[i].type)
			item:getChildByName("Label_col"):setString(equipAttr[i].value)
			item:setPositionY(item:getPositionY() - (i - 1) * item:getSize().height)
			Panel_item:addChild(item)
			-- 下划线
			local line = baseLine:clone()
			line:setPositionY(line:getPositionY() - (i - 1) * line:getSize().height)
			Panel_item:addChild(line)
		end
	end

	-- 调整总大小
	local size
	size = Panel_item:getSize()
	size.height = size.height + addHeight
	Panel_item:setSize(size)

	-- 下调后面内容背景位置
	local lastFrame = Panel_item:getChildByName("Panel_framBg_2")
	local lastContent = Panel_item:getChildByName("Panel_cont_3")
	lastFrame:setPositionY(lastFrame:getPositionY() - addHeight)
	lastContent:setPositionY(lastContent:getPositionY() - addHeight)

	-- 更改属性背景大小
	local frame = Panel_item:getChildByName("Panel_framBg_1")

	local bottom_left = frame:getChildByName("Image_bg_5")
	local bottom_center = frame:getChildByName("Image_bg_6")
	local bottom_right = frame:getChildByName("Image_bg_7")
	bottom_left:setPositionY(bottom_left:getPositionY() - addHeight)
	bottom_center:setPositionY(bottom_center:getPositionY() - addHeight)
	bottom_right:setPositionY(bottom_right:getPositionY() - addHeight)

	local middle_left = frame:getChildByName("Image_bg_2")
	local middle_center = frame:getChildByName("Image_bg_3")
	local middle_right = frame:getChildByName("Image_bg_4")
	middle_left:setPositionY(middle_left:getPositionY() - addHeight / 2)
	middle_center:setPositionY(middle_center:getPositionY() - addHeight / 2)
	middle_right:setPositionY(middle_right:getPositionY() - addHeight / 2)

	size = middle_left:getSize()
	size.height = size.height + addHeight
	middle_left:setSize(size)
	middle_right:setSize(size)

	size = middle_center:getSize()
	size.height = size.height + addHeight
	middle_center:setSize(size)

	-- 拉高所有项
	for i,v in ipairs(Panel_item:getChildren()) do
		v:setPositionY(v:getPositionY() + addHeight)
	end
		
	-- 显示装备
	function viewBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local equipBag = player.equipBag
			local equip = equipBag.getEquipById(Info.equipId) 
			if equip ~= nil then
				require("ui/hero/dressEquip")
				local equipTypes = {2,1,3,4,5,4}
				local equipIndex = 0
				local eq = hp.gameDataLoader.getInfoBySid("equip",Info.equipSid)
				local upEquips = player.equipBag.getEquips_equiped()
				for i,v in ipairs(equipTypes) do
					if eq.type == v then
						equipIndex = i
						if upEquips[i] == null then
							break
						end
					end
				end

				if eq ~= nil then
					local ui = UI_dressEquip.new(nil,equipIndex,eq.type)
					self:addUI(ui)
				end	
			else
				require "ui/msgBox/msgBox"
				self:addModalUI(UI_msgBox.new(
					hp.lang.getStrByID(6034),
					hp.lang.getStrByID(7916),
					hp.lang.getStrByID(6035)))
			end
		end
	end
	
	local viewBtn = Panel_item:getChildByName("Panel_cont_3"):getChildByName("Image_viewItem")
	viewBtn:addTouchEventListener(viewBtnOnTouched)

	-- 删除邮件
	function delBtnOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			self:close()
			player.mailCenter.deleteMail(mailType_, {mailIndex})
		end
	end
	
	local delBtn = Panel_item:getChildByName("Panel_cont_3"):getChildByName("ImageView_delete")
	delBtn:addTouchEventListener(delBtnOnTouched)
	
	-- addCCNode
	-- ===============================
	self:addCCNode(wigetRoot)
end
