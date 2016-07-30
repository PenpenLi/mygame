--
-- ui/smith/equipDesignDetail.lua
-- 装备制造秘籍详细信息界面
--===================================
require "ui/fullScreenFrame"

UI_equipDesignDetail = class("UI_equipDesignDetail", UI)

--init
function UI_equipDesignDetail:init(equipType_,equipSubType_,callback_,customData_)
	-- data
	-- ===============================
	local equipType = equipType_
	local equipSubType = equipSubType_
	local callbackFun= callback_
	local customData = customData_
	--local equips = clone(game.data.equip)
	--local count = table.getn(equips)
	-- 两个下标，一个记录可制作集合下标，一个记录不可制造集合下标
	local canIndex = 1
	local notIndex = 1
	local qua_str=hp.lang.getStrByID(2906)
	local qua_str1=hp.lang.getStrByID(2907)
	-- 每次加载数量
	local defaultNum = 2
	--可以制造的装备信息
	local canMakeEquips = {}
	--分好类的装备
	local equips = {}
	local count=0
	-- function
	-- ===============================
	local pushLoadingItem
	local showDesignDetail
	local resetShowItems
	local callback
	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2902))
	uiFrame:hideTopBackground()
	uiFrame:setTopShadePosY(890)
	uiFrame:setBottomShadePosY(200)

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "equipDesignDetail.json")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)


	local listNode = widgetRoot:getChildByName("ListView_main")
	local itemDemo1 = listNode:getChildByName("Panel_item")
	local itemDemo = itemDemo1:clone()
	local attrDemo = itemDemo:getChildByName("ListView_attrs"):getChildByName("Panel_att_demo")
	local condDemo = itemDemo:getChildByName("ListView_conds"):getChildByName("Panel_condition")
	itemDemo:retain()
	attrDemo:retain()
	condDemo:retain()
	self.attrDemo = attrDemo
	self.condDemo = condDemo
	self.itemDemo = itemDemo

	-- listView监听

	local countScroll = 0

	local function onScrollEvent(t1, t2, t3)
		if t2==ccui.ScrollviewEventType.scrollToBottom then
			if countScroll % 3 == 0 then
				pushLoadingItem(false,defaultNum)
			end
			countScroll = countScroll + 1
		end
	end
	listNode:addEventListenerScrollView(onScrollEvent)

	-- 点击锻造按钮
	local function onBtnMakeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local index = sender:getTag()
			local equipMakeInfo = canMakeEquips[index]
			self:closeAll()
			require("ui/smith/equipForge")
			local ui = UI_equipForge.new(equipMakeInfo)
			self:addUI(ui)
		end
	end

	local btnInfo=widgetRoot:getChildByName("Panel_bottom"):getChildByName("Image_info")
	local btnGet=widgetRoot:getChildByName("Panel_bottom"):getChildByName("Image_get")
	btnInfo:getChildByName("Label_btn"):setString(hp.lang.getStrByID(1030))
	btnGet:getChildByName("Label_btn"):setString(hp.lang.getStrByID(3306))

	-- 点击信息、获取材料按钮
	local function onBtnTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			if sender == btnInfo then
				require "ui/smith/craftingInfo"
				local moreInfoBox = UI_craftingInfo.new()
				self:addModalUI(moreInfoBox)
			end
			if sender == btnGet then
				require("ui/item/boxItem")
				local ui = UI_boxItem.new(2,callback)
				self:addUI(ui)
			end				
		end
	end

	btnInfo:addTouchEventListener(onBtnTouched)
	btnGet:addTouchEventListener(onBtnTouched)

	--用于判定是否有可制造装备
	local items=clone(player.getItemList())
	local materials=game.data.equipMaterial
	local mlist={}
	local mobj={}
	for i,v in ipairs(materials) do
		if v.type~=nil then
			if mlist[v.type]== nil then
				mlist[v.type]={}
			end	
			local mobj={}
			mobj.type=v.type
			mobj.sid=v.sid
			mobj.num=0
			table.insert(mlist[v.type],1,mobj)
		end
	end
	for i,v in ipairs(mlist) do
		for k,m in ipairs(v) do
			if items[m.sid] ~= nil and items[m.sid]>0 then
				m.num=items[m.sid]
			end
		end
	end

	-- 显示品质信息
	local function showQuaInfo(equipInfo,level,listView)
		listView:removeAllItems()
		local k=0
		if equipInfo.type1 and equipInfo.type1 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type1)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value=(equipInfo.value1[level]/100).."%"
				if equipInfo.value1[level]/100 >=0 then
					value="+"..value
				end
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				listView:pushBackCustomItem(contAttr)
				k=k+1
			end
		end
		if equipInfo.type2 and equipInfo.type2 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type2)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value=(equipInfo.value2[level]/100).."%"
				if equipInfo.value2[level]/100 >=0 then
					value="+"..value
				end
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				if k % 2 ~= 0 then
					contAttr:getChildByName("ImageView_bg"):setVisible(false)
				end
				listView:pushBackCustomItem(contAttr)
				k=k+1
			end
		end
		if equipInfo.type3 and equipInfo.type3 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type3)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value=(equipInfo.value3[level]/100).."%"
				if equipInfo.value3[level]/100 >=0 then
					value="+"..value
				end
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				if k % 2 ~= 0 then
					contAttr:getChildByName("ImageView_bg"):setVisible(false)
				end
				listView:pushBackCustomItem(contAttr)
				k=k+1
			end
		end
		if equipInfo.type4 and equipInfo.type4 > 0 then
			local att=hp.gameDataLoader.getInfoBySid("attr", equipInfo.type4)
			if att ~= nil then
				local contAttr = self.attrDemo:clone()
				local value=(equipInfo.value4[level]/100).."%"
				if equipInfo.value4[level]/100 >=0 then
					value="+"..value
				end
				contAttr:getChildByName("Panel_text"):getChildByName("Label_name"):setString(att.desc)
				contAttr:getChildByName("Panel_text"):getChildByName("Label_value"):setString(value)
				if k % 2 ~= 0 then
					contAttr:getChildByName("ImageView_bg"):setVisible(false)
				end
				listView:pushBackCustomItem(contAttr)
				k=k+1
			end
		end
	end

	-- 点击品质按钮
	local function onBtnQuaTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local level=sender:getTag()
			local equipSid=sender:getParent():getTag()
			local equipInfo=hp.gameDataLoader.getInfoBySid("equip", equipSid)
			local listView=sender:getParent():getParent():getChildByName("ListView_attrs")
			for i=1,6 do
				if i==level then
					sender:getParent():getChildByName("Image_qua"..i):getChildByName("Image_selected"):setVisible(true)
				else
					sender:getParent():getChildByName("Image_qua"..i):getChildByName("Image_selected"):setVisible(false)
				end
			end
			showQuaInfo(equipInfo,level,listView)
		end
	end

	-- 重新设置节点高度
	local function adjustHeight(parent_,listView_,panelList_)
		local items=listView_:getItems()
		local num=#items
		if num>0 then
			local item = items[1]
			local totalHeight = item:getSize().height * num
			local size_ = listView_:getSize()
			local addHeight = totalHeight-size_.height
			size_.height = totalHeight
			listView_:setSize(size_)

			local pSize=parent_:getSize()
			pSize.height=pSize.height+addHeight
			parent_:setSize(pSize)
			-- local px, py = parent_:getPosition()
			-- parent_:setPosition(px,py-addHeight)

			for i,v in ipairs(panelList_) do	 	
				local x_, y_ = v:getPosition()
				v:setPosition(x_, y_ + addHeight)
			end
		end
	end

	-- 装备制造信息
	local function newEquipMakeInfo(equip_,matrialSid)
		local equipMakeInfo = clone(equip_)
		equipMakeInfo.matrialSid = matrialSid
		return equipMakeInfo
	end

	--计算可以制造的装备
	local function getCanMakeEquips()
		
		local k = 1
		for i=count,1,-1 do		
			local mlist1=clone(mlist)
			local canMake = true
			-- 武将等级、白银
			if player.getLv() < equips[i].mustLv or player.getResource("silver") < equips[i].cost then
				canMake=false
			end
			if canMake then
				--材料
				local matrialSid={}
				for j,v in pairs(equips[i].matrial) do
					local noItem=true
					if mlist1[v] ~=nil then
						for l,m in ipairs(mlist1[v]) do
							if m.num>0 then
								matrialSid[j]=m.sid
								noItem=false
								m.num = m.num-1
								break
							end
						end
					end
					if noItem then
						canMake=false
						break
					end
				end	

				if canMake then
					canMakeEquips[k] = newEquipMakeInfo(equips[i],matrialSid)
					equips[i] = nil
					k=k+1;
				end
			end
		end
		
	end

	--显示详细信息
	function showDesignDetail(canMake,equipInfo,index_)
		local sid = equipInfo.sid
		local name = equipInfo.name
		local desc = equipInfo.desc
		local mustLv = equipInfo.mustLv
		local cost = equipInfo.cost
		local matrial = equipInfo.matrial

		local contItem = itemDemo:clone()
		listNode:pushBackCustomItem(contItem)
	 	local contTop = contItem:getChildByName("Panel_top_cont")
	 	local contTopFrame = contItem:getChildByName("Panel_top_frame")
	 	local contListConds = contItem:getChildByName("ListView_conds")
	 	local contQua=contItem:getChildByName("Panel_qua_cont")
	 	local contQuaFrame = contItem:getChildByName("Panel_qua_frame")
		local contListAttrs = contItem:getChildByName("ListView_attrs")
		local contBottom = contItem:getChildByName("Panel_bottom")
		contListConds:removeAllItems()

	 	-- 名字
		contTop:getChildByName("Label_name"):setString(name)
		-- 描述
		contTop:getChildByName("Label_desc"):setString(desc)
		-- 图标
		contTop:getChildByName("ImageView_icon"):getChildByName("Image_icon"):loadTexture(string.format("%s%d.png", config.dirUI.equip, sid))
		
		--锻造条件
		
		-- 英雄等级
		local contCond = condDemo:clone()
		local condNode = contCond:getChildByName("Panel_cond")
		condNode:getChildByName("Image_icon"):loadTexture(config.dirUI.common.."hero_normal.png")
		condNode:getChildByName("Label_cond"):setString(string.format(hp.lang.getStrByID(3503), mustLv))
		if player.getLv() < mustLv then
			condNode:getChildByName("Image_ok"):loadTexture(config.dirUI.common.."wrong.png")
		else
			condNode:getChildByName("Image_ok"):loadTexture(config.dirUI.common.."right.png")
		end
		contListConds:pushBackCustomItem(contCond)
		-- 白银
		contCond = condDemo:clone()
		condNode = contCond:getChildByName("Panel_cond")
		condNode:getChildByName("Image_icon"):loadTexture(config.dirUI.common.."silver.png")		
		condNode:getChildByName("Label_cond"):setString(cost)
		if player.getResource("silver") < cost then
			condNode:getChildByName("Image_ok"):loadTexture(config.dirUI.common.."wrong.png")
		else
			condNode:getChildByName("Image_ok"):loadTexture(config.dirUI.common.."right.png")
		end
		contCond:getChildByName("ImageView_bg"):setVisible(false)
		contListConds:pushBackCustomItem(contCond)
		--材料
		local mlist1=clone(mlist)
		local k=0
		for j,v in pairs(matrial) do
			if v>0 then
				contCond = condDemo:clone()
				condNode = contCond:getChildByName("Panel_cond")
				condNode:getChildByName("Image_icon"):loadTexture(config.dirUI.material..v..".png")
				condNode:getChildByName("Label_cond"):setString(hp.lang.getStrByID(3900+v))
				local noItem=true
				if mlist1[v] ~=nil then
					for l,m in ipairs(mlist1[v]) do
						if m.num>0 then
							noItem=false
							m.num = m.num-1
							break
						end
					end
				end
				if noItem then
					condNode:getChildByName("Image_ok"):loadTexture(config.dirUI.common.."wrong.png")
				else
					condNode:getChildByName("Image_ok"):loadTexture(config.dirUI.common.."right.png")
				end
				if k % 2 ~= 0 then
					contCond:getChildByName("ImageView_bg"):setVisible(false)
				end
				contListConds:pushBackCustomItem(contCond)
				k=k+1
			end
		end		

		-- 锻造按钮
		contTop:getChildByName("ImageView_make"):getChildByName("Label_make"):setString(hp.lang.getStrByID(2900))
		contTop:getChildByName("ImageView_make"):addTouchEventListener(onBtnMakeTouched)
		-- 是否可以制作
		if canMake then
			contTop:getChildByName("ImageView_make"):setTag(index_)
		else
			contTop:getChildByName("ImageView_make"):setTouchEnabled(false)
			contTop:getChildByName("ImageView_make"):loadTexture(config.dirUI.common.."button_gray1.png")
		end


		--品质
		contQua:setTag(sid)
		contQua:getChildByName("Label_qua"):setString(qua_str)			
		contQua:getChildByName("Label_qua_0"):setString(qua_str1)

		-- 默认选择6级
		local level=6
		local imageView_qua = nil
		-- 计算品质概率
		if canMake then
			local oddsTotal = 0
			local oddsMin = 0
			local matrialSid = equipInfo.matrialSid
			for i,v in ipairs(matrialSid) do
				if v~=-1 then
					local materialInfo = hp.gameDataLoader.getInfoBySid("equipMaterial", v)
					for i1,v1 in ipairs(game.data.equipOdds) do
						if materialInfo.level+1==v1.level then
							oddsTotal = oddsTotal+v1.weight
							if oddsMin==0 or v1.weight<oddsMin then
								oddsMin = v1.weight
							end
							break
						end
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
					level = i
					if v.min>oddsMin then
						odds[i] = v.max-v.min
					else
						odds[i] = v.max-oddsMin
					end
				else
					level = i
					odds[i] = oddsTotal-v.min+1
				end
				imageView_qua = contQua:getChildByName("Image_qua"..i)
				imageView_qua:getChildByName("Label_name"):setString(string.format("%0.0f%%", odds[i]*100/oddsSeed))
			end
		end

		-- 设置选中品质等级
		for i=1,6 do
			imageView_qua = contQua:getChildByName("Image_qua"..i)
			imageView_qua:addTouchEventListener(onBtnQuaTouched)
			local selected = contQua:getChildByName("Image_qua"..i):getChildByName("Image_selected")
			if i == level then
				selected:setVisible(true)
			else
				selected:setVisible(false)
			end
		end

		showQuaInfo(equipInfo,level,contListAttrs)
		--装备品质属性

		adjustHeight(contItem,contListConds,{contTop,contTopFrame})
		adjustHeight(contItem,contListAttrs,{contTop,contTopFrame,contListConds,contQua,contQuaFrame})

	end


	-- 显示
	function pushLoadingItem(init,num)
		local canNum=#canMakeEquips
		local k = 0
		if canIndex<=canNum then
			for l=canIndex,canNum do
				canIndex = l+1
				k=k+1
				showDesignDetail(true,canMakeEquips[l],l)
				if k>=num then
					break
				end
			end
		end
		if k<num then		
			for i=notIndex,count do				
				if equips[i]~=nil then			
					showDesignDetail(false,equips[i],i)
					notIndex = i+1 
					k=k+1
				end
			 	if k >=num then
			 		break
			 	end
			end
		end
	end

	-- 重置显示
	function resetShowItems()
		listNode:removeAllItems()
		canIndex=1
		notIndex=1
		canMakeEquips={}
		equips={}
		-- 先将装备分好类
		local nowTime=player.getServerTime()
		local l=1
		if customData then
			equips = customData
		else
			for i,v in ipairs(game.data.equip) do
				local eq=game.data.equip[i]
				if v.type == equipType then
					for k,m in ipairs(eq.subType) do
						if m == equipSubType then
							--指定时间显示限时装备
							if eq.showTime[1] > 0 then
								local st=os.time({year=eq.showTime[1],month=eq.showTime[2],day=eq.showTime[3],hour=0,min=0,sec=0})
								local ot=os.time({year=eq.overTime[1],month=eq.overTime[2],day=eq.overTime[3],hour=0,min=0,sec=0})
								if nowTime < st or nowTime > ot then
									break
								end
							end
							equips[l]=eq
							l=l+1
							break
						end
					end
				end
			end
		end
		count = table.getn(equips)
		getCanMakeEquips()
		pushLoadingItem(true,defaultNum)
	end

	-- 重置显示
	function callback()
		resetShowItems()
		if callbackFun~=nil then
			callbackFun()
		end
	end

	resetShowItems()
end


--onRemove
function UI_equipDesignDetail:onRemove()
	-- must release
	self.attrDemo:release()
	self.condDemo:release()
	self.itemDemo:release()
	self.super.onRemove(self)
end
