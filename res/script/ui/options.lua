--
-- ui/options.lua
-- 选项
--===================================
require "ui/fullScreenFrame"

UI_options = class("UI_options", UI)

local VAR_INT = 10

--init
function UI_options:init()
	-- data
	-- ===============================
	self.musicVol = player.getMusicVol()
	self.effectVol = player.getEffectVol()

	-- call back
	self:initCallBack()

	-- ui
	-- ===============================
	self:initUI()

	local uiFrame = UI_fullScreenFrame.new()
	uiFrame:setTopShadePosY(888)
	uiFrame:setTitle(hp.lang.getStrByID(10706), "title1")

	-- addCCNode
	-- ===============================
	self:addChildUI(uiFrame)
	self:addCCNode(self.wigetRoot)	

	self:initShow()
end

function UI_options:initUI()
	self.wigetRoot = ccs.GUIReader:getInstance():widgetFromJsonFile(config.dirUI.root .. "options.json")

	-- 功能
	local listView_ = self.wigetRoot:getChildByName("ListView_3")
	local content_ = listView_:getChildByName("Panel_16"):getChildByName("Panel_17")
	content_:getChildByName("Label_18"):setString(hp.lang.getStrByID(5473))
	-- 音乐
	musicCont = content_:getChildByName("Panel_21")
	musicCont:getChildByName("Label_19"):setString(hp.lang.getStrByID(5474))
	musicCont:getChildByName("Image_22"):addTouchEventListener(self.onMusicVolumeTouched)
	musicCont:getChildByName("Image_23"):addTouchEventListener(self.onMusicVolumeTouched)
	self.musicProgress = musicCont:getChildByName("Image_24"):getChildByName("Slider_25")

	-- 音效
	soudCont = content_:getChildByName("Panel_21_0")
	soudCont:getChildByName("Label_19"):setString(hp.lang.getStrByID(5475))
	soudCont:getChildByName("Image_22"):addTouchEventListener(self.onEffectVolumeTouched)
	soudCont:getChildByName("Image_23"):addTouchEventListener(self.onEffectVolumeTouched)
	self.effectProgress = soudCont:getChildByName("Image_24"):getChildByName("Slider_25")

	-- 退出登录
	local content_ = listView_:getChildByName("Panel_16_0"):getChildByName("Panel_17")
	content_:getChildByName("Label_18"):setString(hp.lang.getStrByID(5468))

	self.loginText = content_:getChildByName("Label_96")
	local logout_ = content_:getChildByName("Image_97")
	logout_:getChildByName("Label_98"):setString(hp.lang.getStrByID(5468))
	logout_:addTouchEventListener(self.onLogoutTouched)
	self.logout = logout_
end

function UI_options:initShow()
	local platform_ = game.sdkHelper.getPlatformName()
	self.loginText:setString(string.format(hp.lang.getStrByID(5469), platform_))

	-- 音量
	self.musicProgress:setPercent(self.musicVol)
	self.effectProgress:setPercent(self.effectVol)
end

function UI_options:initCallBack()
	local function onLogoutTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local function onConfirmTouched()
				cclog_("onConfirmTouched")
				game.sdkHelper.logout()
			end			

			require("ui/msgBox/msgBoxWithGirl")
			local msgBox = UI_msgBoxWithGirl.new(hp.lang.getStrByID(5476), 
				hp.lang.getStrByID(1209), 
				hp.lang.getStrByID(2412),  
				onConfirmTouched
				)
			self:addModalUI(msgBox)
		end
	end	

	local function onMusicVolumeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local music_ = self.musicProgress:getPercent()
			if sender:getTag() == -1 then
				music_ = music_ - VAR_INT
			elseif sender:getTag() == 1 then
				music_ = music_ + VAR_INT
			end

			if music_ > 100 then
				music_ = 100
			elseif music_ < 0 then
				music_ = 0
			end
			self.musicProgress:setPercent(music_)
		end
	end	

	local function onEffectVolumeTouched(sender, eventType)
		hp.uiHelper.btnImgTouched(sender, eventType)
		if eventType==TOUCH_EVENT_ENDED then
			local effect_ = self.effectProgress:getPercent()
			if sender:getTag() == -1 then
				effect_ = effect_ - VAR_INT
			elseif sender:getTag() == 1 then
				effect_ = effect_ + VAR_INT
			end

			if effect_ > 100 then
				effect_ = 100
			elseif effect_ < 0 then
				effect_ = 0
			end
			self.effectProgress:setPercent(effect_)
		end
	end	

	local function changeMusicVolume(sender, eventType)

	end

	local function changeEffectVolume(sender, eventType)

	end

	self.onLogoutTouched = onLogoutTouched
	self.onMusicVolumeTouched = onMusicVolumeTouched
	self.onEffectVolumeTouched = onEffectVolumeTouched
	self.changeMusicVolume = changeMusicVolume
	self.changeEffectVolume = changeEffectVolume
end

function UI_options:heartbeat(dt_)
	local musicVol_ = self.musicProgress:getPercent()
	if musicVol_ ~= self.musicVol then
		cclog_("musicVol_",musicVol_)
		self.musicVol = musicVol_
		cc.SimpleAudioEngine:getInstance():setMusicVolume(musicVol_ / 100)
	end

	local effectVol_ = self.effectProgress:getPercent()
	if effectVol_ ~= self.effectVol then
		cclog_("effectVol_",effectVol_)
		self.effectVol = effectVol_
		cc.SimpleAudioEngine:getInstance():setEffectsVolume(effectVol_ / 100)
	end
end

function UI_options:onRemove()
	player.setMusicVolume(self.musicVol)
	player.setEffectVolume(self.effectVol)
	self.super.onRemove(self)
end