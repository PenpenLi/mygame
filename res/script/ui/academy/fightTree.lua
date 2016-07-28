--
--
-- ui/academy/fightTree.lua
-- 战争科技树
--===================================
require "ui/fullScreenFrame"


UI_fightTree = class("UI_fightTree", UI)


--init
function UI_fightTree:init()
	-- data
	-- ===============================
	local buildLv = 21
	local researchMgr = player.researchMgr
	local researchType = 1


	-- ui
	-- ===============================
	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTitle(hp.lang.getStrByID(9101))

	local widgetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "fightTree.json")

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

	-- 设置开锁、解锁线条
	local function setUnlockLine(lineName)
		local lineNode = linePanel:getChildByName(lineName)
		if lineNode~=nil then
			if lineNode:getTag()==-91 then
				lineNode:loadTexture(imgLineUnlockH)
			else
				lineNode:loadTexture(imgLineUnlockV)
			end
		end
	end

	-- 技能点击响应
	local function onSkillTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			require("ui/academy/researchInfo")
			local ui = UI_researchInfo.new(researchType, sender:getTag())
			self:addModalUI(ui)
		end
	end

	-- 刷新技能树
	local function refreshSkillTree()
		local skillid = 1
		local strSkill = ""
		local skillNode = nil
		local nextLvInfo = nil
		local maxLv = 1
		local curLv = 1
		local lockFlag = true

		for i, sillInfo in ipairs(game.data.research) do
			if sillInfo.type==researchType and sillInfo.level==1 then
				skillid = math.floor(sillInfo.sid/100)
				strSkill = string.format("%d", skillid)
				skillNode = skillPanel:getChildByName(strSkill)

				-- 获取技能最大等级，下一等级信息
				maxLv = researchMgr.getResearchMaxLv(skillid)
				nextLvInfo = researchMgr.getResearchNextLvInfo(skillid)
				if nextLvInfo~=nil then
					curLv = nextLvInfo.level - 1
				else
					curLv = maxLv
					nextLvInfo = sillInfo
				end

				skillNode:setTag(skillid)
				skillNode:getChildByName("name"):setString(sillInfo.name)
				skillNode:getChildByName("progress"):setPercent(curLv*100/maxLv)
				skillNode:getChildByName("desc"):setString(string.format("%d/%d", curLv, maxLv))
				skillNode:addTouchEventListener(onSkillTouched)

				-- 判断是否解锁
				lockFlag = true
				if buildLv>=nextLvInfo.buildLv then
					-- 建筑达到等级
					if sillInfo.mustSid[1]==-1 then
						--解锁
						lockFlag = false
					else
						lockFlag = false
						for i,v in ipairs(nextLvInfo.mustSid) do
							local id = math.floor(v/100)
							if id~=skillid then
								if researchMgr.getResearchLv(id)<v%100 then
									lockFlag = true
								elseif skillid==112 or skillid==114 or skillid==124 or skillid==126 or skillid==130 or skillid==132 then
									setUnlockLine(string.format("%d_%d", id, skillid))
								end
							end
							--getSkillLv
						end
					end
				end

				if lockFlag then
					skillNode:setColor(colorLock)
				else
					skillNode:setColor(colorUnlock)
					skillNode:getChildByName("lock"):setVisible(false)
					if skillid~=110 then
						setUnlockLine(strSkill)
						if skillid==112 then
							setUnlockLine("111_112")
						elseif skillid==114 then
							setUnlockLine("111_114")
						end
					end
				end

			end -- end if sillInfo.type==researchType and sillInfo.level==1
		end
	end
	refreshSkillTree()

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(widgetRoot)
end
