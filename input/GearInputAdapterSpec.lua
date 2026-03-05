---This class is responsible for grabbing the configured input actions and forwarding them to the domain core.
---@class GearInputAdapterSpec
---@field SPEC_NAME string @The name of the specialization
---@field SPEC_TABLE table @The name of the specialization table
---@field GEARBOX_ADAPTER GearboxAdapterInterface @The domain adapter to forward input to
GearInputAdapterSpec = {
	SPEC_NAME = g_currentModName .. ".gearInputAdapter",
	SPEC_TABLE = "spec_" .. g_currentModName .. ".gearInputAdapter",
}

---Registers the specialization with the type manager so it can be assigned to vehicles
---@param typeManager table @The type manager to register the specialization with
---@param typeName string @The vehicle type name
---@param specializations table @The list of specializations to check for prerequisites
function GearInputAdapterSpec.register(typeManager, typeName, specializations)
	if GearInputAdapterSpec.prerequisitesPresent(specializations) then
		typeManager:addSpecialization(typeName, GearInputAdapterSpec.SPEC_NAME)
	end
end

---Static dependency injection
function GearInputAdapterSpec.injectDependencies(gearboxAdapter)
	GearInputAdapterSpec.GEARBOX_ADAPTER = gearboxAdapter
end

---Initializes the specialization
function GearInputAdapterSpec.initSpecialization()
	-- Nothing to do right now
end

---Makes sure any dependent specializations are loaded
---@param specializations table @The list of specializations to check
function GearInputAdapterSpec.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Motorized, specializations)
end

---Registers custom event listeners
---@param vehicleType table @The vehicle type to register the event listeners for
function GearInputAdapterSpec.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", GearInputAdapterSpec)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", GearInputAdapterSpec)
	SpecializationUtil.registerEventListener(vehicleType, "onEnterVehicle", GearInputAdapterSpec)
	SpecializationUtil.registerEventListener(vehicleType, "onLeaveVehicle", GearInputAdapterSpec)
end

---Registers new functions exclusive to this specialization
---@param vehicleType table @The vehicle type
function GearInputAdapterSpec.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "getSpec", GearInputAdapterSpec.getSpec)
	SpecializationUtil.registerFunction(vehicleType, "onGearGroupStateChanged", GearInputAdapterSpec.onGearGroupStateChanged)
	SpecializationUtil.registerFunction(vehicleType, "onGearStateChanged", GearInputAdapterSpec.onGearStateChanged)
end

function GearInputAdapterSpec:onUpdateTick(dt, _, isActiveForInputIgnoreSelection, _)
	if self.isClient then
		if isActiveForInputIgnoreSelection then
			GearInputAdapterSpec.updateActionEvents(self)
		end
	end
end

function GearInputAdapterSpec:onRegisterActionEvents(_, isActiveForInputIgnoreSelection)
	if self.isClient then
		local spec = self:getSpec()
		self:clearActionEventsTable(spec.actionEvents)
		if isActiveForInputIgnoreSelection then
			for i = 1, 8 do
				local callback = function(s) s:onGearGroupStateChanged(i) end
				local _, actionEventId = self:addActionEvent(spec.actionEvents, "GA_GEAR_GROUP_STATE_" .. i, self, callback, false, true, false, true, nil)
				g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
				g_inputBinding:setActionEventText(actionEventId, "")
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)

				callback = function(s) s:onGearStateChanged(i) end
				_, actionEventId = self:addActionEvent(spec.actionEvents, "GA_GEAR_STATE_" .. i, self, callback, false, true, false, true, nil)
				g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
				g_inputBinding:setActionEventText(actionEventId, "")
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end
			GearInputAdapterSpec.updateActionEvents(self)
		end
	end
end

function GearInputAdapterSpec:onGearGroupStateChanged(gearGroupIndex)
	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearGroupInput(gearGroupIndex)
end

function GearInputAdapterSpec:onGearStateChanged(gearStateIndex)
	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearInput(gearStateIndex)
end

function GearInputAdapterSpec:onEnterVehicle()
	local spec_motorized = self.spec_motorized
	if spec_motorized and spec_motorized.motor then
		local motor = spec_motorized.motor
		if not motor:getUseAutomaticGearShifting() then
			-- Manually shifted vehicle
			local numForwardGears = motor.forwardGears and #motor.forwardGears or 1
			local numGearGroups = motor.gearGroups and #motor.gearGroups or 1
			Logging.info("Entered vehicle with %d gear groups and %d forward gears", numGearGroups, numForwardGears)
			GearInputAdapterSpec.GEARBOX_ADAPTER:setCurrentGearLayout(numGearGroups, numForwardGears)
			return
		end
	end
	-- All other cases (No motor, CVT, ...): Disable input processing
	GearInputAdapterSpec.GEARBOX_ADAPTER:setCurrentGearLayout(nil, nil)
end

function GearInputAdapterSpec:onLeaveVehicle()
	-- Reset current gear layout so inputs are no longer being processed
	GearInputAdapterSpec.GEARBOX_ADAPTER:setCurrentGearLayout(nil, nil)
end

function GearInputAdapterSpec:updateActionEvents()
	local spec = self:getSpec()
	for i = 1, 8 do
		local actionEvent = spec.actionEvents["GA_GEAR_GROUP_STATE_" .. i]
		g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)

		actionEvent = spec.actionEvents["GA_GEAR_STATE_" .. i]
		g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
	end
end

function GearInputAdapterSpec:getSpec()
	return self[GearInputAdapterSpec.SPEC_TABLE]
end