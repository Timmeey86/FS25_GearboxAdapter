---Sequentially transforms gear/group input into gear/group output. 
---Examples for when the player has 6 input gears and 2 input groups:
---
---Example 1: Vehicle has 8 gears with no groups:
---		Input Group 1, Gear 1-6 -> Output Gear 1-6
---		Input Group 2, Gear 1-2 -> Output Gear 7-8
---		Input Group 2, Gear 3-4 -> Unused (results in gear 8)
---
---Example 2: Vehicle has 3 groups with 4 gears each:
---		Input Group 1, Gear 1-4 -> Output Group 1, Gear 1-4
---		Input Group 2, Gear 3-6 -> Output Group 3, Gear 1-4
---		Input Group 1, Gear 5-6 -> Output Group 2, Gear 1-2
---		Input Group 2, Gear 1-2 -> Output Group 2, Gear 3-4
---
---Example 3: Vehicle has 18 gears:
---		Input Group 1, Gear 1-6 -> Output Gear 1-6
---		Input Group 2, Gear 1-6 -> Output Gear 7-12
---		Output Gears 13-18 are unusable (that's why it makes sense to have at least 4 buttons / 2 switches for input groups
---@class SequentialTransformationStrategy
---@field vehicleGroupCount number @The number of gear groups the current vehicle has
---@field vehicleGearCount number @The number of gears per gear group the current vehicle has
---@field totalVehicleGears number @The total number of gears the current vehicle has, calculated from the above two parameters
---@field maxInputGroups number @The number of gear groups the player can select with their controller.
---@field maxInputGears number @The number of gears per gear group the player can select with their controller.
---@field totalInputGears number @The total number of gears the player could select in theory be combining groups and gears.
SequentialTransformationStrategy = {}
local SequentialTransformationStrategy_mt = Class(SequentialTransformationStrategy, InputTransformationStrategy)

---Constructor
---@return InputTransformationStrategy @The public interface of the class
function SequentialTransformationStrategy.new()
	local self = setmetatable({}, SequentialTransformationStrategy_mt)
	self.vehicleGroupCount = nil
	self.vehicleGearCount = nil
	self.totalVehicleGears = nil
	return self
end

---Registers a new vehicle gear/group layout to be processed from now on
---@param groupCount number @The number of gear groups in the vehicle.
---@param gearCount number @The number of gears per group in the vehicle.
---@param totalGearCount number @The total number of gears in the vehicle. Usually maxGroups * maxGears, but might be lower if e.g. some vehicle has less gears in the last group or something.
function SequentialTransformationStrategy:changeVehicle(groupCount, gearCount,  totalGearCount)
	self.vehicleGroupCount = groupCount
	self.vehicleGearCount = gearCount
	self.totalVehicleGears = totalGearCount
end

---Sets the number of gear groups and gears the player can select with their controller.
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
---@param totalGearCount number @The total number of gears the player can select with their controller. Usually maxGroups * maxGears.
function SequentialTransformationStrategy:setInputLimits(maxGroups, maxGears, totalGearCount)
	self.maxInputGroups = maxGroups
	self.maxInputGears = maxGears
	self.totalInputGears = totalGearCount
end

---Transforms the generic gear group and gear inputs into a gear selection.
---@param groupInput number @The gear group which was selected.
---@param gearInput number @The gear input which was selected.
---@return number, number @The transformed group and gear to select in the vehicle. The group will be nil if the vehicle doesn't support groups.
function SequentialTransformationStrategy:transformGearInput(groupInput, gearInput)
	-- Calculate the effective gear
	local effectiveGear = gearInput
	if self.maxInputGroups > 1 then
		-- If the player has group 3 selected, it's like skipping two full sets of gears and adding the current gear on top
		effectiveGear = effectiveGear + ((groupInput - 1) * self.maxInputGears)
	end

	if effectiveGear > self.totalVehicleGears then
		-- Out of bounds => return the highest group and gear
		-- Reduce the gear if the total amount of vehicle gears don't match groupCount * gearCount, though.
		return self.vehicleGroupCount, math.clamp(self.vehicleGearCount, 1, (self.totalVehicleGears - ((self.vehicleGroupCount - 1) * self.vehicleGearCount)))
	end

	-- Else: Input gear is within vehicle bounds.
	-- Calculate the sequential gear group which contains this effective gear
	local outputGroup = math.ceil(effectiveGear / self.vehicleGearCount)

	-- Select the appropriate gear within that group
	local outputGear = effectiveGear % self.vehicleGearCount
	if outputGear == 0 then
		outputGear = self.vehicleGearCount
	end

	return outputGroup, outputGear
end