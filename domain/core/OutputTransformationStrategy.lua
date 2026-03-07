---An internal interface for transformation strategies
---@class OutputTransformationStrategy
OutputTransformationStrategy = {}

---Registers a new vehicle gear/group layout to be processed from now on
---@param groupCount number @The number of gear groups in the vehicle.
---@param forwardGearCount number @The number of forward gears per group in the vehicle.
---@param reverseGearCount number @The number of reverse gears in the vehicle.
function OutputTransformationStrategy:changeVehicle(groupCount, forwardGearCount, reverseGearCount, totalGearCount)
	error("Method 'changeVehicle' not defined in implementing class")
end

---Applies new gear selection data to the vehicle.
---@param gearSelectionData GearSelectionData @Data on the groups/gears to select in the vehicle.
function OutputTransformationStrategy:applyNewData(gearSelectionData)
	error("Method 'applyNewData' not defined in implementing class")
end