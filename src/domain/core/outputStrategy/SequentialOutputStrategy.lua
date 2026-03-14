---Sequentially selects the gears in the vehicle.
---
---If the vehicle has less gears than the current number, the highest gear will be selected.
---If the vehicle has more gears then the player can input, then the highest gears will be unreachable.
---
---@class SequentialOutputStrategy
SequentialOutputStrategy = {}

---Constructor
---@return OutputTransformationStrategy @The public interface of the class
function SequentialOutputStrategy.new()
	local self = setmetatable({}, {__index = SequentialOutputStrategy})
	return self
end

---Calculates the real gear and group to be selected based on the effective gear calculated by the input transformation strategy and the current vehicle.
---@param gearSelectionHint GearSelectionHint Information about the gear the input transformation strategy has calculated.
---@param vehicleGearboxInfo VehicleGearboxInfo Information about the current vehicle's gearbox
---@return GearCalculationResult|nil @Information about the direction, group and gear to be applied to the vehicle.
function SequentialOutputStrategy:calculateGearSelection(gearSelectionHint, vehicleGearboxInfo)

	local direction
	local outputGroup
	local outputGear

	if gearSelectionHint.direction == 0 then
		-- neutral gear
		direction = 0
		outputGroup = nil -- leave the group wherever it is
		outputGear = 0
	elseif vehicleGearboxInfo.maxGroups <= 1 then
		-- The vehicle has no groups => Just use the effective gear 1:1
		direction = gearSelectionHint.direction
		outputGroup = nil -- Do not change the group
		outputGear = gearSelectionHint.effectiveGear
	elseif gearSelectionHint.direction > 0 then
		-- The vehicle has more than one group, and the vehicle is moving forwards:
		-- Calculate the effective group and gear by sequentially lining up all the groups with their gears and picking the nth gear.
		direction = 1
		outputGroup = (gearSelectionHint.effectiveGear - 1) // vehicleGearboxInfo.maxForwardGears + 1
		outputGear = (gearSelectionHint.effectiveGear - 1) % vehicleGearboxInfo.maxForwardGears + 1
	else
		-- The vehicle has more than one group, and the vehicle is moving backwards:
		direction = -1
		outputGroup = -1 -- assumption: Vehicles don't have more than one reverse gear group. Things like RLL, RHL etc are gears within the same group
		outputGear = gearSelectionHint.effectiveGear
	end

	return GearCalculationResult.new(direction, outputGroup, outputGear)
end