---Sequentially selects the gears in the vehicle.
---
---If the vehicle has less gears than the current number, the highest gear will be selected.
---If the vehicle has more gears then the player can input, then the highest gears will be unreachable.
---
---@class SequentialOutputStrategy
---@field vehicleGroupCount number @The number of gear groups the current vehicle has
---@field vehicleForwardGearCount number @The number of forward gears per gear group the current vehicle has
---@field vehicleReverseGearCount number @The number of reverse gears in the current vehicle
---@field gearChangeImpl GearChangeInterface @The implementation to call for applying gear changes to the vehicle.
SequentialOutputStrategy = {}
local SequentialOutputStrategy_mt = Class(SequentialOutputStrategy, OutputTransformationStrategy)

---Constructor
---@param gearChangeImpl GearChangeInterface @The implementation to call for applying gear changes to the vehicle.
---@return OutputTransformationStrategy @The public interface of the class
function SequentialOutputStrategy.new(gearChangeImpl)
	local self = setmetatable({}, SequentialOutputStrategy_mt)
	self.vehicleGroupCount = nil
	self.vehicleForwardGearCount = nil
	self.vehicleReverseGearCount = nil
	self.gearChangeImpl = gearChangeImpl
	return self
end

---Registers a new vehicle gear/group layout to be processed from now on
---@param groupCount number @The number of gear groups in the vehicle.
---@param forwardGearCount number @The number of forward gears per group in the vehicle.
---@param reverseGearCount number @The number of reverse gears in the vehicle.
function SequentialOutputStrategy:changeVehicle(groupCount, forwardGearCount, reverseGearCount, totalGearCount)
	self.vehicleGroupCount = groupCount
	self.vehicleForwardGearCount = forwardGearCount
	self.vehicleReverseGearCount = reverseGearCount
	self.totalVehicleGears = totalGearCount
end

---Applies new gear selection data to the vehicle.
---@param gearSelectionData GearSelectionData @Data on the groups/gears to select in the vehicle.
function SequentialOutputStrategy:applyNewData(gearSelectionData)

	local outputGroup
	local outputGear

	if self.vehicleGroupCount == 1 then
		-- Easy case: Just select the sequential gear number
		if gearSelectionData.sequentialGear == 0 then
			outputGroup = nil -- do not change group
		else
			outputGroup = gearSelectionData.sequentialGear > 0 and 1 or -1
		end
		outputGear = gearSelectionData.sequentialGear
	elseif gearSelectionData.sequentialGear == 0 then
		-- neutral gear
		outputGroup = nil -- do not change group
		outputGear = 0
	elseif gearSelectionData.sequentialGear > 0 then
		-- Calculate the effective group and gear
		outputGroup = (gearSelectionData.sequentialGear - 1) // self.vehicleForwardGearCount + 1
		outputGear = (gearSelectionData.sequentialGear - 1) % self.vehicleForwardGearCount + 1
	else
		-- reverse gear
		outputGroup = -1 -- assumption: Vehicles don't have more than one reverse gear group
		outputGear = gearSelectionData.sequentialGear
	end

	-- If the output gear is out of bounds, clamp it to the closest valid gear.
	outputGear = math.clamp(outputGear, -self.vehicleReverseGearCount, self.vehicleForwardGearCount)

	self.gearChangeImpl:changeGroupAndGear(outputGroup, outputGear)
end