--
-- file: playerData/globalData.lua
-- desc: 全局数据,主要是一些枚举类型
--================================================

-- 全局数据
-- ==================

-- 科技加成
-- ==================
globalData = {}

-- 阵营
-- ==================
globalData.ARMY_BELONG = {
	ME = 0,
	ENEMY = 1,
	ALLIANCE = 2,
	NONE = 3,
}

function globalData.getArmyBelong(id_, unionID_)
	if player.getID()==id_ then
		return globalData.ARMY_BELONG.ME
	else
		if (player.getAlliance():getUnionID()==0) or (unionID_~=player.getAlliance():getUnionID()) then
			return globalData.ARMY_BELONG.ENEMY
		else
			return globalData.ARMY_BELONG.ALLIANCE
		end
	end
end

-- buff出处
globalData.ADDNFILTER = {
	RESEARCH = 1,
	HERO = 2,
	VIP = 4,
	ITEMBUF = 8,
	SPECIALBUF = 16,
	BUILDBUFF = 32,
	TITLEBUFF = 64,
}

-- 充值系数
globalData.CHARGE_COEF = 10

-- 场景类型
globalData.SCENETYPE = {
	WORLD = 1, 	-- 世界地图
	KINDOM = 2,	-- 王国地图
	CITY = 3,	-- 城市
	LOGIN = 4,	-- 登录界面
}

-- 出兵的类型
globalData.MARCH_TYPE = {
	ATTACK_CITY 		= 1,	-- 攻击城市
	ATTACK_RESOURCE		= 2,	-- 攻击资源点敌军
	ATTACK_BOSS			= 3,	-- 攻击BOSS
	ATTACK_CAMP			= 4,	-- 攻击营地
	ATTACK_FORTRESS		= 5,	-- 攻击要塞
	OCCUPY_EMPTY 		= 6,	-- 占领空地
	OCCUPY_RESOURCE		= 7,	-- 占领资源点
	RALLY_CITY			= 8,	-- 集火城市
	RALLY_FORTRESS		= 9,	-- 集火要塞
	REINFORCE			= 10,	-- 增援
	DONATE				= 11,	-- 集火捐兵
}

-- 行军类型
globalData.ARMY_TYPE = {
	MARCH_TO = 1,
	CAMP_ING = 2,
	SOURCE_ING = 3,
	SCOUT_TO = 4,
	SOURCE_TO = 5,
	REINFORCE_TO = 6,
	MARCH_BACK = 7,
	LEAGUECITY = 8,
	RALLYING = 9,
	KING_BATTLE_TO = 10,
	KING_BATTLE_OCCUPY = 11,
	KING_BATTLE_RALLY = 12,
	SOURCE_GOLD = 13,	-- 采集钻石特殊处理
}

-- 行军功能func：0-无，1-召回，2-查看，3-前往，4-加速，5-取消集结
globalData.ARMY_FUNC = {
	{backCost=true,loadingBar=true,func={1,2,3,4},speedup=true},	-- 行军
	{backCost=false,loadingBar=false,func={1,2,3,0},speedup=false},	-- 营地
	{backCost=false,loadingBar=true,func={1,2,3,0},speedup=false},	-- 采集
	{backCost=true,loadingBar=true,func={1,0,3,4},speedup=true},	-- 侦查
	{backCost=true,loadingBar=true,func={1,0,3,4},speedup=true},	-- 援助
	{backCost=true,loadingBar=true,func={1,2,3,4},speedup=true},	-- 捐兵
	{backCost=false,loadingBar=true,func={0,2,3,4},speedup=true},	-- 返回
	{backCost=false,loadingBar=false,func={1,2,3,0},speedup=false},	-- 派遣
	{backCost=false,loadingBar=true,func={5,0,3,0},speedup=false},	-- 集结
	{backCost=true,loadingBar=true,func={1,2,3,4},speedup=true},	-- 国王战
	{backCost=false,loadingBar=false,func={1,2,3,0},speedup=false},	-- 占领重镇
	{backCost=false,loadingBar=true,func={5,0,3,0},speedup=false},	-- 集结
	{backCost=false,loadingBar=true,func={1,2,3,0},speedup=false},	-- 采集钻石
}

-- 国王战开启情况
globalData.OPEN_STATUS = {
	OPEN = 0,
	CLOSE = 1,
	NOT_OPEN = 2,
}

-- 士兵总级数
globalData.TOTAL_LEVEL = 4

-- 士兵类型数
globalData.SOLDIER_TYPE = 4

globalData.ACTIVITY_STATUS = {
	OPEN = 0,
	CLOSE = 1,
	NOT_OPEN = 2,
}