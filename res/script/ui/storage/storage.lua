--
-- ui/storage/storage.lua
-- 仓库主界面
--===================================
require "ui/fullScreenFrame"
require "ui/buildingHeader"

UI_storage = class("UI_storage", UI)

--init
function UI_storage:init(building_)
	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo

	local foodInfo = nil
	local woodInfo = nil
	local rockInfo = nil
	local mineInfo = nil
	for i,v in ipairs(game.data.resInfo) do
		if v.sid==3 then
			foodInfo = v
		elseif v.sid==4 then
			woodInfo = v
		elseif v.sid==5 then
			rockInfo = v
		elseif v.sid==6 then
			mineInfo = v
		end
	end
	local storageInfo = nil
	for i,v in ipairs(game.data.storehouse) do
		if b.lv==v.level then
			storageInfo = v
			break
		end
	end

	local function getProtectRes(res_)
		local resNum = player.getResource(res_)
		if resNum>storageInfo.protectResMax then
			return storageInfo.protectResMax
		end

		return resNum
	end


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "storage.json")
	local listView = widgetRoot:getChildByName("ListView_info")
	local itemDesc = listView:getItem(0)
	local itemName = listView:getItem(1)
	local itemFood = listView:getItem(2)
	local itemWood = listView:getItem(3)
	local itemMine = listView:getItem(4)
	local itemRock = listView:getItem(5)
	local moreInfo = listView:getItem(6)

	-- desc
	local itemCont = itemDesc:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_desc"):setString(bInfo.desc)
	-- titleName
	itemCont = itemName:getChildByName("Panel_cont")
	itemCont:getChildByName("Label_name"):setString(hp.lang.getStrByID(2040))
	-- foodInfo
	itemCont = itemFood:getChildByName("Panel_cont")
	local bgNode =  itemCont:getChildByName("ImageView_bg")
	bgNode:getChildByName("Label_name"):setString(foodInfo.name)
	bgNode:getChildByName("Label_num"):setString(getProtectRes(foodInfo.code))
	-- woodInfo
	itemCont = itemWood:getChildByName("Panel_cont")
	bgNode =  itemCont:getChildByName("ImageView_bg")
	bgNode:getChildByName("Label_name"):setString(woodInfo.name)
	bgNode:getChildByName("Label_num"):setString(getProtectRes(woodInfo.code))
	-- mineInfo
	itemCont = itemMine:getChildByName("Panel_cont")
	bgNode =  itemCont:getChildByName("ImageView_bg")
	bgNode:getChildByName("Label_name"):setString(mineInfo.name)
	bgNode:getChildByName("Label_num"):setString(getProtectRes(mineInfo.code))
	--rockInfo
	itemCont = itemRock:getChildByName("Panel_cont")
	bgNode =  itemCont:getChildByName("ImageView_bg")
	bgNode:getChildByName("Label_name"):setString(rockInfo.name)
	bgNode:getChildByName("Label_num"):setString(getProtectRes(rockInfo.code))

	
	--moreInfo
	moreInfoBtn = moreInfo:getChildByName("Panel_cont"):getChildByName("ImageView_moreInfo")
	local function moreInfoMemuItemOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			
			require "ui/storage/storeInfo"
			local moreInfoBox = UI_storeInfo.new(building_)
			self:addModalUI(moreInfoBox)
			
		end
	end
	moreInfoBtn:addTouchEventListener( moreInfoMemuItemOnTouched )
	
	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addChildUI(uiHeader)
	self:addCCNode(widgetRoot)
end
