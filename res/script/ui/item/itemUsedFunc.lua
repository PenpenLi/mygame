
-- 是否可以在商店出售
function itemCanSold(sid_)
	for i,v in ipairs(game.data.shopID) do
		if sid_==v.normalSid then
			return true
		end
	end
	return false
end

-- 是否可以显示，只显示商店可出售或者数量大于0的
function itemCanShow(sid_)
	if player.getItemNum(sid_)>0 then
		return true
	end

	return itemCanSold(sid_)
end


-- 道具使用处理函数
function itemUsedFunc(itemInfo, rstData)
	if itemInfo.funStyle==1 then
		--资源道具
		if itemInfo.parmeter1[1]==8 then
			-- VIP积分
			player.vipStatus.addPoints(tonumber(rstData.res[2]))
		else
			player.addResource(game.data.resType[itemInfo.parmeter1[1]+1][1], itemInfo.parmeter2[1])
		end
	elseif itemInfo.funStyle==8 then
		-- 宝石宝箱、材料宝箱
		if rstData.items~=nil then
			for i=1, #rstData.items, 2 do
				player.addItem(rstData.items[i], rstData.items[i+1])
			end
		end
	elseif itemInfo.funStyle==9 then
		-- 传送
		player.serverMgr.moveCity(rstData.x, rstData.y, rstData.k, true)
		if game.curScene.mapLevel == 2 then
			game.curScene:removeAllModalUI()
			game.curScene:removeAllUI()
			game.curScene:gotoPosition(cc.p(rstData.x, rstData.y))
		end
	elseif itemInfo.funStyle==13 then
		-- 加速行军
	else
		local itemType = itemInfo.sid - itemInfo.sid%50
		if itemType==20000 then
		-- VIP卡
			player.vipStatus.setCD(tonumber(rstData.cd))
		elseif itemType==23000 then
			if itemInfo.funStyle==5 then
			-- 免战牌
				cdBox.setCD(cdBox.CDTYPE.PEACE, rstData.cd[1], rstData.cd[2])
			elseif itemInfo.funStyle==6 then
			-- 反侦察
				cdBox.setCD(cdBox.CDTYPE.FORBIDVIEW, rstData.cd[1], rstData.cd[2])
			end
		end
	end

	if rstData.buff ~= nil then
		player.bufManager.addBuff(rstData.buff)
	end
end
