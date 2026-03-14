---This POD contains hints about the virtual gear which should be transformed into actual gears and gear groups.
---@class GearSelectionHint
---@field direction number @1 = forward, 0 = neutral, -1 = reverse
---@field effectiveGear number @The virtual gear number. Always positive, so direction -1 and gear 3 means the R3 gear.
---@field maxNumGears number @The maximum number of gears which could be produced by the strategy which created this hint. 
---                          This can be used for stretching a smaller input range to a larger vehicle gear range, if needed.
---@field gearGroup number|nil @The gear group to be selected when not using the effective gear (some strategies might need that instead).
---@field gearInGroup number|nil @The gear within the gear group to be selected when not using the effective gear (some strategies might need that instead).
GearSelectionHint = {}

---Creates a new instance of the GearSelectionHint class
---@param direction number 1 = forward, 0 = neutral, -1 = reverse
---@param effectiveGear number The virtual gear number. Always positive, so direction -1 and gear 3 means the R3 gear.
---@param maxNumGears number The maximum number of gears which could be produced by the strategy which created this hint.
---@param gearGroup number|nil The gear group to be selected when not using the effective gear (some strategies might need that instead).
---@param gearInGroup number|nil The gear within the gear group to be selected when not using the effective gear (some strategies might need that instead).
---@return GearSelectionHint
function GearSelectionHint.new(direction, effectiveGear, maxNumGears, gearGroup, gearInGroup)
	local self = setmetatable({}, {__index = GearSelectionHint})

	if direction == nil then
		error("Direction cannot be nil")
		printCallstack()
	end
	if effectiveGear == nil then
		error("EffectiveGear cannot be nil")
		printCallstack()
	end
	if maxNumGears == nil then
		error("MaxNumGears cannot be nil")
		printCallstack()
	end


	self.direction = direction
	self.effectiveGear = effectiveGear
	self.maxNumGears = maxNumGears
	self.gearGroup = gearGroup
	self.gearInGroup = gearInGroup
	return self
end