---Sequentially selects the gears in the vehicle.
---
---If the vehicle has less gears than the current number, the highest gear will be selected.
---If the vehicle has more gears then the player can input, then the highest gears will be unreachable.
---
---@class SequentialOutputStrategy
---@field vehicleGearboxInfo VehicleGearboxInfo|nil @Information about the current vehicle's gearbox.
SequentialOutputStrategy = {}
local SequentialOutputStrategy_mt = Class(SequentialOutputStrategy, OutputTransformationStrategy)

---Constructor
---@return OutputTransformationStrategy @The public interface of the class
function SequentialOutputStrategy.new()
	local self = setmetatable({}, SequentialOutputStrategy_mt)
	self.vehicleGearboxInfo = nil
	return self
end

---Registers a new vehicle gear/group layout to be processed from now on
---@param vehicleGearboxInfo VehicleGearboxInfo information about the vehicle's gearbox or nil if no vehicle
function SequentialOutputStrategy:setGearboxInfo(vehicleGearboxInfo)
	self.vehicleGearboxInfo = vehicleGearboxInfo
end

---Calculates the real gear and group to be selected based on the effective gear calculated by the input transformation strategy and the current vehicle.
---@param gearSelectionHint GearSelectionHint Information about the gear the input transformation strategy has calculated.
---@return GearCalculationResult|nil @Information about the direction, group and gear to be applied to the vehicle.
function SequentialOutputStrategy:calculateGearSelection(gearSelectionHint)

	local direction
	local outputGroup
	local outputGear

	if self.vehicleGearboxInfo and self.vehicleGearboxInfo.maxGroups <= 1 then
		-- The vehicle has no groups => Just use the effective gear 1:1
		direction = gearSelectionHint.direction
		outputGroup = nil -- Do not change the group
		outputGear = gearSelectionHint.gear
	elseif gearSelectionHint.direction == 0 then
		-- other vehicles; neutral gear
		direction = 0
		outputGroup = nil -- leave the group whereever it is
		outputGear = 0
	elseif gearSelectionHint.direction > 0 then
		-- The vehicle has more than one group, and the vehicle is moving forwards:
		-- Calculate the effective group and gear by sequentially lining up all the groups with their gears and picking the nth gear.
		direction = 1
		outputGroup = (gearSelectionHint.gear - 1) // self.vehicleGearboxInfo.maxForwardGears + 1
		outputGear = (gearSelectionHint.gear - 1) % self.vehicleGearboxInfo.maxForwardGears + 1
	else
		-- The vehicle has more than one group, and the vehicle is moving backwards:
		direction = -1
		outputGroup = -1 -- assumption: Vehicles don't have more than one reverse gear group. Things like RLL, RHL etc are gears within the same group
		outputGear = gearSelectionHint.gear
	end

	-- If the output gear is out of bounds, clamp it to the closest valid gear.
	local upperBound = direction > 0 and self.vehicleGearboxInfo.maxForwardGears or self.vehicleGearboxInfo.maxReverseGears
	outputGear = math.min(outputGear, upperBound)

	return GearCalculationResult.new(direction, outputGroup, outputGear)
end