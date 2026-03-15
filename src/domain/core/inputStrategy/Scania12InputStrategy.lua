---Uses the Scania 12+2 transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The crawler gears won't be used, so the player can effectively select 12 forward and 2 reverse gears
---
---The shifting pattern is like this, where each position has a high and low splitter version, and a high and low range version,
---resulting in 4 possible gears per position.
---
---    N      N   5 H/L  (High Range)
---   RL/H    N   2 H/L  (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
---    N    4 H/L  6 H/L  (High Range)
---   C1/2  1 H/L  3 H/L  (Low Range)
--- ---
---The strategy will transform the input into 4 groups (LL, LH, HL, HH) with 3 forward gears each and 1 reverse gear each.
---Additionally, input will be transformed into a sequential number between2 (RH) and 12 (6H) for output strategies which need that.
---
---@class Scania12TransformationStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
Scania12TransformationStrategy = {}
local Scania12TransformationStrategy_mt = {
	__metatable = setmetatable(Scania12TransformationStrategy, {__index = InputTransformationStrategy}),
	__index = Scania12TransformationStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function Scania12TransformationStrategy.new()

	local self = setmetatable({}, Scania12TransformationStrategy_mt)
	self.maxEffectiveGear = 12
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function Scania12TransformationStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function Scania12TransformationStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function Scania12TransformationStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first (including unused slots)
	if shifterInputData.currentGroup > 4 or shifterInputData.currentGroup < 1 or shifterInputData.currentGearSlot > 6
		or shifterInputData.currentGearSlot == 2 or shifterInputData.currentGearSlot == 3
		or (shifterInputData.currentGroup > 2 and shifterInputData.currentGearSlot == 1) then

		return GearSelectionHint.new(0, 0, self.maxEffectiveGear, 0, 0)
	end

	local direction
	local effectiveGear
	local gearGroup
	local gearInGroup

	if shifterInputData.currentGearSlot == 1 then
		-- top left => low range = R1, R2. The group can't be >2 in this case (see top of method)
		direction = -1
		effectiveGear = shifterInputData.currentGroup
		gearGroup = 1
		gearInGroup = shifterInputData.currentGroup
	elseif shifterInputData.currentGearSlot > 3 and shifterInputData.currentGearSlot < 7 then
		-- Slots 4-6 in the gear shifter => Everything between 1L and 6H (12)
		direction = 1

		-- Gear within the group: Slot 4 = 1, Slot 5 = 2, Slot 6 = 3
		local gearWithinGroup = shifterInputData.currentGearSlot - 3

		-- For the effective gear, each slot represents two gears (low and high) within the same range
		-- Therefore we multiply the slot by 2, and remove 1 if it's the L version (in either low or high range)
		effectiveGear = gearWithinGroup * 2 - (shifterInputData.currentGroup % 2 == 0 and 0 or 1)
		-- add +6 if the range selector is in high range
		effectiveGear = effectiveGear + 6 * (shifterInputData.currentGroup > 2 and 1 or 0)

		gearGroup = shifterInputData.currentGroup
		gearInGroup = gearWithinGroup
	else
		-- Player has selected the neutral gear or an unsupported slot like the crawler/low gears or 7 and 8 if their shifter supports it.
		direction = 0
		effectiveGear = 0
		gearGroup = 1
		gearInGroup = 0
	end
	return GearSelectionHint.new(direction, effectiveGear, self.maxEffectiveGear, gearGroup, gearInGroup)
end

---Tells the caller whether this strategy supports Queueing up group changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function Scania12TransformationStrategy:supportsQueueingForGroups()
	-- For now, support queueing in all the strategies
	return true
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function Scania12TransformationStrategy:supportsQueueingForGears()
	return false
end