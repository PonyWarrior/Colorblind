---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,
-- 	so only assign to values or define things here.

Outlines =
{
	-- Default outline, used if anything goes wrong and in places like chaos realm.
	Default =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
	-- Erebus
	F =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
	-- Oceanus
	G =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
	-- Fields of Mourning
	H =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
	-- Tartarus
	I =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
	-- Ephyra
	N =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
	-- Rifts of Thelassy
	O =
	{
		R = 50,
		G = 50,
		B = 255,
		Opacity = 0.8,
		Thickness = 1,
		Threshold = 0.6,
	},
}

function IsOutlineLegal(unit)
	if unit.ObjectId == CurrentRun.Hero.ObjectId then
		return true
	end

	if (config.ExcludeTraps or config.SpeedrunMode) and unit.InheritFrom ~= nil and Contains(unit.InheritFrom, "BaseTrap") then
		return false
	end

	if (config.ExcludeTraps or config.SpeedrunMode) and unit.InheritFrom ~= nil and Contains(unit.InheritFrom, "IsNeutral") then
		return false
	end

	if (config.ExcludeMiscs or config.SpeedrunMode) and unit.InheritFrom ~= nil and Contains(unit.InheritFrom, "BaseBreakable") then
		return false
	end

	return true
end

function StartOver_wrap(base, args)
	base(args)
	CurrentRun.Hero.Outline = Outlines[CurrentRun.CurrentRoom.RoomSetName] or Outlines.Default
	CurrentRun.Hero.Outline.Id = CurrentRun.Hero.ObjectId
	AddOutline(CurrentRun.Hero.Outline)
end

function CreateLevelDisplay_wrap(newEnemy, currentRun)
	if IsOutlineLegal(newEnemy) then
		newEnemy.Outline = Outlines[CurrentRun.CurrentRoom.RoomSetName] or Outlines.Default
		newEnemy.Outline.Id = newEnemy.ObjectId
		game.AddOutline(newEnemy.Outline)
	end
end

function DoEnemyHealthBufferDeplete_wrap(enemy)
	if IsOutlineLegal(enemy) then
		enemy.Outline = Outlines[CurrentRun.CurrentRoom.RoomSetName] or Outlines.Default
		enemy.Outline.Id = enemy.ObjectId
		game.AddOutline(enemy.Outline)
	end
end

function WeaponLobAmmoDrop_override(triggerArgs, weaponDataArgs)
	if triggerArgs.BlockSpawns or ( triggerArgs.ProjectileWave and triggerArgs.ProjectileWave > 0) or triggerArgs.BonusProjectileWave then
		return
	end
	local consumableId = game.SpawnObstacle({ Name = "LobAmmoPack", LocationX = triggerArgs.LocationX, LocationY = triggerArgs.LocationY, Group = "Standing" })
	local consumable = CreateConsumableItem( consumableId, "LobAmmoPack" )
	local ammoDropData = weaponDataArgs.DropForces
	--MOD START
	consumable.Outline = Outlines[CurrentRun.CurrentRoom.RoomSetName] or Outlines.Default
	consumable.Outline.Id = consumable.ObjectId
	AddOutline(consumable.Outline)
	--MOD END

	if triggerArgs.HasImpact ~= nil and weaponDataArgs.CollideForces then
		ammoDropData = weaponDataArgs.CollideForces
	end
	ApplyUpwardForce({ Id = consumableId, Speed = RandomFloat( ammoDropData.UpwardForceMin or 0, ammoDropData.UpwardForceMax or 0 ) })
	if ammoDropData.ForceMax ~= nil then
		local scatter = 0
		if ammoDropData.Scatter then
			scatter = RandomFloat( -(ammoDropData.Scatter)/2, (ammoDropData.Scatter)/2)
		end
		ApplyForce({ Id = consumableId, Speed = RandomFloat( ammoDropData.ForceMin, ammoDropData.ForceMax ), Angle = triggerArgs.Angle + scatter, SelfApplied = true })
	end
	if HeroHasTrait("LobPulseAmmoTrait") then
		local pulseArgs = GetHeroTrait("LobPulseAmmoTrait").PulseArgs
		thread( PulseAmmo, consumable, pulseArgs)
	end
	thread( EscalateMagnetism, consumable )
end