--
-- file: hp/lang.lua
-- desc: 多语言
--================================================


hp.lang = {}


hp.lang.ID = 
{
	Chinese = 1,        -- 简体
	Chinese_tw = 2,     -- 繁体
	English = 3,        -- 英文
}


-- init
-- 初始化
-----------------------------------------
function hp.lang.init()
	hp.lang.setCurrentLangID(hp.lang.ID.Chinese)
end

-- getStrByID
-- 通过id获取字符串
-----------------------------------------
function hp.lang.getStrByID(id_, defStr_)
	for i, v in ipairs(hp.langTable) do
		if v.id==id_ then
			return v.str
		end
	end

	if defStr_~=nil then
		return defStr_
	end

	return ""
end

-- getCurrentLangID
-- 获取当前语言的ID
-----------------------------------------
function hp.lang.getCurrentLangID(langId_)
	return hp.lang.CurrentID
end

-- setCurrentLangID
-- 设置当前语言
-----------------------------------------
function hp.lang.setCurrentLangID(langId_)
	if hp.lang.CurrentID==langId_ then
		return
	end

	hp.lang.CurrentID = langId_

	if hp.lang.CurrentID==hp.lang.ID.English then
		hp.langTable = hp.gameDataLoader.loadFileData("data/lang/English.tab")
	elseif hp.lang.CurrentID==hp.lang.ID.Chinese_tw then
		hp.langTable = hp.gameDataLoader.loadFileData("data/lang/Chinese_tw.tab")
	else
		hp.langTable = hp.gameDataLoader.loadFileData("data/lang/Chinese.tab")
	end
end
