--!strict
-- Timed "active buff" purchases. WalkSpeed/JumpPower effects are computed
-- from FIXED base values every time (never "current value * multiplier"),
-- so buying the same buff back-to-back can never compound — it just
-- refreshes the timer. CoinX2 is a flag other services read via
-- GetCoinMultiplier rather than this module reaching into their logic.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetConstants = require(ReplicatedStorage.Shared.Net.NetConstants)
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)
local ActiveBuffConfig = require(ReplicatedStorage.Shared.Config.ActiveBuffConfig)

local DataService = require(script.Parent.DataService)

local BASE_WALK_SPEED = 16
local BASE_JUMP_POWER = 50
local BASE_JUMP_HEIGHT = 7.2

local BuffService = {}

type BuffEntry = { ExpiresAt: number, Thread: thread? }

-- {[Player]: {[BuffId]: BuffEntry}}
local activeBuffs: { [Player]: { [string]: BuffEntry } } = {}

local function fireBuffChanged(player: Player, buffId: string, active: boolean, duration: number?)
	Remotes.GetEvent(NetConstants.BuffChanged):FireClient(player, {
		BuffId = buffId,
		Active = active,
		Duration = duration,
	})
end

local function applyMovementEffects(player: Player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local playerBuffs = activeBuffs[player]

	local speedMultiplier = 1
	if playerBuffs and playerBuffs.SpeedBoost then
		local def = ActiveBuffConfig.Get("SpeedBoost")
		speedMultiplier = if def then def.Multiplier else 1
	end
	humanoid.WalkSpeed = BASE_WALK_SPEED * speedMultiplier

	local jumpMultiplier = 1
	if playerBuffs and playerBuffs.JumpBoost then
		local def = ActiveBuffConfig.Get("JumpBoost")
		jumpMultiplier = if def then def.Multiplier else 1
	end
	humanoid.JumpPower = BASE_JUMP_POWER * jumpMultiplier
	humanoid.JumpHeight = BASE_JUMP_HEIGHT * jumpMultiplier
end

function BuffService.IsActive(player: Player, buffId: string): boolean
	local playerBuffs = activeBuffs[player]
	return playerBuffs ~= nil and playerBuffs[buffId] ~= nil
end

function BuffService.GetCoinMultiplier(player: Player): number
	if BuffService.IsActive(player, "CoinX2") then
		local def = ActiveBuffConfig.Get("CoinX2")
		return if def then def.Multiplier else 1
	end
	return 1
end

local function activateBuff(player: Player, buffId: string, duration: number)
	activeBuffs[player] = activeBuffs[player] or {}
	local playerBuffs = activeBuffs[player]

	-- Cancel any existing expiry timer for this buff first, so re-buying an
	-- already-active buff refreshes its duration instead of stacking a
	-- second countdown that would revert effects early.
	local existing = playerBuffs[buffId]
	if existing and existing.Thread then
		task.cancel(existing.Thread)
	end

	local entry: BuffEntry = { ExpiresAt = os.clock() + duration, Thread = nil }
	playerBuffs[buffId] = entry

	entry.Thread = task.delay(duration, function()
		local current = activeBuffs[player]
		if current and current[buffId] == entry then
			current[buffId] = nil
			applyMovementEffects(player)
			fireBuffChanged(player, buffId, false)
		end
	end)

	applyMovementEffects(player)
	fireBuffChanged(player, buffId, true, duration)
end

local function onRequestBuyBuff(player: Player, buffId: any)
	if typeof(buffId) ~= "string" then
		return
	end

	local buff = ActiveBuffConfig.Get(buffId)
	if not buff then
		return
	end

	if not DataService.IsLoaded(player) then
		return
	end

	local profile = DataService.GetProfile(player)
	if not profile then
		return
	end

	if profile.Currency.Coins < buff.PriceCoins then
		return
	end

	profile.Currency.Coins -= buff.PriceCoins
	Remotes.GetEvent(NetConstants.CurrencyChanged):FireClient(player, profile.Currency)

	activateBuff(player, buffId, buff.Duration)
end

function BuffService.Init()
	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function()
			-- Let the fresh Humanoid finish applying its own defaults before
			-- we potentially override them with an already-active buff.
			task.wait()
			applyMovementEffects(player)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local playerBuffs = activeBuffs[player]
		if playerBuffs then
			for _, entry in playerBuffs do
				if entry.Thread then
					task.cancel(entry.Thread)
				end
			end
		end
		activeBuffs[player] = nil
	end)

	Remotes.GetEvent(NetConstants.RequestBuyBuff).OnServerEvent:Connect(onRequestBuyBuff)
end

return BuffService
