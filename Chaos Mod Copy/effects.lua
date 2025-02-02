#include "utils.lua"

function chaosSFXInit()
	local loadedSFX = {loops = {}, regular = {}}

	for key, value in ipairs(chaosEffects.effectKeys) do
		local currentEffect = chaosEffects.effects[value]
		
		if #currentEffect.effectSFX > 0 then
			for i=1, #currentEffect.effectSFX do
				local soundData = currentEffect.effectSFX[i]
				
				if type(soundData) == "table" then
					local soundPath = soundData["soundPath"]
					local isLoop = soundData["isLoop"]
					local handle = 0

					if isLoop then
						if loadedSFX.loops[soundPath] ~= nil then
							handle = loadedSFX.loops[soundPath]
						else
							handle = LoadLoop(soundPath)
							loadedSFX.loops[soundPath] = handle
						end
					else
						if loadedSFX.regular[soundPath] ~= nil then
							handle = loadedSFX.regular[soundPath]
						else
							handle = LoadSound(soundPath)
							loadedSFX.regular[soundPath] = handle
						end
					end
					
					currentEffect.effectSFX[i] = handle
				end
			end
		end
	end
end

function chaosSpritesInit()
	local loadedSprites = {}

	for key, value in ipairs(chaosEffects.effectKeys) do
		local currentEffect = chaosEffects.effects[value]
		
		if #currentEffect.effectSprites > 0 then
			for i=1, #currentEffect.effectSprites do
				local currentSpriteData = currentEffect.effectSprites[i]
				
				if type(currentSpriteData) == "string" then
					local handle = 0

					if loadedSprites[currentSpriteData] ~= nil then
						handle = loadedSprites[currentSpriteData]
					else
						handle = LoadSprite(currentSpriteData)
						loadedSprites[currentSpriteData] = handle
					end
					
					currentEffect.effectSprites[i] = handle
				end
			end
		end
	end
end

function chaosKeysInit()
	chaosEffects.disabledEffects = DeserializeTable(GetString(moddataPrefix.. "DisabledEffects"))

	local i = 1

	for key, value in pairs(chaosEffects.effects) do
		chaosEffects.effectKeys[i] = key
		i = i + 1
	end

	table.remove(chaosEffects.activeEffects, 1)
end

function loadChaosEffectData()
	chaosSFXInit()
	chaosSpritesInit()
end

function removeDisabledEffectKeys()
	local newTable = {}
	local i = 1

	for key, value in ipairs(chaosEffects.effectKeys) do
		if chaosEffects.disabledEffects[value] == nil then
			newTable[i] = value
			i = i + 1
		end
	end

	chaosEffects.effectKeys = newTable
end

chaosEffects = {
	maxEffectsLogged =  5,
	activeEffects = {0},

	disabledEffects = {},

	debugPrintOrder = {"name", "effectDuration", "effectLifetime", "effectSFX", "effectSprites", "effectVariables", "onEffectStart", "onEffectTick", "onEffectEnd"},

	effectTemplate = {
		name = "Name", -- This is what shows up on the UI.
		effectDuration = 0, -- If more than 0 this is a timed effect and will last.
		effectLifetime = 0, -- Keep this at 0, this is how long the effect has been running for.
		hideTimer = false, -- For effects that trick the player.
		effectSFX = {}, -- Locations of SFX. Will be replaced by their handle during setup.
		effectSprites = {}, -- Locations of sprites. Will be replaced by their handle during setup.
		effectVariables = {}, -- Any variables the effect has access to.
								-- The reason you want your variables in here rather than its parent Table is readability.
								-- The effect does get full access to itself so you can edit every variable in it.
		onEffectStart = function(vars) end, -- Called when the effect is instantiated. Also called if the effect is not timed.
		onEffectTick = function(vars) end, -- Program your effect in this function. Not called for non-timed effects.
		onEffectEnd = function(vars) end, -- Called for timed effects on end.
	},

	noEffectsEffect = {
		name = "No effects enabled!",
		effectDuration = 10,
		effectLifetime = 0,
		hideTimer = false,
		effectSFX = {},
		effectSprites = {},
		effectVariables = {},
		onEffectStart = function(vars) end,
		onEffectTick = function(vars) end,
		onEffectEnd = function(vars) end,
	},

	effectKeys = {}, -- Leave empty, this is populated automatically.

	effects = {
		instantDeath = {
			name = "Instant Death",
			effectDuration = 5,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetPlayerHealth(0)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				if GetPlayerHealth() <= 0 then
					RespawnPlayer() -- This is used on maps that don't auto respawn you.
				end
			end,
		},

		launchPlayerUp = {
			name = "Launch Player Up",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local currentVehicleHandle = GetPlayerVehicle()
				local upVel = Vec(0, 25, 0)
				if currentVehicleHandle ~= 0 then
					local currentVehicleBody = GetVehicleBody(currentVehicleHandle)
					SetBodyVelocity(currentVehicleBody, upVel)
				else
					SetPlayerVelocity(upVel)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		jetpack = {
			name = "Jetpack",
			effectDuration = 25,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if InputDown("jump") then
					local tempVec = GetPlayerVelocity()

					tempVec[2] = 5

					SetPlayerVelocity(tempVec)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		launchPlayerAnywhere = {
			name = "Launch Player",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local velocity = rndVec(20)

				local currentVehicleHandle = GetPlayerVehicle()
				if currentVehicleHandle ~= 0 then
					local currentVehicleBody = GetVehicleBody(currentVehicleHandle)

					velocity[2] = math.abs(velocity[2])

					SetBodyVelocity(currentVehicleBody, velocity)
				else
					SetPlayerVelocity(velocity)
				end

			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		explosionAtPlayer = {
			name = "Explode Player",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Explosion(GetPlayerTransform().pos, 7.5)
				SetPlayerHealth(1)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		fireAtPlayer = {
			name = "Set Player On Fire",
			effectDuration = 5,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerTransform = GetPlayerTransform()

				SpawnFire(playerTransform.pos)
			end,
			onEffectEnd = function(vars) end,
		},

		removeCurrentVehicle = {
			name = "Remove Current Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local vehicle = GetPlayerVehicle()
				if vehicle ~= 0 then
					Delete(GetVehicleBody(vehicle))
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		holedUp = {
			name = "Hole'd up",
			effectDuration = 3,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerTransform = GetPlayerTransform()

				MakeHole(playerTransform.pos, 1, 1, 1)
			end,
			onEffectEnd = function(vars) end,
		},

		disintegrationField = {
			name = "Disintegration Field",
			effectDuration = 5,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerTransform = GetPlayerTransform()
				local offset = Vec(0, 0, 0)

				for i = -4, 4, 1 do
					MakeHole(VecAdd(playerTransform.pos, Vec(0, i, 0)), 5, 5, 5)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		stopAndStare = {
			name = "Stop And Stare",
			effectDuration = 5,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				SetPlayerVehicle(0)
				SetPlayerVelocity(Vec(0, 0, 0))
			end,
			onEffectEnd = function(vars) end,
		},

		myGlasses = {
			name = "My Glasses!",
			effectDuration = 12,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				table.insert(drawCallQueue, function() UiBlur(1) end)
			end,
			onEffectEnd = function(vars) end,
		},

		slomo25 = {
			name = "0.25x Gamespeed",
			effectDuration = 12,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				timeScale = 0.25
			end,
			onEffectEnd = function(vars) end,
		},

		slomo50 = {
			name = "0.5x Gamespeed",
			effectDuration = 12,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				timeScale = 0.5
			end,
			onEffectEnd = function(vars) end,
		},

		superhot = {
			name = "SUPERTEARDOWN",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {tempSpeed = 0, lastCamRot = nil,},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				-- Add temporary speedup on click
				if InputDown("usetool") then
					vars.effectVariables.tempSpeed = 2
				end

				-- Calculate effect for camera turn and velocity
				local currCamRot = GetPlayerCameraTransform().rot
				local velocitySpeed = VecDist(Vec(0, 0, 0), GetPlayerVelocity())
				local camSpeed = 0
				if vars.effectVariables.lastCamRot ~= nil then
					camSpeed = math.min(VecDist(Vec(0, 0, 0), VecSub(currCamRot, vars.effectVariables.lastCamRot)), 0.5) * 50
				end
				vars.effectVariables.lastCamRot = currCamRot
				local totalSpeed = velocitySpeed + camSpeed + vars.effectVariables.tempSpeed

				-- Apply effect
				if GetPlayerHealth() ~= 0 then
					timeScale = 0.05 + (math.min(totalSpeed / 7, 1) * 0.95)
				else
					timeScale = 0.5
				end

				-- slowly lessen temp speed overtime
				if vars.effectVariables.tempSpeed > 0 then
					vars.effectVariables.tempSpeed = vars.effectVariables.tempSpeed - 0.05
				else
					vars.effectVariables.tempSpeed = 0
				end
			end,
			onEffectEnd = function(vars) end,
		},

		triggerAlarm = {
			name = "Trigger Alarm",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetBool("level.alarm", true)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		pauseAlarm = {
			name = "Pause Alarm",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { timer = 100, },
			onEffectStart = function(vars)
				vars.effectVariables.timer = GetFloat("level.alarmtimer")
			end,
			onEffectTick = function(vars)
				SetFloat("level.alarmtimer", vars.effectVariables.timer)
			end,
			onEffectEnd = function(vars) end,
		},

		teleportToTarget = {
			name = "Teleport to Random Target",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local targets = FindBodies("target", true)
				if(#targets == 0) then
					return
				end
				local randomTarget = targets[math.random(1, #targets)]

				local t = Transform(GetBodyTransform(randomTarget).pos, GetPlayerTransform().rot)
				SetPlayerTransform(t)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		teleportTarget = {
			name = "Teleport Random Target to Player",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local targets = FindBodies("target", true)
				if(#targets == 0) then
					return
				end
				local randomTarget = targets[math.random(1, #targets)]

				local t = Transform(GetPlayerTransform().pos, GetBodyTransform(randomTarget).rot)
				SetBodyTransform(randomTarget, t)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		disintegrateVehicle = {
			name = "Disintegrate Vehicle",
			effectDuration = 2,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {body = 0, tickHalt = 0, lastOffset = 0},
			onEffectStart = function(vars)
				-- Get Current Vehicle
				if GetPlayerVehicle() ~= 0 then
					local body = GetVehicleBody(GetPlayerVehicle())
					vars.effectVariables.body = body
					return
				end

				-- Get Looked At Vehicle
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})
				local hit, hitPoint, distance, normal, shape = raycast(cameraTransform.pos, rayDirection, 50)
				if hit then
					local body = GetShapeBody(shape)
					local veh = GetBodyVehicle(body)
					if veh then
						local body = GetVehicleBody(veh)
						vars.effectVariables.body = body
						return
					end
				end
			end,
			onEffectTick = function(vars)
				local holeSize = 0.3
				local haltAfterHit = 2

				function gridstep(x, y, w, h, xs, ys)
					if ys == nil then ys = xs end
					local res = {}
					local xStep = w / xs
					local yStep = h / ys
					for i=0, xs do
						for j=0, ys do
							table.insert(res, {(i * xStep) + x, (j * yStep) + y})
						end
					end

					return res
				end

				function IsUnbreakable(mat)
						return not mat or mat == 'rock' or mat == 'heavymetal' or mat == 'unbreakable' or mat == 'hardmasonry'
				end

				if vars.effectVariables.body ~= 0 then
					-- Halt by tick
					if vars.effectVariables.tickHalt > 0 then
						vars.effectVariables.tickHalt = vars.effectVariables.tickHalt - 1
						return
					end

					-- Calculate breakable points
					local min, max = GetBodyBounds(vars.effectVariables.body)
					local xSize = max[1] - min[1]
					local ySize = max[2] - min[2]
					local zSize = max[3] - min[3]
					local zOffset = (vars.effectLifetime / vars.effectDuration) * zSize
					if zOffset - vars.effectVariables.lastOffset < holeSize then
						return
					end
					vars.effectVariables.lastOffset = zOffset

					local grid = gridstep(min[1], min[2], xSize, ySize, xSize / holeSize, ySize / holeSize)
					for i=1, #grid do
						local cell = grid[i]
						local pos = Vec(cell[1], cell[2], min[3] + zOffset)
						local hit, p, n, shape = QueryClosestPoint(pos, holeSize)
						if hit then
							local mat = GetShapeMaterialAtPosition(shape, pos)
							if mat and not IsUnbreakable(mat) then
								MakeHole(pos, holeSize, holeSize, holeSize, silent)
								-- DebugCross(pos, 1, 0, 0, 1)
								vars.effectVariables.tickHalt = haltAfterHit
							end
						end
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},

		blindingLights = {
			name = "Blinding Lights",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { allLights = {} },
			onEffectStart = function(vars)
				local shapes = QueryAabbShapes(Vec(-1000, -1000, -1000), Vec(1000, 1000, 1000))
				for i=1, #shapes do
					local lights = GetShapeLights(shapes[i])
					for j=1, #lights do
						if not HasTag(lights[j], "alarm") then
							table.insert(vars.effectVariables.allLights, lights[j])
						end
					end
				end

				for i=1, #vars.effectVariables.allLights do
					local currentLight = vars.effectVariables.allLights[i]
					SetLightEnabled(currentLight, true)
					SetLightIntensity(currentLight, 10000.0)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				for i=1, #vars.effectVariables.allLights do
					local currentLight = vars.effectVariables.allLights[i]
					SetLightEnabled(currentLight, true)
					SetLightIntensity(currentLight, 5.0)
				end
			end,
		},

		blackout = {
			name = "Blackout",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { allLights = {} },
			onEffectStart = function(vars)
				local shapes = QueryAabbShapes(Vec(-1000, -1000, -1000), Vec(1000, 1000, 1000))
				local allLights = {}
				for i=1, #shapes do
					local lights = GetShapeLights(shapes[i])
					for j=1, #lights do
						if not HasTag(lights[j], "alarm") then
							table.insert(vars.effectVariables.allLights, lights[j])
						end
					end
				end

				for i=1, #vars.effectVariables.allLights do
					local currentLight = vars.effectVariables.allLights[i]
					SetLightEnabled(currentLight, false)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) 
				for i=1, #vars.effectVariables.allLights do
					local currentLight = vars.effectVariables.allLights[i]
					SetLightEnabled(currentLight, true)
				end
			end,
		},

		smokeScreen = {
			name = "Smokescreen",
			effectDuration = 12,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				ParticleReset()
				ParticleType("smoke")
				ParticleColor(0.7, 0.6, 0.5)
				ParticleRadius(1)
				for i = 1, 20 do
					local direction = rndVec(10)
					SpawnParticle(GetPlayerTransform().pos, direction, 2)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		takeABreak = {
			name = "Take A Break",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetPaused(true)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		invincibility = {
			name = "Invincibility",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				SetPlayerHealth(1)
			end,
			onEffectEnd = function(vars) end,
		},

		teleportToSpawn = {
			name = "Teleport To Spawn",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetPlayerVehicle(0)

				RespawnPlayer()
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		oneHitKO = {
			name = "One Hit KO",
			effectDuration = 7,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetPlayerHealth(1)
			end,
			onEffectTick = function(vars)
				vars.effectVariables.hp = GetPlayerHealth()
				if GetPlayerHealth() < 1 then
					SetPlayerHealth(0)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		tiredPlayer = {
			name = "I'm Tired",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {fadeAlpha = 0, waking = false},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local deltatime = GetChaosTimeStep() / 2

				if vars.effectVariables.waking then
					vars.effectVariables.fadeAlpha = vars.effectVariables.fadeAlpha - deltatime
				else
					vars.effectVariables.fadeAlpha = vars.effectVariables.fadeAlpha + deltatime
				end

				if vars.effectVariables.fadeAlpha > 1 then
					vars.effectVariables.waking = true
				elseif vars.effectVariables.fadeAlpha < 0 then
					vars.effectVariables.waking = false
				end

				table.insert(drawCallQueue, function()
				UiBlur(vars.effectVariables.fadeAlpha)
				UiPush()

					UiColor(0, 0, 0, vars.effectVariables.fadeAlpha)
					UiAlign("center middle")
					UiTranslate(UiCenter(), UiMiddle())
					UiRect(UiWidth() + 10, UiHeight() + 10)

				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},

		airstrike = {
			name = "Airstrike",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { maxShells = 50, shellNum = 1, defaultShell = { active = false, explode = false, velocity = 500 }, shells = {},},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				function AirstrikeOperations(projectile)
					projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity, (VecScale(projectile.gravity, GetTimeStep()/4)))
					local point2 = VecAdd(projectile.pos, VecScale(projectile.predictedBulletVelocity, GetTimeStep()/4))
					local dir = VecNormalize(VecSub(point2, projectile.pos))
					local distance = VecLength(VecSub(point2, projectile.pos))
					local hit, dist, normal, shape = QueryRaycast(projectile.pos, dir, distance)
					if hit then
						projectile.explode = true
					else
						projectile.pos = point2
					end
				end

				function randomPosInSky()
					local playerPos = GetPlayerTransform().pos

					playerPos[2] = playerPos[2] + 150

					playerPos[1] = playerPos[1] + math.random(-50, 50)
					playerPos[3] = playerPos[3] + math.random(-50, 50)

					return playerPos
				end

				function randomDirection(projectilePos)
					local playerPos = GetPlayerTransform().pos

					local direction = dirVec(projectilePos, playerPos)

					direction[2] = 0

					local randomVec = rndVec(0.5)

					randomVec[2] = -1

					return VecNormalize(VecAdd(direction, randomVec))
				end

				function createRocket(pos)
					vars.effectVariables.shells[vars.effectVariables.shellNum] = deepcopy(vars.effectVariables.defaultShell)
					local direction = randomDirection(pos)

					local loadedShell = vars.effectVariables.shells[vars.effectVariables.shellNum]
					loadedShell.active = true
					loadedShell.pos = pos
					loadedShell.predictedBulletVelocity = VecScale(direction, loadedShell.velocity)

					vars.effectVariables.shellNum = (vars.effectVariables.shellNum % vars.effectVariables.maxShells) + 1
				end

				if math.random(1, 20) >= 16 then
					createRocket(randomPosInSky())
				end

				for key, shell in ipairs(vars.effectVariables.shells) do
					if shell.active and shell.explode then
						shell.active = false
						Explosion(shell.pos, 2)
					end

					if shell.active then
						AirstrikeOperations(shell)
						SpawnParticle("smoke", shell.pos, 0.5, 0.5, 0.5)
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},

		laserVision = {
			name = "Laser Vision",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})

				local hit, hitPoint = raycast(cameraTransform.pos, rayDirection, 1000)

				if hit == false then
					return
				end

				MakeHole(hitPoint, 0.2, 0.2, 0.2)
				SpawnParticle("smoke", hitPoint, Vec(0, 1, 0), 1, 2)
			end,
			onEffectEnd = function(vars) end,
		},

		teleportToRandomLocation = {
			name = "Teleport To A Random Location",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()
				local playerPos = playerTransform.pos

				playerPos[2] = playerPos[2] + 50

				playerPos[1] = playerPos[1] + math.random(-50, 50)--(-50, 50)
				playerPos[3] = playerPos[3] + math.random(-50, 50)--(-50, 50)

				local hit, hitPoint = raycast(playerPos, Vec(0, -1, 0), 1000)

				local newTransform = nil

				SetPlayerVehicle(0)

				if hit then
					newTransform = Transform(VecAdd(hitPoint, Vec(0, 1, 0)), playerTransform.rot)
				else
					RespawnPlayer() -- Pretty unlikely edge case to not hit, but in the event use this instead.
				end

				SetPlayerTransform(newTransform)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		deleteVision = {
			name = "Hope That Wasn't Important",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})

				local hit, hitPoint, distance, normal, shape = raycast(cameraTransform.pos, rayDirection, 50)

				if not hit then
					return
				end

				local shapeBody = GetShapeBody(shape)

				if not IsBodyDynamic(shapeBody) then
					return
				end

				local currentVehicleHandle = GetPlayerVehicle()

				if currentVehicleHandle == GetBodyVehicle(shapeBody) then
					SetPlayerVehicle(0)
				end

				Delete(shapeBody)

			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		portraitMode = {
			name = "Portrait Mode",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {currentBorderPos = 0},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if vars.effectVariables.currentBorderPos < UiWidth() / 3 then
					vars.effectVariables.currentBorderPos = vars.effectVariables.currentBorderPos + GetChaosTimeStep() * 100
				elseif vars.effectVariables.currentBorderPos > UiWidth() / 3 then
					vars.effectVariables.currentBorderPos = UiWidth() / 3
				end

				table.insert(drawCallQueue, function()
				UiPush()
					UiColor(0, 0, 0, 1)

					UiAlign("left middle")
					UiTranslate(-10, UiMiddle())
					UiRect(vars.effectVariables.currentBorderPos, UiHeight() + 10)
				UiPop()

				UiPush()
					UiColor(0, 0, 0, 1)

					UiAlign("right middle")
					UiTranslate(UiWidth() + 10, UiMiddle())
					UiRect(vars.effectVariables.currentBorderPos, UiHeight() + 10)
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},

		explodingStare = {
			name = "Explosive Stare",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {currentBorderPos = 0},
			onEffectStart = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})

				local hit, hitPoint = raycast(cameraTransform.pos, rayDirection, 50)

				if hit then
					Explosion(hitPoint, 1)
				end

			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		featherFalling = {
			name = "Feather Falling",
			effectDuration = 12,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local maxFallSpeed = -1

				local vel = GetPlayerVelocity()
				if(vel[2] < maxFallSpeed) then
					SetPlayerVelocity(Vec(vel[1], maxFallSpeed, vel[3]))
				end
			end,
			onEffectEnd = function(vars) end,
		},

		explodeRandomExplosive = {
			name = "Explode Random Explosive",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local explosives = {}
				for i=1, #nearbyShapes do
					if HasTag(nearbyShapes[i], "explosive") then
						explosives[#explosives + 1] = nearbyShapes[i]
					end
				end

				if(#explosives == 0) then
					return
				end

				local randomExplosive = explosives[math.random(1, #explosives)]

				Explosion(GetShapeWorldTransform(randomExplosive).pos,2)
				end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		teleportAFewMeters = {
			name = "Teleport A Few Meters",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {currentBorderPos = 0},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()

				local direction = rndVec(1)

				local distance = math.random(10, 20)

				direction[2] = math.abs(direction[2])

				local newPos = VecAdd(playerTransform.pos, VecScale(direction, distance))

				local currentVehicle = GetPlayerVehicle()

				if currentVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(currentVehicle)
					local vehicleTransform = GetBodyTransform(vehicleBody)

					SetBodyTransform(vehicleBody, Transform(newPos, vehicleTransform.rot))
				else
					SetPlayerTransform(Transform(newPos, playerTransform.rot))
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		rewind = {
			name = "Lets Try That Again",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {transform = Transform(Vec(0,0,0), QuatEuler(0,0,0)), currentVehicle = 0, velocity = Vec(0,0,0)},
			onEffectStart = function(vars)
				vars.effectVariables.transform = GetPlayerTransform()

				vars.effectVariables.currentVehicle = GetPlayerVehicle()

				if vars.effectVariables.currentVehicle ~= 0 then
					vars.effectVariables.velocity = GetBodyVelocity(GetVehicleBody(vars.effectVariables.currentVehicle))
				else
					vars.effectVariables.velocity = GetPlayerVelocity()
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				SetPlayerVehicle(vars.effectVariables.currentVehicle)

				if vars.effectVariables.currentVehicle ~= 0 then
					SetBodyTransform(GetVehicleBody(vars.effectVariables.currentVehicle), vars.effectVariables.transform)
					SetBodyVelocity(GetVehicleBody(vars.effectVariables.currentVehicle), vars.effectVariables.velocity)
				else
					SetPlayerTransform(vars.effectVariables.transform)
					SetPlayerVelocity(vars.effectVariables.velocity)
				end
			end,
		},

		setPlayerIntoRandomVehicle = {
			name = "Enter Nearby Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local vehicles = {}
				for i=1, #nearbyShapes do
					if GetBodyVehicle(GetShapeBody(nearbyShapes[i])) ~= 0 then
						vehicles[#vehicles+1] = GetBodyVehicle(GetShapeBody(nearbyShapes[i]))
					end
				end

				if(#vehicles == 0) then
					return
				end

				local closestVehicle = 0
				local closestDistance = 10000

				local playerPos = GetPlayerTransform().pos
				for i = 1, #vehicles do
					local distance = VecLength(VecSub(GetVehicleTransform(vehicles[i]).pos, playerPos))

					if distance < closestDistance then
						closestDistance = distance
						closestVehicle = vehicles[i]
					end
				end

				SetPlayerVehicle(closestVehicle)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		ejectFromVehicle = {
			name = "Eject From Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetPlayerVehicle(0)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		cantUseVehicles = {
			name = "Take A Walk",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if GetPlayerVehicle() ~= 0 then
					SetPlayerVehicle(0)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		nothing = {
			name = "Nothing",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		fakeDeath = {
			name = "Fake Death",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { deathTimer = 5, nameBackup = "", playerTransform = nil},
			onEffectStart = function(vars)
				if GetPlayerVehicle() ~= 0 then
					SetPlayerVehicle(0)
				end

				vars.effectVariables.playerTransform = GetPlayerTransform()
				vars.effectVariables.nameBackup = vars.name -- In case I decide on a new name
				vars.name = chaosEffects.effects["instantDeath"].name
			end,
			onEffectTick = function(vars)
				if vars.effectLifetime >= vars.effectVariables.deathTimer then
					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0
					vars.effectLifetime = 0
				else
					SetPlayerHealth(1)

					local playerCamera = GetPlayerCameraTransform()
					local playerCameraPos = playerCamera.pos

					SetCameraTransform(Transform(VecAdd(playerCameraPos, Vec(0, -1, 0)), QuatEuler(-5, 0, 45)))

					SetPlayerTransform(vars.effectVariables.playerTransform)

					table.insert(drawCallQueue, function()
					UiPush()
						local currFade = 100 / 5 * vars.effectLifetime / 100

						UiColor(0, 0, 0, currFade)
						UiAlign("center middle")
						UiTranslate(UiCenter(), UiMiddle())
						UiRect(UiWidth() + 10, UiHeight() + 10)

					UiPop()
					end)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		fakeTeleport = {
			name = "Fake Teleport",
			effectDuration = 3,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { revealTimer = 3, nameBackup = "", transform = 0 },
			onEffectStart = function(vars)
				SetPlayerVehicle(0)

				vars.effectVariables.transform = GetPlayerTransform()

				RespawnPlayer()

				vars.effectVariables.nameBackup = vars.name
				vars.name = chaosEffects.effects["teleportToSpawn"].name
			end,
			onEffectTick = function(vars)
				if vars.effectLifetime >= vars.effectVariables.revealTimer then
					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0
					vars.effectLifetime = 0

					SetPlayerVehicle(0)
					SetPlayerTransform(vars.effectVariables.transform)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		speedLimit = {
			name = "Speed Limit",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local limit = 5

				if(GetPlayerVehicle ~= 0) then

					local vehicleBody = GetVehicleBody(GetPlayerVehicle())
					local speed = VecLength(GetBodyVelocity(vehicleBody))
					if speed > limit then
						SetBodyVelocity(vehicleBody, VecScale(GetBodyVelocity(vehicleBody), limit/speed))
					end

				end
			end,
			onEffectEnd = function(vars) end,
		},

		ghostCars = {
			name = "Ghost Cars",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {vehs = {},},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local vehicles = {}
				for i=1, #nearbyShapes do
					if GetBodyVehicle(GetShapeBody(nearbyShapes[i])) ~= 0 then
						vehicles[#vehicles+1] = GetBodyVehicle(GetShapeBody(nearbyShapes[i]))
					end
				end

				vars.effectVariables.vehs = vehicles
			end,
			onEffectTick = function(vars)
				for i=1, #vars.effectVariables.vehs do
					DriveVehicle(vars.effectVariables.vehs[i], 1, 0, false)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		launchAllVehicles = {
			name = "Launch All Vehicles Up",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				for i=1, #nearbyShapes do
					if GetBodyVehicle(GetShapeBody(nearbyShapes[i])) ~= 0 then
						SetBodyVelocity(GetShapeBody(nearbyShapes[i]), Vec(0, 25, 0))
					end
				end

				vars.effectVariables.vehs = vehicles
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		flipVehicle = {
			name = "Invert Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				if GetPlayerVehicle() ~= 0 then
					local vehicleBody = GetVehicleBody(GetPlayerVehicle())

					SetBodyTransform(vehicleBody, Transform(VecAdd(GetBodyTransform(vehicleBody).pos, Vec(0,3,0)), QuatRotateQuat(GetBodyTransform().rot, QuatAxisAngle(Vec(1,0,0), 180))))
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		knocking = {
			name = "Who's there?",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/knock.ogg"}},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				PlaySound(vars.effectSFX[1])
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		diggydiggyhole = {
			name = "Diggy Diggy Hole",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				MakeHole(GetPlayerTransform().pos, 5, 5, 5)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		disableTools = {
			name = "Hold On To That Tool",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {tools = {}},
			onEffectStart = function(vars)
				vars.effectVariables.tools = ListKeys("game.tool")

				for i = 1, #vars.effectVariables.tools do
					SetBool("game.tool."..vars.effectVariables.tools[i]..".enabled", false)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				for i = 1, #vars.effectVariables.tools do
					SetBool("game.tool."..vars.effectVariables.tools[i]..".enabled", true)
				end
			end,
		},

		cinematicMode = {
			name = "Cinematic Mode",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				table.insert(drawCallQueue, function()
				UiPush()
					UiColor(0, 0, 0, 1)

					local middleSize = UiHeight()/2.5

					UiRect(UiWidth(),UiHeight()/2-middleSize)

					UiTranslate(0, UiHeight()/2+middleSize)

					UiRect(UiWidth(),UiHeight()/2-middleSize)
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},

		dvdScreensaver = {
			name = "DVD Screensaver",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { x = 0, y = 0, px = true, py = true},
			onEffectStart = function(vars)
				vars.effectVariables.x = UiCenter()
				vars.effectVariables.y = UiMiddle()
			end,
			onEffectTick = function(vars)
				local speed = 5
				local middleSize = UiHeight() / 5

				if vars.effectVariables.px then
					vars.effectVariables.x = vars.effectVariables.x + speed
				else
					vars.effectVariables.x = vars.effectVariables.x - speed
				end

				if vars.effectVariables.x + middleSize >= UiWidth() or vars.effectVariables.x - middleSize <= 0 then
					vars.effectVariables.px = not vars.effectVariables.px
				end

				if vars.effectVariables.py then
					vars.effectVariables.y = vars.effectVariables.y + speed
				else
					vars.effectVariables.y = vars.effectVariables.y - speed
				end

				if vars.effectVariables.y + middleSize >= UiHeight() or vars.effectVariables.y - middleSize <= 0 then
					vars.effectVariables.py = not vars.effectVariables.py
				end

				table.insert(drawCallQueue, function()
				UiPush()
					UiTranslate(vars.effectVariables.x - UiCenter(), vars.effectVariables.y - UiMiddle())
					UiColor(0, 0, 0, 1)

					--Top part
					UiPush()
						UiTranslate(-UiWidth()/2, -UiHeight()/2)
						UiRect(UiWidth()*2,UiHeight()-middleSize)
					UiPop()

					--Bottom part
					UiPush()
						UiTranslate(-UiWidth()/2, UiHeight()/2+middleSize)

						UiRect(UiWidth()*2,UiHeight()-middleSize)
					UiPop()

					--Left part
					UiPush()
						UiTranslate(-UiWidth()/2, 0)
						UiRect(UiWidth()-middleSize,UiHeight())
					UiPop()

					--Right part
					UiPush()
						UiTranslate(UiWidth()/2+middleSize, 0)

						UiRect(UiWidth()-middleSize,UiHeight())
					UiPop()
				UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},

		quakefov = { -- Disables tool functionality, unsure how to fix yet.
			name = "Quake FOV",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				SetCameraFov(140)
			end,
			onEffectEnd = function(vars) end,
		},

		binoculars = {
			name = "Binoculars",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				SetCameraFov(10)
			end,
			onEffectEnd = function(vars) end,
		},

		turtlemode = {
			name = "Turtle Mode",
			effectDuration = 20,
			effectLifetime = 0,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerCamera = GetPlayerCameraTransform()
				local playerCameraPos = playerCamera.pos

				local playerCameraRot = QuatRotateQuat(playerCamera.rot, QuatEuler(0, 0, -180))

				SetCameraTransform(Transform(playerCamera.pos, playerCameraRot))
			end,
			onEffectEnd = function(vars) end,
		},

		networkLag = {
			name = "Lag",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {lastPlayerPos = nil, lastPlayerRot = nil, lastPlayerVel = nil, lastPlayerVehicle = 0, lastPlayerVehiclePos = nil, lastPlayerVehicleRot = nil, lastPlayerVehicleVel = nil,},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()

				vars.effectVariables.lastPlayerPos = playerTransform.pos
				vars.effectVariables.lastPlayerRot = playerTransform.rot

				vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()

				if vars.effectVariables.lastPlayerVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
					local vehicleTransform = GetBodyTransform(vehicleBody)

					vars.effectVariables.lastPlayerVehiclePos = vehicleTransform.pos
					vars.effectVariables.lastPlayerVehicleRot = vehicleTransform.rot
					vars.effectVariables.lastPlayerVehicleVel = GetBodyVelocity(vehicleBody)
				end
			end,
			onEffectTick = function(vars)
				if vars.effectLifetime % 2 <= 0.5 and vars.effectLifetime > 1 then
					if vars.effectVariables.lastPlayerVehicle ~= 0 then
						local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
						local vehicleTransform = GetBodyTransform(vehicleBody)

						SetBodyTransform(vehicleBody, Transform(vars.effectVariables.lastPlayerVehiclePos, vars.effectVariables.lastPlayerVehicleRot))
						SetBodyVelocity(vehicleBody, vars.effectVariables.lastPlayerVehicleVel)
					else
						SetPlayerTransform(Transform(vars.effectVariables.lastPlayerPos, vars.effectVariables.lastPlayerRot))
						SetPlayerVehicle(vars.effectVariables.lastPlayerVehicle)
						SetPlayerVelocity(vars.effectVariables.lastPlayerVel)
					end
				else
					if vars.effectLifetime % 3 <= 2.5 then
						local playerTransform = GetPlayerTransform()

						vars.effectVariables.lastPlayerPos = playerTransform.pos
						vars.effectVariables.lastPlayerRot = playerTransform.rot

						if GetPlayerVehicle() == vars.effectVariables.lastPlayerVehicle then
							local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
							local vehicleTransform = GetBodyTransform(vehicleBody)

							vars.effectVariables.lastPlayerVehiclePos = vehicleTransform.pos
							vars.effectVariables.lastPlayerVehicleRot = vehicleTransform.rot
							vars.effectVariables.lastPlayerVehicleVel = GetBodyVelocity(vehicleBody)
						else
							vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
						end
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},

		virtualReality = {
			name = "Virtual Reality",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {lastPlayerPos = nil, lastPlayerRot = nil, lastPlayerVel = nil, lastPlayerVehicle = 0, lastPlayerVehiclePos = nil, lastPlayerVehicleRot = nil, lastPlayerVehicleVel = nil,},
			onEffectStart = function(vars)
				local playerTransform = GetPlayerTransform()

				vars.effectVariables.lastPlayerPos = playerTransform.pos
				vars.effectVariables.lastPlayerRot = playerTransform.rot

				vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()

				if vars.effectVariables.lastPlayerVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
					local vehicleTransform = GetBodyTransform(vehicleBody)

					vars.effectVariables.lastPlayerVehiclePos = vehicleTransform.pos
					vars.effectVariables.lastPlayerVehicleRot = vehicleTransform.rot
					vars.effectVariables.lastPlayerVehicleVel = GetBodyVelocity(vehicleBody)
				end
			end,
			onEffectTick = function(vars)
				table.insert(drawCallQueue, function()
					UiPush()
						UiColor(0, 1, 0, 0.3)
						UiRect(UiWidth(), UiHeight())
					UiPop()
				end)
			end,
			onEffectEnd = function(vars)
				if vars.effectVariables.lastPlayerVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(vars.effectVariables.lastPlayerVehicle)
					local vehicleTransform = GetBodyTransform(vehicleBody)

					SetBodyTransform(vehicleBody, Transform(vars.effectVariables.lastPlayerVehiclePos, vars.effectVariables.lastPlayerVehicleRot))
					SetBodyVelocity(vehicleBody, vars.effectVariables.lastPlayerVehicleVel)
				else
					SetPlayerTransform(Transform(vars.effectVariables.lastPlayerPos, vars.effectVariables.lastPlayerRot))
					SetPlayerVehicle(vars.effectVariables.lastPlayerVehicle)
					SetPlayerVelocity(vars.effectVariables.lastPlayerVel)
				end
			end,
		},

		flashbang = {
			name = "Flashbang",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/flashbang.ogg"}},
			effectSprites = {},
			effectVariables = {flashOpacity = 1,},
			onEffectStart = function(vars)
				PlaySound(vars.effectSFX[1])
			end,
			onEffectTick = function(vars)
				if vars.effectVariables.flashOpacity > 0 then
					if vars.effectLifetime > 2.5 then
						table.insert(drawCallQueue, function()
							UiBlur(vars.effectVariables.flashOpacity)
							UiPush()
								UiColor(1, 1, 1, vars.effectVariables.flashOpacity)
								UiRect(UiWidth(), UiHeight())
							UiPop()
						end)
					end
					if vars.effectLifetime > 4.2 then
						vars.effectVariables.flashOpacity = vars.effectVariables.flashOpacity - 0.01
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},

		moveOrDie = {
			name = "Move or Die",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local hp = GetPlayerHealth()
				local step = 0.01

				-- Don't count vertical velocity
				local vel = GetPlayerVelocity()
				vel[2] = 0

				local nextHPStep = ((VecLength(vel) / 3.5) * step) - step
				SetPlayerHealth(hp + nextHPStep)
			end,
			onEffectEnd = function(vars) end,
		},

		keepGoingForward = {
			name = "My W Key Is Stuck",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerVehicle = GetPlayerVehicle()
				
				if playerVehicle > 0 then
					DriveVehicle(playerVehicle, 1, 0, false)
					return
				end
			
				local playerVel = VecCopy(GetPlayerVelocity())

				playerVel[1] = 0
				playerVel[3] = 0

				local isTouchingGround = playerVel[2] >= -0.00001 and playerVel[2] <= 0.00001

				if vars.effectVariables.jumpNextFrame then
					vars.effectVariables.jumpNextFrame = false

					playerVel[2] = 5

					SetPlayerVelocity(playerVel)
				end

				if InputPressed("space") and isTouchingGround then
					vars.effectVariables.jumpNextFrame = true
				end

				local forwardMovement = 1
				local rightMovement = 0

				if InputDown("left") then
					rightMovement = rightMovement - 1
				end

				if InputDown("right") then
					rightMovement = rightMovement + 1
				end

				forwardMovement = forwardMovement * 10
				rightMovement = rightMovement * 10

				local playerTransform = GetPlayerTransform()

				local forwardInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(0, 0, -1))
				local rightInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(1, 0, 0))

				local forwardDirectionStrength = VecScale(forwardInWorldSpace, forwardMovement)
				local rightDirectionStrength = VecScale(rightInWorldSpace, rightMovement)

				playerVel = VecAdd(VecAdd(playerVel, forwardDirectionStrength), rightDirectionStrength)

				SetPlayerVelocity(playerVel)
			end,
			onEffectEnd = function(vars) end,
		},

		keepJumping = {
			name = "Bunnyhop",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerVel = VecCopy(GetPlayerVelocity())

				playerVel[1] = 0
				playerVel[3] = 0

				local groundBelow = raycast(GetPlayerTransform().pos, Vec(0, -1, 0), 0.1)
				local isTouchingGround = playerVel[2] >= -0.00001 and playerVel[2] <= 0.00001
				vars.effectVariables.a = playerVel[2]

				if groundBelow then
					playerVel[2] = 7
				end

				local forwardMovement = 0
				local rightMovement = 0

				if InputDown("up") then
					forwardMovement = forwardMovement + 1
				end

				if InputDown("down") then
					forwardMovement = forwardMovement - 1
				end

				if InputDown("left") then
					rightMovement = rightMovement - 1
				end

				if InputDown("right") then
					rightMovement = rightMovement + 1
				end

				forwardMovement = forwardMovement * 7
				rightMovement = rightMovement * 7

				local playerTransform = GetPlayerTransform()

				local forwardInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(0, 0, -1))
				local rightInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(1, 0, 0))

				local forwardDirectionStrength = VecScale(forwardInWorldSpace, forwardMovement)
				local rightDirectionStrength = VecScale(rightInWorldSpace, rightMovement)

				playerVel = VecAdd(VecAdd(playerVel, forwardDirectionStrength), rightDirectionStrength)

				playerVel = playerVel

				SetPlayerVelocity(playerVel)
			end,
			onEffectEnd = function(vars) end,
		},

		vehicleKickflip = {
			name = "Kickflip",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local playerVehicle = GetPlayerVehicle()

				if playerVehicle ~= 0 then
					local vehicleBody = GetVehicleBody(playerVehicle)

					local vehicleTransform = GetVehicleTransform(playerVehicle)

					local kickflipPosition = TransformToParentPoint(vehicleTransform, Vec(1, 0.5, 0))
					local jumpPosition = TransformToParentPoint(vehicleTransform, Vec(0, 0, 0))

					local bodyMass = GetBodyMass(vehicleBody)

					local velocityMultiplier = 1

					if bodyMass > 15000 then
						velocityMultiplier = 1.6
					elseif bodyMass > 10000 then
						velocityMultiplier = 1.3
					end

					local kickflipVel = Vec(0, velocityMultiplier * (2 * bodyMass), 0)
					local jumpVel = Vec(0, velocityMultiplier * (5.7 * bodyMass), 0)

					ApplyBodyImpulse(vehicleBody, jumpPosition, jumpVel)
					ApplyBodyImpulse(vehicleBody, kickflipPosition, kickflipVel)
				end
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		freeShots = {
			name = "Free Shots",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {lastFrameTool = "", lastFrameAmmo = ""},
			onEffectStart = function(vars)
				vars.effectVariables.lastFrameTool = GetString("game.player.tool")
				vars.effectVariables.lastFrameAmmo =  GetFloat("game.tool." ..  vars.effectVariables.lastFrameTool .. ".ammo")
			end,
			onEffectTick = function(vars)
				local currentTool = GetString("game.player.tool")
				local currentAmmo = GetFloat("game.tool." ..  currentTool .. ".ammo")
				if currentTool == vars.effectVariables.lastFrameTool then
					if currentAmmo < vars.effectVariables.lastFrameAmmo then
						SetFloat("game.tool." ..  currentTool .. ".ammo", vars.effectVariables.lastFrameAmmo)
					end
				else
					vars.effectVariables.lastFrameTool = GetString("game.player.tool")
					vars.effectVariables.lastFrameAmmo =  GetFloat("game.tool." ..  vars.effectVariables.lastFrameTool .. ".ammo")
				end
			end,
			onEffectEnd = function(vars) end,
		},

		birdPerspective = {
			name = "GTA 2",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { playerVehicleLastFrame = 0 },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerCameraPos = nil

				local playerTransform = GetPlayerTransform()

				local playerPos = playerTransform.pos

				-- Camera movement

				local cameraRayOrigin = VecAdd(playerPos, Vec(0, 1, 0))
				local cameraRayDir = TransformToParentVec(playerTransform, {0, 1, 0})

				local cameraHit, cameraHitPoint = raycast(cameraRayOrigin, cameraRayDir, 30)

				if cameraHit then
					playerCameraPos = VecAdd(cameraHitPoint, Vec(0, -2, 0))
				else
					playerCameraPos = VecAdd(GetPlayerCameraTransform().pos, Vec(0, 30, 0))
				end

				if GetPlayerVehicle() == 0 then
					SpawnParticle("smoke", playerPos, Vec(0, 0, 0),  0.5, 0.5)
				end

				local distanceBetweenCamera = VecDist(playerPos, playerCameraPos)

				local fov = 120 / 30 * (120 - distanceBetweenCamera)

				if not cameraHit or distanceBetweenCamera < 6 then
					fov = 90
				end

				SetCameraTransform(Transform(playerCameraPos, QuatEuler(-90, -90, 0)), fov)
				-- End camera movement

				--####################

				-- Player movement

				local walkingSpeed = 7

				local currentPlayerVelocity = GetPlayerVelocity()

				local forwardMovement = 0

				local rightMovement = 0

				local upwardsMovement = 0

				if InputDown("w") then
					forwardMovement = forwardMovement + walkingSpeed
				end

				if InputDown("s") then
					forwardMovement = forwardMovement - walkingSpeed
				end

				if InputDown("a") then
					rightMovement = rightMovement - walkingSpeed
				end

				if InputDown("d") then
					rightMovement = rightMovement + walkingSpeed
				end

				SetPlayerVelocity(Vec(forwardMovement,  currentPlayerVelocity[2], rightMovement))

				-- End Player movement

				--####################

				-- Enter Vehicle

				if GetPlayerVehicle() == 0 and vars.effectVariables.playerVehicleLastFrame ~= 0 then
					vars.effectVariables.playerVehicleLastFrame = 0
					return
				end

				local range = 2

				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local bodyList = QueryAabbBodies(minPos, maxPos)

				local vehicleList = {}

				for i=1, #bodyList do
					local currBody = bodyList[i]

					local vehicle = GetBodyVehicle(currBody)

					if vehicle ~= 0 then
						table.insert(vehicleList, vehicle)
					end
				end

				function getDistToVehicle(vehicle)
					local vehicleTransform = GetVehicleTransform(vehicle)
					local vehiclePos = vehicleTransform.pos

					local distance = VecDist(playerPos, vehiclePos)

					return distance
				end

				if #vehicleList <= 0 then
					return
				end

				local closestVehicleDist = getDistToVehicle(vehicleList[1])
				local closetVehicleIndex = vehicleList[1]

				if #vehicleList > 1 then
					for i=2, #vehicleList do
						local currentVehicle = vehicleList[i]
						local currDist = getDistToVehicle(currentVehicle)

						if currDist < closestVehicleDist then
							closestVehicleDist = currDist
							closetVehicleIndex = currentVehicle
						end
					end
				end

				if GetPlayerVehicle() == 0 then
					DrawBodyOutline(GetVehicleBody(closetVehicleIndex), 1, 1, 1, 0.75)
				end

				if InputPressed("e") then
					SetPlayerVehicle(closetVehicleIndex)
				end

				vars.effectVariables.playerVehicleLastFrame = GetPlayerVehicle()

				-- End Enter Vehicle

				-- TODO: Render enter vehicle on top of closest vehicle.
			end,
			onEffectEnd = function(vars) end,
		},

		objectFlyAway = {
			name = "Hope That Can Fly",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local cameraTransform = GetCameraTransform()
				local rayDirection = TransformToParentVec(cameraTransform, Vec(0, 0, -1))

				local hit, hitPoint, distance, normal, shape = raycast(cameraTransform.pos, rayDirection, 50)

				if not hit then
					return
				end

				local shapeBody = GetShapeBody(shape)

				if not IsBodyDynamic(shapeBody) then
					return
				end

				local upVel = Vec(0, 35, 0)
				SetBodyVelocity(shapeBody, upVel)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		fakeDeleteVehicle = {
			name = "Fake Delete Vehicle",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { revealTimer = 5, nameBackup = "", transform = 0, vehicle = 0, triggered = false},
			onEffectStart = function(vars)
				local vehicle = GetPlayerVehicle()

				if vehicle ~= 0 then
					local vehicleBody = GetVehicleBody(vehicle)
					local bodyTransform = GetBodyTransform(vehicleBody)

					vars.effectVariables.vehicle = vehicle
					vars.effectVariables.transform = TransformCopy(bodyTransform)

					bodyTransform.pos = VecAdd(bodyTransform.pos, Vec(0, 10000, 0))

					SetPlayerVehicle(0)

					local bodyShapes = GetBodyShapes(vehicleBody)
					
					for i = 1, #bodyShapes do
						local currentShape = bodyShapes[i]
						local localTransform = TransformCopy(GetShapeLocalTransform(currentShape))
						
						localTransform.pos = VecAdd(localTransform.pos, Vec(0, 10000, 0))
						
						SetShapeLocalTransform(currentShape, localTransform)
					end
					
					SetBodyTransform(vehicleBody, bodyTransform) -- Just get the vehicle out of there
					
					SetBodyVelocity(vehicleBody, Vec(0, 0, 0))
				else
					return
				end

				vars.effectVariables.nameBackup = vars.name
				vars.name = chaosEffects.effects["removeCurrentVehicle"].name
			end,
			onEffectTick = function(vars)
				if (vars.effectLifetime >= vars.effectVariables.revealTimer or vars.effectVariables.vehicle == 0) and not vars.effectVariables.triggered then
					vars.effectVariables.triggered = true

					vars.name = vars.effectVariables.nameBackup
					vars.effectDuration = 0

					local vehicle = vars.effectVariables.vehicle

					if vehicle ~= 0 then
						local vehicleBody = GetVehicleBody(vehicle)
						
						local bodyShapes = GetBodyShapes(vehicleBody)
					
						for i = 1, #bodyShapes do
							local currentShape = bodyShapes[i]
							local localTransform = TransformCopy(GetShapeLocalTransform(currentShape))
							
							localTransform.pos = VecAdd(localTransform.pos, Vec(0, -10000, 0))
							
							SetShapeLocalTransform(currentShape, localTransform)
						end
						
						SetBodyTransform(vehicleBody, vars.effectVariables.transform)

						SetBodyVelocity(vehicleBody, Vec(0, 0, 0))

						SetPlayerVehicle(vehicle)
					end
				end
			end,

			onEffectEnd = function(vars) end,
		},

		freezeFrame = {
			name = "Freeze Frame",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { bodies = {} },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local function has_value(tab, val)
					for index, value in ipairs(tab) do
							if value == val then
									return true
							end
					end
					return false
				end

				local range = 100

				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local bodies = QueryAabbBodies(minPos, maxPos)

				for i=1, #bodies do
					local body = bodies[i]
					if IsBodyDynamic(body) and not has_value(vars.effectVariables.bodies, body) then
						table.insert(vars.effectVariables.bodies, body)
						SetBodyDynamic(body, false)
					end
				end
			end,
			onEffectEnd = function(vars)
				for key, body in ipairs(vars.effectVariables.bodies) do
					SetBodyDynamic(body, true)
					local com = GetBodyCenterOfMass(body)
					local worldPoint = TransformToParentPoint(GetBodyTransform(body), com)
					ApplyBodyImpulse(body, worldPoint, Vec(0, 0, 10))
				end
			end,
		},

		lowgravity = {
			name = "Low Gravity",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { affectedBodies = {}},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerPos = GetPlayerTransform().pos
				local range = 50

				local tempVec = GetPlayerVelocity()
				tempVec[2] = 0.5
				SetPlayerVelocity(tempVec)

				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local shapeList = QueryAabbBodies(minPos, maxPos)

				for i = 1, #shapeList do
					local shapeBody = shapeList[i]

					if IsBodyDynamic(shapeBody) then

						if vars.effectVariables.affectedBodies[shapeBody] == nil then
							vars.effectVariables.affectedBodies[shapeBody] = "hit"
						end

						local bodyVelocity = GetBodyVelocity(shapeBody)

						bodyVelocity[2] = 0.5

						SetBodyVelocity(shapeBody, bodyVelocity)
					end
				end
			end,
			onEffectEnd = function(vars)
				for shapeBody, value in pairs(vars.effectVariables.affectedBodies) do
					local shapeTransform = GetBodyTransform(shapeBody)
					ApplyBodyImpulse(shapeBody, shapeTransform.pos, Vec(0, -1, 0))
				end
			end,
		},

		explosivePunch = {
			name = "Explosive Punch",
			effectDuration = 17.5,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if InputPressed("usetool") then
					local cameraTransform = GetCameraTransform()
					local rayDirection = TransformToParentVec(cameraTransform, {0, 0, -1})

					local hit, hitPoint, distance = raycast(cameraTransform.pos, rayDirection, 3)

					if hit == false then
						return
					end

					Explosion(hitPoint, 0.5)
					SetPlayerHealth(1)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		suddenFlood = {
			name = "Sudden Flood",
			effectDuration = 30,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {"MOD/sprites/square.png"},
			effectVariables = { waterHeight = -1 },
			onEffectStart = function(vars)
				vars.effectVariables.waterHeight = math.random(12, 15)
			end,
			onEffectTick = function(vars)
				local playerPos = GetPlayerTransform().pos
				local playerCamera = GetPlayerCameraTransform()
				local floatHeightDiff = 0.25

				local waterPos = VecCopy(playerPos)

				waterPos[2] = vars.effectVariables.waterHeight

				local rotation = QuatEuler(90, 0, 0)

				DrawSprite(vars.effectSprites[1], Transform(waterPos, rotation), 500, 500, 0, 0, 1, 0.25, true, true)

				-- Object Behaviour

				local range = 50

				local minPos = VecAdd(waterPos, Vec(-range, -(vars.effectVariables.waterHeight + range), -range))
				local maxPos = VecAdd(waterPos, Vec(range, -floatHeightDiff, range))

				local shapeList = QueryAabbShapes(minPos, maxPos)

				for key, value in ipairs(shapeList) do
					local shapeBody = GetShapeBody(value)

					if IsBodyDynamic(shapeBody) then
						local shapeTransform = GetBodyTransform(shape)

						local bodyVelocity = GetBodyVelocity(shapeBody)

						bodyVelocity[2] = 0.1 * math.abs(shapeTransform.pos[2] - (vars.effectVariables.waterHeight - floatHeightDiff))

						SetBodyVelocity(shapeBody, bodyVelocity)
					end
				end

				-- End Object Behaviour

				--####################

				-- Player Behaviour

				if playerPos[2] < vars.effectVariables.waterHeight - floatHeightDiff then
					local playerVelocity = GetPlayerVelocity()

					if InputDown("crouch") then
						playerVelocity[2] = -3
					elseif InputDown("jump") then
						playerVelocity[2] = 3
					else
						playerVelocity[2] = 2
					end


					SetPlayerVelocity(playerVelocity)
				end

				if playerCamera.pos[2] < vars.effectVariables.waterHeight then
					table.insert(drawCallQueue, function()
						UiPush()
							UiAlign("top left")
							UiColor(0.25, 0.25, 1, 0.5)
							UiRect(UiWidth() + 20, UiHeight() + 20)
							UiBlur(0.25)
						UiPop()
					end)
				end

				-- End Player Behaviour
			end,
			onEffectEnd = function(vars) end,
		},

		dontStopDriving = {
			name = "Speed",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { fuseTimer = 10, inVehicle = false, uiHeightAnim = -300 },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local vehicle = GetPlayerVehicle()

				-- Explode if exiting during speed
				if vehicle == 0 then
					if vars.effectVariables.inVehicle then
						vars.effectVariables.inVehicle = false
						vars.effectDuration = 0
						Explosion(GetPlayerTransform().pos, 4)
						Explosion(GetPlayerTransform().pos, 4)
					end
					return
				end

				vars.effectVariables.inVehicle = true
				local vehicleBody = GetVehicleBody(vehicle)
				local vehicleTransform = GetVehicleTransform(vehicle)

				local vel = TransformToLocalVec(vehicleTransform, GetBodyVelocity(vehicleBody))

				local speed = -vel[3]
				--Speed is in meter per second, convert to km/h
				speed = speed * 3.6
				speed = math.abs(math.floor(speed))

				table.insert(drawCallQueue, function()
					UiPush()
						if vars.effectVariables.uiHeightAnim <= 0 then
							vars.effectVariables.uiHeightAnim = vars.effectVariables.uiHeightAnim + (GetChaosTimeStep() * 600)
							UiTranslate(0, vars.effectVariables.uiHeightAnim)
						end

						local w = UiWidth() * 0.6
						local h = 150
						UiAlign("top center")
						UiTranslate(UiWidth()/2, UiHeight() * 0.05)
						UiColor(0, 0, 0, 0.5)
						UiImageBox("ui/common/box-solid-shadow-50.png", w, h, -50, -50)
						UiWindow(w, h, true)

						local warnAmount = 0
						if vars.effectVariables.fuseTimer < 3 then
							warnAmount = (3 - vars.effectVariables.fuseTimer) / 3
						end

						local recovering = speed >= 30
						if not recovering then
							vars.effectVariables.fuseTimer = vars.effectVariables.fuseTimer - GetChaosTimeStep()
						elseif vars.effectVariables.fuseTimer < 10 then
							vars.effectVariables.fuseTimer = vars.effectVariables.fuseTimer + GetChaosTimeStep()
						elseif vars.effectVariables.fuseTimer > 10 then
							 vars.effectVariables.fuseTimer = 10
						end

						if vars.effectVariables.fuseTimer <= 0 then
							Explosion(GetPlayerTransform().pos, 4)
							Explosion(GetPlayerTransform().pos, 4)
							vars.effectDuration = 0
						end

						UiPush()
							UiFont("bold.ttf", 50)
							UiAlign("center middle")
							UiTranslate(UiCenter(), 50)
							UiTextShadow(0, 0, 0, 0.5, 2.0)
							UiScale(2.0)

							if recovering then
								UiColor(0.25, 1, 0.25)
							else
								UiColor(1, (1 - warnAmount), (1 - warnAmount))
							end

							local shakeDist = 5
							local shakeX = math.random(-(shakeDist * warnAmount), (shakeDist * warnAmount))
							local shakeY = math.random(-(shakeDist * warnAmount), (shakeDist * warnAmount))
							UiTranslate(shakeX, shakeY)

							local decSplit = splitString(tostring(vars.effectVariables.fuseTimer), '.')
							local decimals = '00'
							if decSplit[2] ~= nil then
								decimals = stringLeftPad(string.sub(decSplit[2], 0, 2), 2, '0')
							end
							UiText(decSplit[1] .. '.' .. decimals)
						UiPop()

						UiPush()
							UiFont("regular.ttf", 40)
							UiColor(1, 1, 1)
							UiTextShadow(0, 0, 0, 0.5, 2.0)
							UiAlign("bottom center")
							UiTranslate(UiCenter(), UiHeight() * 0.85)
							UiText("Keep above 30 km/h or the bomb explodes!")

							UiFont("regular.ttf", 26)
							UiTranslate(0, 25)
							UiText("Current speed: " .. speed .. " km/h")
						UiPop()
					UiPop()
				end)

			end,
			onEffectEnd = function(vars) end,
		},

		teleportGun = {
			name = "Teleport Gun",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				if InputPressed("usetool") then
					local cameraTransform = GetCameraTransform()
					local rayDirection = TransformToParentVec(cameraTransform, Vec(0, 0, -1))

					local hit, hitPoint, distance, normal = raycast(cameraTransform.pos, rayDirection, 100)

					if hit == false then
						return
					end

					local newPos = VecAdd(hitPoint, VecScale(normal, 1.5))

					local playerTransform = GetPlayerTransform()

					SetPlayerTransform(Transform(newPos, playerTransform.rot))
				end
			end,
			onEffectEnd = function(vars) end,
		},

		foggyDay = {
			name = "Foggy Day",
			effectDuration = 30,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {"MOD/sprites/square.png"},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local cameraTransform = GetCameraTransform()
				local forwardDirection = TransformToParentVec(cameraTransform, Vec(0, 0, -1))

				local fogStep = 0.5
				local fogLayers = 100
				local fogStart = 40

				for i = 1, fogLayers do
					local spritePos = VecAdd(cameraTransform.pos, VecScale(forwardDirection, fogStart - i * fogStep))
					local spriteRot = QuatLookAt(spritePos, cameraTransform.pos)

					DrawSprite(vars.effectSprites[1], Transform(spritePos, spriteRot), 200, 200, 0.25, 0.25, 0.25, 0.5, true, true)
				end
			end,
			onEffectEnd = function(vars) end,
		},

		honkingVehicles = {
			name = "Honk Honk",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/carhonks/honk01.ogg"},
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk02.ogg"},
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk03.ogg"},
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk04.ogg"},
						 {isLoop = false, soundPath = "MOD/sfx/carhonks/honk05.ogg"}, },
			effectSprites = {},
			effectVariables = {vehicles = {}},
			onEffectStart = function(vars)
				local range = 500
				local minPos = Vec(-range, -range, -range)
				local maxPos = Vec(range, range, range)
				local nearbyShapes = QueryAabbShapes(minPos, maxPos)

				for i = 1, #nearbyShapes do
					local currentShape = nearbyShapes[i]
					local shapeBody = GetShapeBody(currentShape)

					if GetBodyVehicle(shapeBody) ~= 0 then
						local vehicleHandle = GetBodyVehicle(shapeBody)

						vars.effectVariables.vehicles[#vars.effectVariables.vehicles + 1] = {handle = vehicleHandle, honkTimer = 0}
					end
				end
			end,
			onEffectTick = function(vars)
				for index, vehicleData in ipairs(vars.effectVariables.vehicles) do
					if math.random(1, 10) > 6 and vehicleData.honkTimer <= 0 then
						vehicleData.honkTimer = math.random(3, 5)

						local vehicleTransform = GetVehicleTransform(vehicleData.handle)

						local sfxIndex = math.random(1, #vars.effectSFX)

						PlaySound(vars.effectSFX[sfxIndex], vehicleTransform.pos,  1)
					else
						vehicleData.honkTimer = vehicleData.honkTimer - GetChaosTimeStep()
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},

		superWalkJump = {
			name = "Super Jump & Super Walkspeed",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { jumpNextFrame = false },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerVel = VecCopy(GetPlayerVelocity())

				playerVel[1] = 0
				playerVel[3] = 0

				local isTouchingGround = playerVel[2] >= -0.00001 and playerVel[2] <= 0.00001

				if vars.effectVariables.jumpNextFrame then
					vars.effectVariables.jumpNextFrame = false

					playerVel[2] = 15

					SetPlayerVelocity(playerVel)
				end

				if InputPressed("jump") and isTouchingGround then
					vars.effectVariables.jumpNextFrame = true
				end

				local forwardMovement = 0
				local rightMovement = 0

				if InputDown("up") then
					forwardMovement = forwardMovement + 1
				end

				if InputDown("down") then
					forwardMovement = forwardMovement - 1
				end

				if InputDown("left") then
					rightMovement = rightMovement - 1
				end

				if InputDown("right") then
					rightMovement = rightMovement + 1
				end

				forwardMovement = forwardMovement * 25
				rightMovement = rightMovement * 25

				local playerTransform = GetPlayerTransform()

				local forwardInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(0, 0, -1))
				local rightInWorldSpace = TransformToParentVec(GetPlayerTransform(), Vec(1, 0, 0))

				local forwardDirectionStrength = VecScale(forwardInWorldSpace, forwardMovement)
				local rightDirectionStrength = VecScale(rightInWorldSpace, rightMovement)

				playerVel = VecAdd(VecAdd(playerVel, forwardDirectionStrength), rightDirectionStrength)

				playerVel = playerVel

				SetPlayerVelocity(playerVel)
			end,
			onEffectEnd = function(vars) end,
		},

		tripleJump = {
			name = "Triple Jump",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { jumpNextFrame = false, jumpsLeft = 0, maxExtraJumps = 2 },
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerVel = GetPlayerVelocity()

				local isTouchingGround = playerVel[2] >= -0.00001 and playerVel[2] <= 0.00001

				if vars.effectVariables.jumpNextFrame then
					vars.effectVariables.jumpNextFrame = false

					playerVel[2] = 4
				end

				if InputPressed("jump") and vars.effectVariables.jumpsLeft > 0 then
					vars.effectVariables.jumpsLeft = vars.effectVariables.jumpsLeft - 1
					vars.effectVariables.jumpNextFrame = true
				end

				if isTouchingGround and vars.effectVariables.jumpsLeft < vars.effectVariables.maxExtraJumps then
					vars.effectVariables.jumpsLeft = vars.effectVariables.maxExtraJumps
				end

				SetPlayerVelocity(playerVel)
			end,
			onEffectEnd = function(vars) end,
		},

		simonSays = {
			name = "1 Gordon Says",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { activeDelay = 2, forcedInput = nil, avoid = false},
			onEffectStart = function(vars)
				local possibleInputs = {{key = "up", message = "forwards"},
										{key = "down", message = "backwards"},
										{key = "left", message = "left"},
										{key = "right", message = "right"}}

				local selectedInput = possibleInputs[math.random(1, #possibleInputs)]

				vars.effectVariables.forcedInput = selectedInput
				
				if math.random(1, 10) > 5 then
					vars.effectVariables.avoid = true
				end
			end,
			onEffectTick = function(vars)
				local forcedInput = vars.effectVariables.forcedInput

				table.insert(drawCallQueue, function()
					UiPush()
						UiFont("regular.ttf", 52)
						UiTextShadow(0, 0, 0, 0.5, 2.0)

						UiAlign("center middle")

						UiTranslate(UiCenter(), UiHeight() * 0.2)

						UiText("Gordon Says")

						UiTranslate(0, 40)

						UiFont("regular.ttf", 26)
						
						if vars.effectVariables.avoid then
							UiText("Don't press the " .. forcedInput.message.. " movement key!")
						else
							UiText("Press and hold the " .. forcedInput.message.. " movement key!")
						end
						
						UiPush()
							if vars.effectVariables.activeDelay > 0 then
								UiTranslate(-50, 20)
								
								UiColor(0, 0, 0, 0.25)
								
								UiAlign("left middle")
								
								UiRect(100, 5)
								
								local color = 0.75 / 2 * vars.effectVariables.activeDelay
								
								UiColor(1, color, color, 0.5)
								
								local barWidth = 100 / 2 * vars.effectVariables.activeDelay
								
								UiRect(barWidth, 5)
							end
						UiPop()
						
					UiPop()
				end)

				if vars.effectVariables.activeDelay > 0 then
					vars.effectVariables.activeDelay = vars.effectVariables.activeDelay - GetChaosTimeStep()
					return
				end

				if (not InputDown(forcedInput.key) and not vars.effectVariables.avoid) or (InputDown(forcedInput.key) and vars.effectVariables.avoid) then
					local playerPos = GetPlayerTransform().pos
					Explosion(playerPos, 3)
					SetPlayerHealth(0)
					vars.effectDuration = 0
					return
				end
			end,
			onEffectEnd = function(vars) end,
		},

		teleportToHeaven = {
			name = "Teleport To Heaven",
			effectDuration = 50,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				SetPlayerVehicle(0)

				local playerTransform = GetPlayerTransform()

				playerTransform.pos = VecAdd(playerTransform.pos, Vec(0, 500, 0))

				SetPlayerTransform(playerTransform)
			end,
			onEffectTick = function(vars)
				local playerTransform = GetPlayerTransform()
				local rayDirection = TransformToParentVec(playerTransform, Vec(0, -1, 0))

				local hit, hitPoint, distance, normal = raycast(playerTransform.pos, rayDirection, 2)

				if hit == false then
					return
				end

				SetPlayerHealth(0.2)
				SetPlayerVelocity(Vec(0, 0, 0))

				vars.effectDuration = 0
				vars.effectLifetime = 0
			end,
			onEffectEnd = function(vars) end,
		},

		jumpyVehicles = {
			name = "Jumpy Vehicles",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {vehicles = {}},
			onEffectStart = function(vars)
				local range = 500
				local minPos = Vec(-range, -range, -range)
				local maxPos = Vec(range, range, range)
				local nearbyShapes = QueryAabbShapes(minPos, maxPos)

				for i = 1, #nearbyShapes do
					local currentShape = nearbyShapes[i]
					local shapeBody = GetShapeBody(currentShape)

					local vehicleHandle = GetBodyVehicle(shapeBody)

					if vehicleHandle ~= 0 then
						vars.effectVariables.vehicles[#vars.effectVariables.vehicles + 1] = {handle = vehicleHandle, jumpTimer = math.random(0, 3)}
					end
				end
			end,
			onEffectTick = function(vars)
				for index, vehicleData in ipairs(vars.effectVariables.vehicles) do
					if math.random(1, 10) > 5 and vehicleData.jumpTimer <= 0 then
						vehicleData.jumpTimer = 5

						local vehicleHandle = vehicleData.handle

						local vehicleBody = GetVehicleBody(vehicleHandle)

						local vehicleVelocity = VecCopy(GetBodyVelocity(vehicleBody))

						vehicleVelocity[2] = 5

						SetBodyVelocity(vehicleBody, vehicleVelocity)

					else
						local vehicleTransform = GetVehicleTransform(vehicleData.handle)
						local vehicleBody = GetBodyTransform(vehicleTransform)

						vehicleData.jumpTimer = vehicleData.jumpTimer - GetChaosTimeStep()
					end
				end
			end,
			onEffectEnd = function(vars) end,
		},

		hacking = {
			name = "Hacking",
			effectDuration = 60,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { currHack = "nil", lives = 4, damageAlpha = 0, wordWheels = {}, currentHackPos = 1, ip = {19, 20, 16, 80}, playerPos = nil, barLineUpBars = {}},
			onEffectStart = function(vars)
				vars.effectVariables.playerPos = GetPlayerTransform().pos

				local hackTypes = {"letterLineup", "barLineup",}-- "ipLookup"}

				local letterLineupWords = {"teardown", "lockelle", "xplosive", "shotguns", "destroyd", "chaosmod"} --"resident"
				local letterLineupLetters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

				local hackType = hackTypes[math.random(1, #hackTypes)]

				function getRandomLetter()
					return letterLineupLetters[math.random(1, #letterLineupLetters)]
				end

				if hackType == "letterLineup" then
					local word = letterLineupWords[math.random(1, #letterLineupWords)]

					for i = 1, 8 do
						local currLetter = word:sub(i, i)
						local wordWheel = { offset = math.random(0, 9), locked = false, letters = {currLetter} }

						for j = 2, 10 do
							local garbageLetter = currLetter

							while garbageLetter == currLetter do
								garbageLetter = getRandomLetter()
							end

							wordWheel.letters[j] = garbageLetter
						end

						vars.effectVariables.wordWheels[i] = wordWheel
					end
				elseif hackType == "ipLookup" then

				elseif hackType == "barLineup" then
					vars.effectVariables.barLineUpBars[1] = { value = 1, direction = 1, locked = false}
					for i = 2, 8 do
						local val = 1 - i * 0.2
						local dir = 1

						if val > 1 then
							val = 1
							dir = -1
						elseif val < -1 then
							val = -1
							dir = 1
						end

						vars.effectVariables.barLineUpBars[i] = { value = val, direction = dir }
					end
				end

				vars.effectVariables.currHack = hackType
			end,
			onEffectTick = function(vars)
				function endMinigame()
					vars.effectLifetime = vars.effectDuration
				end
				
				if GetPlayerHealth() <= 0 then
					endMinigame()
					return
				end

				if vars.effectVariables.lives <= 0 then
					endMinigame()
					return
				end

				SetPlayerTransform(Transform(vars.effectVariables.playerPos, Quat(0, 0, 0, 0)))

				local hackType = vars.effectVariables.currHack
				local drawCall = function() end

				local damageAlpha = vars.effectVariables.damageAlpha

				if damageAlpha > 0 then
					damageAlpha = damageAlpha - GetChaosTimeStep()
				end

				vars.effectVariables.damageAlpha = damageAlpha

				function drawBlackScreen()
					UiPush()
						UiColor(0, 0, 0, 1)

						UiAlign("center middle")

						UiTranslate(UiCenter(), UiMiddle())

						UiRect(UiWidth() + 10, UiHeight() + 10)
					UiPop()
				end

				function drawWindow()
					UiPush()
						UiAlign("center middle")

						UiTranslate(UiCenter(), UiMiddle())

						UiColor(0.4, 0.4, 1, 1)

						UiRect(UiWidth() * 0.6, UiHeight() * 0.7)

						UiColor(0, 0, 0, 1)

						UiTranslate(0, UiHeight() * 0.02)

						UiRect(UiWidth() * 0.595, UiHeight() * 0.65)
					UiPop()
				end

				function drawLives()
					UiPush()
						UiAlign("center middle")

						UiTranslate(UiCenter(), UiMiddle())

						UiTranslate(UiWidth() * 0.25, -UiHeight() * 0.25)

						UiAlign("center bottom")

						for i = 0, 3 do
							UiPush()
								if i + 1 <= vars.effectVariables.lives then
									UiColor(0, 0.8, 0.8, 1)
								else
									UiColor(0.5, 0.5, 0.5, 1)
								end

								UiTranslate(13 * i, 0)
								UiRect(10, 10 + i * 7)
							UiPop()
						end
					UiPop()
				end

				function drawDamage()
					UiPush()
						UiAlign("center middle")

						UiTranslate(UiCenter(), UiMiddle())

						UiColor(1, 0, 0, vars.effectVariables.damageAlpha)

						UiTranslate(0, UiHeight() * 0.02)

						UiRect(UiWidth() * 0.595, UiHeight() * 0.65)
					UiPop()
				end

				function loseLive()
					vars.effectVariables.damageAlpha = 1
					vars.effectVariables.lives = vars.effectVariables.lives - 1
				end

				function resetWordWheels()
					loseLive()
					vars.effectVariables.currentWordWheel = 1

					for i = 1, 8 do
						local wordWheel = vars.effectVariables.wordWheels[i]

						wordWheel.offset = math.random(0, 9)
						wordWheel.locked = false
					end
				end

				function barLineupLoseLevel()
					loseLive()
					local currentBarIndex = vars.effectVariables.currentHackPos

					if currentBarIndex > 1 then
						currentBarIndex = vars.effectVariables.currentHackPos - 1
						vars.effectVariables.currentHackPos = currentBarIndex
					end

					local currentBar = vars.effectVariables.barLineUpBars[currentBarIndex]

					currentBar.locked = false
				end

				if hackType == "letterLineup" then
					for i = 1, 8 do
						local wordWheel = vars.effectVariables.wordWheels[i]

						if not wordWheel.locked then

							wordWheel.offset = wordWheel.offset + GetChaosTimeStep() * 4

							if wordWheel.offset > 10 then
								wordWheel.offset = 0
							end
						end
					end

					if vars.effectVariables.currentHackPos > 8 then
						endMinigame()
						return
					end

					if InputPressed("space") then
						local currentWordWheelIndex = vars.effectVariables.currentHackPos
						local currentWordWheel = vars.effectVariables.wordWheels[currentWordWheelIndex]
						local currOffset = currentWordWheel.offset

						if currOffset >= 0 and currOffset <= 2 then
							currentWordWheel.offset = 1
							currentWordWheel.locked = true
							vars.effectVariables.currentHackPos = currentWordWheelIndex + 1
						else
							resetWordWheels()
						end
					end

					drawCall = function()
						UiPush()
							drawBlackScreen()
							drawWindow()
							drawLives()

							local offset = 5
							local width = UiWidth() * 0.5 / 8

							UiPush()
								UiAlign("center middle")
								UiTranslate(UiCenter(), UiMiddle())

								UiTranslate(-(width + offset) * 3.5, UiHeight() * 0.075) --0.175

								for i = 0, 7 do
									local wordWheel = vars.effectVariables.wordWheels[i + 1]

									UiPush()
										UiTranslate((width + offset) * i, 0)-- UiHeight() * 0.15)

										UiWindow(width, UiHeight() * 0.4, true)

										UiColor(0.3, 0.3, 0.3, 1)

										UiRect(UiWidth() * 2, UiHeight() * 2)

										UiColor(0, 0, 0, 1)

										UiTranslate(UiCenter(), UiMiddle())

										UiRect(UiWidth() * 0.97, UiHeight())

										UiColor(1, 1, 1, 1)

										UiFont("regular.ttf", 80)

										for j = -2, 12 do
											UiPush()
												local letter = ""

												if j < 1 then
													letter = wordWheel.letters[10 + j]
												elseif j > 10 then
													letter = wordWheel.letters[j - 10]
												else
													letter = wordWheel.letters[j]
												end

												if letter == wordWheel.letters[1] then
													UiColor(1, 0, 0, 1)
												end

												UiTranslate(0, -UiHeight() / 5 * wordWheel.offset)
												UiTranslate(0, UiHeight() / 5 * j)
												UiText(letter)
											UiPop()
										end
									UiPop()
								end
							UiPop()

							UiPush()
								UiAlign("center middle")
								UiTranslate(UiCenter(), UiMiddle())

								UiColor(1, 0, 0, 0.5)

								UiTranslate(0, UiHeight() * 0.075 / 2)

								UiRect((width + offset) * 8, 2)

								UiTranslate(-(width + offset) * 4, UiHeight() * 0.075 / 2)

								UiRect(2, UiHeight() * 0.075)

								UiTranslate((width + offset) * 8, 0)

								UiRect(2, UiHeight() * 0.075)

								UiTranslate(-(width + offset) * 4, UiHeight() * 0.075 / 2)

								UiRect((width + offset) * 8, 2)
							UiPop()

							drawDamage()
						UiPop()
					end
				elseif hackType == "ipLookup" then
					drawCall = function()
						UiPush()
							drawBlackScreen()
							drawWindow()
							drawLives()

						UiPop()
					end
				elseif hackType == "barLineup" then
					for i = 1, 8 do
						local currBar = vars.effectVariables.barLineUpBars[i]

						if not currBar.locked then
							local dir = currBar.direction
							local val = currBar.value + GetChaosTimeStep() * dir * 1.5

							if val > 1 then
								val = 1
								dir = -1
							elseif val < -1 then
								val = -1
								dir = 1
							end

							currBar.value = val
							currBar.direction = dir
						end
					end

					if vars.effectVariables.currentHackPos > 8 then
						endMinigame()
						return
					end

					if InputPressed("space") then
						local currentBarIndex = vars.effectVariables.currentHackPos
						local currentBar = vars.effectVariables.barLineUpBars[currentBarIndex]
						local currValue = currentBar.value

						if currValue <= 0.2 and currValue >= -0.2 then
							currentBar.value = 0
							currentBar.locked = true
							vars.effectVariables.currentHackPos = currentBarIndex + 1
						else
							barLineupLoseLevel()
						end
					end

					drawCall = function()
						UiPush()
							drawBlackScreen()
							drawWindow()
							drawLives()

							UiPush()
								UiAlign("center middle")
								UiTranslate(UiCenter(), UiMiddle())

								local barHeight = UiHeight() * 0.2
								local barWidth = UiHeight() * 0.025
								local offset = UiWidth() * 0.075 / 8

								UiTranslate(0, UiHeight() * 0.1)

								UiColor(1, 0, 0, 1)

								UiRect(UiHeight() * 0.5, UiHeight() * 0.4)

								UiColor(0, 0, 0, 1)

								UiRect(UiHeight() * 0.49, UiHeight() * 0.39)

								UiColor(1, 0, 0, 1)

								UiRect(UiHeight() * 0.5, barHeight * 0.15)

								UiTranslate(-(barWidth + offset) * 4.5, 0)

								for i = 1, 8 do
									local currVal = vars.effectVariables.barLineUpBars[i].value

									UiPush()
										UiTranslate((barWidth + offset) * i, currVal * 100)

										UiColor(1, 1, 1, 1)

										UiTranslate(0, -barHeight * 0.3)

										if vars.effectVariables.currentHackPos == i then
											UiColor(0.9, 0.9, 0, 1)
											UiRect(barWidth + 6, barHeight * 0.4 + 6)
											UiColor(1, 1, 1, 1)
										end

										UiRect(barWidth, barHeight * 0.4)

										UiTranslate(0, barHeight * 0.6)

										if vars.effectVariables.currentHackPos == i then
											UiColor(0.9, 0.9, 0, 1)
											UiRect(barWidth + 6, barHeight * 0.4 + 6)
											UiColor(1, 1, 1, 1)
										end

										UiRect(barWidth, barHeight * 0.4)
									UiPop()
								end
							UiPop()

							drawDamage()
						UiPop()
					end
				end

				UiMakeInteractive()
				table.insert(drawCallQueue, drawCall)
			end,
			onEffectEnd = function(vars)
				if vars.effectVariables.lives <= 0 then
					local playerPos = GetPlayerTransform().pos
					Explosion(playerPos, 3)
					SetPlayerHealth(0)
				end
			end,
		},

		grieferJesus = {
			name = "Griefer Jesus",
			effectDuration = 30,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {"MOD/sprites/grieferJesus/Playa1.png",
							 "MOD/sprites/grieferJesus/Playa2.png",
							 "MOD/sprites/grieferJesus/Playa3.png",
							 "MOD/sprites/grieferJesus/Playa4.png",
							 "MOD/sprites/grieferJesus/Playa5.png",
							 "MOD/sprites/grieferJesus/Playa6.png",
							 "MOD/sprites/grieferJesus/Playa7.png",
							 "MOD/sprites/grieferJesus/Playa8.png"},
			effectVariables = { npcTransform = nil, attackCooldown = 5, maxCooldown = 5},
			onEffectStart = function(vars)
				local playerCameraTransform = GetPlayerCameraTransform()
				local cameraForward = Vec(0, 0, -5)
				local cameraForwardWorldSpace = TransformToParentPoint(playerCameraTransform, cameraForward)

				cameraForwardWorldSpace[2] = GetPlayerTransform().pos[2]

				vars.effectVariables.npcTransform = Transform(cameraForwardWorldSpace, QuatEuler(0, 0, 0))
			end,
			onEffectTick = function(vars)
				local grieferTransform = vars.effectVariables.npcTransform
				local grieferForward = Vec(0, 0, -1)
				local cameraTransform = GetCameraTransform()
				local cameraPos = VecCopy(cameraTransform.pos)

				local playerPos = GetPlayerTransform().pos

				cameraPos[2] = grieferTransform.pos[2]

				-- RENDER SPRITE BEHAVIOR

				local dirToPlayer = dirVec(grieferTransform.pos, cameraPos)
				local localSpaceDirToPlayer = TransformToLocalVec(grieferTransform, dirToPlayer)

				local currentAngle = VecAngle360(grieferForward, localSpaceDirToPlayer)

				if currentAngle < 0 then
					currentAngle = currentAngle + 360
				end

				local viewPoint = ((currentAngle - (currentAngle % 45)) / 45) + 1

				local spriteRot = QuatLookAt(grieferTransform.pos, cameraPos)

				local spriteTransform = Transform(grieferTransform.pos, spriteRot)

				DrawSprite(vars.effectSprites[viewPoint],  spriteTransform, 1, 2, 1, 1, 1, 1, true, false)

				-- MOVEMENT BEHAVIOR

				-- -- ROTATE TOWARDS PLAYER BEHAVIOR

				local endRot = QuatLookAt(grieferTransform.pos, cameraPos)

				local rotStep = QuatSlerp(grieferTransform.rot, endRot, GetChaosTimeStep() * 2)

				grieferTransform.rot = rotStep

				-- MOVEMENT

				local grieferBackwards = VecScale(grieferForward, -1)
				local grieferRight = Vec(1, 0, 0)
				local grieferLeft = VecScale(grieferRight, -1)

				local walkSpeed = 2.5

				local distanceFromPlayer = VecDist(grieferTransform.pos, playerPos)

				function CanSeePlayer()
					local rayStart = grieferTransform.pos
					local rayDir = dirVec(grieferTransform.pos, playerPos)
					local rayDist = VecDist(grieferTransform.pos, playerPos)
					local hit, hitPoint = raycast(rayStart, rayDir, rayDist, true)

					return not hit
				end

				function canMoveTowards(direction)
					local directionWorldSpace = TransformToParentPoint(grieferTransform, direction)
					local dirVector = dirVec(grieferTransform.pos, directionWorldSpace)

					local hit = raycast(grieferTransform.pos, dirVector, 1, 0.25)

					return not hit
				end

				function moveTowards(direction)
					local directionWorldSpace = TransformToParentPoint(grieferTransform, direction)
					local dirVector = dirVec(grieferTransform.pos, directionWorldSpace)

					local newPos = VecCopy(grieferTransform.pos)

					local movedDistance = VecScale(dirVector, walkSpeed * GetChaosTimeStep())

					newPos = VecAdd(newPos, movedDistance)

					grieferTransform.pos = newPos
				end

				if not CanSeePlayer() or distanceFromPlayer > 30 then

					if canMoveTowards(grieferForward) then
						moveTowards(grieferForward)
					elseif canMoveTowards(grieferRight) then
						moveTowards(grieferRight)
					elseif canMoveTowards(grieferLeft) then
						moveTowards(grieferLeft)
					elseif canMoveTowards(grieferBackwards) then
						moveTowards(grieferBackwards)
					end
				end

				-- ATTACK BEHAVIOR

				function FireShot(rayDist, rayOffset)
					local rayStart = grieferTransform.pos

					local rayDir = dirVec(grieferTransform.pos, playerPos)

					rayDir = VecAdd(rayDir, rayOffset)

					local shotLocation = VecAdd(rayStart, VecScale(rayDir, rayDist))

					local hit, hitPoint = raycast(rayStart, rayDir, rayDist)

					return shotLocation, hit, hitPoint
				end

				function SpawnParticles(startPoint, endPoint)
					local particleDist = VecDist(startPoint, endPoint)

					local particles = math.floor(particleDist)

					local particleDir = dirVec(startPoint, endPoint)

					ParticleReset()
					ParticleType("smoke")
					ParticleRadius(0.1, 0.3)
					ParticleGravity(0, 0.4)
					ParticleCollide(1)

					for i = 1, particles do
						local currPos = VecAdd(startPoint, VecScale(particleDir, i))

						SpawnParticle(currPos, particleDir, 3)
					end
				end

				vars.effectVariables.attackCooldown = vars.effectVariables.attackCooldown - GetChaosTimeStep()

				if math.random(1, 10) < 5 or vars.effectVariables.attackCooldown >= 0 then
					return
				end

				vars.effectVariables.attackCooldown = vars.effectVariables.maxCooldown

				local attackAngle = 15

				if currentAngle < attackAngle or currentAngle > 360 - attackAngle then
					local rayDist = VecDist(grieferTransform.pos, playerPos)
					local rayOffset = rndVec(rayDist / 5000)

					local shotLocation, hit, hitPoint = FireShot(rayDist, rayOffset)

					if not hit then
						local distToPlayer = VecDist(shotLocation, playerPos)

						if distToPlayer <= 0.25 then
							local playerHealth = GetPlayerHealth() - 0.7

							Explosion(shotLocation, 3)
							SetPlayerHealth(playerHealth)
							SpawnParticles(grieferTransform.pos, shotLocation)
						else
							local secondShotLocation, secondHit, secondHitPoint = FireShot(rayDist * 2, rayOffset)

							if secondHit then
								Explosion(secondHitPoint, 3)
								SpawnParticles(grieferTransform.pos, secondHitPoint)
							else
								SpawnParticles(grieferTransform.pos, secondShotLocation)
								Explosion(secondShotLocation, 3)
							end
						end
					else
						local distToHit = VecDist(grieferTransform.pos, hitPoint)

						SpawnParticles(grieferTransform.pos, hitPoint)

						Explosion(hitPoint, 3)
					end
				end

			end,
			onEffectEnd = function(vars) end,
		},

		gravityField = {
			name = "Gravity Field",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { affectedBodies = {}},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerPos = GetPlayerTransform().pos
				local range = 50

				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local shapeList = QueryAabbBodies(minPos, maxPos)

				for i = 1, #shapeList do
					local shapeBody = shapeList[i]

					if IsBodyDynamic(shapeBody) then

						if vars.effectVariables.affectedBodies[shapeBody] == nil then
							vars.effectVariables.affectedBodies[shapeBody] = "hit"
						end

						local shapeTransform = GetBodyTransform(shapeBody)

						local dirToPlayer = VecScale(dirVec(shapeTransform.pos, playerPos), 5)

						local bodyVelocity = dirToPlayer

						SetBodyVelocity(shapeBody, bodyVelocity)
					end
				end
			end,
			onEffectEnd = function(vars)
				for shapeBody, value in pairs(vars.effectVariables.affectedBodies) do
					local shapeTransform = GetBodyTransform(shapeBody)
					ApplyBodyImpulse(shapeBody, shapeTransform.pos, Vec(0, -1, 0))
				end
			end,
		},

		randomInformation = {
			name = "Useless Information",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local gpv = GetPlayerVehicle()
				local fire = GetFireCount()
				local health = GetPlayerHealth()
				local shape = GetPlayerPickShape()
				if shape ~= 0 then
					DrawShapeOutline(shape, 0.5)
				end

				table.insert(drawCallQueue, function()
					UiPush()
						UiFont("regular.ttf", 30)
						UiTextShadow(0, 0, 0, 0.5, 2.0)
						UiAlign("left")
						UiTranslate(UiCenter() * 0.3, UiHeight() * 0.2)
						UiText("Active fires: " .. fire) -- Fire counter
						UiTranslate(0, 40)
						UiText("Player Vehicle Handle: " .. gpv) -- Player vehicle handle
						UiTranslate(0, 40)
						UiText("Player Health: " .. math.floor(health * 100)) -- Health
					UiPop()
				end)
			end,
			onEffectEnd = function(vars) end,
		},

		explodeNearbyVehicle = {
			name = "Explode Nearby Vehicle",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local vehicles = {}
				for i=1, #nearbyShapes do
					if GetBodyVehicle(GetShapeBody(nearbyShapes[i])) ~= 0 then
						vehicles[#vehicles+1] = GetBodyVehicle(GetShapeBody(nearbyShapes[i]))
					end
				end

				if(#vehicles == 0) then
					return
				end

				local closestVehicle = 0
				local closestDistance = 10000

				local playerPos = GetPlayerTransform().pos
				for i = 1, #vehicles do
					local vehicleTransform = GetVehicleTransform(vehicles[i])
					local distance = VecDist(vehicleTransform.pos, playerPos)

					if distance < closestDistance then
						closestDistance = distance
						closestVehicle = vehicles[i]
					end
				end

				if closestVehicle <= 0 then
					return
				end

				local vehicleTransform = GetVehicleTransform(closestVehicle)

				Explosion(vehicleTransform.pos, 2.5)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		playerSwap = {
			name = "Player Swap",
			effectDuration = 25,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {{isLoop = false, soundPath = "MOD/sfx/drum.ogg"}},
			effectSprites = {},
			effectVariables = {flashPos = 0, playerTransform = nil, prevZoomStep = 0, cameraWobbleOffset = Vec(0, 0, 0)},
			onEffectStart = function(vars)
				vars.effectVariables.playerTransform = GetPlayerTransform()
			end,
			onEffectTick = function(vars)
				-- Camera position Calc
				function getZoomStep(i, steps)
					-- Example: i = 17.7, steps = 5
					-- (17.7 - (17.7 % 5)) / 5
					-- (17.7 - 2.7) / 5
					-- 15 / 5 = 3

					return (i - (i % steps)) / steps
				end

				local zoomStep = vars.effectVariables.prevZoomStep

				if vars.effectLifetime <= 10 then -- Zoom out
					zoomStep = getZoomStep(vars.effectLifetime, 2.5)

				elseif vars.effectLifetime >= 15 then -- Zoom back in
					local lifetimeAfter = 12.5 - (vars.effectLifetime - 12.5)

					zoomStep = getZoomStep(lifetimeAfter, 2.5)
				end

				-- Camera positioning

				local playerPos = GetPlayerTransform().pos

				local cameraOffset = Vec(0, 20 + zoomStep * 20, 0)

				local cameraPos = VecAdd(playerPos, cameraOffset)

				local cameraRot = QuatLookAt(cameraPos, playerPos)

				vars.effectVariables.cameraWobbleOffset = VecAdd(vars.effectVariables.cameraWobbleOffset, VecScale(rndVec(0.5), GetChaosTimeStep() * (zoomStep)))

				local cameraWobbleQuat = QuatEuler(vars.effectVariables.cameraWobbleOffset[1], vars.effectVariables.cameraWobbleOffset[2], vars.effectVariables.cameraWobbleOffset[3])

				local cameraRotEndPoint = QuatRotateQuat(cameraRot, cameraWobbleQuat)

				local newTransform = Transform(cameraPos, cameraRotEndPoint)

				table.insert(drawCallQueue, function()
					UiPush()
						UiTranslate(UiCenter(), UiMiddle())
						UiAlign("center middle")
						UiColor(1, 0.75, 0.21, 0.25)
						UiRect(UiWidth() + 10, UiHeight() + 10)
						UiColor(1, 1, 1, vars.effectVariables.flashPos)
						UiRect(UiWidth() + 10, UiHeight() + 10)
						UiBlur(0.25)
					UiPop()
				end)

				if vars.effectVariables.prevZoomStep ~= zoomStep then
					PlaySound(vars.effectSFX[1], cameraPos, 5)
					vars.effectVariables.prevZoomStep = zoomStep
					vars.effectVariables.flashPos = 0.5
				elseif vars.effectVariables.flashPos > 0 then
					vars.effectVariables.flashPos = vars.effectVariables.flashPos - GetChaosTimeStep()
				end

				SetCameraTransform(newTransform)

				SetPlayerTransform(vars.effectVariables.playerTransform)
			end,
			onEffectEnd = function(vars) end,
		},

		swapToRandomTool = {
			name = "Swap To Random Tool",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				local toolList = ListKeys("game.tool")

				local selectedTool = toolList[math.random(1, #toolList)]

				SetString("game.player.tool", selectedTool)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},

		loseSomething = {
			name = "Lose Something?",
			effectDuration = 10,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { disabledTool = "" },
			onEffectStart = function(vars)
				local tools = ListKeys("game.tool")
				local randomToolIndex = math.random(1, #tools)
				local randomToolId = tools[randomToolIndex]

				local isToolEnabled = GetBool("game.tool." .. vars.effectVariables.disabledTool .. ".enabled")

				if not isToolEnabled then -- To prevent unlocking tools the player shouldn't have.
					randomToolId = "sledge"
				end

				vars.effectVariables.disabledTool = randomToolId

				SetBool("game.tool." .. vars.effectVariables.disabledTool .. ".enabled", false)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				SetBool("game.tool." .. vars.effectVariables.disabledTool .. ".enabled", true)
			end,
		},

		opExplosive = {
			name = "Upgrade Random Explosives",
			effectDuration = 11,
			effectLifetime = 0,
			hideTimer = true,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { upgraded = {}},
			onEffectStart = function(vars)
				local nearbyShapes = QueryAabbShapes(Vec(-100, -100, -100), Vec(100, 100, 100))

				local explosives = {}
				for i=1, #nearbyShapes do
						if HasTag(nearbyShapes[i], "explosive") then
								explosives[#explosives + 1] = nearbyShapes[i]
						end
				end

				if(#explosives == 0) then
						return
				end
				
				local minRandom = math.floor(#explosives * 0.1)
				local maxRandom = math.floor(#explosives * 0.5)
				
				for i = 1, math.random(minRandom, maxRandom) do
					local randomIndex = math.random(1, #explosives)
					local randomExplosive = explosives[randomIndex]

					vars.effectVariables.upgraded[i] = randomExplosive

					SetTag(randomExplosive, "explosive", 110)
					
					table.remove(explosives, randomIndex, 1)
				end
			end,
			onEffectTick = function(vars) 
				local alpha = 1 - vars.effectLifetime / (vars.effectDuration - 1)
				
				for i = 1, #vars.effectVariables.upgraded do
					local explosive = vars.effectVariables.upgraded[i]
					
					DrawShapeOutline(explosive, 1, 0, 0, alpha)
				end
				
				if vars.effectLifetime >= 10 then
					vars.effectLifetime = 0
					vars.effectDuration = 0
				end
			end,
			onEffectEnd = function(vars) end,
		},
		
		noclip = {
			name = "Noclip",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { playerPos = nil, offset = nil, lastPlayerVehicle = 0},
			onEffectStart = function(vars)
				local cameraTransform = GetPlayerCameraTransform()
				local playerTransform = GetPlayerTransform()
				
				vars.effectVariables.playerPos = playerTransform.pos
				
				vars.effectVariables.offset = VecSub(cameraTransform.pos, playerTransform.pos)
				
				vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
			end,
			onEffectTick = function(vars)
				if GetPlayerVehicle() ~= 0 then
					vars.effectVariables.lastPlayerVehicle = GetPlayerVehicle()
					return
				end
				
				local cameraTransform = GetPlayerCameraTransform()
				local playerTransform = GetPlayerTransform()
				
				if vars.effectVariables.lastPlayerVehicle ~= 0 then
					vars.effectVariables.lastPlayerVehicle = 0
					
					vars.effectVariables.playerPos = playerTransform.pos
					
					--vars.effectVariables.offset = VecSub(cameraTransform.pos, playerTransform.pos)
				end
				
				table.insert(drawCallQueue, function()
					UiPush()
						UiAlign("center middle")
						UiTranslate(UiWidth() * 0.5, UiHeight() * 0.9)
						
						UiTextShadow(0, 0, 0, 0.5, 2.0)
						UiFont("regular.ttf", 26)
						
						UiText("Shift to sprint.\nRight Mouse Button to use tools and interact with the world.\n(Flickering warning, don't use inside or close above/below voxels)")
					UiPop()
				end)
			
				local xMovement = 0
				local yMovement = 0
				local zMovement = 0
				
				local movementSpeed = 5
				
				if InputDown("up") then
					zMovement = zMovement - 1
				end
				
				if InputDown("down") then
					zMovement = zMovement + 1
				end
				
				if InputDown("left") then
					xMovement = xMovement - 1
				end
				
				if InputDown("right") then
					xMovement = xMovement + 1
				end
				
				if InputDown("jump") then
					yMovement = yMovement + 1
				end
				
				if InputDown("crouch") then
					yMovement = yMovement - 1
				end
				
				if InputDown("shift") then
					movementSpeed = movementSpeed * 2
				end
				
				local playerPos = vars.effectVariables.playerPos 
				
				if xMovement ~= 0 or yMovement ~= 0 or zMovement ~= 0 then
					local cameraTransform = GetCameraTransform()
					
					local worldDirectionPoint = TransformToParentPoint(cameraTransform, Vec(xMovement, yMovement, zMovement))
					local worldDirectionDir = dirVec(cameraTransform.pos, worldDirectionPoint)
					
					local distanceTraveled = VecScale(worldDirectionDir, movementSpeed * GetChaosTimeStep())
					
					playerPos = VecAdd(playerPos, distanceTraveled)
					
					vars.effectVariables.playerPos = playerPos
				end
				
				if not InputDown("rmb") then
					SetCameraTransform(Transform(VecAdd(playerPos, vars.effectVariables.offset), playerTransform.rot))
				end
				
				SetPlayerTransform(Transform(playerPos, playerTransform.rot))
				SetPlayerVelocity(Vec(0, 0, 0))
			end,
			onEffectEnd = function(vars) end,
		},
		
		quietDay = {
			name = "Quiet Day",
			effectDuration = 15,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				UiMute(1, true)
			end,
			onEffectEnd = function(vars) end,
		},

		metaAlterEffectDuration = {
			name = "(Meta)_x Effect Duration",
			effectDuration = 35,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {metaTimerAltered = true},
			onEffectStart = function(vars)
				local speed = math.random(1, 2)

				if speed == 1 then
					vars.effectVariables.speed = 2
				else
					vars.effectVariables.speed = 0.5
				end

				vars.name = "(Meta)".. vars.effectVariables.speed .. "x Effect Duration"
			end,
			onEffectTick = function(vars)
				for i = 1, #chaosEffects.activeEffects do
					local currEffect = chaosEffects.activeEffects[i]

					if currEffect.effectDuration > 0 and currEffect.effectVariables["metaTimerAltered"] == nil then
						currEffect.effectVariables.metaTimerAltered = true
						currEffect.effectDuration = currEffect.effectDuration * vars.effectVariables.speed
					end

				end
			end,
			onEffectEnd = function(vars) end,
		},

		metaAlterChaosTimer = {
			name = "(Meta)_x Timer Speed",
			effectDuration = 35,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { chaosTimerBackup = -1},
			onEffectStart = function(vars)
				vars.effectVariables.chaosTimerBackup = chaosTimer

				local speed = math.random(1,3)

				if speed == 1 then
					chaosTimer = chaosTimer * 2
					vars.name = "(Meta)0.5x Timer Speed"
				elseif speed == 2 then
					chaosTimer = chaosTimer / 2
					vars.name = "(Meta)2x Timer Speed"
				else
					chaosTimer = chaosTimer / 3
					vars.name = "(Meta)3x Timer Speed"
				end

			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				chaosTimer = vars.effectVariables.chaosTimerBackup
			end,
		},

		metaNoChaos = {
			name = "(Meta)No Chaos",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { chaosTimerBackup = 12 },
			onEffectStart = function(vars)
				-- Close off other effects normally first.
				for i = 1, #chaosEffects.activeEffects do
					local currEffect = chaosEffects.activeEffects[i]
					if currEffect ~= vars then
						currEffect.onEffectEnd(currEffect)
					end
				end
				
				chaosEffects.activeEffects = {vars}
				vars.effectVariables.chaosTimerBackup = chaosTimer
				chaosTimer = 100000000
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars)
				currentTime = 0
				chaosTimer = vars.effectVariables.chaosTimerBackup
			end,
		},
		
		glitch = {
			name = "Glitch",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { blackAndWhite = false, glitches = {},},
			onEffectStart = function(vars) 
				if math.random(1, 10) > 10 then
					vars.effectVariables.blackAndWhite = true
				end
			end,
			onEffectTick = function(vars)
				local maxGlitches = 200
				
				function createGlitch()
					local lifetime = math.random(5, 10) / 10
					local red = math.random(0,100) / 100
					local green = math.random(0,100) / 100
					local blue = math.random(0,100) / 100
					local alpha = math.random(0,100) / 100
					
					local boxW = math.random(0,10000) / 10000
					local boxH = math.random(1, 50)
					local boxX = math.random(0,10000) / 10000
					local boxY = math.random(0,100) / 100
					
					local newGlitch = { lifetime = lifetime, 
										r = red, 
										g = green, 
										b = blue, 
										a = alpha, 
										w = boxW, 
										h = boxH, 
										x = boxX, 
										y = boxY }
										
					table.insert(vars.effectVariables.glitches, newGlitch)
				end
				
				while #vars.effectVariables.glitches < maxGlitches do
					createGlitch()
				end
				
				for i = #vars.effectVariables.glitches, 1, -1 do
					local currGlitch = vars.effectVariables.glitches[i]
					currGlitch.lifetime = currGlitch.lifetime - GetChaosTimeStep()
					table.insert(drawCallQueue, function()
						UiPush()
							if vars.effectVariables.blackAndWhite then
								UiColor(currGlitch.r, currGlitch.r, currGlitch.r, currGlitch.a)
							else
								UiColor(currGlitch.r, currGlitch.g, currGlitch.b, currGlitch.a)
							end
							UiAlign("center middle")
							UiTranslate(UiWidth() * currGlitch.x, UiHeight() * currGlitch.y)
							UiRect(UiWidth() * currGlitch.w, currGlitch.h)

						UiPop()
					end)
					
					if currGlitch.lifetime <= 0 then
						table.remove(vars.effectVariables.glitches, i, 1)
					end
				end

				end,
			onEffectEnd = function(vars) end,
		},
		
		blind = {
            name = "Blind",
            effectDuration = 10,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = {},
            onEffectStart = function(vars)end,
            onEffectTick = function(vars) 
                table.insert(drawCallQueue, function()
                        UiPush()
                            UiColor(0, 0, 0, 1)
                            UiAlign("center middle")
                            UiTranslate(UiCenter(), UiMiddle())
                            UiRect(UiWidth() + 10, UiHeight() + 10)
                        UiPop()
                end)
            end,
            onEffectEnd = function(vars) end,
        },
		
		blindfold = {
            name = "Blindfold",
            effectDuration = 10,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = {},
            onEffectStart = function(vars)end,
            onEffectTick = function(vars) 
                table.insert(drawCallQueue, function()
                    
                        UiPush()
                            UiColor(0, 0, 0, 1)
                            UiAlign("center middle")
                            UiTranslate(UiCenter(), UiMiddle())
                            UiRect(UiWidth() + 10, UiHeight() * 0.8)
        
                        UiPop()
                    
                end)
            end,
            onEffectEnd = function(vars) end,
        },
		
		notTheBees = {
            name = "Not The Bees!",
            effectDuration = 15,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = { tickTimer = 0, maxTick = 0.85},
            onEffectStart = function(vars)end,
            onEffectTick = function(vars) 
				if vars.effectVariables.tickTimer < vars.effectVariables.maxTick then
					vars.effectVariables.tickTimer = vars.effectVariables.tickTimer + GetChaosTimeStep()
					return
				end
				
				vars.effectVariables.tickTimer = 0
				
				SetPlayerHealth(GetPlayerHealth() - 0.1)
            end,
            onEffectEnd = function(vars) end,
        },
		
		lockPlayerInsideVehicle = {
            name = "Lock Player Inside Vehicle",
            effectDuration = 15,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = { currVehicle = 0},
            onEffectStart = function(vars) 
				vars.effectVariables.currVehicle = GetPlayerVehicle()
			end,
            onEffectTick = function(vars) 
				if vars.effectVariables.currVehicle == 0 then
					vars.effectVariables.currVehicle = GetPlayerVehicle()
				else
					SetPlayerVehicle(vars.effectVariables.currVehicle)
				end
            end,
            onEffectEnd = function(vars) end,
        },
		
		unbreakableEverything = {
			name = "Everything Is Unbreakable",
            effectDuration = 10,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = { affectedBodies = {} },
            onEffectStart = function(vars) 
				local range = 500
			
				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				vars.effectVariables.affectedBodies = QueryAabbBodies(minPos, maxPos)
				
				for i = 1, #vars.effectVariables.affectedBodies do
					local currBody = vars.effectVariables.affectedBodies[i]
					SetTag(currBody, "unbreakable")
				end
			end,
            onEffectTick = function(vars) end,
            onEffectEnd = function(vars) 
				for i = 1, #vars.effectVariables.affectedBodies do
					local currBody = vars.effectVariables.affectedBodies[i]
					RemoveTag(currBody, "unbreakable")
				end
			end,
		},
		
		forcefield = {
			name = "Forcefield",
            effectDuration = 15,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = {},
            onEffectStart = function(vars) end,
            onEffectTick = function(vars) 
				local range = 20
				local forceStrength = 3
			
				local playerPos = GetPlayerTransform().pos
	
				local rangeVec = Vec(range / 2, range / 2, range / 2)
				
				local minPos = VecAdd(playerPos, VecScale(rangeVec, -1))
				local maxPos = VecAdd(playerPos, rangeVec)
				
				local bodies = QueryAabbBodies(minPos, maxPos)
				
				local playerVehicle = GetPlayerVehicle()
				
				for i = 1, #bodies do
					local body = bodies[i]
					
					local vehicleHandle = GetBodyVehicle(body)
					
					if IsBodyDynamic(body) and (vehicleHandle ~= playerVehicle or playerVehicle == 0) then
						local bodyTransform = GetBodyTransform(body)
						local directionFromPlayer = dirVec(playerPos, bodyTransform.pos)
						
						local mass = GetBodyMass(body)
						
						local distanceStrength = range - VecDist(playerPos, bodyTransform.pos)
						
						local strengthAdjustedDirectionVector = VecScale(directionFromPlayer, forceStrength * mass + distanceStrength * 2)
						
						ApplyBodyImpulse(body, bodyTransform.pos, strengthAdjustedDirectionVector)
					end
				end
			end,
            onEffectEnd = function(vars) end,
		},
		
		beyblades = {
			name = "Beyblades",
            effectDuration = 10,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = { vehicles = {} },
            onEffectStart = function(vars)
				local range = 500
				local minPos = Vec(-range, -range, -range)
				local maxPos = Vec(range, range, range)
				local nearbyBodies = QueryAabbBodies(minPos, maxPos)

				for i = 1, #nearbyBodies do
					local currentBody = nearbyBodies[i]
					local vehicleBody = GetBodyVehicle(currentBody)

					if vehicleBody ~= 0 then
						local vehicleHandle = GetBodyVehicle(currentBody)

						vars.effectVariables.vehicles[#vars.effectVariables.vehicles + 1] = vehicleHandle
					end
				end
			end,
			onEffectTick = function(vars)
				local vel = Vec(0, 5, 0)
			
				for i = 1, #vars.effectVariables.vehicles do
					local currVehicle = vars.effectVariables.vehicles[i]
					
					
					if GetPlayerVehicle() ~= currVehicle then
						local vehicleBody = GetVehicleBody(currVehicle)
						SetBodyAngularVelocity(vehicleBody, vel)
					end
				end
			end,
            onEffectEnd = function(vars) end,
		},
		
		allVehiclesInvulnerable = {
			name = "All Vehicles Are Invulnerable",
            effectDuration = 20,
            effectLifetime = 0,
            hideTimer = false,
            effectSFX = {},
            effectSprites = {},
            effectVariables = { vehicles = {} },
            onEffectStart = function(vars)
				local range = 500
				local minPos = Vec(-range, -range, -range)
				local maxPos = Vec(range, range, range)
				local nearbyBodies = QueryAabbBodies(minPos, maxPos)

				for i = 1, #nearbyBodies do
					local currentBody = nearbyBodies[i]
					local vehicleBody = GetBodyVehicle(currentBody)

					if vehicleBody ~= 0 then
						local vehicleHandle = GetBodyVehicle(currentBody)

						vars.effectVariables.vehicles[#vars.effectVariables.vehicles + 1] = currentBody
						
						SetTag(currentBody, "unbreakable")
					end
				end
			end,
			onEffectTick = function(vars) end,
            onEffectEnd = function(vars) 
				for i = 1, #vars.effectVariables.vehicles do
					local currVehicleBody = vars.effectVariables.vehicles[i]
					
					RemoveTag(currVehicleBody, "unbreakable")
				end
			end,
		},
		
		highgravity = {
			name = "High Gravity",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { affectedBodies = {}},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars)
				local playerPos = GetPlayerTransform().pos
				local range = 50

				local tempVec = GetPlayerVelocity()
				tempVec[2] = -2
				SetPlayerVelocity(tempVec)

				local minPos = VecAdd(playerPos, Vec(-range, -range, -range))
				local maxPos = VecAdd(playerPos, Vec(range, range, range))
				local shapeList = QueryAabbBodies(minPos, maxPos)

				for i = 1, #shapeList do
					local shapeBody = shapeList[i]

					if IsBodyDynamic(shapeBody) then

						if vars.effectVariables.affectedBodies[shapeBody] == nil then
							vars.effectVariables.affectedBodies[shapeBody] = "hit"
						end

						local bodyVelocity = GetBodyVelocity(shapeBody)

						bodyVelocity[2] = -2

						SetBodyVelocity(shapeBody, bodyVelocity)
					end
				end
			end,
			onEffectEnd = function(vars)
				for shapeBody, value in pairs(vars.effectVariables.affectedBodies) do
					local shapeTransform = GetBodyTransform(shapeBody)
					ApplyBodyImpulse(shapeBody, shapeTransform.pos, Vec(0, -1, 0))
				end
			end,
		},
		
		phonesringing = {
			name = "Whose Phone Is It?",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { tick = 0.75, maxTick = 0.75, lastSfx = 0},
			onEffectStart = function(vars) end,
			onEffectTick = function(vars) 
				local tick = vars.effectVariables.tick
				local sounds = {"MOD/sfx/phonesringing/phone01.ogg", 
								"MOD/sfx/phonesringing/phone02.ogg", 
								"MOD/sfx/phonesringing/phone03.ogg",
								"MOD/sfx/phonesringing/phone04.ogg",
								"MOD/sfx/phonesringing/phone05.ogg",
								"MOD/sfx/phonesringing/phone06.ogg"}
				
				tick = tick - GetChaosTimeStep()
				
				if tick <= 0 then
					tick = vars.effectVariables.maxTick
					local randomNum = math.random(1, #sounds)
					
					if randomNum == vars.effectVariables.lastSfx then
						randomNum = randomNum + 1
						if randomNum > #sounds then
							randomNum = 1
						end
					end
					
					local sfxPath = sounds[randomNum]
					
					UiSound(sfxPath)
					
					vars.effectVariables.lastSfx = randomNum
				end
				
				vars.effectVariables.tick = tick
			end,
			onEffectEnd = function(vars) end,
		},
		
		pixelatedScreen = {
			name = "Pixelated",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { resolution = 50, },
			onEffectStart = function(vars) 
				--local resolutions = {30, 40, 50}
				--vars.effectVariables.resolution = resolutions[math.random(1, #resolutions)]
			end,
			onEffectTick = function(vars) 
				local resolution = vars.effectVariables.resolution
				local rayOrigTransform = GetCameraTransform()
				
				local widthMax = 2
				local heightMax = 1
				
				local fovWPerRes = widthMax / resolution
				local fovHPerRes = heightMax / resolution
				
				function drawAt(x, y, pixelWidth, pixelHeight)
					UiPush()
						local color = {0, 0.75, 1}
						
						local xDir = fovWPerRes * x - widthMax / 2
						local yDir = fovHPerRes * (resolution - y) - heightMax / 2
						
						local localRayDir = Vec(xDir, yDir, -1)
						local rayDir = dirVec(rayOrigTransform.pos, TransformToParentPoint(rayOrigTransform, localRayDir))
					
						local hit, hitPoint, distance, normal, shape = raycast(rayOrigTransform.pos, rayDir, 250, 0, true)
						
						if hit then
							local mat, r, g, b, a = GetShapeMaterialAtPosition(shape, hitPoint)
							
							local inWater = IsPointInWater(hitPoint)
							
							color[1] = r
							color[2] = g
							color[3] = b
							
							if inWater then
								color[3] = color[3] + 0.25
								
								if color[3] > 1 then 
									color[3] = 1
								end
							end
						end
						
						UiColor(color[1], color[2], color[3], 1)
						UiTranslate(x * pixelWidth, y * pixelHeight)
						UiRect(pixelWidth, pixelHeight)
					UiPop()
				end
				
				table.insert(drawCallQueue, function()
					local UiWidthPerPixel = math.ceil(UiWidth() / resolution)
					local UiHeightPerPixel = math.ceil(UiHeight() / resolution)
					
					for x = 0, resolution - 1 do
						for y = 0, resolution - 1 do
							drawAt(x, y, UiWidthPerPixel, UiHeightPerPixel)
						end
					end
				end)
			end,
			onEffectEnd = function(vars) end,
		},
		
		lightHurts = {
			name = "Stay In The Dark/Light",
			effectDuration = 30,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {avoidLight = true, allLights = {}, damageTick = 0.25, maxTick = 0.25, skybox = "", skyboxbrightness = 0, ambient = 0, sunBrightness = 0, exposure = 0, skyboxtint = {0, 0, 0}, fogColor = {0, 0, 0}, fogParams = {0, 0, 0, 0}},
			onEffectStart = function(vars) 
				if math.random(1,10) > 5 or true then
					vars.effectVariables.avoidLight = false
					vars.name = "Stay In The Light"
				else
					vars.name = "Stay In The Dark"
				end
			
				vars.effectVariables.skybox = GetEnvironmentProperty("skybox")
				vars.effectVariables.skyboxbrightness = GetEnvironmentProperty("skyboxbrightness")
				vars.effectVariables.ambient = GetEnvironmentProperty("ambient")
				vars.effectVariables.sunBrightness = GetEnvironmentProperty("sunBrightness")
				vars.effectVariables.exposure = GetEnvironmentProperty("exposure")
				
				local skyTint1, skyTint2, skyTint3 = GetEnvironmentProperty("skyboxtint")
				vars.effectVariables.skyboxtint = {skyTint1, skyTint2, skyTint3}
				
				local fogColor1, fogColor2, fogColor3 = GetEnvironmentProperty("fogColor")
				vars.effectVariables.fogColor = {fogColor1, fogColor2, fogColor3}
				
				local fogParam1, fogParam2, fogParam3, fogParam4 = GetEnvironmentProperty("fogParams")
				vars.effectVariables.fogParams = {fogParam1, fogParam2, fogParam3, fogParam4}
				
				SetEnvironmentProperty("skybox", "night_clear.dds")
				SetEnvironmentProperty("skyboxbrightness", 0.05)
				SetEnvironmentProperty("ambient", 0)
				SetEnvironmentProperty("sunBrightness", 0)
				SetEnvironmentProperty("exposure", 1.5)
				SetEnvironmentProperty("skyboxtint", 1, 1, 1)
				SetEnvironmentProperty("fogColor", 0.02, 0.02, 0.024)
				SetEnvironmentProperty("fogParams", 20, 120, 0.9, 2)
				
				local shapes = QueryAabbShapes(Vec(-1000, -1000, -1000), Vec(1000, 1000, 1000))
				for i=1, #shapes do
					local lights = GetShapeLights(shapes[i])
					for j=1, #lights do
						if not HasTag(lights[j], "alarm") then
							table.insert(vars.effectVariables.allLights, lights[j])
						end
					end
				end
			end,
			onEffectTick = function(vars) 
				local playerHeight = 1.8
				
				if InputDown("crouch") then
					playerHealth = 0.9
				end
			
				local playerPos = VecAdd(GetPlayerTransform().pos, Vec(0, playerHeight, 0))
				local damageTick = vars.effectVariables.damageTick
				local avoidLight = vars.effectVariables.avoidLight
				
				function hittingPlayer(light)
					if not IsLightActive(light) then
						return false
					end
					
					if not IsPointAffectedByLight(light, playerPos) then
						return false
					end
					
					local lightTransform = GetLightTransform(light)
					
					local rayOrig = lightTransform.pos
					local rayDir = dirVec(rayOrig, playerPos)
					local rayDist = VecDist(rayOrig, playerPos)
					
					QueryRejectShape(GetLightShape(light))
					local hit = raycast(rayOrig, rayDir, rayDist)
					
					if hit then
						return false
					end
					
					return true
				end
				
				local damageTickHappened = false
				local inLight = false
			
				for i = 1, #vars.effectVariables.allLights do
					local light = vars.effectVariables.allLights[i]
					if hittingPlayer(light) then
						if avoidLight then
							SetLightColor(light, 1, 0, 0)
						
							if not damageTickHappened then
								damageTick = damageTick - GetChaosTimeStep()
								
								if damageTick < 0 then
									damageTick = vars.effectVariables.maxTick
									local playerHealth = GetPlayerHealth()
									
									SetPlayerHealth(playerHealth - 0.05)
								end
								
								damageTickHappened = true
							end
						else
							inLight = true
						end
					elseif avoidLight then
						SetLightColor(light, 1, 1, 1)
					end
				end
				
				if not inLight and not avoidLight then
					damageTick = damageTick - GetChaosTimeStep()
					
					if damageTick < 0 then
						damageTick = vars.effectVariables.maxTick
						local playerHealth = GetPlayerHealth()
						
						SetPlayerHealth(playerHealth - 0.05)
					end
				end
				
				vars.effectVariables.damageTick = damageTick
			end,
			onEffectEnd = function(vars) 
				SetEnvironmentProperty("skybox", vars.effectVariables.skybox)
				SetEnvironmentProperty("skyboxbrightness", vars.effectVariables.skyboxbrightness)
				SetEnvironmentProperty("ambient", vars.effectVariables.ambient)
				SetEnvironmentProperty("sunBrightness", vars.effectVariables.sunBrightness)
				SetEnvironmentProperty("exposure", vars.effectVariables.exposure)
				SetEnvironmentProperty("skyboxtint", vars.effectVariables.skyboxtint[1], vars.effectVariables.skyboxtint[2], vars.effectVariables.skyboxtint[3])
				
				SetEnvironmentProperty("fogColor", vars.effectVariables.fogColor[1], vars.effectVariables.fogColor[2], vars.effectVariables.fogColor[3])
				SetEnvironmentProperty("fogParams", vars.effectVariables.fogParams[1], vars.effectVariables.fogParams[2], vars.effectVariables.fogParams[3], vars.effectVariables.fogParams[4])
			end,
		},
		
		nightTime = {
			name = "Night Time",
			effectDuration = 25,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {skybox = "", skyboxbrightness = 0, ambient = 0, sunBrightness = 0, exposure = 0, skyboxtint = {0, 0, 0}, fogColor = {0, 0, 0}, fogParams = {0, 0, 0, 0}},
			onEffectStart = function(vars) 
				vars.effectVariables.skybox = GetEnvironmentProperty("skybox")
				vars.effectVariables.skyboxbrightness = GetEnvironmentProperty("skyboxbrightness")
				vars.effectVariables.ambient = GetEnvironmentProperty("ambient")
				vars.effectVariables.sunBrightness = GetEnvironmentProperty("sunBrightness")
				vars.effectVariables.exposure = GetEnvironmentProperty("exposure")
				
				local skyTint1, skyTint2, skyTint3 = GetEnvironmentProperty("skyboxtint")
				vars.effectVariables.skyboxtint = {skyTint1, skyTint2, skyTint3}
				
				local fogColor1, fogColor2, fogColor3 = GetEnvironmentProperty("fogColor")
				vars.effectVariables.fogColor = {fogColor1, fogColor2, fogColor3}
				
				local fogParam1, fogParam2, fogParam3, fogParam4 = GetEnvironmentProperty("fogParams")
				vars.effectVariables.fogParams = {fogParam1, fogParam2, fogParam3, fogParam4}
				
				SetEnvironmentProperty("skybox", "night_clear.dds")
				SetEnvironmentProperty("skyboxbrightness", 0.05)
				SetEnvironmentProperty("ambient", 0)
				SetEnvironmentProperty("sunBrightness", 0)
				SetEnvironmentProperty("exposure", 1.5)
				SetEnvironmentProperty("skyboxtint", 1, 1, 1)
				SetEnvironmentProperty("fogColor", 0.02, 0.02, 0.024)
				SetEnvironmentProperty("fogParams", 20, 120, 0.9, 2)
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) 
				SetEnvironmentProperty("skybox", vars.effectVariables.skybox)
				SetEnvironmentProperty("skyboxbrightness", vars.effectVariables.skyboxbrightness)
				SetEnvironmentProperty("ambient", vars.effectVariables.ambient)
				SetEnvironmentProperty("sunBrightness", vars.effectVariables.sunBrightness)
				SetEnvironmentProperty("exposure", vars.effectVariables.exposure)
				SetEnvironmentProperty("skyboxtint", vars.effectVariables.skyboxtint[1], vars.effectVariables.skyboxtint[2], vars.effectVariables.skyboxtint[3])
				
				SetEnvironmentProperty("fogColor", vars.effectVariables.fogColor[1], vars.effectVariables.fogColor[2], vars.effectVariables.fogColor[3])
				SetEnvironmentProperty("fogParams", vars.effectVariables.fogParams[1], vars.effectVariables.fogParams[2], vars.effectVariables.fogParams[3], vars.effectVariables.fogParams[4])
			end,
		},
		
		drunkfov = {
			name = "Drunk FOV",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { fov = 1, goingBack = false},
			onEffectStart = function(vars) 
				vars.effectVariables.fov = GetInt("options.gfx.fov")
			end,
			onEffectTick = function(vars) 
				local changeSpeed = 50
				
				if vars.effectVariables.goingBack then
					vars.effectVariables.fov = vars.effectVariables.fov - GetChaosTimeStep() * changeSpeed
					
					if vars.effectVariables.fov < 60 then
						vars.effectVariables.goingBack = false
					end
				else
					vars.effectVariables.fov = vars.effectVariables.fov + GetChaosTimeStep() * changeSpeed
					
					if vars.effectVariables.fov > 120 then
						vars.effectVariables.goingBack = true
					end
				end
			
				SetCameraFov(vars.effectVariables.fov)
			end,
			onEffectEnd = function(vars) end,
		},
		
		tunnelfov = {
			name = "Tunnel FOV",
			effectDuration = 20,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = { currFov = 120 },
			onEffectStart = function(vars) 
				local maxDist = 100
				local maxFov = 150
			
				local hit, hitPoint, distance = raycast(orig, dir, maxDist)
				
				if distance == nil then
					distance = maxDist
				end
				
				local targetFov = maxFov - maxFov / maxDist * distance
				
				vars.effectVariables.currFov = targetFov
			end,
			onEffectTick = function(vars) 
				local cameraTransform = GetCameraTransform()
				
				local orig = cameraTransform.pos
				local dir = TransformToParentVec(cameraTransform, Vec(0, 0, -1))
				
				local maxDist = 100
				local maxFov = 150
				local lerpSpeed = 2.5
				
				local hit, hitPoint, distance = raycast(orig, dir, maxDist)
				
				if distance == nil then
					distance = maxDist
				end
				
				local currFov = vars.effectVariables.currFov
				
				local targetFov = maxFov - maxFov / maxDist * distance
				
				currFov = lerp(currFov, targetFov, GetChaosTimeStep() * lerpSpeed)
				
				vars.effectVariables.currFov = currFov
				
				SetCameraFov(currFov)
			end,
			onEffectEnd = function(vars) end,
		},
		
		spawnTank = {
			name = "Spawn A Tank",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Spawn("MOD/spawn/mil-tank.xml", GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		spawnCrane = {
			name = "Spawn A Crane Truck",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Spawn("MOD/spawn/crane_truck.xml", GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},	
		
		spawnAlarm = {
			name = "Spawn Griefer Robot",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Spawn("MOD/spawn/alarm.xml", GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},	

		spawnSpider = {
			name = "Spawn Extreme Griefer Robot",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Spawn("MOD/spawn/spider.xml", GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},			

		spawnDockHandler = {
			name = "Spawn Dock Handler",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Spawn("MOD/spawn/dock_handler.xml", GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},	
		
		spawnTerrorbyte = {
			name = "Spawn Terrorbyte",
			effectDuration = 0,
			effectLifetime = 0,
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars)
				Spawn("MOD/spawn/terrorbyte.xml", GetPlayerTransform())
			end,
			onEffectTick = function(vars) end,
			onEffectEnd = function(vars) end,
		},
		
		randomSpawning = {
			name = "Spawn Random Object",
			effectDuration = 0,
			effectLifetime = 0, 
			hideTimer = false,
			effectSFX = {},
			effectSprites = {},
			effectVariables = {},
			onEffectStart = function(vars) 
				local gSpawnList = {}	
				function trim(s)
					local n = string.find(s,"%S")
					return n and string.match(s, ".*%S", n) or ""
				end
				local mods = ListKeys("spawn")
				local types = {}
				for m=1, #mods do
					local mod = mods[m]
					if HasKey("mods.available." .. mod) then
						local ids = ListKeys("spawn." .. mod)
						for i=1, #ids do
							local tmp = "spawn." .. mod .. "." .. ids[i]
							local n = GetString(tmp)
							local p = GetString(tmp .. ".path")
							local t = "Other"
							local s = string.find(n, "/", 1, true)
							if s and s > 1 then
								t = string.sub(n, 1, s-1)
								n = string.sub(n, s+1, string.len(n))
							end
							if n == "" then 
								n = "Unnamed"
							end
							t = trim(t)
							local found = false
							for j=1, #types do
								if string.lower(types[j]) == string.lower(t) then
									t = types[j]
									found = true
									break
								end
							end
							if not found then
								types[#types+1] = t
							end
							
							local item = {}
							item.name = n
							item.type = t
							item.path = p
							item.mod = mod
							gSpawnList[#gSpawnList+1] = item
							
						end
					end
				end
				
				local randomIndex = math.random(1,#gSpawnList)
				Spawn((gSpawnList[randomIndex].path), GetPlayerTransform())
			end,
			onEffectTick = function(vars)end,
			onEffectEnd = function(vars) end,
		},
	},	-- EFFECTS TABLE
}

chaosKeysInit()