---This POD contains hints about the virtual gear which should be transformed into actual gears and gear groups.
---@class GearSelectionHint
---@field direction number @1 = forward, 0 = neutral, -1 = reverse
---@field gear number @The virtual gear number. Always positive, so direction -1 and gear 3 means the R3 gear.
---@field maxNumGears number @The maximum number of gears which could be produced by the strategy which created this hint. 
---                          This can be used for stretching a smaller input range to a larger vehicle gear range, if needed.
GearSelectionHint = {}
local GearSelectionHint_mt = Class(GearSelectionHint)

---Creates a new instance of the GearSelectionHint class
---@param direction number 1 = forward, 0 = neutral, -1 = reverse
---@param gear number The virtual gear number. Always positive, so direction -1 and gear 3 means the R3 gear.
---@param maxNumGears number The maximum number of gears which could be produced by the strategy which created this hint.
---@return GearSelectionHint
function GearSelectionHint.new(direction, gear, maxNumGears)
	local self = setmetatable({}, GearSelectionHint_mt)

	if direction == nil then
		error("Direction cannot be nil")
		printCallstack()
	end
	if gear == nil then
		error("Gear cannot be nil")
		printCallstack()
	end
	if maxNumGears == nil then
		error("MaxNumGears cannot be nil")
		printCallstack()
	end
	
	self.direction = direction
	self.gear = gear
	self.maxNumGears = maxNumGears
	return self
end