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
	MISSION_COLLECT = 9,			-- 任务奖励领取
	MISSION_COMPLETE = 10,	  		-- 任务完成
	MISSION_REFRESH = 11,			-- 任务刷新
	MISSION_DAILY_START = 12,		-- 日常任务开始
	MISSION_DAILY_REFRESH = 13,		-- 日常任务刷新
	MISSION_DAILY_COMPLETE = 14,	-- 日常任务完成
	MISSION_DAILY_COLLECTED = 15,	-- 日常任务奖励领取
	MISSION_DAILY_QUICKFINISH = 16,	-- 日常任务快速完成
	CD_STARTED = 18,				 --cd开始 param={cdType=cd类型, cdInfo=cd信息}
	CD_FINISHED = 19,				 --cd结束 param={cdType=cd类型, cdInfo=cd信息}
	--医馆
	HOSPITAL_CHOOSE_SOLDIER = 20,		-- 选择伤兵
	HOSPITAL_HEAL_FINISH = 21,		-- 治疗完成
	HOSPITAL_HURT_REFRESH = 22,		-- 伤兵刷新
	SOLDIER_NUM_CHANGE = 23,		-- 士兵变化	1-城内 2-总士兵 3-野外 4-伤兵
	TRAP_MESSAGE = 24,				-- 陷阱消息 {mstType:1-解散 2-刷新}
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
	HERO_LV_UP = 50,                -- 武将升级提示
	COPY_DATA_REQUEST = 52,			-- 副本数据请求
	COPY_NOTIFY = 53,				-- 副本通知消息
	UNION_NOTIFY = 54,				-- 联盟通知 {详见 unionHttpHelper}
	CHANGE_CITYNAME = 55,			-- 主城改名
	BUF_NOTITY = 56,				-- buf刷新 {msgType: 1-道具buf}
	MAIN_MENU_MANSION_LIGHT = 57,	--通知主菜单按钮闪亮消息
	PM_CHECK_CHANGE = 58,			--丞相
	FAMOUS_HERO_NUM_CHANGE = 59,	--名将列表变化
	CD_CHANGED = 60,				--cd改变
	UPGRADEGIFT_GET = 61,			--府邸升级礼包领取
	ARMY_CONFLICT = 62,				--军队冲突 {msgType:1-刷新}
	SOURCEUI_CLOSE = 63,			--关闭资源UI {param:belong}
	SOLO_ACTIVITY = 64,				--单人活动
	KING_BATTLE = 65,				--国王争夺战
	TITLE_INFO = 66,				--头衔信息
	CITY_POS_CHANGED = 67,          --城市位置发生变化
	UNION_ACTIVITY = 68,			-- 联盟活动
	GOLD_SHOP = 69,					-- 钻石商城
	SIGN_IN = 70,					-- 签到
	PUSH_CONFIG = 71,				-- 推送配置
	KINGDOM_ACTIVITY = 72,			-- 王国活动
	WORLD_INFO = 73,				-- 世界地图
	NOVICE_GIFT = 74,				-- 新手礼包
}


-- 消息处理者
local msgMgr = {}

-- init
-- 初始化
-----------------------------------------
function hp.msgCenter.init()
end

-- addMsgMgr
-- 添加消息处理
-----------------------------------------
function hp.msgCenter.addMsgMgr(msg_, mgr_)
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
	if msgMgr[msg_]~=nil then
		for i,v in ipairs(msgMgr[msg_]) do
			v:onMsg(msg_, param_)
		end
	end

	cclog_("sendMsg:", msg_, table.getn(msgMgr[msg_]or{}))
end
