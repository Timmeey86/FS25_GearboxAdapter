---This POD stores the result of the calculation of which group and gear should be selected
---@class GearCalculationResult
---@field direction number @The direction the vehicle should move in, where 1 = forward, 0 = neutral, -1 = reverse
---@field group number @The gear group which should be selected (1 if the vehicle has none)
---@field gear number @The gear which should be selected within the gear group
GearCalculationResult = {}
local GearCalculationResult_mt = Class(GearCalculationResult)

---Creates a new instance of the GearCalculationResult class
---@param direction number The direction the vehicle should move in, where 1 = forward, 0 = neutral, -1 = reverse
---@param group number|nil The gear group which should be selected (nil if it should not be changed)
---@param gear number The gear which should be selected within the gear group
---@return GearCalculationResult
function GearCalculationResult.new(direction, group, gear)
	local self = setmetatable({}, GearCalculationResult_mt)
	self.direction = direction
	self.group = group
	self.gear = gear
	return self
end