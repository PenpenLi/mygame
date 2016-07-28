--
-- ui/smith/equipForge.lua
-- 装备锻造界面
--===================================
require "ui/fullScreenFrame"


UI_equipForge = class("UI_equipForge", UI)


--init
function UI_equipForge:init(equipMakeInfo_)
	-- data
	-- ===============================
	local maxColorLv = 6 --6种颜色等级
	local materialList = clone(player.getItemList())
	local forge_cd = nil
	self.isForging = false	--正在锻造
	local isConnecting = false --正在进行网络连接

	local selectedMaterialTag = {-1, -1, -1, -1}
	local selectEquip = nil
	local materialSid = nil
	local makeNodes = {}

	if equipMakeInfo_ ~= nil then
		materialSid=equipMakeInfo_.matrialSid
	end

	-- fun
	-- ===============================
	local selectMaterial
	local unselectMaterial
	local unselectAllMaterial
	local checkEquip
	local forgeEquip
	local setforgingInfo
	local getMakeOdds
	local callback


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2900))
	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipForge.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)

	--
	-- ===============================
	local contNode = widgetRoot:getChildByName("Panel_cont")

	-- 银币
	local silverImg = contNode:getChildByName("Image_silver")
	local silverNum = silverImg:getChildByName("Label_num")
	self.silverNum = silverNum
	silverNum:setString(player.getResource("silver"))
	local function onSilverTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/item/resourceItem")
			local ui = UI_resourceItem.new(1)
			self:addUI(ui)
		end
	end
	silverImg:addTouchEventListener(onSilverTouched)	

	-- 装备
	local equipNode = contNode:getChildByName("Image_equip")
	local equipNameNode = equipNode:getChildByName("Label_name")
	local function onEquipTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local sid=math.floor(sender:getTag()/10)
			local level=sender:getTag()%10
			local equipInfo = hp.gameDataLoader.getInfoBySid("equip", sid)
			require "ui/smith/equipInfo"
			self:addModalUI(UI_equipInfo.new(equipInfo,level))
		end
	end
	equipNode:addTouchEventListener(onEquipTouched)

	-- 架上材料
	local selectItemF1 = contNode:getChildByName("Image_itemframe1")
	local selectItemF2 = contNode:getChildByName("Image_itemframe2")
	local selectItemF3 = contNode:getChildByName("Image_itemframe3")
	local selectItemF4 = contNode:getChildByName("Image_itemframe4")
	local selectItem1 = selectItemF1:getChildByName("Image_item")
	local selectItem2 = selectItemF2:getChildByName("Image_item")
	local selectItem3 = selectItemF3:getChildByName("Image_item")
	local selectItem4 = selectItemF4:getChildByName("Image_item")
	local function onSelectItemTouched(sender, eventType)
		local selectIndex = sender:getTag()
		local materialTag = selectedMaterialTag[selectIndex]
		if materialTag==-1 or self.isForging or isConnecting then
		-- 没有放东西
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			unselectMaterial(selectIndex)
			checkEquip()
		end
	end
	selectItem1:addTouchEventListener(onSelectItemTouched)
	selectItem2:addTouchEventListener(onSelectItemTouched)
	selectItem3:addTouchEventListener(onSelectItemTouched)
	selectItem4:addTouchEventListener(onSelectItemTouched)

	-- 取消按钮
	local cancelBtn = contNode:getChildByName("Image_cancle")
	local function onCancelBtnTouched(sender, eventType)
		if self.isForging or isConnecting then
			-- 无法操作的条件
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			unselectAllMaterial()
			checkEquip()
		end
	end
	cancelBtn:addTouchEventListener(onCancelBtnTouched)

	-- 生成概率
	local ProbCont = contNode:getChildByName("Panel_prob")
	local ProbTextCont = ProbCont:getChildByName("Panel_text")
	local ProbTextNode = {}
	for i=1, maxColorLv do
		ProbTextNode[i] = ProbTextCont:getChildByTag(i)
	end
	ProbCont:getChildByName("Label_prob"):setString(hp.lang.getStrByID(2901))

	-- 锻造秘诀
	local forgeBookBtn = contNode:getChildByName("Image_forgeBookBtn")
	forgeBookBtn:getChildByName("Label_name"):setString(hp.lang.getStrByID(2902))
	local function onBookBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/smith/equipDesign"
			self:addUI(UI_equipDesign.new(callback))
		end
	end
	forgeBookBtn:addTouchEventListener(onBookBtnTouched)

	--更多信息
	local moreBtn = contNode:getChildByName("Image_moreInfo")
	moreBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(1030))
	local function onMoreBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require "ui/smith/craftingInfo"
			local moreInfoBox = UI_craftingInfo.new()
			self:addModalUI(moreInfoBox)
		end
	end
	moreBtn:addTouchEventListener(onMoreBtnTouched)

	--立即锻造
	local nowBtn = contNode:getChildByName("Image_now")
	nowBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(2903))
	local function onNowBtnTouched(sender, eventType)
		if self.isForging or isConnecting then
			-- 无法操作的条件
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			--forgeEquip()
		end
	end
	nowBtn:addTouchEventListener(onNowBtnTouched)

	--锻造
	local forgeBtn = contNode:getChildByName("Image_forge")
	local needSilver = forgeBtn:getChildByName("Label_num")
	forgeBtn:getChildByName("Label_text"):setString(hp.lang.getStrByID(2900))
	local function onForgeBtnTouched(sender, eventType)
		if self.isForging or isConnecting then
			-- 无法操作的条件
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			forgeEquip()
		end
	end
	forgeBtn:addTouchEventListener(onForgeBtnTouched)

	-- 材料列表
	local materialListNode = widgetRoot:getChildByName("ListView_material")
	local materialLine = materialListNode:getItem(0)
	local materialDemo = materialLine:clone()
	materialDemo:retain()
	self.materialDemo=materialDemo
	local function onItemTouched(sender, eventType)
		if self.isForging or isConnecting then
			-- 无法操作的条件
			return
		end

		local tag = sender:getTag()
		local sid = math.floor(tag/1000)
		local mNum = materialList[sid]
		if mNum<=0 then
		-- 没有材料了
			return
		end

		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			selectMaterial(tag)
			checkEquip()
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

		mframe:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+1))
		itemImg:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
		itemImg:setTag(materialInfo.sid*1000+lineNode:getTag()*10+lineIndex)
		itemImg:addTouchEventListener(onItemTouched)
		itemName:setString(materialInfo.name)
		itemNum:setString(materialList[materialInfo.sid])
		if materialSid ~= nil then
			for k,v in pairs(materialSid)do
				if v == materialInfo.sid then
					makeNodes[v] = itemImg
					break
				end
			end	
		end 
	end

	-- 设置材料列表
	local function refreshMaterialList()
		materialListNode:removeAllItems()
		local lineNode = nil
		local mNum = 0
		local lineIndex = 0
		for i=maxColorLv-1, 0, -1 do
			for j, v in ipairs(game.data.equipMaterial) do
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
		for i,v in ipairs(selectedMaterialTag) do
			if v==-1 then
				local sid = math.floor(itemTag/1000)
				local lineNum = math.floor((itemTag%1000)/10)
				local lineIndex = itemTag%10
				-- 设置选择
				local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", sid)
				local itemFrame = contNode:getChildByName("Image_itemframe" .. i)
				local itemImg = itemFrame:getChildByName("Image_item")
				itemFrame:setVisible(true)
				itemFrame:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+1))
				itemImg:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
				-- 设置列表
				local lineNode = materialListNode:getItem(lineNum-1)
				local numNode = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_num" .. lineIndex)
				local mNum = materialList[sid]-1
				numNode:setString(mNum)
				if mNum<=0 then
					numNode:setColor(wrongColor)
					lineNode:getChildByName("Panel_frame1"):getChildByTag(lineIndex):setColor(disableColor)
					lineNode:getChildByName("Panel_cont1"):getChildByName("Image_item" .. lineIndex):setColor(disableColor)
				end
				materialList[sid] = mNum
				selectedMaterialTag[i] = itemTag
				return
			end
		end
	end
	-- 取消材料选择
	function unselectMaterial(selectIndex)
		local itemTag = selectedMaterialTag[selectIndex]
		local sid = math.floor(itemTag/1000)
		local lineNum = math.floor((itemTag%1000)/10)
		local lineIndex = itemTag%10
		--设置选择
		contNode:getChildByName("Image_itemframe" .. selectIndex):setVisible(false)
		-- 设置列表
		local lineNode = materialListNode:getItem(lineNum-1)
		local mNum = materialList[sid]+1
		local numNode = lineNode:getChildByName("Panel_cont2"):getChildByName("Label_num" .. lineIndex)
		numNode:setString(mNum)
		numNode:setColor(normalColor)
		lineNode:getChildByName("Panel_frame1"):getChildByTag(lineIndex):setColor(normalColor)
		lineNode:getChildByName("Panel_cont1"):getChildByName("Image_item" .. lineIndex):setColor(normalColor)

		materialList[sid] = mNum
		selectedMaterialTag[selectIndex] = -1
	end
	-- 取消所有材料
	function unselectAllMaterial()
		for i,v in ipairs(selectedMaterialTag) do
			if v~=-1 then
				unselectMaterial(i)
			end
		end
	end

	-- 获取各品质生成概率
	function getMakeOdds(selectedInfo)
		local oddsTotal = 0
		local oddsMin = 0
		for i,v in ipairs(selectedInfo) do
			for i1,v1 in ipairs(game.data.equipOdds) do
				if v.level+1==v1.level then
					oddsTotal = oddsTotal+v1.weight
					if oddsMin==0 or v1.weight<oddsMin then
						oddsMin = v1.weight
					end
					break
				end
			end
		end

		local oddsSeed = oddsTotal-oddsMin+1
		local oddsList = {}
		local odds = {}
		for i,v in ipairs(game.data.equipOdds) do
			oddsList[i] = {}
			oddsList[i].min = v.weight
			if i>1 then
				oddsList[i-1].max = v.weight
			end

			if i==#game.data.equipOdds then
				oddsList[i].max = 0xffffffff
			end
		end
		for i,v in ipairs(oddsList) do
			if v.max<=oddsMin or oddsTotal<v.min then
				odds[i] = 0
			elseif v.max<oddsTotal then
				if v.min>oddsMin then
					odds[i] = (v.max-v.min)*100/oddsSeed
				else
					odds[i] = (v.max-oddsMin)*100/oddsSeed
				end
			else
				odds[i] = (oddsTotal-v.min+1)*100/oddsSeed
			end
		end
		return odds
	end


	-- 检测可以锻造出的装备
	function checkEquip()
		local selectedInfo = {}
		for i,v in ipairs(selectedMaterialTag) do
			if v~=-1 then
				local sid = math.floor(v/1000)
				local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", sid)
				table.insert(selectedInfo, materialInfo)
			end
		end

		selectEquip = nil
		if #selectedInfo>0 then
			for i, equip in ipairs(game.data.equip) do
				if #equip.matrial==#selectedInfo then
				-- 个数相同
					local mType = {}
					local isOk = true
					for i,v in ipairs(selectedInfo) do
						mType[i] = v.type
					end
					for i1,v1 in ipairs(equip.matrial) do
						local bFound = false
						for i2,v2 in ipairs(mType) do
							if v1==v2 then
								bFound=true
								mType[i2]=-1
								break
							end
						end

						if not bFound then
							isOk = false
							break
						end
					end

					if isOk then
						selectEquip = equip
						break
					end
				end
			end
		end

		--装备展示
		if selectEquip==nil then
			equipNode:setVisible(false)
			equipNode:setTouchEnabled(false)
			ProbTextCont:setVisible(false)

			forgeBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			forgeBtn:setTouchEnabled(false)
			needSilver:setString(0)
			nowBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			nowBtn:setTouchEnabled(false)
		else
			equipNode:setVisible(true)
			equipNode:setTouchEnabled(true)
			equipNode:loadTexture(string.format("%s%d.png", config.dirUI.equip, selectEquip.sid))
			equipNameNode:setString(selectEquip.name)

			-- 各品质概率
			ProbTextCont:setVisible(true)

			local odds=getMakeOdds(selectedInfo)
			local maxLv = 1
			for i=1,#odds do
				if odds[i]~=0 then
					maxLv = i
				end
				ProbTextNode[i]:setString(string.format("%0.0f%%", odds[i]))
			end

			equipNode:setTag(selectEquip.sid*10+maxLv)

			-- 设置锻造按钮
			forgeBtn:loadTexture(config.dirUI.common .. "button_green.png")
			forgeBtn:setTouchEnabled(true)
			needSilver:setString(selectEquip.cost)
			nowBtn:loadTexture(config.dirUI.common .. "button_green.png")
			nowBtn:setTouchEnabled(true)
		end

	end

	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				if tag==1 then
				-- 锻造
					local materials = {}
					for i,v in ipairs(selectedMaterialTag) do
						if v~=-1 then
							local sid = math.floor(v/1000)
							table.insert(materials, sid)
							player.expendItem(sid, 1)
						else
							table.insert(materials, 0)
						end
					end
					player.expendResource("silver", selectEquip.cost)
					cdBox.initCDInfo(cdBox.CDTYPE.EQUIP, {data.cd, data.cd, selectEquip.sid, data.id, data.lv, materials})

					--unselectAllMaterial()
					setforgingInfo()
				elseif tag==2 then
				-- 取消锻造
				end
			end
		end

		isConnecting = false
	end
	-- 锻造装备
	function forgeEquip()
		if player.getResource("silver")<selectEquip.cost then
		-- 金币不够
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(2904), 
				hp.lang.getStrByID(2905), 
				hp.lang.getStrByID(1209)
				)
			self:addModalUI(msgBox)
			return
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 7
		oper.type = 2
		oper.sid = selectEquip.sid
		oper.materialsid = {}
		for i,v in ipairs(selectedMaterialTag) do
			if v~=-1 then
				local sid = math.floor(v/1000)
				table.insert(oper.materialsid, sid)
			else
				table.insert(oper.materialsid, 0)
			end
		end
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper, 1)
		isConnecting = true
	end

	-- 进度条
	local progressBg = contNode:getChildByName("Image_progressBg")
	local cdProgess = progressBg:getChildByName("ProgressBar_cd")
	local cdText = progressBg:getChildByName("Label_time")
	local cdSpeedBtn = progressBg:getChildByName("Image_speedBtn")
	-- 设置锻造信息
	function setforgingInfo()
		forge_cd = cdBox.getCDInfo(cdBox.CDTYPE.EQUIP)
		if forge_cd.cd>0 then
			self.isForging = true
			progressBg:setVisible(true)
			cdProgess:setPercent((forge_cd.total_cd-forge_cd.cd)*100/forge_cd.total_cd)
			cdText:setString(hp.datetime.strTime(forge_cd.cd))

			-- 设置锻造材料
			local selectedInfo={}
			for i, v in ipairs(forge_cd.materials) do
				if v~=0 then
					local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", v)
					table.insert(selectedInfo, materialInfo)
					local itemFrame = contNode:getChildByName("Image_itemframe" .. i)
					local itemImg = itemFrame:getChildByName("Image_item")
					itemFrame:setVisible(true)
					itemFrame:loadTexture(string.format("%scolorframe_%d.png", config.dirUI.common, materialInfo.level+1))
					itemImg:loadTexture(string.format("%s%d.png", config.dirUI.material, materialInfo.type))
				end
			end

			local equipInfo = hp.gameDataLoader.getInfoBySid("equip", forge_cd.equip)
			equipNode:setVisible(true)
			-- 设置装备
			equipNode:setTouchEnabled(true)
			equipNode:loadTexture(string.format("%s%d.png", config.dirUI.equip, equipInfo.sid))
			-- 计算最大品质
			local odds=getMakeOdds(selectedInfo)
			local maxLv = 1
			for i=1,#odds do
				if odds[i]~=0 then
					maxLv = i
				end
			end
			equipNode:setTag(equipInfo.sid*10+maxLv)
			equipNameNode:setString(equipInfo.name)

			-- 锻造按钮设置为不可用
			forgeBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			forgeBtn:setTouchEnabled(false)
			needSilver:setString(0)
			nowBtn:loadTexture(config.dirUI.common .. "button_gray.png")
			nowBtn:setTouchEnabled(false)
		end
	end
	setforgingInfo()
	--锻造结束

	local function forgeFinished()
		self.isForging = false
		equipNode:setVisible(false)
		equipNode:setTouchEnabled(false)
		progressBg:setVisible(false)
		ProbTextCont:setVisible(false)
		for i=1, 4 do
			selectedMaterialTag[i] = -1
			contNode:getChildByName("Image_itemframe" .. i):setVisible(false)
		end
	end
	self.forgeFinished = forgeFinished

	-- 加速
	local function onSpeedBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if self.isForging then
				require("ui/item/speedItem")
				local ui = UI_speedItem.new(cdBox.CDTYPE.EQUIP)
				self:addUI(ui)
			end
		end
	end
	cdSpeedBtn:addTouchEventListener(onSpeedBtnTouched)

	-- 刷新所有
	local function refreshAll()
		forge_cd = cdBox.getCDInfo(cdBox.CDTYPE.EQUIP)
		if forge_cd.cd<=0 then
			unselectAllMaterial()
			checkEquip()
		end
		materialList = clone(player.getItemList())
		refreshMaterialList()
	end

	--回调
	function callback()
		refreshAll()
	end

	-- 显示指定锻造准备信息
	local function showEquipMakeInfo()
		for k,v in pairs(materialSid) do
			onItemTouched(makeNodes[v],TOUCH_EVENT_ENDED)	
		end	
	end

	if equipMakeInfo_ ~= nil then
		materialSid=equipMakeInfo_.matrialSid
		showEquipMakeInfo()
	end

	--
	-- ==================================
	self.cdProgess = cdProgess
	self.cdText = cdText

	-- registMsg
	self:registMsg(hp.MSG.RESOURCE_CHANGED)
end

-- onMsg
function UI_equipForge:onMsg(msg_, resInfo_)
	if msg_==hp.MSG.RESOURCE_CHANGED then
		if resInfo_.name=="silver" then
			self.silverNum:setString(resInfo_.num)
		end
	end
end


function UI_equipForge:heartbeat(dt)
	if self.isForging then
		local forge_cd = cdBox.getCDInfo(cdBox.CDTYPE.EQUIP)
		if forge_cd.cd>0 then
			self.cdProgess:setPercent((forge_cd.total_cd-forge_cd.cd)*100/forge_cd.total_cd)
			self.cdText:setString(hp.datetime.strTime(forge_cd.cd))
		else
			self.forgeFinished()
		end
	end
end

--onRemove
function UI_equipForge:onRemove()
	-- must release
	self.materialDemo:release()
	self.super.onRemove(self)
end
