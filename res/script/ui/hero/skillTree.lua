--
-- ui/hero/skillTree.lua
-- 英雄技能树
--===================================
require "ui/fullScreenFrame"


UI_skillTree = class("UI_skillTree", UI)


--init
function UI_skillTree:init(hero_)
	-- data
	-- ===============================
	local lv = player.getLv()
	local skillList = hero_.getSkillList()
	local pointCount = 0
	local pointUsed = 0
	for i,v in ipairs(game.data.heroLv) do
		pointCount = pointCount+v.dit
		if v.level==lv then
			heroConstInfo = v
			break
		end
	end
	for k,v in pairs(skillList) do
		pointUsed = pointUsed+v
	end
	--pointCount = 100
	self.pointRemain = pointCount - pointUsed
	self.hero = hero_

	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(2601))

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "skillTree.json")

	-- header
	local pointsNode = widgetRoot:getChildByName("Panel_header"):getChildByName("Label_gift")

	--技能树
	local listView = widgetRoot:getChildByName("ListView_list")
	local treePanel = listView:getChildByName("Panel_tree")
	local skillPanel = treePanel:getChildByName("Panel_skill")
	local linePanel = treePanel:getChildByName("Panel_line")

	local colorLock = cc.c3b(128, 128, 128)
	local colorUnlock = cc.c3b(255, 255, 255)
	local imgLineLockH = config.dirUI.common .. "skillLine_lockH.png"
	local imgLineLockV = config.dirUI.common .. "skillLine_lockV.png"
	local imgLineUnlockH = config.dirUI.common .. "skillLine_unlockH.png"
	local imgLineUnlockV = config.dirUI.common .. "skillLine_unlockV.png"

	-- 检查技能是否加锁状态
	local function skillIsLock(skillConstInfo)
		local lockFlag = true
		for i,v in ipairs(skillConstInfo.lastSid) do
			if v==-1 then
				lockFlag = false
				break
			end

			skillLv = skillList[v] or 0
			if skillLv>=skillConstInfo.lastLv[i] then
				lockFlag = false
				break
			end
		end

		return lockFlag
	end
	self.skillIsLock = skillIsLock

	-- 设置开锁、解锁线条
	local lineNode = nil
	local function setLockLine(lineName)
		lineNode = linePanel:getChildByName(lineName)
		if lineNode:getTag()==-91 then
			lineNode:loadTexture(imgLineLockH)
		else
			lineNode:loadTexture(imgLineLockV)
		end
	end
	local function setUnlockLine(lineName)
		lineNode = linePanel:getChildByName(lineName)
		if lineNode:getTag()==-91 then
			lineNode:loadTexture(imgLineUnlockH)
		else
			lineNode:loadTexture(imgLineUnlockV)
		end
	end

	--
	local curUpSkillNode = nil
	local function onHttpResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				self:allotSkillPoint(curUpSkillNode, 1)
			end
		end

		curUpSkillNode = nil
	end

	local function allotSkillPoint(skillNode, pointNum)
		if curUpSkillNode~=nil then
			return
		end
		curUpSkillNode = skillNode

		local skillConstInfo = game.data.skill[skillNode:getTag()]
		local skillId = skillConstInfo.sid
		local skillLv = 0
		if skillList[skillId]==nil then
			skillLv = pointNum
		else
			skillLv = skillList[skillId]+pointNum
		end

		if skillLv>skillConstInfo.maxLv then
			-- 超出技能等级上限
			return
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 9
		oper.type = 1
		oper.sid = skillConstInfo.sid
		oper.num = pointNum
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onHttpResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	self.allotSkillPoint1 = allotSkillPoint

	-- 技能点击响应
	local function onSkillTouched(sender, eventType)
		--hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local tag = sender:getTag()
			local skillConstInfo = game.data.skill[tag]
			require("ui/hero/allotSkillPoint")
			local ui = UI_allotSkillPoint.new(self, sender, hero_, skillConstInfo.sid)
			self.allotUI = ui
			self:addModalUI(ui)
		end
	end

	-- 刷新技能树
	local function refreshSkillTree()
		local strSkill = ""
		local skillNode = nil
		local skillLv = 0

		pointsNode:setString(string.format(hp.lang.getStrByID(2503), self.pointRemain))

		for i, sillInfo in ipairs(game.data.skill) do
			strSkill = tostring(sillInfo.sid)
			skillNode = skillPanel:getChildByName(strSkill)
			skillLv = skillList[sillInfo.sid] or 0

			skillNode:setTag(i)
			skillNode:getChildByName("name"):setString(sillInfo.name)
			skillNode:getChildByName("progress"):setPercent(skillLv*100/sillInfo.maxLv)
			skillNode:getChildByName("desc"):setString(string.format("%d/%d", skillLv, sillInfo.maxLv))
			skillNode:addTouchEventListener(onSkillTouched)

			-- 判断是否解锁
			if skillIsLock(sillInfo) then
				skillNode:setColor(colorLock)
				skillNode:getChildByName("lock"):setVisible(true)

				-- 设置线
				if sillInfo.sid==1001 or sillInfo.sid==1002 then
				else
					if sillInfo.sid==1003 then
						setLockLine("_1001")
						setLockLine("_1002")
						setLockLine("1001_1002")
						setLockLine("_1003")
						setLockLine("_1004")
					elseif sillInfo.sid==1005 then
						setLockLine("1001_1005_")
					elseif sillInfo.sid==1006 then
						setLockLine("1002_1006_")
					end
					setLockLine(strSkill)
				end
			else
				skillNode:setColor(colorUnlock)
				skillNode:getChildByName("lock"):setVisible(false)

				-- 设置线
				if sillInfo.sid==1001 or sillInfo.sid==1002 then
				else
					if sillInfo.sid==1003 then
						if skillList[1001]~=nil then
							setUnlockLine("_1001")
						end
						if skillList[1002]~=nil then
							setUnlockLine("_1002")
						end
						setUnlockLine("1001_1002")
						setUnlockLine("_1003")
						setUnlockLine("_1004")
					elseif sillInfo.sid==1005 then
						setUnlockLine("1001_1005_")
					elseif sillInfo.sid==1006 then
						setUnlockLine("1002_1006_")
					end
					setUnlockLine(strSkill)
				end
			end
		end
	end

	refreshSkillTree()

	-- 重置天赋
	local itemSid = 20201
	local needNum = 1
	local goldNum = 0
	local function onResetResponse(status, response, tag)
		if status==200 then
			local data = hp.httpParse(response)
			if data.result~=nil and data.result==0 then
				skillList = {}
				self.pointRemain = pointCount
				refreshSkillTree()

				if goldNum==0 then
					player.expendItem(itemSid, needNum)
				end
				Scene.showMsg({2002})
			end
		end
	end
	local function onConfirmReset()
		if player.getResource("gold")<goldNum then
			-- 金币不够
			require("ui/msgBox/msgBox")
			local msgBox = UI_msgBox.new(hp.lang.getStrByID(2826), 
				hp.lang.getStrByID(2827), 
				hp.lang.getStrByID(1209), 
				hp.lang.getStrByID(2412)
				)
			self:addModalUI(msgBox)
			return
		end

		local cmdData={operation={}}
		local oper = {}
		oper.channel = 9
		oper.type = 2
		oper.sid = 0
		oper.num = 0
		oper.gold = goldNum
		cmdData.operation[1] = oper
		local cmdSender = hp.httpCmdSender.new(onResetResponse)
		cmdSender:send(hp.httpCmdType.SEND_INTIME, cmdData, config.server.cmdOper)
	end
	local btnReset = listView:getChildByName("Panel_reset"):getChildByName("Panel_cont"):getChildByName("ImageView_reset")
	btnReset:getChildByName("Label_desc"):setString(hp.lang.getStrByID(2602))
	local function onResetTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local haveNum = player.getItemNum(itemSid)
			local itemInfo = hp.gameDataLoader.getInfoBySid("item", itemSid)
			local descInfo
			if haveNum>=needNum then
				goldNum = 0
				descInfo = string.format(hp.lang.getStrByID(2603), needNum, itemInfo.name, haveNum)
			else
				goldNum = itemInfo.sale
				descInfo = string.format(hp.lang.getStrByID(2604), needNum, itemInfo.name, haveNum)
			end
			require "ui/msgBox/msgBox"
			local ui = UI_msgBox.new(hp.lang.getStrByID(2602), descInfo, 
				hp.lang.getStrByID(1209), hp.lang.getStrByID(2412), onConfirmReset)
			self:addModalUI(ui)
		end
	end
	btnReset:addTouchEventListener(onResetTouched)

	-- obj global data & fun
	-- ===============================
	self.pointsNode = pointsNode
	self.skillPanel = skillPanel

	self.setLockLine = setLockLine
	self.setUnlockLine = setUnlockLine


	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)
end

-- allotSkillPoint
-- 分配技能点
----------------------------
function UI_skillTree:allotSkillPoint(skillNode, point)
	if point>self.pointRemain then
		-- 超出剩余点数
		return
	end

	local tagId = skillNode:getTag()
	local sillConstInfo = game.data.skill[tagId]
	local skillList = self.hero.getSkillList()
	local skillId = sillConstInfo.sid
	local skillLv = 0

	if skillList[skillId]==nil then
		skillLv = point
	else
		skillLv = skillList[skillId]+point
	end

	if skillLv>sillConstInfo.maxLv then
		-- 超出技能等级上限
		return
	end
	
	-- 分配成功
	self.pointRemain = self.pointRemain - point
	skillList[skillId] = skillLv
	-- 发送技能变化的消息
	hp.msgCenter.sendMsg(hp.MSG.SKILL_CHANGED, {skillSid=sillConstInfo.sid, lv=skillLv})

	-- 更新技能
	self.pointsNode:setString(string.format(hp.lang.getStrByID(2503), self.pointRemain))
	skillNode:getChildByName("progress"):setPercent(skillLv*100/sillConstInfo.maxLv)
	skillNode:getChildByName("desc"):setString(string.format("%d/%d", skillLv, sillConstInfo.maxLv))

	-- 解锁技能
	local unlockSkill = {}
	for i, sillInfo in ipairs(game.data.skill) do
		for i,v in ipairs(sillInfo.lastSid) do
			if v==sillConstInfo.sid and skillLv>=sillInfo.lastLv[i] then
				table.insert(unlockSkill, sillInfo.sid)
			end
		end
	end
	for i, v in ipairs(unlockSkill) do
		local strTmp = string.format("%d", v)
		local skillNode = self.skillPanel:getChildByName(strTmp)
		skillNode:setColor(cc.c3b(255, 255, 255))
		skillNode:getChildByName("lock"):setVisible(false)
		if v==1003 then
			if skillList[1001]~=nil then
				self.setUnlockLine("_1001")
			end
			if skillList[1002]~=nil then
				self.setUnlockLine("_1002")
			end
			self.setUnlockLine("1001_1002")
			self.setUnlockLine("_1003")
			self.setUnlockLine("_1004")
		elseif v==1005 then
			self.setUnlockLine("1001_1005_")
		elseif v==1006 then
			self.setUnlockLine("1002_1006_")
		end
		self.setUnlockLine(strTmp)
	end

	self.allotUI.refreshInfo()
end
