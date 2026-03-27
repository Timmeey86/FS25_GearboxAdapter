---This class is responsible for grabbing the configured input actions, interpreting them and forwarding them to the domain core.
---@class GearInputAdapterSpec
---@field SPEC_NAME string @The name of the specialization
---@field SPEC_TABLE table @The name of the specialization table
---@field GEARBOX_ADAPTER GearboxAdapterInterface @The domain adapter to forward input to
---@field currentSwitchState number @The current switch state for groups in binary, where bit 0 = switch 1, bit 1 = switch 2, bit 2 = switch 3
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
	SpecializationUtil.registerFunction(vehicleType, "onDirectGroupChanged", GearInputAdapterSpec.onDirectGroupChanged)
	SpecializationUtil.registerFunction(vehicleType, "onDirectGearChanged", GearInputAdapterSpec.onDirectGearChanged)
	SpecializationUtil.registerFunction(vehicleType, "onSwitchForGroupChanged", GearInputAdapterSpec.onSwitchForGroupChanged)
end

function GearInputAdapterSpec:onUpdateTick(dt, _, isActiveForInputIgnoreSelection, _)
	if self.groupSwitch1Flipped == nil then
		self.groupSwitch1Flipped = false
		self.groupSwitch2Flipped = false
		self.groupSwitch3Flipped = false
	end
	if self.isClient then
		if isActiveForInputIgnoreSelection then
			GearInputAdapterSpec.updateActionEvents(self)
		end
	end
end

local errorShownForDirectGroups = false
local errorShownForDirectGears = false
local errorShownForSwitchGroups = false
local errorShownForDirectGearR = false

function GearInputAdapterSpec:onRegisterActionEvents(_, isActiveForInputIgnoreSelection)
	if self.isClient then
		local spec = self:getSpec()
		self:clearActionEventsTable(spec.actionEvents)
		if isActiveForInputIgnoreSelection then
			local callback, actionEventId, success
			for i = 1, 8 do
				callback = function(s) s:onDirectGroupChanged(i) end
				success, actionEventId = self:addActionEvent(spec.actionEvents, "GA_DIRECT_GROUP_" .. i, self, callback, true, true, false, true, nil)
				if not success and not errorShownForDirectGroups then
					Logging.error("Failed registering an action event for direct group " .. i .. ". Shifting will not work properly")
					errorShownForDirectGroups = true
				end
				g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
				g_inputBinding:setActionEventText(actionEventId, "")
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)

				callback = function(s, _, state) s:onDirectGearChanged(i, state) end
				success, actionEventId = self:addActionEvent(spec.actionEvents, "GA_DIRECT_GEAR_" .. i, self, callback, true, true, false, true, nil)
				if not success and not errorShownForDirectGears then
					Logging.error("Failed registering an action event for direct gear " .. i .. ". Shifting will not work properly")
					errorShownForDirectGears = true
				end
				g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
				g_inputBinding:setActionEventText(actionEventId, "")
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end

			for i = 1, 3 do
				callback = function(s, _, state) s:onSwitchForGroupChanged(i, state) end
				success, actionEventId = self:addActionEvent(spec.actionEvents, "GA_SWITCH_GROUP_" .. i, self, callback, true, true, false, true, nil)
				if not success and not errorShownForSwitchGroups then
					Logging.error("Failed registering an action event for switch group " .. i .. ". Shifting will not work properly")
					errorShownForSwitchGroups = true
				end
				g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
				g_inputBinding:setActionEventText(actionEventId, "")
				g_inputBinding:setActionEventTextVisibility(actionEventId, false)
			end

			-- Reverse gear
			callback = function(s, _, state) s:onDirectGearChanged(-1, state) end
			success, actionEventId = self:addActionEvent(spec.actionEvents, "GA_DIRECT_GEAR_R", self, callback, true, true, false, true, nil)
			if not success and not errorShownForDirectGearR then
				Logging.error("Failed registering an action event for reverse gear. Shifting will not work properly")
				errorShownForDirectGearR = true
			end
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW)
			g_inputBinding:setActionEventText(actionEventId, "")
			g_inputBinding:setActionEventTextVisibility(actionEventId, false)

			GearInputAdapterSpec.updateActionEvents(self)
		end
	end
end

function GearInputAdapterSpec:onDirectGroupChanged(gearGroupIndex)
	-- Use groups 1:1. We assume there is never a neutral group, but rather if the neutral gear is selected, the group does not matter
	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearGroupInput(gearGroupIndex)
end

function GearInputAdapterSpec:onDirectGearChanged(gearStateIndex, state)
	-- Always use the gear which was set, but in addition to what FS25 does, supply the neutral gear as soon as a gear gets removed
	local inputGear = state == 1 and gearStateIndex or 0

	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearInput(inputGear)
end

function GearInputAdapterSpec:onSwitchForGroupChanged(switchIndex, state)
	local spec = self:getSpec()
	if not spec then
		return
	end

	-- Calculate in binary since switches can be combined (Switch 3 = MSB, Switch 1 = LSB):
	-- Binary     Decimal    Group
	-- 000        0          1
	-- 001        1          2
	-- 010        2          3
	-- 011        3          4
	-- 100        4          5
	-- 101        5          6
	-- 110        6          7
	-- 111        7          8
	local switchBit = 2 ^ (switchIndex - 1)
	if state == 1 then
		spec.currentSwitchState = bit32.bor(spec.currentSwitchState, switchBit)
	else
		spec.currentSwitchState = bit32.band(spec.currentSwitchState, bit32.bnot(switchBit))
	end

	-- The effective gear group is the switch state as a decimal number + 1 since no switch pressed means group 1
	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearGroupInput(spec.currentSwitchState + 1)
end

function GearInputAdapterSpec:onEnterVehicle()
	local spec_motorized = self.spec_motorized
	if spec_motorized and spec_motorized.motor then
		local motor = spec_motorized.motor

		local hasAutomaticShift = motor:getUseAutomaticGearShifting() or motor.forwardGears == nil
		local needsClutchForGroups = not hasAutomaticShift and motor.groupType ~= VehicleMotor.TRANSMISSION_TYPE.POWERSHIFT
		local needsClutchForGears = not hasAutomaticShift and motor.gearType ~= VehicleMotor.TRANSMISSION_TYPE.POWERSHIFT

		local numForwardGears = (not hasAutomaticShift and motor.forwardGears and #motor.forwardGears) or 1
		local numForwardGroups = 0
		local numReverseGears = 0
		local hasReverseGearGroup = false
		for _, gearGroup in ipairs(motor.gearGroups or {}) do
			if gearGroup.ratio and gearGroup.ratio < 0 then
				-- Special vehicle which uses a regular group for reversing
				numReverseGears = numForwardGears
				hasReverseGearGroup = true
			else
				numForwardGroups = numForwardGroups + 1
			end
		end
		self.hasReverseGearGroup = hasReverseGearGroup

		if numReverseGears == 0 then
			numReverseGears = (not hasAutomaticShift and motor.backwardGears and #motor.backwardGears) or 0
		end
		local numGearGroups = (not hasAutomaticShift and motor.gearGroups and #motor.gearGroups) or 1

		local gearboxInfo = VehicleGearboxInfo.new(hasAutomaticShift, needsClutchForGroups, needsClutchForGears, numGearGroups, numForwardGears, numReverseGears)

		GearInputAdapterSpec.GEARBOX_ADAPTER:setGearboxInfo(gearboxInfo)
		return
	end

	-- All other cases (No motor, CVT, automatic shifting, ...): Disable input processing
	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearboxInfo(nil)
end

function GearInputAdapterSpec:onLeaveVehicle()
	-- Reset current gear layout so inputs are no longer being processed
	GearInputAdapterSpec.GEARBOX_ADAPTER:setGearboxInfo(nil)
end

function GearInputAdapterSpec.onManualClutchChanged(vehicle, clutchValue)
	GearInputAdapterSpec.GEARBOX_ADAPTER:setClutchState(clutchValue)
end
VehicleMotor.onManualClutchChanged = Utils.appendedFunction(VehicleMotor.onManualClutchChanged, GearInputAdapterSpec.onManualClutchChanged)

function GearInputAdapterSpec:updateActionEvents()
	local spec = self:getSpec()
	for i = 1, 8 do
		local actionEvent = spec.actionEvents["GA_DIRECT_GROUP_" .. i]
		if actionEvent then
			g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
		end

		actionEvent = spec.actionEvents["GA_DIRECT_GEAR_" .. i]
		if actionEvent then
			g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
		end
	end

	for i = 1, 3 do
		local actionEvent = spec.actionEvents["GA_SWITCH_GROUP_" .. i]
		if actionEvent then
			g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
		end
	end

	local actionEvent = spec.actionEvents["GA_DIRECT_GEAR_R"]
	if actionEvent then
		g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)
	end
end

function GearInputAdapterSpec:getSpec()
	local spec = self[GearInputAdapterSpec.SPEC_TABLE]
	if spec.currentSwitchState == nil then
		spec.currentSwitchState = 1
	end
	return spec
end