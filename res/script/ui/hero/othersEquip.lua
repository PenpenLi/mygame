--
-- ui/hero/othersEquip.lua
-- 他人装备信息
--===================================

require "ui/frame/popFrame"
require "ui/UI"

UI_othersEquip = class("UI_othersEquip", UI)

function UI_othersEquip:init(equipInfo_)

	-- [20002,2,2,[114,154,124]]

	local sid = equipInfo_[1]
	local id = equipInfo_[2]
	local lv = equipInfo_[3] + 1
	local gemInfo = equipInfo_[4]
	local equipInfo = hp.gameDataLoader.getInfoBySid("equip", sid)

	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipInfo2.json")
	local uiFrame = UI_popFrame.new(widget, hp.lang.getStrByID(2908))

	local list = widget:getChildByName("ListView_root")

	-- info panel
	local content_info = list:getItem(0):getChildByName("Panel_content")
	content_info:getChildByName("Image_icon_bg"):loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, lv))
	content_info:getChildByName("Image_icon_bg"):getChildByName("Image_icon"):loadTexture(config.dirUI.equip .. sid .. ".png")
	content_info:getChildByName("Image_name"):getChildByName("Label_name"):setString(equipInfo.name)
	content_info:getChildByName("Label_desc"):setString(equipInfo.desc)
	content_info:getChildByName("Label_mustlv"):setString(string.format(hp.lang.getStrByID(3503), equipInfo.mustLv))

	-- attribute panel
	local baseItem = list:getItem(2):clone()
	if equipInfo.type1 ~= -1 then
		local attributeInfo = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type1)
		local item = list:getItem(2)

		item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(attributeInfo.desc)
		if equipInfo.value1[lv] > 0 then
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString("+" .. equipInfo.value1[lv] / 100 .. "%")
		else
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString(equipInfo.value1[lv] / 100 .. "%")
		end
	end

	if equipInfo.type2 ~= -1 then
		local attributeInfo = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type2)
		local item = baseItem:clone()
		list:pushBackCustomItem(item)

		item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(attributeInfo.desc)
		if equipInfo.value2[lv] > 0 then
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString("+" .. equipInfo.value2[lv] / 100 .. "%")
		else
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString(equipInfo.value2[lv] / 100 .. "%")
		end
	end

	if equipInfo.type3 ~= -1 then
		local attributeInfo = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type3)
		local item = baseItem:clone()
		list:pushBackCustomItem(item)

		item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(attributeInfo.desc)
		if equipInfo.value3[lv] > 0 then
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString("+" .. equipInfo.value3[lv] / 100 .. "%")
		else
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString(equipInfo.value3[lv] / 100 .. "%")
		end
	end

	if equipInfo.type4 ~= -1 then
		local attributeInfo = hp.gameDataLoader.getInfoBySid("attr", equipInfo.type4)
		local item = baseItem:clone()
		list:pushBackCustomItem(item)

		item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(attributeInfo.desc)
		if equipInfo.value4[lv] > 0 then
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString("+" .. equipInfo.value4[lv] / 100 .. "%")
		else
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString(equipInfo.value4[lv] / 100 .. "%")
		end
	end

	for i,v in ipairs(gemInfo) do
		if v ~= 0 then
			local gemInfo = hp.gameDataLoader.getInfoBySid("gem", v)
			local attributeInfo = hp.gameDataLoader.getInfoBySid("attr", gemInfo.key[1])

			local item = baseItem:clone()
			list:pushBackCustomItem(item)

			item:getChildByName("Panel_content"):getChildByName("Label_name"):setString(attributeInfo.desc)
			item:getChildByName("Panel_content"):getChildByName("Label_value"):setString("+" .. gemInfo.value[1] / 100 .. "%")
		end
	end

	self:addChildUI(uiFrame)
	self:addCCNode(widget)
end