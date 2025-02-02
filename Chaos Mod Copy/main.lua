#include "quickload.lua"
#include "effects.lua"
#include "utils.lua"
#include "debug.lua"

-- Globals
drawCallQueue = {}
timeScale = 1 -- This one is required to keep chaos time flowing normally.
testThisEffect = "" -- Leave empty to let RNG grab effects.
lastEffectKey = ""
currentTime = 0
timerPaused = false
chaosPaused = false
hasTheGameReloaded = false
newstart = 1

-- Inside the init() these changes don't get backed up.
-- Here they do. Allowing quickloading to be available.
saveFileInit()

removeDisabledEffectKeys()
loadChaosEffectData()

UpdateQuickloadPatch()

function init()
	debugInit()

	UpdateQuickloadPatch()
end

function chaosUnavailable()
	return chaosEffects.effectTemplate.onEffectStart == nil
end

function getCopyOfEffect(key)
	return deepcopy(chaosEffects.effects[key])
end

function getRandomEffect()
	local key = testThisEffect -- Debug effect, if this is empty replaced by RNG.

	if #chaosEffects.effectKeys <= 0 then
		return deepcopy(chaosEffects.noEffectsEffect)
	end

	if key == "" then
		
		DebugPrint("")
		newstart = 1
		Spawn("MOD/twitchchat.xml", GetPlayerTransform())
		twitchat = FindBody("twitch")
		
		local desc = GetDescription(twitchat)
		
		
		if desc == "1" then 
			key = get1
		elseif desc == "2" then
			key = get2
		elseif desc == "3" then
			key = get3
		elseif desc == "4" then
			key = get4
		end
		
		
		Delete(twitchat)
			
		local index = math.random(1, #chaosEffects.effectKeys)
		-- key = chaosEffects.effectKeys[index]
	end

	if key == lastEffectKey and testThisEffect == "" and #chaosEffects.effectKeys > 1 then
		return getRandomEffect()
	end

	lastEffectKey = key

	local effectInstance = getCopyOfEffect(key)

	return effectInstance
end

function triggerEffect(effect)
	table.insert(chaosEffects.activeEffects, 1, effect)

	effect.onEffectStart(effect)
end

function triggerChaos()
	triggerEffect(getRandomEffect())
	
end

function removeChaosLogOverflow()
	if #chaosEffects.activeEffects > chaosEffects.maxEffectsLogged then
		for i = #chaosEffects.activeEffects, 1, -1 do
			local curr = chaosEffects.activeEffects[i]
			if curr.effectDuration <= 0 then
				table.remove(chaosEffects.activeEffects, i)
				if #chaosEffects.activeEffects <= chaosEffects.maxEffectsLogged then
					break
				end
			end
		end
	end
end

function chaosEffectTimersTick(dt)
	for key, value in ipairs(chaosEffects.activeEffects) do
		if value.effectDuration > 0 then
			value.effectLifetime = value.effectLifetime + dt
			if value.effectLifetime >= value.effectDuration then
				value.onEffectEnd(value)
				table.remove(chaosEffects.activeEffects, key)
			else
				value.onEffectTick(value)
			end
		end
	end
end

function GetChaosTimeStep()
	if timeScale < 1 then
		return GetTimeStep() * (timeScale + 1)
	else
		return GetTimeStep()
	end
end

function tick(dt)
	
	if newstart == 1 then 
		able1 = math.random(1, #chaosEffects.effectKeys)
		able2 = math.random(1, #chaosEffects.effectKeys)
		able3 = math.random(1, #chaosEffects.effectKeys)
		able4 = math.random(1, #chaosEffects.effectKeys)
		get1 = chaosEffects.effectKeys[able1]
		get2 = chaosEffects.effectKeys[able2]
		get3 = chaosEffects.effectKeys[able3]
		get4 = chaosEffects.effectKeys[able4]
		pname1 = getCopyOfEffect(get1)
		pname2 = getCopyOfEffect(get2)
		pname3 = getCopyOfEffect(get3)
		pname4 = getCopyOfEffect(get4)
		
		DebugPrint(pname1.name)
		DebugPrint(pname2.name)
		DebugPrint(pname3.name)
		DebugPrint(pname4.name)
		newstart = 0
	end
	
	if quickloadTick() then
		-- Has quickloaded
		chaosTimer = chaosTimerBackup
	end

	-- Failsafe
	if chaosUnavailable() then
		chaosEffects.activeEffects = {}

		local warningEffect = getCopyOfEffect("nothing")
		warningEffect.name = "An error occurred while loading\nthe effects from a quick load.\nPlease restart the level to\nkeep using Chaos mod."
		warningEffect.onEffectStart = function() end
		warningEffect.onEffectTick = function() end
		warningEffect.onEffectEnd = function() end

		triggerEffect(warningEffect)
		currentTime = chaosTimer
		return
	end

	debugTick()

	if not timerPaused then
		if(timeScale < 1) then
			dt = dt * (timeScale + 1)
		end

		currentTime = currentTime + dt

		if currentTime > chaosTimer then
			currentTime = 0
			triggerChaos()
			removeChaosLogOverflow()
		end
	end

	if not chaosPaused then
		chaosEffectTimersTick(dt)
	end

	if timeScale ~= 1 then
		SetTimeScale(timeScale)
		timeScale = 1
	end
end

function drawTimer()
	local currentTimePercenage = 100 / chaosTimer * currentTime / 100

	UiAlign("center middle")

	UiPush()
		UiColor(0.1, 0.1, 0.1, 0.5)
		UiTranslate(UiCenter(), 0)

		UiRect(UiWidth() + 10, UiHeight() * 0.05)
	UiPop()

	UiPush()
		if chaosUnavailable() then
			UiColor(1, 0.25, 0.25)
		else
			UiColor(0.25, 0.25, 1)
		end
		UiTranslate(UiCenter() * currentTimePercenage, 0)
		UiRect(UiWidth() * currentTimePercenage, UiHeight() * 0.05)
	UiPop()
end

function drawEffectLog()
UiPush()
	UiColor(1, 1, 1)
	UiTranslate(UiWidth() * 0.9, UiHeight() * 0.1)
	UiAlign("right middle")
	UiTextShadow(0, 0, 0, 0.5, 2.0)
	UiFont("regular.ttf", 26)

	for key, value in ipairs(chaosEffects.activeEffects) do
		UiText(value.name)

		if value.effectDuration > 0 and not value.hideTimer then
			local effectDurationPercentage = 1 - (100 / value.effectDuration * value.effectLifetime / 100)

			UiColor(0.2, 0.2, 0.2, 0.2)
			UiTranslate(100, 0)
			UiRect(75, 20)

			UiAlign("center middle")

			UiColor(0.7, 0.7, 0.7, 0.5)

			UiTranslate(-75 / 2 , 0)

			UiRect(75 * effectDurationPercentage, 20)

			UiTranslate(75 / 2)

			UiColor(1, 1, 1, 1)

			UiAlign("right middle")

			UiTranslate(-100, 0)
		end
		UiTranslate(0, 40)
	end

UiPop()
end

function processDrawCallQueue()
	for key, value in ipairs(drawCallQueue) do
		value()
	end

	drawCallQueue = {}
end

function draw()
	UiPush()
		if hasTheGameReloaded then
			drawTimer()
			drawEffectLog()
			return
		end

		processDrawCallQueue()

		drawTimer()
		drawEffectLog()

		debugDraw()
	UiPop()
end
