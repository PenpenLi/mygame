--
-- file: hp/msgCenter.lua
-- desc: hp消息管理中心
--================================================


hp.msgCenter = {}


-- 消息定义
hp.MSG =
{
	--资源变化
	RESOURCE_CHANGED = 1,			--资源变化
	--士兵训练
	BARRACK_TRAIN = 2,			    --士兵训练
	BARRACK_TRAIN_FIN = 3,		    --士兵训练完成
	TRAP_TRAIN = 4,				    --陷阱训练
	TRAP_TRAIN_FIN = 5,			    --陷阱训练完成
	MAIL_CHANGED = 6,				--邮件变化
	--调整伤兵
	CHANGE_HURT_SOLDIER = 7,
	ITEM_CHANGED = 8,				--道具变化param={sid=道具sid, num=道具个数}
	MISSION_COMPLETE = 9,			-- 任务完成
	MISSION_MAIN_STATUS_CHANGE = 10,	-- 任务状态改变
	MISSION_MAIN_REFRESH = 11,		-- 任务刷新
	MISSION_DAILY_CHANGE = 12,		-- 日常任务变化
	MISSION_DAILY_REFRESH = 13,		-- 日常任务更新
	MISSION_DAILY_COMPLETE = 14,	-- 日常任务结束
	MISSION_DAILY_COLLECTED = 15,	-- 日常任务奖励领取
	MISSION_DAILY_STATUS_CHANGE = 16,	-- 日常任务
	MISSION_DAILY_RECIEVE_CHANGE = 17,	-- 日常任务可领取的任务改变
	CD_STARTED = 18,				 --cd开始 param={cdType=cd类型, cdInfo=cd信息}
	CD_FINISHED = 19,				 --cd结束 param={cdType=cd类型, cdInfo=cd信息}
	--医馆
	HOSPITAL_CHOOSE_SOLDIER = 20,		-- 选择伤兵
	HOSPITAL_HEAL_FINISH = 21,		-- 治疗完成
	HOSPITAL_HURT_REFRESH = 22,		-- 伤兵刷新
	SOLDIER_NUM_CHANGE = 23,		-- 士兵变化
	TRAP_NUM_CHANGE = 24,			-- 陷阱数量变化
	--工会
	UNION_CHOOSE_ICON = 25,			-- 工会选择图标
	UNION_DATA_PREPARED = 26,		-- 公会数据准备好
	-- 聊天
	CHATINFO_NEW = 27,				--有新的聊天信息
	-- 地图添加军队
	MAP_ARMY_ATTACK = 28,			-- 地图添加部队
	FRIEND_MGR = 29,				--好友管理消息{}
	VIP = 30,						--vip状态变化的消息 param: 1--等级变化、2--积分变化、3--cd变化
	PRISON_MGR = 31,				--监狱管理
	FAMOUS_HERO_LIST_UPDATE = 32,	--名将页面刷新消息
	-- 公会
	UNION_SHOP_STAR_CLICK = 33,		-- 商店求购商品
	UNION_HELP_INFO_CHANGE = 34,	-- 公会帮助信息改变
	-- 使馆
	EMBASSY = 35,					-- 使馆 param: 1-类型
	GUIDE_STEP = 36,				-- 新手引导, param=当前步骤
	GUIDE_OVER = 37,				-- 新手引导结束，弹出公会钻石图标
	-- 书签
	BIGMAP_BOOKMARK = 38,			-- 大地图 书签 param[1]: 1-删除
	-- 关闭界面
	CLOSE_WINDOW = 39,				-- {1-士兵训练 2-陷阱训练}
	UNION_RECEIVE_GIFT = 40,		-- 领取联盟礼包
	ONLINE_GIFT = 41,				--在线礼包

	--角色相关
	LV_CHANGED = 42,				--等级变化
	EXP_CHANGED = 43,				--经验变化
	POWER_CHANGED = 44,				--战力变化
	HERO_INFO_CHANGE = 45,			-- 英雄信息变化
	SKILL_CHANGED = 46,				-- 英雄技能变化
	-- 行军管理
	MARCH_MANAGER = 47,
	MARCH_ARMY_NUM_CHANGE = 48,
	-- 进入公会
	UNION_JOIN_SUCCESS = 49,
	--武将相关
	HERO_LV_UP = 50,                 --武将升级提示
}

-- 消息处理者
hp.msgCenter.msgMgr = {}

-- init
-- 初始化
-----------------------------------------
function hp.msgCenter.init()
end

-- addMsgMgr
-- 添加消息处理
-----------------------------------------
function hp.msgCenter.addMsgMgr(msg_, mgr_)
	local msgMgr = hp.msgCenter.msgMgr

	if msgMgr[msg_]==nil then
		msgMgr[msg_] = {}
	else
		for i,v in ipairs(msgMgr[msg_]) do
			if v==mgr_ then
			-- 已添加
				return false
			end
		end
	end
	table.insert(msgMgr[msg_], mgr_)

	return true
end

-- removeMsgMgr
-- 移除消息处理
-----------------------------------------
function hp.msgCenter.removeMsgMgr(msg_, mgr_)
	local msgMgr = hp.msgCenter.msgMgr


	if msgMgr[msg_]~=nil then
		for i,v in ipairs(msgMgr[msg_]) do
			if v==mgr_ then
				table.remove(msgMgr[msg_], i)
				break
			end
		end
	end

	return true
end

-- sendMsg
-- 发送消息
-----------------------------------------
function hp.msgCenter.sendMsg(msg_, param_)
	local msgMgr = hp.msgCenter.msgMgr

	if msgMgr[msg_]~=nil then
		for i,v in ipairs(msgMgr[msg_]) do
			v:onMsg(msg_, param_)
		end
	end

	cclog_("sendMsg:", msg_)
end
