---An internal interface for transformation strategies
---@class InputTransformationStrategy
InputTransformationStrategy = {}

---Registers a new vehicle gear/group layout to be processed from now on
---@param groupCount number @The number of gear groups in the vehicle.
---@param gearCount number @The number of gears per group in the vehicle.
---@param totalGearCount number @The total number of gears in the vehicle. Usually maxGroups * maxGears, but might be lower if e.g. some vehicle has less gears in the last group or something.
function InputTransformationStrategy:changeVehicle(groupCount, gearCount, totalGearCount)
	error("Method 'changeVehicle' not defined in implementing class")
end

---Sets the number of gear groups and gears the player can select with their controller.
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
---@param totalGearCount number @The total number of gears the player can select with their controller. Usually maxGroups * maxGears.
function InputTransformationStrategy:setInputLimits(maxGroups, maxGears, totalGearCount)
	error("Method 'setInputLimits' not defined in implementing class")
end

---Transforms the generic gear group and gear inputs into a gear selection.
---@param groupInput number @The gear group which was selected.
---@param gearInput number @The gear input which was selected.
---@return number, number @The transformed group and gear to select in the vehicle. The group will be nil if the vehicle doesn't support groups.
function InputTransformationStrategy:transformGearInput(groupInput, gearInput)
	error("Method 'transformGearInput' not defined in implementing class")
	return 1, 1
end
