--
-- ui/activity/unionActivity/member.lua
-- 联盟活动_成员
--=============================================

UI_member = class("UI_member", UI)

local data

function UI_member:init(data_)
	
	data = data_.member

	self:initUI()
end

function UI_member:initUI()
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "unionActivityInfo_member.json")
	local list = widget:getChildByName("ListView_member")

	local titile = list:getItem(0)
	titile:getChildByName("Panel_content"):getChildByName("Label_text"):setString(hp.lang.getStrByID(5650))

	local item = list:getItem(1):clone()

	if #data == 0 or data == nil then
		list:removeItem(1)
	else
		-- insert list
		for i,v in ipairs(data) do
			local temp_item
			if i == 1 then
				temp_item = list:getItem(1)
			elseif i == #data then
				temp_item = item
				list:pushBackCustomItem(temp_item)
			else
				temp_item = item:clone()
				list:pushBackCustomItem(temp_item)
			end
			local temp_content = temp_item:getChildByName("Panel_content")
			temp_content:getChildByName("Image_icon"):loadTexture(config.dirUI.common .. hp.gameDataLoader.getInfoBySid("unionRank", v[1]).image)
			temp_content:getChildByName("Label_name"):setString(v[2])
			temp_content:getChildByName("Label_score"):setString(v[3])
			if i % 2 == 0 then
				temp_item:getChildByName("Panel_frame"):getChildByName("Image_bg"):setVisible(false)
			end
		end
	end

	self:addCCNode(widget)
end