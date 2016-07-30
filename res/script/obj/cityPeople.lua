--
-- obj/cityPeople.lua
-- 行人
--================================================


CityPeople = class("cityPeople")


--
-- auto functions
--==============================================

-- getSpriteFrames
local function getSpriteFrames(name_, fn_)
	local frames = {}
	local frameCache = cc.SpriteFrameCache:getInstance()
	frameCache:addSpriteFrames(string.format("%s%s/%s.plist", config.dirUI.animation, "cityMap", name_))
	for i=1, fn_ do
		local strName = string.format("animation/%s/%s/%d.png", "cityMap", name_, i)
		local frame = frameCache:getSpriteFrame(strName)
		if frame==nil then
			cclog_("getSpriteFrames=================", strName)
		else
			table.insert(frames, frame)
		end
	end

	return frames
end

--
-- ctor
-------------------------------
function CityPeople:ctor(container_, constInfo_)
	local stepNum = #constInfo_.x
	local peopleNode = cc.Sprite:create() -- 人物节点
	local aniFrames = nil
	peopleNode:setAnchorPoint(0.5, 0.2)
	container_.objLayer:addChild(peopleNode)

	local curStep = 0
	local nextStep = 0
	local dirStep = 1 --步骤进行方向
	local dirPeople = 1 --人朝向

	local function step()
		if nextStep==0 then
			curStep = math.random(stepNum)
			if math.random(2)==1 then
				dirStep = 1
			else
				dirStep = -1
			end
		else
			curStep = nextStep
		end

		-- 确定下一关键点
		if dirStep==1 then
		-- 正向前进到头
			if curStep>=stepNum then
				dirStep = -1
			end
		else
		-- 反向前进到头
			if curStep<=1 then
				dirStep = 1
			end
		end
		nextStep = curStep+dirStep

		-- 确定移动方向
		-- 设置人物节点和方向
		local x1 = constInfo_.x[curStep]
		local y1 = constInfo_.y[curStep]
		local x2 = constInfo_.x[nextStep]
		local y2 = constInfo_.y[nextStep]
		local ani
		local fn
		local ft
		local speed
		if dirStep==1 then
		-- 正向前进，取当前动画信息
			ani = constInfo_.ani[curStep]
			fn = constInfo_.fn[curStep]
			ft = constInfo_.ft[curStep]/1000
			speed = constInfo_.speed[curStep]
		else
		-- 反向前进，取前一步骤信息
			ani = constInfo_.ani[nextStep]
			fn = constInfo_.fn[nextStep]
			ft = constInfo_.ft[nextStep]/1000
			speed = constInfo_.speed[nextStep]
		end
		peopleNode:setPosition(x1, y1)
		if x1==x2 and y1==y2 then
		-- 原地动作
			if dirPeople==1 or dirPeople==2 then
				aniFrames = getSpriteFrames(ani.."1", fn)
			else
				aniFrames = getSpriteFrames(ani.."2", fn)
			end
			local animation = cc.Animation:createWithSpriteFrames(aniFrames, ft)
			local action = cc.Sequence:create(cc.Animate:create(animation), cc.CallFunc:create(step))
			peopleNode:setSpriteFrame(aniFrames[1])
			peopleNode:stopAllActions()
			peopleNode:runAction(action)
		else
		-- 移动动作
			if y1>y2 then
				if x1>x2 then
					dirPeople=1
					peopleNode:setScaleX(1)
				else
					dirPeople=2
					peopleNode:setScaleX(-1)
				end
				aniFrames = getSpriteFrames(ani.."1", fn)
			else
				if x1<x2 then
					dirPeople=3
					peopleNode:setScaleX(1)
				else
					dirPeople=4
					peopleNode:setScaleX(-1)
				end
				aniFrames = getSpriteFrames(ani.."2", fn)
			end
			local animation = cc.Animation:createWithSpriteFrames(aniFrames, ft)
			local action = cc.RepeatForever:create(cc.Animate:create(animation))
			local space = math.sqrt(math.pow(x1-x2, 2)+math.pow(y1-y2, 2))
			local time = space/speed
			local mvTo = cc.Sequence:create(cc.MoveTo:create(time, cc.p(x2, y2)), cc.CallFunc:create(step))
			peopleNode:setSpriteFrame(aniFrames[6])
			peopleNode:stopAllActions()
			peopleNode:runAction(action)
			peopleNode:runAction(mvTo)
		end

		-- 每隔0.2s，检测一下行人的Zorder
		local function checkZorder()
			local p = container_:pMap2Tilemap(cc.p(peopleNode:getPosition()))
			peopleNode:setLocalZOrder(p.x+p.y)
		end
		peopleNode:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(checkZorder))))
		checkZorder()
	end
	step()
end
