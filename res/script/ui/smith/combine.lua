--
-- ui/smith/combine.lua
-- 材料合成界面
--===================================
require "ui/fullScreenFrame"


UI_combine = class("UI_combine", UI)


--init
function UI_combine:init(type_)
	-- data
	-- ===============================
	local headerType = 1
	if type_~=nil then
		headerType = type_
	end
	local maxColorLv = 6
	local minColorLv = 1
	local lvDiff = 0
	if headerType==2 then
	-- 材料的等级差异1
		maxColorLv = 5
		minColorLv = 0
		lvDiff = 1
	end

	local needSrcNum = 4
	local materialList = nil
	local isConnecting = false
	local selectedMaterialTag = -1
	local selectedMaterialNum = 0

	-- functions
	local refreshMaterialList

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(3302))
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "combine.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)

	--
	local rscSid = 0
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				--合成
				player.expendItem(rscSid, 4)
				player.addItem(rscSid+1, 1)
				unselectMaterial()
				refreshMaterialList()
			end
		end

		rscSid = 0
	end
	local function combine()
		if rscSid~=0 then
			return
		end
		rscSid = math.floor(selectedMaterialTag/1000)
		local cmdData={operation={}}
		local oper = {}
		oper.channel = 7
		if headerType==1 then
			oper.type = 5
		else
			oper.type = 4
		end
		oper.sid = rscSid
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
	end
	-- btn
	-----------------------------------
	local contPanel = widgetRoot:getChildByName("Panel_cont")
	local moreInfoBtn = contPanel:getChildByName("Image_moreInfo")
	local combineBtn = contPanel:getChildByName("Image_combine")
	local getBtn = contPanel:getChildByName("Image_get")
	moreInfoBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(1030))
	combineBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(3302))
	local getTxt = getBtn:getChildByName("Label_text")
	getTxt:setString(hp.lang.getStrByID(3305))
	
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender==moreInfoBtn then
			elseif sender==combineBtn then
				combine()
			elseif sender==getBtn then
				require("ui/item/boxItem")
				local ui = UI_boxItem.new(headerType, refreshMaterialList)
				self:addUI(ui)
			end
		end
	end
	
	
	--更多信息
	
	local function onMoreBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/smith/craftingInfo"
			local moreInfoBox = UI_craftingInfo.new()
			self:addModalUI(moreInfoBox)
		end
	end
	
	moreInfoBtn:addTouchEventListener(onMoreBtnTouched)
	combineBtn:addTouchEventListener(onBtnTouched)
	getBtn:addTouchEventListener(onBtnTouched)
	combineBtn:setTouchEnabled(false)

	-- tab
	-----------------------------
	local tabPanel = widgetRoot:getChildByName("Panel_headTab")
	local tabGem = tabPanel:getChildByName("ImageView_gem")
	local gemIcon = tabGem:getChildByName("Image_icon")
	local gemText = tabGem:getChildByName("Label_name")
	local tabMaterial = tabPanel:getChildByName("ImageView_material")
	local materialIcon = tabMaterial:getChildByName("Image_icon")
	local materialText = tabMaterial:getChildByName("Label_name")
	local typeSelected = tabGem
	local scaleSelected = tabGem:getScale()
	local colorSelected = tabGem:getColor()
	local scaleUnselected = tabMaterial:getScale()
	local colorUnselected = tabMaterial:getColor()
	local function tabType(tabNode)
		unselectMaterial()
		typeSelected:setScale(scaleUnselected)
		typeSelected:setColor(colorUnselected)
		typeSelected:getChildByName("Image_icon"):setColor(colorUnselected)
		typeSelected:getChildByName("Label_name"):setColor(colorUnselected)
		typeSelected = tabNode
		typeSelected:setScale(scaleSelected)
		typeSelected:setColor(colorSelected)
		typeSelected:getChildByName("Image_icon"):setColor(colorSelected)
		typeSelected:getChildByName("Label_name"):setColor(colorSelected)

		headerType = typeSelected:getTag()
		if headerType==2 then
		-- 材料的等级差异1
			maxColorLv = 5
			minColorLv = 0
			lvDiff = 1
			getTxt:setString(hp.lang.getStrByID(3306))
		else
			maxColorLv = 6
			minColorLv = 1
			lvDiff = 0
			getTxt:setString(hp.lang.getStrByID(3305))
		end
	end
	local function onTabTouched(sender, eventType)
		if sender==typeSelected then
			return
		end

		if eventType==TOUCH_EVENT_BEGAN then
			sender:setColor(colorSelected)
			sender:getChildByName("Image_icon"):setColor(colorSelected)
			sender:getChildByName("Label_name"):setColor(colorSelected)
		elseif eventType==TOUCH_EVENT_MOVED then
			if sender:hitTest(sender:getTouchMovePos())==true then
				sender:setColor(colorSelected)
				sender:getChildByName("Image_icon"):setColor(colorSelected)
				sender:getChildByName("Label_name"):setColor(colorSelected)
			else
				sender:setColor(colorUnselected)
				sender:getChildByName("Image_icon"):setColor(colorUnselected)
				sender:getChildByName("Label_name"):setColor(colorUnselected)
			end
		elseif eventType==TOUCH_EVENT_ENDED then
			tabType(sender)
			refreshMaterialList()
		end
	end
	tabGem:addTouchEventListener(onTabTouched)
	tabMaterial:addTouchEventListener(onTabTouched)
	if typeSelected:getTag()~=headerType then
	--切换tab
		tabType(tabPanel:getChildByTag(headerType))
	end

	-- 合成信息
	----------------------------------
	local dstFrame = contPanel:getChildByName("Image_itemframe")
	local dstImg = dstFrame:getChildByName("Image_item")
	local infoNode = contPanel:getChildByName("Label_info")
	local srcNodes = {}
	for i=1, needSrcNum do
		srcNodes[i] = {}
		srcNodes[i].frame = contPanel:getChildByName("Image_itemframe" .. i)
		srcNodes[i].img = srcNodes[i].frame:getChildByName("Image_item")
	end
	local combineInfo = contPanel:getChildByName("Image_combineTo")
	local fromFrame = combineInfo:getChildByName("Image_itemframe_src")
	local fromImg = fromFrame:getChildByName("Image_item")
	local fromText = combineInfo:getChildByName("Label_Itemname_src")
	local toFrame = combineInfo:getChildByName("Image_itemframe_dst")
	local toImg = toFrame:getChildByName("Image_item")
	local toText = combineInfo:getChildByName("Label_Itemname_dst")

	-- 材料列表
	----------------------------------
	local materialListNode = widgetRoot:getChildByName("ListView_material")
	local materialLine = materialListNode:getItem(0)
	local materialDemo = materialLine:clone()
	self.materialDemo = materialDemo
	materialDemo:retain()
	local function onItemTouched(sender, eventType)
		if isConnecting then
			-- 无法操作的条件
			return
		end
		local tag = sender:getTag()
		if tag==selectedMaterialTag then
		-- 材料已选择
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			selectMaterial(tag)
		end
	end
	local function setMaterialInfo(lineNode, lineIndex, materialInfo)
		local mframe = lineNode:getChildByName("Panel_frame1"):getChildByTag(lineIndex)
		local textBg = lineNode:getChildByName("Panel_frame2"):getChildByTag(lineIndex)
		local itemImg = lineNode:getChildByName("Panel_cont1"):getChildByTag(lineIndex)
		local itemName = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_name" .. lineIndex)
		local itemNum = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_num" .. lineIndex)

		mframe:setVisible(true)
		textBg:setVisible(true)
		itemImg:setVisible(true)
		itemName:setVisible(true)
		itemNum:setVisible(true)

		mframe:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+lvDiff))
		if headerType==1 then
			itemImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, materialInfo.sid))
		else
			itemImg:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
		end
		itemImg:setTag(materialInfo.sid*1000+lineNode:getTag()*10+lineIndex)
		itemImg:addTouchEventListener(onItemTouched)
		itemName:setString(materialInfo.name)
		itemNum:setString(materialList[materialInfo.sid])
	end

	-- 设置材料列表
	function refreshMaterialList()
		local lineNode = nil
		local mNum = 0
		local lineIndex = 0
		local items = nil
		if headerType==1 then
			items = game.data.gem
		else
			items = game.data.equipMaterial
		end
		materialList = clone(player.getItemList())
		materialListNode:removeAllItems()
		for i=maxColorLv, minColorLv, -1 do
			for j, v in ipairs(items) do
				if v.level==i then
				-- 等级排序
					if materialList[v.sid]~=nil and materialList[v.sid]>0 then
					-- 只显示拥有的材料
						mNum = mNum+1
						lineIndex = mNum%3
						if lineIndex==1 then
							lineNode = materialDemo:clone()
							materialListNode:pushBackCustomItem(lineNode)
							lineNode:setTag(math.ceil(mNum/3))
						end
						if lineIndex==0 then
							lineIndex = 3
						end

						setMaterialInfo(lineNode, lineIndex, v)
					end
				end
			end
		end
	end
	refreshMaterialList()

	-- 选择一个材料
	local disableColor = cc.c3b(92, 92, 92)
	local wrongColor = cc.c3b(255, 0, 0)
	local normalColor = cc.c3b(255, 255, 255)
	function selectMaterial(itemTag)
		unselectMaterial()

		local sid = math.floor(itemTag/1000)
		local lineNum = math.floor((itemTag%1000)/10)
		local lineIndex = itemTag%10
		if materialList[sid]<needSrcNum then
			selectedMaterialNum = materialList[sid]
		else
			selectedMaterialNum = needSrcNum
		end

		-- 设置选择
		local materialInfo = nil
		local dstMaterialInfo = nil
		if headerType==1 then
			materialInfo = hp.gameDataLoader.getInfoBySid("gem", sid)
			dstMaterialInfo = hp.gameDataLoader.getInfoBySid("gem", sid+1)
		else
			materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", sid)
			dstMaterialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", sid+1)
		end
		for i=1, selectedMaterialNum do
			srcNodes[i].frame:setVisible(true)
			srcNodes[i].frame:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+lvDiff))
			if headerType==1 then
				srcNodes[i].img:loadTexture(string.format("%s%d.png", config.dirUI.gem, materialInfo.sid))
			else
				srcNodes[i].img:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
			end
		end
		-- 设置列表
		local lineNode = materialListNode:getItem(lineNum-1)
		local numNode = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_num" .. lineIndex)
		local mNum = materialList[sid]-selectedMaterialNum
		numNode:setString(mNum)
		if mNum<=0 then
			numNode:setColor(wrongColor)
			lineNode:getChildByName("Panel_frame1"):getChildByTag(lineIndex):setColor(disableColor)
			lineNode:getChildByName("Panel_cont1"):getChildByName("Image_item" .. lineIndex):setColor(disableColor)
		end
		materialList[sid] = mNum
		selectedMaterialTag = itemTag

		-- 合成结果
		if dstMaterialInfo==nil then
			infoNode:setVisible(true)
			infoNode:setString("材料等级已最高，无法继续合成")
		elseif selectedMaterialNum<needSrcNum then
			infoNode:setVisible(true)
			infoNode:setString("需要4个相同的材料才能进行合成")
		else
			dstFrame:setVisible(true)
			dstFrame:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, dstMaterialInfo.level+lvDiff))
			if headerType==1 then
				dstImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, dstMaterialInfo.sid))
			else
				dstImg:loadTexture(string.format("%s%d.png", config.dirUI.material, dstMaterialInfo.type))
			end
			combineInfo:setVisible(true)
			fromFrame:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+lvDiff))
			if headerType==1 then
				fromImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, materialInfo.sid))
			else
				fromImg:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
			end
			fromText:setString(materialInfo.name)
			toFrame:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, dstMaterialInfo.level+lvDiff))
			if headerType==1 then
				toImg:loadTexture(string.format("%s%d.png", config.dirUI.gem, dstMaterialInfo.sid))
			else
				toImg:loadTexture(string.format("%s%d.png", config.dirUI.material, dstMaterialInfo.type))
			end
			toText:setString(dstMaterialInfo.name)
			combineBtn:loadTexture(config.dirUI.common .. "button_green.png")
			combineBtn:setTouchEnabled(true)
		end
	end

	-- 取消材料选择
	function unselectMaterial()
		if selectedMaterialNum>0 then
			local sid = math.floor(selectedMaterialTag/1000)
			local lineNum = math.floor((selectedMaterialTag%1000)/10)
			local lineIndex = selectedMaterialTag%10
			--设置选择
			for i=1, selectedMaterialNum do
				srcNodes[i].frame:setVisible(false)
			end
			-- 设置列表
			local lineNode = materialListNode:getItem(lineNum-1)
			local mNum = materialList[sid]+selectedMaterialNum
			local numNode = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_num" .. lineIndex)
			numNode:setString(mNum)
			numNode:setColor(normalColor)
			lineNode:getChildByName("Panel_frame1"):getChildByTag(lineIndex):setColor(normalColor)
			lineNode:getChildByName("Panel_cont1"):getChildByName("Image_item" .. lineIndex):setColor(normalColor)

			materialList[sid] = mNum
			selectedMaterialTag = -1
			selectedMaterialNum = 0
		end

		infoNode:setVisible(false)
		combineInfo:setVisible(false)
		dstFrame:setVisible(false)
		combineBtn:loadTexture(config.dirUI.common .. "button_gray.png")
		combineBtn:setTouchEnabled(false)
	end
end

--onRemove
function UI_combine:onRemove()
	-- must release
	self.materialDemo:release()

	self.super.onRemove(self)
end

