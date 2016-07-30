--
-- obj/buildingTmp.lua
-- 建筑物。 当不在城内场景中，临时创建的建筑，代替实现建筑的一些功能和数据
--================================================


BuildingTmp = class("BuildingTmp")


--
-- auto functions
--==============================================

--
-- ctor
-------------------------------
function BuildingTmp:ctor(build_)
	self.build = build_
	self.container = game.curScene

	self.bInfo = nil
	self.upInfo = nil
	self.imgPath = nil
	self:init()
end

--
-- init
-------------------------------
function BuildingTmp:init()
	if self.build==nil then
		return false
	end


	for i,v in ipairs(game.data.building) do
		if self.build.sid==v.sid then
			self.bInfo = v
			break
		end
	end

	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and self.build.lv==v.level then
			self.upInfo = v
			break
		end
	end

	local level = self.build.lv-1
	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and level==v.level then
			self.imgPath = string.format("%s%s", config.dirUI.building, v.img)
			break
		end
	end

	return true
end


-- onClicked
function BuildingTmp:onClicked()
	if self.build~=nil then
		local bInfo = nil
		for i,v in ipairs(game.data.building) do
			if self.build.sid==v.sid then
				bInfo = v
				break
			end
		end
		if bInfo.showtype==1 then
			--主建筑
			require "ui/mainBuilding"
			local ui  = UI_mainBuilding.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==2 or bInfo.showtype==14 then
			-- 生产类建筑
			require "ui/productionBuilding"
			local ui  = UI_productionBuilding.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==3 then
			-- 仓库
			require "ui/storage/storage"
			local ui  = UI_storage.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==4 then
			-- 学院
			require "ui/academy/academy"
			local ui = UI_academy.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==5 then
			-- 祭坛
			require "ui/altar/altar"
			local ui = UI_altar.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==6 then
			-- 兵营
			require "ui/barrack/barrack"
			local ui = UI_barracks.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==7 then
			-- 使馆
			require "ui/embassy/embassy"
			local ui = UI_embassy.new(self)
			self.container:addUI(ui)			
		elseif bInfo.showtype==8 then
			-- 铁匠铺
			require "ui/smith/smith"
			local ui = UI_smith.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==10 then
			-- 军政厅
			require "ui/hallOfWar/hallOFWar"
			local ui = UI_hallOfWar.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==11 then
			-- 医院
			require "ui/hospital/hospital"
			local ui = UI_hospital.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==12 then
			-- 市场
			require "ui/market/market"
			local ui = UI_market.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==13 then
			-- 地牢
			require "ui/prison/prison"
			local ui = UI_prison.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==15 then
			-- 城墙
			require "ui/wall/wall"
			local ui = UI_wall.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==16 then
			-- 哨塔
			require "ui/watchtower/watchtower"
			local ui = UI_watchtower.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==17 then
			-- 别院
			require "ui/gymnos/gymnos"
			local ui = UI_gymnos.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==18 then
			--墓地
			require "ui/cemetery/cemetery.lua"
			local ui = UI_cemetery.new(self)
			self.container:addUI(ui)
		elseif bInfo.showtype==19 then
			--招贤馆
			require "ui/takeInHeroRoom/takeInHeroRoom"
			local ui = UI_takeInHeroRoom.new(self)
			self.container:addUI(ui)
		else
			require "ui/buildingDef"
			local ui = UI_buildingDef.new(self)
			self.container:addUI(ui)
		end
	end
end


-- 升级建筑
function BuildingTmp:upgradeBuilding()
	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and self.build.lv==v.level then
			self.imgPath = string.format("%s%s", config.dirUI.building, v.img)
			break
		end
	end
	self.build.lv = self.build.lv+1
	
	for i,v in ipairs(game.data.building) do
		if self.build.sid==v.sid then
			self.bInfo = v
			break
		end
	end

	for i, v in ipairs(game.data.upgrade) do
		if self.build.sid==v.buildSid and self.build.lv==v.level then
			self.upInfo = v
			break
		end
	end

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")
end

-- 拆除建筑
function BuildingTmp:destoryBuilding()
	player.buildingMgr.removeBuilding(self.build)

	self.build = nil
	self.bInfo = nil
	self.upInfo = nil
	self.uplvIcon = nil

	cc.SimpleAudioEngine:getInstance():playEffect("sound/build.mp3")
end

