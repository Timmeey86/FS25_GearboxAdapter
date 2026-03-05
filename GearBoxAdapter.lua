MOD_DIRECTORY = g_currentModDirectory

local gearChangeHandler = GearChangeHandler.new()
local gearboxAdapter = DomainGearboxAdapter.new(gearChangeHandler)

-- For now, use a fixed configuration
gearboxAdapter:setTransformationStrategy(GearboxAdapterInterface.STRATEGY.SEQUENTIAL)
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