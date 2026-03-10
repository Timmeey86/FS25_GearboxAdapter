---An internal interface for transformation strategies
---@class OutputTransformationStrategy
OutputTransformationStrategy = {}

---Registers a new vehicle gear/group layout to be processed from now on
---@param vehicleGearboxInfo VehicleGearboxInfo|nil information about the vehicle's gearbox or nil if no vehicle
function OutputTransformationStrategy:setGearboxInfo(vehicleGearboxInfo)
	error("Method 'setGearboxInfo' not defined in implementing class")
end

---Calculates the real gear and group to be selected based on the effective gear calculated by the input transformation strategy and the current vehicle.
---@param gearSelectionHint GearSelectionHint Information about the gear the input transformation strategy has calculated.
---@return GearCalculationResult|nil @Information about the direction, group and gear to be applied to the vehicle or nil if no change should be applied.
function OutputTransformationStrategy:calculateGearSelection(gearSelectionHint)
	error("Method 'calculateGearSelection' not defined in implementing class")
	return nil
end