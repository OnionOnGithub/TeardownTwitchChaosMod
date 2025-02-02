#include "textbox.lua"
#include "utils.lua"

local debugMenuEnabled = false

local mouseActive = false

local overrideTimeScale = false
local overrideChaosTime = false

local effectListScrollPosition = 0
local isMouseInList = false
local listScreenHeight = 0
local listScreenMaxScroll = 0
local effectCount = 0

local sortedEffectList = {}

function debugInit()
	debugSetupEffectsList()
	
	if testThisEffect ~= "" then
		chaosTimer = chaosEffects.effects[testThisEffect].effectDuration
		currentTime = chaosTimer * 0.98
	end
end

function debugTick()
	if mouseActive then
		UiMakeInteractive()
	end

	if debugMenuEnabled then
		textboxClass_tick()
		checkMouseScroll()
	end
	
	if #sortedEffectList == 0 and debugMenuEnabled then
		debugSetupEffectsList()
	end

	checkDebugMenuToggles()
end

function debugSetupEffectsList()
	effectCount = GetEffectCount()
	
	sortedEffectList = SortEffectsTable(effectCount)
end

function debugDraw()
	if testThisEffect ~= "" or debugMenuEnabled then
		drawDebugText()
	end

	if debugMenuEnabled then
		drawDebugMenu()
		drawEffectList()
		listScreenHeight = UiMiddle() - 20
		listScreenMaxScroll = (effectCount * 30 + 2) - listScreenHeight + 15
	end
end

function checkDebugMenuToggles()
	if debugMenuEnabled and InputPressed("h") then
		mouseActive = not mouseActive
	end

	if InputDown("ctrl") and InputPressed("h") then
		debugMenuEnabled = not debugMenuEnabled
		
		if not debugMenuEnabled then
			mouseActive = false
		end
	end
end

function checkMouseScroll()
	if not isMouseInList then
		return
	end

	effectListScrollPosition = effectListScrollPosition + -InputValue("mousewheel") * 10

	if effectListScrollPosition < 0 then
		effectListScrollPosition = 0
	elseif effectListScrollPosition > listScreenMaxScroll then
		effectListScrollPosition = listScreenMaxScroll
	end
end

function debugFunc()
	if InputPressed("p") then
		for i=1, 20 do
		DebugPrint(" ")
		end

		DebugPrint(chaosEffects.testVar == nil)

		for key, value in pairs(chaosEffects.effects["myGlasses"]) do
			if type(value) ~= "table" and type(value) ~= "function"then
				DebugPrint(key .. ": " .. value)
			else
				DebugPrint(key .. ": " .. type(value))
			end
		end
	end
end

function drawDebugText()
	local effect = nil

	local testedEffect = testThisEffect

	if testedEffect == "" then
		if chaosEffects.activeEffects[1] == nil then
			return
		end
	end

	if #chaosEffects.activeEffects <= 0 then
		effect = chaosEffects.effects[testedEffect]
	else
		effect = chaosEffects.activeEffects[1]
	end

	UiPush()
		UiAlign("top left")
		UiTranslate(UiWidth() * 0.025, UiHeight() * 0.05)
		UiTextShadow(0, 0, 0, 0.5, 2.0)
		UiFont("bold.ttf", 26)
		UiColor(1, 0.25, 0.25, 1)
		UiText("CHAOS MOD DEBUG MODE ACTIVE")
		UiTranslate(0, UiHeight() * 0.025)
		if testedEffect ~= "" then
			UiText("Testing effect: " .. testedEffect)
		else
			UiText("Current first effect: ")
		end

		for index, key in ipairs(chaosEffects.debugPrintOrder) do
			local effectProperty = effect[key]

			UiTranslate(0, UiHeight() * 0.025)
			if type(effectProperty) == "string" or type(effectProperty) == "number" then
				UiText(key .." = " .. effectProperty)
			elseif type(effectProperty) == "table" then
				UiText(key .." = " .. tableToText(effectProperty))
			else
				UiText(key .. " = " .. tostring(effectProperty))
			end
		end
	UiPop()
end

function drawEffectList()
	UiPush()
		UiWordWrap(330)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		UiFont("regular.ttf", 26)

		UiTranslate(0, UiHeight())

		UiAlign("bottom left")

		UiColor(0, 0, 0, 0.75)

		UiRect(350, UiMiddle())

		UiAlign("top center")

		UiTranslate(175, -UiMiddle())

		UiColor(1, 1, 1, 0.75)

		UiRect(350, 30)

		UiColor(0, 0, 0, 1)

		UiText("Trigger Effect")

		UiTranslate(-175, 30)

		UiAlign("top left")

		UiPush()
			isMouseInList = UiIsMouseInRect(350, UiMiddle() - 30)

			UiWindow(350, UiMiddle() - 30, true)

			UiColor(1, 1, 1, 1)

			local i = 0
			
			for key, uid in ipairs(sortedEffectList) do
				local effect = chaosEffects.effects[uid]
				UiPush()
					UiTranslate(0, i * 30 + 2 - effectListScrollPosition)
					
					local textWidth, textHeight = UiGetTextSize(effect.name)
					local fontSize = 26
					local fontDecreaseIncrement = 2
					
					while textWidth > 320 do
						fontSize = fontSize - fontDecreaseIncrement

						UiFont("regular.ttf", fontSize)
						
						textWidth, textHeight = UiGetTextSize(effect.name)
					end
					
					if UiTextButton(effect.name, 330, 30) then
						triggerEffect(getCopyOfEffect(uid))
					end

					i = i + 1

				UiPop()
			end

			UiAlign("right middle")

			UiTranslate(350, (effectListScrollPosition / listScreenMaxScroll) * 2 * UiMiddle())

			UiRect(20, 40)
		UiPop()

	UiPop()
end

function drawDebugMenu()
	UiPush()
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		UiWordWrap(500)

		UiAlign("bottom right")
		UiTranslate(UiWidth(), UiHeight())

		UiFont("regular.ttf", 26)

		UiColor(0, 0, 0, 0.75)

		UiRect(500, 500)

		UiTranslate(-250, -500)

		UiAlign("top center")

		UiColor(1, 1, 1, 0.75)

		UiRect(500, 30)

		UiColor(0, 0, 0, 1)

		UiText("Chaos Mod Debug Menu")

		UiAlign("top left")

		UiTranslate(-230, 40)

		UiColor(1, 1, 1, 1)
		-- TODO: Remove this text eventually.
		UiText("(While this menu is open)\nPress H to toggle mouse input.")

		UiTranslate(0, 50)

		UiText("Current time: " .. roundToTwoDecimals(currentTime) .. "/" .. chaosTimer)

		UiTranslate(0, 30)

		local effects = ""

		for key, value in ipairs(chaosEffects.activeEffects) do
			if key > 1 then
			effects = effects .. ", "
			end
			effects = effects .. value.name
		end

		UiText("Active effects: " .. effects)

		UiTranslate(0, 90)

		UiText("Last Effect Key: " .. lastEffectKey)

		UiTranslate(0, 30)

		local chaosEffectsText = "Pause Chaos Effects"

		if chaosPaused then
			chaosEffectsText = "Resume Chaos Effects"
		end

		if UiTextButton(chaosEffectsText, 220, 30) then
			chaosPaused = not chaosPaused
		end

		UiTranslate(0, 40)

		local chaosTimerText = "Pause Timer"

		if timerPaused then
			chaosTimerText = "Resume Timer"
		end

		if UiTextButton(chaosTimerText, 220, 30) then
			timerPaused = not timerPaused
		end

		UiTranslate(0, 40)

		if UiTextButton("Clear effects", 220, 30) then
			chaosEffects.activeEffects = {}
		end

		UiTranslate(0, 40)

		local timescaleOverrideText = "Override Timescale"

		if overrideTimeScale then
			timescaleOverrideText = "Release Timescale"
		end

		if UiTextButton(timescaleOverrideText, 220, 30) then
			overrideTimeScale = not overrideTimeScale
		end

		UiTranslate(120, 40)

		local textBox01, newBox01 = textboxClass_getTextBox(1)

		if newBox01 then
			textBox01.name = "Timescale"
			textBox01.value = timeScale .. ""
			textBox01.numbersOnly = true
			textBox01.limitsActive = true
			textBox01.numberMin = 0.1
			textBox01.numberMax = 1
			textBox01.height = 30
		end

		if overrideTimeScale then
			if textBox01.value == "" then
				timeScale = 1
			else
				timeScale = tonumber(textBox01.value)
			end
		end

		textboxClass_render(textBox01)

		UiTranslate(0, 30)

		local textBox02, newBox02 = textboxClass_getTextBox(2)

		if newBox02 then
			textBox02.name = "Chaos Timer"
			textBox02.value = chaosTimer .. ""
			textBox02.numbersOnly = true
			textBox02.limitsActive = true
			textBox02.numberMin = 1
			textBox02.numberMax = 10000
			textBox02.active = false
			textBox02.height = 30
		end

		if textboxClass_inputFinished(textBox02) then
			chaosTimer = tonumber(textBox02.value)
		elseif not textBox02.inputActive then
			textBox02.value = chaosTimer .. ""
		end

		textboxClass_render(textBox02)

	UiPop()
end