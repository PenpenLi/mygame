--
-- file: hp/common.lua
-- desc: 一些基础函数
--================================================


hp.common = {}

-- 四舍五入函数
-- value_
-- 需要处理的数字
-------------------------------------------
function hp.common.round(value_)
	local floor = math.floor(value_)
	if (value_ - floor) >= 0.5 then
		return math.ceil(value_)
	else
		return floor
	end
end

-- 获取一个表的大小
function hp.common.getTableTotalNum(table_)
	local len_ = 0
	for i, v in pairs(table_) do
		len_ = len_ + 1
	end
	return len_
end

-- 获取列表中的最小值
-- list_: {1,2,3,4,5}
function hp.common.getMinNumber(list_)
	local num_ = 0
	for i,v in pairs(list_) do
		num_ = num_ + 1
	end

	if num_ == 0 then
		return nil
	end

	local min = list_[1]
	for i,v in pairs(list_) do
		if min > v then
			min = v
		end
	end
	return min
end

-- 获取列表中的最大值
-- list_: {1,2,3,4,5}
function hp.common.getMaxNumber(list_)
	local num_ = 0
	for i,v in pairs(list_) do
		num_ = num_ + 1
	end

	if num_ == 0 then
		return nil
	end

	local max = list_[1]
	for i,v in pairs(list_) do
		if max < v then
			max = v
		end
	end
	return max
end

-- 
-- name : stringSub
-- desc : 截取utf-8字符串
-- @param str_ : 源字符串
-- @param i_ : 从第i_个字开始截取
-- @param j_ : 截取到第j_个字
-------------------------------------------
function hp.common.stringSub(str_, i_, j_)
	local i = 1
	local j = 1
	local len = #str_
	local byte = 0

	for x=1, i_-1 do
		if i>=len then
			break
		end

		byte = string.byte(str_, i)
		if byte >= 240 then
			i = i+4
		elseif byte >= 224 then
			i = i+3
		elseif byte >= 192 then
			i = i+2
		else
			i = i+1
		end
	end

	for x=1, j_ do
		if j>=len then
			j = j+1
			break
		end

		byte = string.byte(str_, j)
		if byte >= 240 then
			j = j+4
		elseif byte >= 224 then
			j = j+3
		elseif byte >= 192 then
			j = j+2
		else
			j = j+1
		end
	end

	j = j-1

	return string.sub(str_, i, j)
end


-- 
-- name : stringSub
-- desc : 获取utf-8字符串前n_个字符，一个汉字算两个字符
-- @param str_ : 源字符串
-- @param n_ : 截取字符个数
-------------------------------------------
function hp.common.utf8_strSub(str_, n_)
	-- 获取要截取长度
	local n = 0
	local len = #str_
	local byte = 0

	local pos = 1
	while pos<=len do
		byte = string.byte(str_, pos)
		if byte >= 192 then
		-- 汉字
			n = n+2
			if n>n_ then
				pos = pos-1
				break
			end
			if byte >= 240 then
				pos = pos+4
			elseif byte >= 224 then
				pos = pos+3
			else
				pos = pos+2
			end
		else
			n = n+1
			if n>n_ then
				pos = pos-1
				break
			end
			pos = pos+1
		end
	end

	if pos==0 then
		return ""
	end
	return string.sub(str_, 1, pos)
end

--数值转换  超过1千用K表示，精确到小数点后一位
function hp.common.changeNumUnit(num)
	if num > 1000 then 
		local temp=string.format("%0.1f", num/1000)
		local len = string.len(temp)
		if string.sub(temp, len, len) == "0" then
			return string.sub(temp, 1, len-2) .."K"
		end
		return temp.."K"
	end
	return num
end
