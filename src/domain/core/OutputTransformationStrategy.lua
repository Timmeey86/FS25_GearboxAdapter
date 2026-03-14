---An internal interface for transformation strategies
---@class OutputTransformationStrategy
OutputTransformationStrategy = {}

---Calculates the real gear and group to be selected based on the effective gear calculated by the input transformation strategy and the current vehicle.
---@param gearSelectionHint GearSelectionHint Information about the gear the input transformation strategy has calculated.
---@param vehicleGearboxInfo VehicleGearboxInfo Information about the current vehicle's gearbox
---@return GearCalculationResult|nil @Information about the direction, group and gear to be applied to the vehicle or nil if no change should be applied.
function OutputTransformationStrategy:calculateGearSelection(gearSelectionHint, vehicleGearboxInfo)
	error("Method 'calculateGearSelection' not defined in implementing class")
	return nil
end