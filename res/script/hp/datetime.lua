--
-- file: hp/datetime.lua
-- desc: 时间相关函数
--================================================


hp.datetime = {}

-- strTime
-- 将秒数转换为时间字符串
-------------------------------------------
function hp.datetime.strTime(second_)
	if second_>=86400 then
		return string.format("%dd %02d:%02d:%02d", math.floor(second_/86400), math.floor((second_%86400)/3600), math.floor((second_%3600)/60), math.floor(second_%60))
	elseif second_>=3600 then
		return string.format("%02d:%02d:%02d", math.floor(second_/3600), math.floor((second_%3600)/60), math.floor(second_%60))
	elseif second_>=60 then
		return string.format("%02d:%02d", math.floor(second_/60), math.floor(second_%60))
	end

	return string.format("00:%02d", math.floor(second_))
end

-- strTimeAgo
-- 。。时间以前
-------------------------------------------
function hp.datetime.strTimeAgo(second_)
	if second_<=0 then
		second_ = 1
	end

	if second_>=86400 then
		return string.format("%d天以前", math.floor(second_/86400))
	elseif second_>=3600 then
		return string.format("%d小时以前", math.floor(second_/3600))
	elseif second_>=60 then
		return string.format("%d分钟以前", math.floor(second_/60))
	end

	return string.format("%d秒以前", second_)
end

-- strTime
-- 超过1天显示xd 一天内显示 00:00:00 形式
-------------------------------------------
function hp.datetime.strTime1(second_)
	if second_<0 then
		second_ = 0
	end
	if second_>=86400 then
		return string.format("%dd", math.floor(second_/86400))
	elseif second_>=3600 then
		return string.format("%02d:%02d:%02d", math.floor(second_/3600), math.floor((second_%3600)/60), math.floor(second_%60))
	elseif second_>=60 then
		return string.format("%02d:%02d", math.floor(second_/60), math.floor(second_%60))
	end
	return string.format("00:%02d", math.floor(second_))
end