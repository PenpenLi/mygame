--
-- ui/battle/battle.lua
-- 战斗过程展示界面
--===================================
require "ui/battle/BattleMatrix"
local battleCfg = require("ui/battle/battleCfg")


UI_battle = class("UI_battle", UI)


--init
function UI_battle:init(groupSid_, data_, endCallback_)
	-- data
	-- ==============================
	local data = data_.film

	local skipFlag = false
	-- ui
	-- ==============================
	local wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "battle.json")

	--
	local defenderPanel = wigetRoot:getChildByName("Panel_defender")
	local attackerPanel = wigetRoot:getChildByName("Panel_attacker")
	local trapPanel = wigetRoot:getChildByName("Panel_trap")

	local infoFrame = wigetRoot:getChildByName("Panel_frameInfo")
	local defBgImg = infoFrame:getChildByName("Image_defInfoBg")
	local attBgImg = infoFrame:getChildByName("Image_attInfoBg")

	local contPanel = wigetRoot:getChildByName("Panel_cont")
	local btnSkip = contPanel:getChildByName("Image_skip")
	local labelSkip = contPanel:getChildByName("Label_skip")
	local defSBg = contPanel:getChildByName("Image_defSelected")
	local attSBg = contPanel:getChildByName("Image_attSelected")
	local itemInfoNode = contPanel:getChildByName("Image_infoItem")

	local attackerHp = contPanel:getChildByName("BitmapLabel_hp1")
	local defenderHp = contPanel:getChildByName("BitmapLabel_hp2")

	wigetRoot:getChildByName("Panel_frame"):getChildByName("Image_bg"):loadTexture(config.dirUI.battleBg .. groupSid_ .. ".png")
	local a1 = cc.FadeOut:create(0.5)
	local a2 = cc.FadeIn:create(0.3)
	local a3 = cc.DelayTime:create(0.6)
	local a = cc.RepeatForever:create(cc.Sequence:create(a1, a2, a3))
	defSBg:runAction(a)
	attSBg:runAction(a:clone())
	-- 军队信息显示
	--===========================================
	local infoNodeH = 36
	local defNodeInfos = {}
	local defNum = 0
	local defItemX = 142
	local defItemY = 930
	local bgNode = nil
	local function defListAddInfo(armySid, num)
		local nodeInfo = {}
		if defNum==0 then
			bgNode = itemInfoNode
		else
			bgNode = itemInfoNode:clone()
			contPanel:addChild(bgNode)
		end
		bgNode:setPosition(defItemX, defItemY-infoNodeH*defNum)

		nodeInfo.bgNode = bgNode
		nodeInfo.num = bgNode:getChildByName("Label_num")
		nodeInfo.progress = bgNode:getChildByName("ProgressBar_num")

		if armySid==0 then
		--城墙防御
			bgNode:getChildByName("Label_name"):setString(hp.lang.getStrByID(1101))
		else
			local armyInfo = hp.gameDataLoader.getInfoBySid("army", armySid)
			bgNode:getChildByName("Label_name"):setString(armyInfo.name)
		end
		nodeInfo.num:setString(num)
		nodeInfo.progress:setPercent(100)

		table.insert(defNodeInfos, 1, nodeInfo)
		defNum = defNum+1
	end
	local attNodeInfos = {}
	local attNum = 0
	local attItemX = 500
	local attItemY = 30
	local function attListAddInfo(armySid, num)
		local nodeInfo = {}
		bgNode = itemInfoNode:clone()
		contPanel:addChild(bgNode)
		bgNode:setPosition(attItemX, attItemY+infoNodeH*attNum)

		nodeInfo.bgNode = bgNode
		nodeInfo.num = bgNode:getChildByName("Label_num")
		nodeInfo.progress = bgNode:getChildByName("ProgressBar_num")

		local armyInfo = hp.gameDataLoader.getInfoBySid("army", armySid)
		bgNode:getChildByName("Label_name"):setString(armyInfo.name)
		nodeInfo.num:setString(num)
		nodeInfo.progress:setPercent(100)

		table.insert(attNodeInfos, 1, nodeInfo)
		attNum = attNum+1
	end

	local function infoBgResetSize()
		defBgImg:setSize(cc.size(282, infoNodeH*defNum+20))
		attBgImg:setSize(cc.size(282, infoNodeH*attNum+20))
	end

	local defCurIndex = 0
	local defCurItem = nil
	local function defListSelectItem()
		defCurIndex = defCurIndex+1
		if defCurItem~=nil then
			defCurItem.bgNode:setScale(hp.uiHelper.RA_scale)
		end
		defCurItem = defNodeInfos[defCurIndex]
		defCurItem.bgNode:setScale(1.1*hp.uiHelper.RA_scale)
		defSBg:setPosition(defCurItem.bgNode:getPosition())
	end
	local attCurIndex = 0
	local attCurItem = nil
	local function attListSelectItem()
		attCurIndex = attCurIndex+1
		if attCurItem~=nil then
			attCurItem.bgNode:setScale(hp.uiHelper.RA_scale)
		end
		attCurItem = attNodeInfos[attCurIndex]
		attCurItem.bgNode:setScale(1.1*hp.uiHelper.RA_scale)
		attSBg:setPosition(attCurItem.bgNode:getPosition())
	end

	local function defListSelectItemNum(num_, remainNum_)
		defCurItem.num:setString(string.format("%d/%d", remainNum_, num_))
		defCurItem.progress:setPercent(remainNum_*100/num_)
	end
	local function attListSelectItemNum(num_, remainNum_)
		attCurItem.num:setString(string.format("%d/%d", remainNum_, num_))
		attCurItem.progress:setPercent(remainNum_*100/num_)
	end
	

	-- 解析战斗信息
	--===========================================
	-- data = {
	-- 	{ 209525684568065, 1000, {1001, 122, 2001, 100, 3001, 200, 4001, 200} },
	-- 	{ 209525684568066, 1000, 100, {1001, 122, 2001, 100, 3001, 200, 4001, 200} },
	-- 	{ {22, 0}, {0, 100}, {50, 0}, {0, 80}, {160, 0}, {0, 100}, {20, 0}, {0, 190} },
	-- 	{ 100, {122, 100, 200, 200}, {0, 0, 0, 0} },
	-- 	{ 100, 100, {122, 100, 200, 10}, {0, 0, 0, 190} }, 
	-- }

	local attackerInfo
	local defenderInfo
	local boutInfoList
	local maxNum = 0
	local function parseData(data_)
		--进攻方信息
		attackerInfo = {}
		local dataEle = data[1]
		attackerInfo.id = dataEle[1]
		attackerInfo.power = dataEle[2]
		attackerInfo.armyTypes = {}
		attackerInfo.armyNums = {}
		for i, v in ipairs(dataEle[3]) do
			if i%2==1 then
				table.insert(attackerInfo.armyTypes, v)
			else
				table.insert(attackerInfo.armyNums, v)
				if v>maxNum then
					maxNum = v
				end
			end
		end
		dataEle = data[4]
		attackerInfo.powerLoss = dataEle[1]
		attackerInfo.armyLossNums = {}
		attackerInfo.armyRemainNums = {}
		for i, v in ipairs(dataEle[2]) do
			table.insert(attackerInfo.armyLossNums, v)
		end
		for i, v in ipairs(dataEle[3]) do
			table.insert(attackerInfo.armyRemainNums, v)
		end

		--防守方信息
		defenderInfo = {}
		dataEle = data[2]
		defenderInfo.id = dataEle[1]
		defenderInfo.power = dataEle[2]
		defenderInfo.trapNum = dataEle[3]
		if defenderInfo.trapNum>maxNum then
			maxNum = defenderInfo.trapNum
		end
		defenderInfo.armyTypes = {}
		defenderInfo.armyNums = {}
		for i, v in ipairs(dataEle[4]) do
			if i%2==1 then
				table.insert(defenderInfo.armyTypes, v)
			else
				table.insert(defenderInfo.armyNums, v)
				if v>maxNum then
					maxNum = v
				end
			end
		end
		dataEle = data[5]
		defenderInfo.powerLoss = dataEle[1]
		defenderInfo.trapLossNum = dataEle[2]
		defenderInfo.armyLossNums = {}
		defenderInfo.armyRemainNums = {}
		for i, v in ipairs(dataEle[3]) do
			table.insert(defenderInfo.armyLossNums, v)
		end
		for i, v in ipairs(dataEle[4]) do
			table.insert(defenderInfo.armyRemainNums, v)
		end

		-- 战斗回合
		boutInfoList = data[3]
	end
	parseData(data)

	-- 战场参数
	--===========================================
  	local battleWidth = config.resSize.width --战场宽度
  	local battleHeight = config.resSize.height --战场高度

	local sX = battleWidth/2 --基点x坐标
  	local sY = 0 --基点y坐标
  	local armySpaceX = battleCfg.defenderOffsetX - battleCfg.attackerOffsetX --军队x相距
  	local armySpaceY = battleCfg.defenderOffsetY - battleCfg.attackerOffsetY --军队y相距
  	local skewX = armySpaceX/armySpaceY --x倾斜

	-- 军队起始坐标点
	local defenderX = sX+battleCfg.defenderOffsetX
	local defenderY = sY+battleCfg.defenderOffsetY
	local attackerX = sX+battleCfg.attackerOffsetX
	local attackerY = sY+battleCfg.attackerOffsetY
	-- 军队攻击坐标点
	local attOffset = armySpaceY/2 - battleCfg.attackSpace
	local DefenderAttX = defenderX - (attOffset-battleCfg.trapOffset)*skewX
	local DefenderAttY = defenderY - (attOffset-battleCfg.trapOffset)

	-- 军队
	--===========================================
	local trapMtx = nil
	local defMtxList = {}
	local attackMtxList = {}
	local mtx
	-- 初始化防守方军队
	-- 陷阱
	if defenderInfo.trapNum>0 then
		mtx = BattleMatrix.new(101, 1, defenderInfo.trapNum/maxNum, skewX)
		trapPanel:setPosition(DefenderAttX, DefenderAttY)
		trapPanel:addChild(mtx.armyNode)
		trapMtx = mtx
	end
	-- 军队
	local x, y
	defenderPanel:setPosition(defenderX, defenderY)
	for i,v in ipairs(defenderInfo.armyTypes) do
		mtx = BattleMatrix.new(v, 1, defenderInfo.armyNums[i]/maxNum, skewX)
		if i>1 then
			x, y = defMtxList[i-1].armyNode:getPosition()
			y = y + (defMtxList[i-1]:getSize().height + mtx:getSpace())
			x = y*skewX
		else
			x = 0
			y = 0
		end
		mtx.armyNode:setPosition(x, y)
		defenderPanel:addChild(mtx.armyNode)
		table.insert(defMtxList, mtx)
	end
	for i=#defenderInfo.armyTypes, 1, -1  do
		defListAddInfo(defenderInfo.armyTypes[i], defenderInfo.armyNums[i])
	end
	if defenderInfo.trapNum>0 then
		defListAddInfo(0, defenderInfo.trapNum)
	end

	-- 初始化进攻方军队
	attackerPanel:setPosition(attackerX, attackerY)
	for i,v in ipairs(attackerInfo.armyTypes) do
		mtx = BattleMatrix.new(v, 2, attackerInfo.armyNums[i]/maxNum, skewX)
		if i>1 then
			x, y = attackMtxList[i-1].armyNode:getPosition()
			y = y - (attackMtxList[i-1]:getSize().height + mtx:getSpace())
			x = y*skewX
		else
			x = 0
			y = 0
		end
		mtx.armyNode:setPosition(x, y)
		attackerPanel:addChild(mtx.armyNode)
		table.insert(attackMtxList, mtx)
	end
	for i=#attackerInfo.armyTypes, 1, -1 do
		attListAddInfo(attackerInfo.armyTypes[i], attackerInfo.armyNums[i])
	end

	infoBgResetSize()
	self:addCCNode(wigetRoot)


	-- 战斗逻辑
	-- ====================================
	local boutStep
	local armyAdv
	local onArrived
	local onAttack
	local onDied

	----------------------------------
	local boutIndex = 1		-- 回合索引
	local boutInfo 			-- 回合信息

	local attTimes = 1

	local attIndex = 1		-- 攻击部队索引
	local attTotalNum = 0 	-- 攻击方本队总认识
	local attNum = 0		-- 攻击方人数
	local attLoseNum = 0	-- 攻击方损失
	local attMtx 			-- 攻击方方阵		
	local attMtxAdv = false	-- 攻击方是否要前进

	local defIndex = 1 		-- 防守部队索引
	local defTotalNum = 0 	-- 防守方本队总认识
	local defNum = 0		-- 防守方人数
	local defLoseNum = 0	-- 防守方损失
	local defMtx 			-- 防守方方阵
	local defMtxAdv = false	-- 防守方是否要前进
	function boutStep()
		boutInfo = boutInfoList[boutIndex]
		if boutInfo==nil then
		-- 回合结束
			return
		end

		if boutIndex==1 then
		--第一回合
			attTotalNum = attackerInfo.armyNums[attIndex]
			attNum = attTotalNum
			attMtx = attackMtxList[attIndex]
			attMtxAdv = true

			if defenderInfo.trapNum>0 then
				defIndex = 0
				defTotalNum = defenderInfo.trapNum
				defNum = defTotalNum
				defMtx = trapMtx
				defMtxAdv = false
			else
				defIndex = 1
				defTotalNum = defenderInfo.armyNums[defIndex]
				defNum = defTotalNum
				defMtx = defMtxList[defIndex]
				defMtxAdv = true
			end
			attLoseNum = attNum - boutInfo[1]
			defLoseNum = defNum - boutInfo[2]

			attListSelectItem()
			defListSelectItem()
		else
			if attNum==attLoseNum then
			--攻击方全死，选取下一队
				attIndex = attIndex+1
				attTotalNum = attackerInfo.armyNums[attIndex]
				attNum = attTotalNum
				attMtx = attackMtxList[attIndex]
				attMtxAdv = true
				attListSelectItem()
			else
				attNum = attNum-attLoseNum
				attMtxAdv = false
			end
			if defNum==defLoseNum then
			--防守方全死，选取下一队
				defIndex = defIndex+1
				defTotalNum = defenderInfo.armyNums[defIndex]
				defNum = defTotalNum
				defMtx = defMtxList[defIndex]
				defMtxAdv = true
				defListSelectItem()
			else
				defNum = defNum-defLoseNum
				defMtxAdv = false
			end
			attLoseNum = attNum - boutInfo[1]
			defLoseNum = defNum - boutInfo[2]
		end

		if attLoseNum==0 or defLoseNum==0 then
			attTimes = 1
		else
			attTimes = 3
		end

		boutIndex = boutIndex+1
	end

	-- 进攻方到达攻击地点
	local attTime = 1
	local attLoseNum_ = 0
	local defLoseNum_ = 0
	local px1, py1 = attackerHp:getPosition()
	local px2, py2 = defenderHp:getPosition()
	attackerHp:setOpacity(0)
	defenderHp:setOpacity(0)
	local function showLoseNum_(owner, num)
		if num==0 then
			return
		end
		local act = cc.Spawn:create(cc.MoveBy:create(1, cc.p(0, 80*hp.uiHelper.RA_scale)), cc.FadeOut:create(1))
		if owner==1 then
			attackerHp:setString(tostring(num))
			attackerHp:setPosition(px1, py1)
			attackerHp:setOpacity(255)
			attackerHp:stopAllActions()
			attackerHp:runAction(act)
		else
			defenderHp:setString(tostring(num))
			defenderHp:setPosition(px2, py2)
			defenderHp:setOpacity(255)
			defenderHp:stopAllActions()
			defenderHp:runAction(act)
		end
	end
	function onArrived()
		if skipFlag then
			return
		end

		attTime = 0
		attLoseNum_ = 0
		defLoseNum_ = 0

		for i=attIndex+1, #attackMtxList do
			attackMtxList[i]:stand()
		end
		attMtx:attack(attTimes, onAttack)

		for i=defIndex+1, #defMtxList do
			defMtxList[i]:stand()
		end
		defMtx:attack(attTimes)
	end
	-- 进攻方攻击
	function onAttack()
		if skipFlag then
			return
		end
				
		attTime = attTime+1
		if attTime>attTimes then
		-- 这里有个bug
			return
		end
		local attNum_ = math.ceil(attLoseNum*attTime/attTimes)
		local defNum_ = math.ceil(defLoseNum*attTime/attTimes)
		attListSelectItemNum(attTotalNum, attNum-attNum_)
		showLoseNum_(1, attLoseNum_-attNum_)
		attLoseNum_ = attNum_
		defListSelectItemNum(defTotalNum, defNum-defNum_)
		showLoseNum_(2, defLoseNum_-defNum_)
		defLoseNum_ = defNum_
		if attTime>=attTimes then
			if attNum==attLoseNum then
				attMtx:die(onDied)
				if defNum==defLoseNum then
					defMtx:die()
				else
					defMtx:stand()
				end
			else
				attMtx:stand()
				if defNum==defLoseNum then
					defMtx:die(onDied)
				else
					defMtx:stand()
				end
			end
		end
	end
	-- 进攻方死亡
	function onDied()
		if skipFlag then
			return
		end

		boutStep()
		if boutInfo==nil then
		--战斗结束
			-- 欢呼动画
			if attNum==attLoseNum then
				attIndex = attIndex+1
			end
			for i=attIndex, #attackMtxList do
				attackMtxList[i]:cheer()
			end

			if defNum==defLoseNum then
				defIndex = defIndex+1
			end
			if defIndex==nil or defIndex==0 then
				defIndex = 1
			end
			for i=defIndex, #defMtxList do
				defMtxList[i]:cheer()
			end
			-- 回调
			--self:close()
			if endCallback_ then
				endCallback_(attackerInfo, defenderInfo, self)

				--
				if data_.win==0 then
					cc.SimpleAudioEngine:getInstance():playMusic("sound/battle_win.mp3", false)
				else
					cc.SimpleAudioEngine:getInstance():playMusic("sound/battle_fail.mp3", false)
				end
			end
		else
		--部队前进
			armyAdv()
		end
	end

	-- 军队攻击坐标点
	function armyAdv(firstFlag)
		local ft = 0
		if attMtxAdv then
		-- 进攻方前进
			local x, y
			if attIndex==1 then
				y = armySpaceY/2 - battleCfg.attackSpace
				x = y*skewX
				x = x*hp.uiHelper.RA_scaleX
				y = y*hp.uiHelper.RA_scaleY
			else
				local x_, y_ = attackMtxList[attIndex-1].armyNode:getPosition()
				x, y = attMtx.armyNode:getPosition()
				x = x_-x
				y = y_-y
			end
			ft = y/(battleCfg.armySpeed*hp.uiHelper.RA_scaleY)
			local m = cc.MoveBy:create(ft, cc.p(x, y))
			attackerPanel:runAction(cc.Sequence:create(m, cc.CallFunc:create(onArrived)))
			for i=attIndex, #attackMtxList do
				attackMtxList[i]:advance()
			end
		end

		if defMtxAdv then
		-- 防守方前进
			local x, y
			if defIndex==1 then
				y = armySpaceY/2 - battleCfg.attackSpace
				x = y*skewX
				x = x*hp.uiHelper.RA_scaleX
				y = y*hp.uiHelper.RA_scaleY
			else
				local x_, y_ = defMtxList[defIndex-1].armyNode:getPosition()
				 x, y = defMtx.armyNode:getPosition()
				 x = x-x_
				 y = y-y_
			end
			if ft==0 then
			-- 如果已经有速度，已进攻方速度算
				ft = y/(battleCfg.armySpeed*hp.uiHelper.RA_scaleY)
			end
			local m = cc.MoveBy:create(ft, cc.p(-x, -y))
			if attMtxAdv then
				defenderPanel:runAction(m)
			else
				defenderPanel:runAction(cc.Sequence:create(m, cc.CallFunc:create(onArrived)))
			end
			for i=defIndex, #defMtxList do
				defMtxList[i]:advance()
			end
		elseif firstFlag then
			for i=1, #defMtxList do
				defMtxList[i]:stand()
			end
		end
	end

	boutStep()
	armyAdv(true)


	local function onSkipTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			skipFlag = true
			if endCallback_ then
				endCallback_(attackerInfo, defenderInfo, self)
			end
		end
	end
	btnSkip:addTouchEventListener(onSkipTouched)


	--播放战斗音效
	cc.SimpleAudioEngine:getInstance():playMusic("sound/battle_ing.mp3", true)
end

-- onRemove
function UI_battle:onRemove()
	self.super.onRemove(self)

	cc.SimpleAudioEngine:getInstance():playMusic("sound/background.mp3", true)
end
