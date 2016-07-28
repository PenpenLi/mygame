--
-- ui/mainBuilding.lua
-- 医馆界面
--===================================

require "ui/UI"
require "ui/fullScreenFrame"
require "ui/buildingHeader"


UI_hospitalBuilding = class("UI_hospitalBuilding", UI)


local labelNum = {}
local labelNum2 = {}
local listView = nil
local soldier_allNumber ={}
soldier_allNumber_changed = {}
local  treatCostChange =nil
local woundedSoldierMax
local soldierInfo = {}
local treatCost = {0,0,0,0,0}
local resourceNumber = 5




--init
function UI_hospitalBuilding:init(building_)

	-- 点击伤兵
	local function soldierOnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			print("sender:getTag()"..sender:getTag())
			require "ui/hospitalSoldier"
			local ui_ = UI_hospitalSolider.new(sender:getTag(),soldier_allNumber_changed[sender:getTag()] ,soldier_allNumber[sender:getTag()])
			self:addModalUI(ui_)
		end
	end

	-- 更多信息
	local function onMoreInfoTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
	end


	-- data
	-- ===============================
	local b = building_.build
	local bInfo = building_.bInfo
	local imgPath = building_.imgPath



	-- 无伤兵界面
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(bInfo.name)
	local uiHeader = UI_buildingHeader.new(building_)
	print("信息：",b.lv)

	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hospitalBuilding.json")

	local Panel_cost = wigetRoot:getChildByName("Panel_cost")
	local stone = Panel_cost:getChildByName("Label_stone")
	local wood = Panel_cost:getChildByName("Label_wood")
	local iron = Panel_cost:getChildByName("Label_iron")
	local food = Panel_cost:getChildByName("Label_food")
	local coin = Panel_cost:getChildByName("Label_coin")

	local Panel_solider = wigetRoot:getChildByName("Panel_solider")
	local Panel_treat_yes = wigetRoot:getChildByName("Panel_treat_yes")
	local Panel_treat_no = wigetRoot:getChildByName("Panel_treat_no")


	--资源消耗


	--伤兵界面
	local hospitalSoldier = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "hospitalSoldierAll.json")
	listView = hospitalSoldier:getChildByName("ListView_list")
	local container = listView:getChildByName("Panel_horContainer")
	--local totalSoldierNum = listView:getChildByName("Panel_adampt1"):getChildByName("Panel_adampt2"):getChildByName("ImageView_troops"):getChildByName("Label_troops")
	local adampt = container:getChildByName("Panel_adampt")
	local index = 1
	local soldierType = player.getSoldierType()
	for i = 1, table.getn(game.data.army) do
		if game.data.army[i].level == 1 then
			local soldier = adampt:getChildByName(string.format("ImageView_soldier%d", index))

			-- set image
			local soldierImage = soldier:getChildByName("ImageView_soldier")
			soldierImage:loadTexture(string.format("%s/%s", config.dirUI.soldier, game.data.army[i].image))

			-- set clickEvent
			soldierImage:addTouchEventListener(soldierOnTouched)
			--soldier:addTouchEventListener(soldierOnTouched)

			-- set tag
			--print("tag"..soldierImage:getTag())
			soldierImage:setTag(game.data.army[i].type)

			-- set name
			soldier:getChildByName("Label_name"):setString(game.data.army[i].name)

			-- get number label
			print("game.data.army[i].type:"..game.data.army[i].type)
			labelNum[game.data.army[i].type] = soldierImage:getChildByName("ImageView_numberbg1")
			labelNum2[game.data.army[i].type] = soldierImage:getChildByName("ImageView_numberbg2")
			--soldierImage:getChildByName("ImageView_numberbg1"):setVisible(false)

			if index == 3 then
				container = container:clone()
				listView:pushBackCustomItem(container)	
				adampt = container:getChildByName("Panel_adampt")		
				index = 1

			else
				index = index + 1
			end
		end
	end

-- hide redundant ui
	for i = index, 3 do
		adampt:getChildByName(string.format("ImageView_soldier%d", i)):setVisible(false)
	end


	local all_soliderNumber = 0
	-- local army_ = player.getHurtArmy()
	-- if  army_~= nil then
	-- 	for i = 1, player.getSoldierType() do
	-- 		local soldier = army_.army_()[i]
	-- 		if soldier ~= nil then
	-- 			local temp = soldier:getNumber()
	-- 			soldier_allNumber[i] = temp;
	-- 			soldier_allNumber_changed[i] = 0;
	-- 			soldierInfo [i] = player.getArmyInfoByType(i)
	-- 			all_soliderNumber = all_soliderNumber + temp
	-- 			labelNum[i]:getChildByName("Label_number"):setString(tostring(temp))
	-- 			labelNum2[i]:setVisible(false)
	-- 		end
	-- 	end	
	-- end

	if player.getTotalArmy() ~= nil then
		for i = 1, player.getSoldierType() do			
			local temp = player.getTotalArmy():getSoldierNumberByType(i)

				soldier_allNumber[i] = temp;
				soldier_allNumber_changed[i] = 0;
				soldierInfo [i] = player.getArmyInfoByType(i)
				all_soliderNumber = all_soliderNumber + temp
				labelNum[i]:getChildByName("Label_number"):setString(tostring(temp))
				labelNum2[i]:setVisible(false)
		end	
	end


	--可容纳伤兵人数
	woundedSoldierMax = 200
	for i,v in ipairs(game.data.hospital) do
			if v.level==b.lv then
				woundedSoldierMax = v.woundedSoldierMax
				break
			end
	end

	Panel_cost:getChildByName("ImageView_6512"):getChildByName("Label_max"):setString(string.format("0/"..woundedSoldierMax))
	Panel_cost:getChildByName("ImageView_6512"):getChildByName("LoadingBar"):setPercent(0*100/woundedSoldierMax)



	-- register msg
	self:registMsg(hp.MSG.CHANGE_HURT_SOLDIER)

	--调整消耗显示
	function treatCostChange()
		all_soliderNumber=0
		treatCost = {0,0,0,0,0}
		for i,v in ipairs(soldier_allNumber_changed) do
			labelNum[i]:getChildByName("Label_number"):setString(tostring(soldier_allNumber[i]-v))
			labelNum2[i]:getChildByName("Label_number"):setString(tostring(v))
			labelNum2[i]:setVisible(true)
			all_soliderNumber = all_soliderNumber + v
			treatCost[1] =treatCost[1] + v * soldierInfo[i].costs[5]
			treatCost[2] =treatCost[2] + v * soldierInfo[i].costs[4]
			treatCost[3] =treatCost[3] + v * soldierInfo[i].costs[6]
			treatCost[4] =treatCost[4] + v * soldierInfo[i].costs[3]
			treatCost[5] =treatCost[5] + v * soldierInfo[i].costs[2]
			
		end

		stone:setString(treatCost[1])
		wood:setString(treatCost[2])
		iron:setString(treatCost[3])
		food:setString(treatCost[4])
		coin:setString(treatCost[5])
		--修改cost显示
		Panel_cost:getChildByName("Button_hospital"):getChildByName("Label_number"):setString(string.format(all_soliderNumber))
		Panel_cost:getChildByName("ImageView_6512"):getChildByName("Label_max"):setString(string.format(all_soliderNumber.."/"..woundedSoldierMax))
		Panel_cost:getChildByName("ImageView_6512"):getChildByName("LoadingBar"):setPercent(all_soliderNumber*100/woundedSoldierMax)

		--修改元宝和时间显示
		Panel_treat_yes:getChildByName("ImageView_gold"):getChildByName("Label_goldCost"):setString(string.format(hp.lang.getStrByID(2024),all_soliderNumber))
		Panel_treat_yes:getChildByName("ImageView_time"):getChildByName("Label_timeCost"):setString(all_soliderNumber)
	
	end


	-- 全选事件
	local function onChechAllTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		for i,v in ipairs(soldier_allNumber_changed) do
			soldier_allNumber_changed[i] = soldier_allNumber[i]
		end
		treatCostChange()
	end

	--注册事件
	Panel_treat_yes:getChildByName("Button_checkAll"):addTouchEventListener(onChechAllTouched)


	-- addCCNode
	-- ===============================
	if(0~=all_soliderNumber) then
		Panel_solider:getChildByName(string.format("Panel_noSoldier")):setVisible(false)
		self:addChildUI(uiFrame)
		self:addChildUI(uiHeader)
		self:addCCNode(wigetRoot)
		self:addCCNode(hospitalSoldier)

	else
		Panel_treat_yes:setVisible(false)
		self:addChildUI(uiFrame)
		self:addChildUI(uiHeader)
		self:addCCNode(wigetRoot)
	end
	--treatCostChange()
end



function UI_hospitalBuilding:onMsg(msg_, parm_)
	for i,v in ipairs(soldier_allNumber_changed) do
		print("soldier_allNumber_changed"..i..v)
	end
	treatCostChange()

end