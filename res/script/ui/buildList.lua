--
-- ui/buildList.lua
-- 建筑列表界面
--===================================
require "ui/UI"
require "ui/fullScreenFrame"


UI_buildList = class("UI_buildList", UI)


--init
function UI_buildList:init(building_)
	-- data
	-- ===============================
	local blockType = building_.block.type
	local buildingMgr = player.buildingMgr

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2300+blockType))
	
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "buildList.json")
	local listView = wigetRoot:getChildByName("ListView_building")
	-- Prompt
	local itemPrompt = listView:getChildByName("Panel_itemPrompt")
	local promptCont = itemPrompt:getChildByName("Panel_cont")
	promptCont:getChildByName("Label_info"):setString(hp.lang.getStrByID(2303))
	-- building
	local function itemOnTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/build_upgrade"
			local ui  = UI_buildUpgrade.new({type=1, building=building_, sid=sender:getTag()})
			self:addUI(ui)

			-- 新手指引进入下一步，建造农场/地牢
			player.guide.stepEx({2003, 7003})
		end
	end
	local itemBuilding = listView:getChildByName("Panel_itemBuilding")
	local itemTmp = itemBuilding
	local itemNum = 0
	local openNum = 0

	local farmItem = nil
	local prisonItem = nil
	-- 
	for i,v in ipairs(game.data.building) do
		if blockType==v.type then
			if buildingMgr.getBuildingNumBySid(v.sid)<v.maxCount then
			-- 数量未超上限
				-- 判断前续建筑
				if itemNum>0 then
					itemTmp = itemBuilding:clone()
				end

				local upInfo = nil
				local bOpen = true
				for i, up in ipairs(game.data.upgrade) do
					if v.sid==up.buildSid and 0==up.level then
						upInfo = up
						break
					end
				end
				for i, mustSid in ipairs(upInfo.mustBuildSid) do
					if mustSid~=-1 then
						if buildingMgr.getBuildingMaxLvBySid(mustSid)<upInfo.mustBuildLv[i] then
							bOpen = false
							break
						end
					end
				end

				local itemCont = itemTmp:getChildByName("Panel_cont")
				itemCont:getChildByName("ImageView_building"):loadTexture(config.dirUI.building .. upInfo.img)
				itemCont:getChildByName("ImageView_nameBg"):getChildByName("Label_name"):setString(v.name)
				itemCont:getChildByName("Label_desc"):setString(v.buildDesc)
				itemCont:setTag(v.sid)
				itemCont:addTouchEventListener(itemOnTouched)

				--农田、地牢关联的新手引导
				if 1002==v.sid then
					farmItem = itemCont
				elseif 1016==v.sid then
					prisonItem = itemCont
				end

				if bOpen then
					itemCont:getChildByName("ImageView_notOpen"):setVisible(false)
					openNum = openNum+1
					if itemNum>0 then
						listView:insertCustomItem(itemTmp, openNum)
					end
				else
					itemCont:getChildByName("ImageView_notOpen"):setVisible(true)
					if itemNum>0 then
						listView:pushBackCustomItem(itemTmp)
					end
				end

				itemNum = itemNum+1
			end
		end
	end

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	-- registMsg
	self:registMsg(hp.MSG.GUIDE_STEP)


	-- 进行新手引导绑定
	-- =========================================
	local function bindGuideUI( step )
		if step==2003 then
			listView:visit()
			player.guide.bind2Node(step, farmItem, itemOnTouched)
		elseif step==7003 then
			listView:visit()
			player.guide.bind2Node(step, prisonItem, itemOnTouched)
		end
	end
	self.bindGuideUI = bindGuideUI
end

-- onMsg
function UI_buildList:onMsg(msg_, param_)
	if msg_==hp.MSG.GUIDE_STEP then
		self.bindGuideUI(param_)
	end
end