MOD_DIRECTORY = g_currentModDirectory

local function isClutchEnabledFunc()
	return g_gameSettings:getValue(GameSettings.SETTING.GEAR_SHIFT_MODE) == VehicleMotor.SHIFT_MODE_MANUAL_CLUTCH
end

local gearChangeHandler = GearChangeHandler.new()
local gearboxAdapter = DomainGearboxAdapter.new(gearChangeHandler, isClutchEnabledFunc)

-- For now, use a fixed configuration
gearboxAdapter:setTransformationStrategy(GearboxAdapterInterface.STRATEGY.EATON_FULLER_18)
gearboxAdapter:setInputLimits(4, 6)
gearboxAdapter:setCurrentGearLayout(3, 4) -- depends on vehicle


TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, function(typeManager)
	if typeManager.typeName == "vehicle" then
		-- Inject dependencies (can't do it much earlier since the spec isn't alive)
		GearInputAdapterSpec.injectDependencies(gearboxAdapter)

		for typeName, typeEntry in pairs(typeManager.types) do
			if(SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations)) then
				GearInputAdapterSpec.register(typeManager, typeName, typeEntry.specializations)
			end
		end
	end
end)