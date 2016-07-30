--
-- file: obj/cdBox.lua
-- desc: cd队列
--================================================
-- BUILD(1)建筑类型,DONATE(2)捐赠类,ABILITY(3)科技类,BRANCH(4)士兵训练类,TRAP(5)陷阱训练,EQUIP(6)装备制造,
-- VIP(7)vip状态激活,PEACE(8)和平盾状态,FORBIDVIEW(9)-禁止查看状态,KILLHERO(10)-杀死一个英雄
-- DAILYTASK(11)日常任务, LEAGUETASK(12)联盟任务, VIPTASK(13)vip任务,REMEDY(14)-复活士兵
-- INDUCE(15) 招降

-- cdBox obj
cdBox = {}


-- cd类型
cdBox.CDTYPE = 
{
	BUILD = 1, --建筑
	DONATE = 2, --捐赠
	RESEARCH = 3, --科技
	BRANCH = 4, --士兵训练
	TRAP = 5, --陷阱训练
	EQUIP = 6, --装备锻造
	VIP = 7, --vip状态激活
	PEACE = 8, --和平盾状态
	FORBIDVIEW = 9, --禁止查看状态
	KILLHERO = 10, --杀死一个英雄
	DAILYTASK = 11, --日常任务
	LEAGUETASK = 12, --联盟任务
	VIPTASK = 13,--vip任务
	REMEDY = 14,--治疗伤兵
	INDUCE = 15,--招降英雄
	MARCH = 16,--行军
	CROSS_KINGDOM = 17, --跨服
}


--
-- private datas
---------------------------------
local cdBoxData = {}

local cdIconList = 
{
	"cd_icon_build.png",   --1
	"cd_icon_build.png",   --2
	"cd_icon_research.png", --3
	"cd_icon_remedy.png", --4
	"cd_icon_trap.png", --5
	"cd_icon_equip.png", --6
	"cd_icon_build.png", --7
	"cd_icon_build.png", --8
	"cd_icon_build.png", --9
	"cd_icon_build.png", --10
	"cd_icon_dailytask.png", --11
	"cd_icon_leaguetask.png", --12
	"cd_icon_viptask.png", --13
	"cd_icon_remedy.png", --14
	"cd_icon_build.png", --15
	"cd_icon_march.png", --16
	"cd_icon_march.png", --17
}


--
-- private functions
---------------------------------
local handleCDFinish


--
-- public functions
---------------------------------

-- init
function cdBox.init()
	for k, v in pairs(cdBox.CDTYPE) do
		cdBoxData[v] = {}
		cdBoxData[v].cd = 0
		cdBoxData[v].total_cd = 0
		cdBoxData[v].helped = false
	end
end

-- initCD
function cdBox.initCD(data_)
	local cdData = data_.cd
	if cdData~=nil then
		for i=1, #cdData, 3 do
			cdBoxData[cdData[i]].cd = cdData[i+1]
			cdBoxData[cdData[i]].total_cd = cdData[i+2]
		end
	end

	cdBox.initCDInfo(cdBox.CDTYPE.BUILD, data_.build_cd, true)
	cdBox.initCDInfo(cdBox.CDTYPE.RESEARCH, data_.ability_cd, true)
	cdBox.initCDInfo(cdBox.CDTYPE.EQUIP, data_.equipcd, true)
	cdBox.initCDInfo(cdBox.CDTYPE.BRANCH, data_.branch_cd, true)
	cdBox.initCDInfo(cdBox.CDTYPE.TRAP, data_.trap_cd, true)
	cdBox.initCDInfo(cdBox.CDTYPE.REMEDY, data_.branchHN, true)
	cdBox.initCDHelpInfo(data_.cdh)
end

-- initCDInfo
function cdBox.initCDInfo(cdType_, infoData_, notMsg_)
	if infoData_==nil then
		return
	end

	local cdInfo = cdBoxData[cdType_]
	cdInfo.helped = false

	if cdType_==cdBox.CDTYPE.BUILD then
	--1---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.type = infoData_[3] --类型：建造or升级or拆除
		cdInfo.sid = infoData_[4] --建筑sid
		cdInfo.level = infoData_[5] --建筑等级

	elseif cdType_==cdBox.CDTYPE.DONATE then
	--2---------------------------------

	elseif cdType_==cdBox.CDTYPE.RESEARCH then
	--3---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.sid = infoData_[3] --科技的sid

	elseif cdType_==cdBox.CDTYPE.BRANCH then
	--4---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.type = infoData_[3] --兵种
		cdInfo.number = infoData_[4] --造兵数量

	elseif cdType_==cdBox.CDTYPE.TRAP then
	--5---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总cd
		cdInfo.sid = infoData_[3] --城防类型sid
		cdInfo.number = infoData_[4] --个数

	elseif cdType_==cdBox.CDTYPE.EQUIP then
	--6---------------------------------
		cdInfo.cd = infoData_[1] --cd
		cdInfo.total_cd = infoData_[2] --总计cd
		cdInfo.equip = infoData_[3] --锻造装备sid
		cdInfo.id = infoData_[4] --锻造装备id
		cdInfo.level = infoData_[5] --锻造装备等级
		cdInfo.materials = infoData_[6] --锻造材料列表

	elseif cdType_==cdBox.CDTYPE.VIP then
	--7---------------------------------

	elseif cdType_==cdBox.CDTYPE.PEACE then
	--8---------------------------------

	elseif cdType_==cdBox.CDTYPE.FORBIDVIEW then
	--9---------------------------------

	elseif cdType_==cdBox.CDTYPE.KILLHERO then
	--10---------------------------------
	elseif cdType_==cdBox.CDTYPE.DAILYTASK then
	--11---------------------------------		
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	elseif cdType_==cdBox.CDTYPE.LEAGUETASK then
	--12---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	elseif cdType_==cdBox.CDTYPE.VIPTASK then
	--13---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	elseif cdType_==cdBox.CDTYPE.REMEDY then
	--14---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
		cdInfo.soldier = {}
		for i = 1, globalData.TOTAL_LEVEL do
			cdInfo.soldier[i] = infoData_[2 + i]
		end
	
	elseif cdType_==cdBox.CDTYPE.REMEDY then
	--16---------------------------------
		cdInfo.cd = infoData_[1]
		cdInfo.total_cd = infoData_[2]
	end

	if not notMsg_ then
		hp.msgCenter.sendMsg(hp.MSG.CD_STARTED, {cdType=cdType_, cdInfo=cdInfo})
	end
end

-- synData
function cdBox.synData(data_)
	if data_~=nil then
		-- 未查到的，完成cd
		for cdType, cdInfo in pairs(cdBoxData) do
			if cdInfo.cd~=0 then
				local fIndex = 0
				for i=1, #data_, 3 do
					if cdType==data_[i] then
						fIndex = i
						break
					end
				end

				if fIndex==0 then
				-- 未查到，cd已结束
					cdBox.setCD(cdType, 0)
				end
			end
		end

		-- 重新设置cd
		for i=1, #data_, 3 do
			cdBox.setCD(data_[i], data_[i+1], data_[i+2])
		end
	end
end

-- initCDInfo
function cdBox.initCDHelpInfo(data_)
	if data_~=nil then
		for i,v in ipairs(data_) do
			local cdInfo = cdBoxData[v]
			cdInfo.helped = true
		end
	end
end

--getCDInfo
function cdBox.getCDInfo(cdType_)
	return cdBoxData[cdType_]
end

--setCDInfo
function cdBox.setCDInfo(cdType_, cdInfo_)
	cclog_("setCDInfo",cdType_)
	cdBoxData[cdType_] = cdInfo_
end

--getCD
function cdBox.getCD(cdType_)
	return cdBoxData[cdType_].cd
end

--setCD
function cdBox.setCD(cdType_, cd_, total_)
	local cdInfo = cdBoxData[cdType_]
	if total_ ~= nil then
		cdInfo.total_cd = total_
	end

	if cdInfo.cd~=0 and cd_==0 then
	-- 完成cd
		cdInfo.cd = cd_
		handleCDFinish(cdType_, cdInfo)
		hp.msgCenter.sendMsg(hp.MSG.CD_FINISHED, {cdType=cdType_, cdInfo=cdInfo})
	elseif cdInfo.cd==0 and cd_~=0 then
	-- 开始cd
		cdInfo.cd = cd_
		hp.msgCenter.sendMsg(hp.MSG.CD_STARTED, {cdType=cdType_, cdInfo=cdInfo})
	else
		cdInfo.cd = cd_
		hp.msgCenter.sendMsg(hp.MSG.CD_CHANGED, {cdType=cdType_, cdInfo=cdInfo})
	end
end

--addCD
function cdBox.addCD(cdType_, dt_)
	local cdInfo = cdBoxData[cdType_]
	cdInfo.cd = cdInfo.cd + dt_
end

--speedCD
function cdBox.speedCD(cdType_, dt_)
	local cdInfo = cdBoxData[cdType_]
	if cdInfo.cd~=0 then
		if cdInfo.cd>dt_ then
			cdInfo.cd = cdInfo.cd-dt_
		else
			cdInfo.cd = 0
			handleCDFinish(cdType_, cdInfo)
			hp.msgCenter.sendMsg(hp.MSG.CD_FINISHED, {cdType=cdType_, cdInfo=cdInfo})
		end
	end
end

--cancleCD
function cdBox.cancleCD(cdType_)
	cdBoxData[cdType_].cd = 0
end

-- canVisible
-- 是否可以在cd列表中显示
function cdBox.canVisible(cdType_)
	if cdType_==cdBox.CDTYPE.BUILD
		or cdType_==cdBox.CDTYPE.RESEARCH
		or cdType_==cdBox.CDTYPE.BRANCH
		or cdType_==cdBox.CDTYPE.TRAP
		or cdType_==cdBox.CDTYPE.EQUIP
		or cdType_==cdBox.CDTYPE.DAILYTASK
		or cdType_==cdBox.CDTYPE.LEAGUETASK
		or cdType_==cdBox.CDTYPE.VIPTASK
		or cdType_==cdBox.CDTYPE.REMEDY 
		or cdType_==cdBox.CDTYPE.MARCH
		or cdType_==cdBox.CDTYPE.CROSS_KINGDOM then

		return true
	end

	return false
end

-- canSpeed
-- 是否可以加速
function cdBox.canSpeed(cdType_)
	if cdType_==cdBox.CDTYPE.BUILD
		or cdType_==cdBox.CDTYPE.RESEARCH
		or cdType_==cdBox.CDTYPE.BRANCH
		or cdType_==cdBox.CDTYPE.TRAP
		or cdType_==cdBox.CDTYPE.EQUIP
		or cdType_==cdBox.CDTYPE.DAILYTASK
		or cdType_==cdBox.CDTYPE.LEAGUETASK
		or cdType_==cdBox.CDTYPE.VIPTASK
		or cdType_==cdBox.CDTYPE.REMEDY 
		or cdType_==cdBox.CDTYPE.MARCH then

		return true
	end

	return false
end

-- canFreeSpeed
function cdBox.canFreeSpeed(cdType_)
	if cdType_==cdBox.CDTYPE.BUILD
		or cdType_==cdBox.CDTYPE.RESEARCH then

		return true
	end

	return false
end

-- canHelp
function cdBox.canHelp(cdType_)
	if cdBox.canFreeSpeed(cdType_) then
		if player.getAlliance():getUnionID()~=0 then
			local cdInfo = cdBoxData[cdType_]
			if cdInfo.helped then
				return false
			else
				return true
			end
		end
	end

	return false
end

-- help
function cdBox.help(cdType_)
	local cdInfo = cdBoxData[cdType_]
	cdInfo.helped = true
end

-- getIconFile
function cdBox.getIconFile(cdType_)
	return config.dirUI.common .. cdIconList[cdType_]
end

-- getDescInfo
function cdBox.getDescInfo(cdType_)
	local cdInfo = cdBoxData[cdType_]
	if cdType_==cdBox.CDTYPE.BUILD then
	--1---------------------------------
		local sInfo = hp.gameDataLoader.getInfoBySid("building", cdInfo.sid)
		if sInfo==nil then
		-- 兼容一下老版本，未找到建筑
			return nil
		end
		local strType
		if cdInfo.type==1 then
			strType = hp.lang.getStrByID(2023)
		elseif cdInfo.type==2 then
			strType = hp.lang.getStrByID(2021)
		else
			strType = hp.lang.getStrByID(2402)
		end
		return string.format("%s %slv%d", strType, sInfo.name, cdInfo.level)
	elseif cdType_==cdBox.CDTYPE.DONATE then
	--2---------------------------------
	elseif cdType_==cdBox.CDTYPE.RESEARCH then
	--3---------------------------------
		local sInfo = hp.gameDataLoader.getInfoBySid("research", cdInfo.sid)
		if sInfo==nil then
		-- 兼容一下老版本，未找到科技
			return nil
		end
		return string.format("%slv%d", sInfo.name, sInfo.level)
	elseif cdType_==cdBox.CDTYPE.BRANCH then
	--4---------------------------------
		local sInfo = player.soldierManager.getArmyInfoByType(cdInfo.type)
		return string.format("%s × %d", sInfo.name, cdInfo.number)
	elseif cdType_==cdBox.CDTYPE.TRAP then
	--5---------------------------------
		local sInfo = hp.gameDataLoader.getInfoBySid("trap", cdInfo.sid)
		return string.format("%s × %d", sInfo.name, cdInfo.number)
	elseif cdType_==cdBox.CDTYPE.EQUIP then
	--6---------------------------------
		local sInfo = hp.gameDataLoader.getInfoBySid("equip", cdInfo.equip)
		return sInfo.name
	elseif cdType_==cdBox.CDTYPE.VIP then
	--7---------------------------------
	elseif cdType_==cdBox.CDTYPE.PEACE then
	--8---------------------------------
	elseif cdType_==cdBox.CDTYPE.FORBIDVIEW then
	--9---------------------------------
	elseif cdType_==cdBox.CDTYPE.KILLHERO then
	--10---------------------------------
	elseif cdType_==cdBox.CDTYPE.DAILYTASK then
	--11---------------------------------
		local questInfo = player.questManager.getDoingDailyInfo(1)
		if questInfo~=nil then
			local qualityName = {1425,1424,1423,1422,1421,1420}
			return hp.lang.getStrByID(qualityName[questInfo.quality])
		end
	elseif cdType_==cdBox.CDTYPE.LEAGUETASK then
	--12---------------------------------
		local questInfo = player.questManager.getDoingDailyInfo(2)
		if questInfo~=nil then
			local qualityName = {1425,1424,1423,1422,1421,1420}
			return hp.lang.getStrByID(qualityName[questInfo.quality])
		end
	elseif cdType_==cdBox.CDTYPE.VIPTASK then
	--13---------------------------------
		local questInfo = player.questManager.getDoingDailyInfo(3)
		if questInfo~=nil then
			local qualityName = {1425,1424,1423,1422,1421,1420}
			return hp.lang.getStrByID(qualityName[questInfo.quality])
		end
	elseif cdType_==cdBox.CDTYPE.REMEDY then
	--14---------------------------------
	end

	return nil
end


-- heartbeat
function cdBox.heartbeat(dt)
	for cdType, cdInfo in pairs(cdBoxData) do
		if cdInfo.cd~=0 then
			if cdInfo.cd>dt then
				cdInfo.cd = cdInfo.cd-dt
			else
				cdInfo.cd = 0
				handleCDFinish(cdType, cdInfo)
				hp.msgCenter.sendMsg(hp.MSG.CD_FINISHED, {cdType=cdType, cdInfo=cdInfo})
			end
		end
	end
end


--
-------------------------------------------

-- handleCDFinish
-- cd结束处理
function handleCDFinish(cdType_, cdInfo_)
	if cdType_==cdBox.CDTYPE.BUILD then
	--1---------------------------------

	elseif cdType_==cdBox.CDTYPE.DONATE then
	--2---------------------------------

	elseif cdType_==cdBox.CDTYPE.RESEARCH then
	--3---------------------------------

	elseif cdType_==cdBox.CDTYPE.BRANCH then
	--4---------------------------------
		player.soldierManager.soldierTrainFinish(cdInfo_)

	elseif cdType_==cdBox.CDTYPE.TRAP then
	--5---------------------------------
		player.trapManager.trapTrainFinish(cdInfo_)

	elseif cdType_==cdBox.CDTYPE.EQUIP then
	--6---------------------------------
		player.equipBag.addEquip({cdInfo_.equip, cdInfo_.id, cdInfo_.level, {0, 0, 0}})

	elseif cdType_==cdBox.CDTYPE.VIP then
	--7---------------------------------

	elseif cdType_==cdBox.CDTYPE.PEACE then
	--8---------------------------------

	elseif cdType_==cdBox.CDTYPE.FORBIDVIEW then
	--9---------------------------------

	elseif cdType_==cdBox.CDTYPE.KILLHERO then
	--10---------------------------------
	elseif cdType_==cdBox.CDTYPE.DAILYTASK then
	--11---------------------------------
		player.questManager.dailyTaskFinish(cdType_, cdInfo_)
	elseif cdType_==cdBox.CDTYPE.LEAGUETASK then
	--12---------------------------------
		player.questManager.dailyTaskFinish(cdType_, cdInfo_)
	elseif cdType_==cdBox.CDTYPE.VIPTASK then
	--13---------------------------------
		player.questManager.dailyTaskFinish(cdType_, cdInfo_)
	elseif cdType_==cdBox.CDTYPE.REMEDY then
	--14---------------------------------
		player.soldierManager.healSoldierFinish(cdInfo_.soldier)
	end
end