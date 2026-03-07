---This is a POD with what each input transformation strategy should calculate.
---@class GearSelectionData
---@field gearGroup number @The resulting gear group. 0 means no input.
---@field gearWithinGroup number @The resulting gear within gearGroup. 0 means neutral, negative means reverse.
---@field sequentialGear number @The resulting gear number if there were no gears. 0 means neutral, negative means reverse.
---@field maxSequentialGear number @The maximum possible gear which can be produced by the input transformation strategy, based on the player's controllers.
GearSelectionData = {}
local GearSelectionData_mt = Class(GearSelectionData)

---Constructor.
---@param gearGroup number @The resulting gear group. 0 means no input.
---@param gearWithinGroup number @The resulting gear within gearGroup. 0 means neutral, negative means reverse.
---@param sequentialGear number @The resulting gear number if there were no gears. 0 means neutral, negative means reverse.
---@param maxSequentialGear number @The maximum possible gear which can be produced by the input transformation strategy, based on the player's controllers.
---@return GearSelectionData @The transformed input data containing the resulting gear group, gear within group, and sequential gear.
function GearSelectionData.new(gearGroup, gearWithinGroup, sequentialGear, maxSequentialGear)
	local self = setmetatable({}, GearSelectionData_mt)
	self.gearGroup = gearGroup
	self.gearWithinGroup = gearWithinGroup
	self.sequentialGear = sequentialGear
	self.maxSequentialGear = maxSequentialGear
	return self
end