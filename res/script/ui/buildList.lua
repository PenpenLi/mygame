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
	local mainBuildLv = buildingMgr.getBuildingMaxLvBySid(1001)

	--主线任务，需要建造的建筑
	local qSid = -1
	local questId = player.questManager.getDoingMainQuestInfo()
	if questId~=nil then
		local questInfo = hp.gameDataLoader.getInfoBySid("quests", questId)
		if questInfo~=nil and questInfo.showtype==2 then
		--建造
			qSid = questInfo.parameter1
		end
	end
	
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2300+blockType))
	uiFrame:setTopShadePosY(888)
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "buildList.json")
	local listView = wigetRoot:getChildByName("ListView_building")
	-- Prompt
	local itemPrompt = listView:getChildByName("Panel_itemPrompt")
	local promptCont = itemPrompt:getChildByName("Panel_cont")
	promptCont:getChildByName("Label_info"):setString(hp.lang.getStrByID(2303))
	-- building
	local function itemOnTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local bSid = sender:getTag()
			if bSid==-1 then
			--建造数量已达到开放上限
				require("ui/msgBox/msgBox")
				local ui = UI_msgBox.new(hp.lang.getStrByID(6034), hp.lang.getStrByID(2305), hp.lang.getStrByID(1209))
				self:addModalUI(ui)
				return
			end

			require "ui/build_upgrade"
			local ui  = UI_buildUpgrade.new({type=1, building=building_, sid=bSid})
			self:addUI(ui)
			self:moveOut(2, 0.2, 2)
			ui:moveIn(2, 0.2)

			-- 新手指引进入下一步，建造农场
			player.guide.stepEx({2009, 4007})
		end
	end
	local itemBuilding = listView:getChildByName("Panel_itemBuilding")
	local itemTmp = itemBuilding
	local itemNum = 0
	local openNum = 0
	local canBuildNum = 0

	local farmItem = nil
	local barrackItem = nil

	local activeIndex = 0
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
				local nameBg = itemCont:getChildByName("ImageView_nameBg")
				itemCont:getChildByName("ImageView_building"):loadTexture(config.dirUI.building .. upInfo.img)
				nameBg:getChildByName("BitmapLabel_name"):setString(v.name)
				itemCont:getChildByName("Label_desc"):setString(v.buildDesc)
				itemCont:setTag(v.sid)
				itemCont:addTouchEventListener(itemOnTouched)

				--农田、地牢关联的新手引导
				if 1002==v.sid then
					farmItem = itemCont
				elseif 1009==v.sid then
					barrackItem = itemCont
				end

				if bOpen then
				-- 已开放
					itemCont:getChildByName("ImageView_notOpen"):setVisible(false)
					openNum = openNum+1

					-- 已建造数量
					local bdNum = buildingMgr.getBuildingNumBySid(v.sid)
					local count = v.count[mainBuildLv]
					local numNode = nameBg:getChildByName("Label_num")
					numNode:setVisible(true)
					numNode:setString(string.format("(%d/%d)", bdNum, count))
					if bdNum<count then
					-- 开放数量未建满
						numNode:setColor(cc.c3b(66, 234, 39))
						canBuildNum = canBuildNum+1
						if itemNum>0 then
							listView:insertCustomItem(itemTmp, canBuildNum)
						end
					else
					-- 开放数量已建满
						numNode:setColor(cc.c3b(244, 66, 69))
						itemCont:setTag(-1)
						if itemNum>0 then
							listView:insertCustomItem(itemTmp, openNum)
						end
					end
				else
				-- 未开放
					itemCont:getChildByName("ImageView_notOpen"):setVisible(true)
					nameBg:getChildByName("Label_num"):setVisible(false)
					if itemNum>0 then
						listView:pushBackCustomItem(itemTmp)
					end
					itemCont:addTouchEventListener(itemOnTouched)
				end
				itemNum = itemNum+1

				--主线建造指引
				local itemFrame = itemTmp:getChildByName("Panel_frame")
				local pointImg = itemCont:getChildByName("Image_point")
				local imgl = itemFrame:getChildByName("Image_left")
				local imgt = itemFrame:getChildByName("Image_top")
				local imgr = itemFrame:getChildByName("Image_right")
				local imgb = itemFrame:getChildByName("Image_bottom")
				if player.guide.isFinished() and qSid==v.sid then
					imgl:setVisible(true)
					imgt:setVisible(true)
					imgr:setVisible(true)
					imgb:setVisible(true)
					pointImg:setVisible(true)

					-- 线框动画
					local aOut = cc.FadeOut:create(0.8)
					local aIn = cc.FadeIn:create(0.4)
					local aSq = cc.Sequence:create(aOut, aIn)
					local aRep = cc.RepeatForever:create(aSq)
					imgl:runAction(aRep)
					imgt:runAction(aRep:clone())
					imgr:runAction(aRep:clone())
					imgb:runAction(aRep:clone())

					-- 箭头呼吸动画
					local aUp = cc.ScaleTo:create(0.8, 1.1*hp.uiHelper.RA_scale)
					local aDown = cc.ScaleTo:create(0.4, 1.0*hp.uiHelper.RA_scale)
					local scaleSq = cc.Sequence:create(aUp, aDown)
					local scaleRep = cc.RepeatForever:create(scaleSq)
					pointImg:runAction(scaleRep)

					activeIndex = canBuildNum
				else
					imgl:setVisible(false)
					imgt:setVisible(false)
					imgr:setVisible(false)
					imgb:setVisible(false)
					pointImg:setVisible(false)
				end
			end
		end
	end

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(wigetRoot)


	if activeIndex>=4 then
	-- 跳转到任务指引项
		listView:visit()
		listView:scrollToPercentVertical((activeIndex-1)*100/itemNum, 0.01, false)
	end

	-- registMsg
	self:registMsg(hp.MSG.GUIDE_STEP)

	-- 进行新手引导绑定
	-- =========================================
	local function bindGuideUI( step )
		if step==2009 then
			listView:visit()
			player.guide.bind2Node(step, farmItem, itemOnTouched)
		elseif step==4007 then
			listView:visit()
			player.guide.bind2Node(step, barrackItem, itemOnTouched)
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