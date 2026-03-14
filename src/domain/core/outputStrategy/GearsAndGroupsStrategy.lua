---Tries selecting gears and groups 1:1 exactly as input, and uses fallbacks for when that would be problematic
---
---If the vehicle has less groups and gears in groups than the player can input, then everything can be selected (and some slots might be unused).
---If the vehicle has only a single gear group, the effective input gear calculated by the input strategy will be used.
---If the vehicle has e.g. less groups than the player can input, but more gears per group, then some gears will be unreachable.
---If the vehicle has more than one group, but the input strategy did not provide a group/gear within group suggestion, the sequential
---strategy will be used as a fallback.
---
---@class GearsAndGroupsStrategy
---@field fallbackStrategy OutputTransformationStrategy The fallback strategy.
GearsAndGroupsStrategy = {}

---Constructor
---@return OutputTransformationStrategy @The public interface of the class
function GearsAndGroupsStrategy.new()
	local self = setmetatable({}, {__index = GearsAndGroupsStrategy})
	self.fallbackStrategy = SequentialOutputStrategy.new()
	return self
end
---Calculates the real gear and group to be selected based on the effective gear calculated by the input transformation strategy and the current vehicle.
---@param gearSelectionHint GearSelectionHint Information about the gear the input transformation strategy has calculated.
---@param vehicleGearboxInfo VehicleGearboxInfo Information about the current vehicle's gearbox
---@return GearCalculationResult|nil @Information about the direction, group and gear to be applied to the vehicle.
function GearsAndGroupsStrategy:calculateGearSelection(gearSelectionHint, vehicleGearboxInfo)

	local direction
	local outputGroup
	local outputGear


	if gearSelectionHint.direction == 0 then
		-- neutral gear
		direction = 0
		outputGroup = nil -- leave the group wherever it is
		outputGear = 0
	elseif vehicleGearboxInfo.maxGroups > 1 then
		-- Use the calculated group inputs 1:1
		direction = gearSelectionHint.direction
		if gearSelectionHint.gearGroup ~= nil and gearSelectionHint.gearInGroup ~= nil then
			outputGroup = gearSelectionHint.gearGroup
			outputGear = gearSelectionHint.gearInGroup
		else
			-- Fallback: The input strategy could not calculate gears and groups => Sequential strategy will be the best match
			return self.fallbackStrategy:calculateGearSelection(gearSelectionHint, vehicleGearboxInfo)
		end
	else
		-- The vehicle has no groups => Just use the effective gear 1:1
		direction = gearSelectionHint.direction
		outputGroup = nil -- Do not change the group
		outputGear = gearSelectionHint.effectiveGear
	end

	return GearCalculationResult.new(direction, outputGroup, outputGear)
end