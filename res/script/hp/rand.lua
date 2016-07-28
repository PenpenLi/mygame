

hp.Rand = class("hp.Rand")


function hp.Rand:ctor(seed_)
	self.A = 16807
	self.M = 2147483647
	self.R = 2836
	self.Q = 127773
	self.MASK = 123459876

	--随机种子
	self.seed = seed_ 
end


function hp.Rand:getSeed()
	return self.seed
end

function hp.Rand:setSeed(seed_)
	self.seed = seed_
end

-- bit.bnot(a) - 返回一个a的补充   
-- bit.band(w1,...) - 返回w的位与   
-- bit.bor(w1,...) - 返回w的位或   
-- bit.bxor(w1,...) - 返回w的位异或   
-- bit.lshift(a,b) - 返回a向左偏移到b位   
-- bit.rshift(a,b) - 返回a逻辑右偏移到b位   
-- bit.arshift(a,b) - 返回a算术偏移到b位   
-- bit.mod(a,b) - 返回a除以b的整数余数  
function hp.Rand:randomInt()
	local r = bit.bxor(self.seed, self.MASK)
	local k = math.floor(r/self.Q)
	r=self.A*(r-k*self.Q)-self.R*k
	if r<0 then
		r = r+self.M
	end
	self.seed = r
	return r
end

function hp.Rand:randomValue(v1, v2)
	if v2>v1 then
		if v2==v1+1 then
			return v1
		end
		return self:randomInt()%(v2-v1)+v1
	elseif v1>v2 then
		if v1==v2+1 then
			return v2
		end
		return randomInt()%(v1-v2)+v2
	end
	return v1
end



--local rr = hp.Rand.new(100155)
--local nums = {0, 0, 0, 0, 0}
--local tmp = 1
--
--print(os.clock())
--for i=1, 10000000 do
--	tmp = rr:randomValue(6, 11)
--	nums[tmp-5] = nums[tmp-5]+1
--end
--print(os.clock())
--print(json.encode(nums))