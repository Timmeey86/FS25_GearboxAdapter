MOD_DIRECTORY = g_currentModDirectory
MOD_NAME = g_currentModName

local function isClutchEnabledFunc()
	return g_gameSettings:getValue(GameSettings.SETTING.GEAR_SHIFT_MODE) == VehicleMotor.SHIFT_MODE_MANUAL_CLUTCH
end

local gearChangeHandler = GearChangeHandler.new()
local gearboxAdapter = DomainGearboxAdapter.new(gearChangeHandler, isClutchEnabledFunc)

-- For now, use a fixed configuration
gearboxAdapter:setInputTransformationStrategy(GearboxAdapterInterface.INPUT_STRATEGY.EATON_FULLER_18)
gearboxAdapter:setOutputTransformationStrategy(GearboxAdapterInterface.OUTPUT_STRATEGY.SEQUENTIAL)
gearboxAdapter:setInputLimits(4, 6)


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