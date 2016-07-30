--
-- ui/activity/bossActivity/bossActivity.lua
-- 精英BOSS活动界面
--=============================================

require "ui/fullScreenFrame"

UI_bossActivity = class("UI_bossActivity", UI)

-- 活动数据
local data

-- 初始化
function UI_bossActivity:init()
	-- 活动数据
	local activity = player.bossActivityMgr.getActivity()
	if activity and activity.status ~= BOSS_ACTIVITY_STATUS.CLOSE then
		data = hp.gameDataLoader.getInfoBySid("bossActivity", activity.sid)
	end
	-- 初始化触摸事件
	self:initTouchEvent()
	-- 初始化界面
	self:initUI()
end

-- 初始化触摸事件
function UI_bossActivity:initTouchEvent()
	-- 查看详细
	local function checkDetailsTouch(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)		
		if eventType == TOUCH_EVENT_ENDED then
			local function prepareData()
				local equips = {}
				for i,sid in ipairs(data.equip) do
					local info = hp.gameDataLoader.getInfoBySid("equip", sid)
					table.insert(equips, info)
				end
				return equips
			end
			require "ui/smith/equipDesignDetail"
			local ui = UI_equipDesignDetail.new(0, 0, nil, prepareData())
			self:addChildUI(ui)
		end
	end
	self.checkDetailsTouch = checkDetailsTouch
end

-- 初始化界面
function UI_bossActivity:initUI()
	-- 加载 Json
	-- ===============================
	local widget = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "bossActivity.json")
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(11615), "title1")

	-- 设置数据
	local listview = widget:getChildByName("ListView_root")

	-- 活动内容
	local activity_info = listview:getItem(0)
	local info_content = activity_info:getChildByName("Panel_content")

	-- 基础信息
	if data then
		local startTime = data.startTime
		local endTime = data.endTime
		local time = string.format(hp.lang.getStrByID(11601), startTime[1], startTime[2], startTime[3], endTime[1], endTime[2], endTime[3])

		info_content:getChildByName("Label_title"):setString(data.title)
		info_content:getChildByName("Label_desc"):setString(data.desc)
		info_content:getChildByName("Label_time"):setString(time)

		-- 装备信息
		local function setEquipInfo(childName, index)
			local equip_content = info_content:getChildByName(childName)
			local equip_info = hp.gameDataLoader.getInfoBySid("equip", data.equip[index])
			equip_content:getChildByName("Image_equip"):loadTexture(config.dirUI.equip .. data.equip[index] .. ".png")
			equip_content:getChildByName("Image_nameBg"):getChildByName("Label_name"):setString(equip_info.name)
		end
		setEquipInfo("Image_equip_1", 1)
		setEquipInfo("Image_equip_2", 2)
		setEquipInfo("Image_equip_3", 3)
		setEquipInfo("Image_equip_4", 4)

		-- 查看更多
		local checkDetailsBtn = info_content:getChildByName("Image_checkBtn")
		checkDetailsBtn:addTouchEventListener(self.checkDetailsTouch)
		checkDetailsBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(11602))
	else
		-- 活动未开启
		local label_title = info_content:getChildByName("Label_title")
		local label_text = info_content:getChildByName("Label_desc")
		local bg_title = activity_info:getChildByName("Panel_frame"):getChildByName("Image_titleBg")

		label_title:setString(hp.lang.getStrByID(11619))
		label_text:setString(hp.lang.getStrByID(11620))
		info_content:getChildByName("Label_time"):setVisible(false)

		info_content:getChildByName("Image_equip_1"):setVisible(false)
		info_content:getChildByName("Image_equip_2"):setVisible(false)
		info_content:getChildByName("Image_equip_3"):setVisible(false)
		info_content:getChildByName("Image_equip_4"):setVisible(false)

		info_content:getChildByName("Label_apostrophe"):setVisible(false)
		info_content:getChildByName("Image_checkBtn"):setVisible(false)

		local size = activity_info:getSize()
		size.height = size.height / 2
		activity_info:setSize(size)

		label_title:setPositionY(label_title:getPositionY() - size.height)
		label_text:setPositionY(label_text:getPositionY() - size.height * 1.2)
		label_text:setScale(1.2)
		bg_title:setPositionY(bg_title:getPositionY() - size.height)
	end

	-- 活动说明
	local activity_explain = listview:getItem(1)
	local explain_content = activity_explain:getChildByName("Panel_content")

	explain_content:getChildByName("Label_title"):setString(hp.lang.getStrByID(11603))
	explain_content:getChildByName("Label_title1"):setString(hp.lang.getStrByID(11604))
	explain_content:getChildByName("Label_title2"):setString(hp.lang.getStrByID(11606))
	explain_content:getChildByName("Label_info1"):setString(hp.lang.getStrByID(11605))
	explain_content:getChildByName("Label_info2"):setString(hp.lang.getStrByID(11607))
	explain_content:getChildByName("Label_info3"):setString(hp.lang.getStrByID(11608))

	-- 活动说明（材料）
	local explain_material = listview:getItem(2)
	local material_content = explain_material:getChildByName("Panel_content")

	material_content:getChildByName("Label_title"):setString(hp.lang.getStrByID(11609))
	material_content:getChildByName("Label_info"):setString(hp.lang.getStrByID(11610))

	local material_border = material_content:getChildByName("Image_material")
	material_border:getChildByName("Label_info"):setString(hp.lang.getStrByID(11611))

	-- 活动说明（装备）
	local explain_equip = listview:getItem(3)
	local equip_content = explain_equip:getChildByName("Panel_content")

	equip_content:getChildByName("Label_title"):setString(hp.lang.getStrByID(11613))
	equip_content:getChildByName("Label_info"):setString(hp.lang.getStrByID(11614))

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widget)
end