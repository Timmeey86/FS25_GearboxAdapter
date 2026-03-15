---Uses the ZF12 transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The player can effectively select 12 forward and 1 reverse gear
---
---The shifting pattern is like this, where each of the three forward positions has a high and low splitter version, and a high and low 
---range version, resulting in 4 possible gears per position.
---
---    N    4 H/L  5 H/L  (High Range)
---    N    1 H/L  2 H/L  (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
---    N      N    6 H/L (High Range)
---    R      N    5 H/L (Low Range)
---
---The strategy will transform the input into 4 groups (LL, LH, HL, HH) with 3 forward gears each and 1 reverse gear in total
---Additionally, input will be transformed into a sequential number between -1 (R) and 12 (6H) for output strategies which need that.
---
---@class ZF12InputStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
ZF12InputStrategy = {}
local ZF12InputStrategy_mt = {
	__metatable = setmetatable(ZF12InputStrategy, {__index = InputTransformationStrategy}),
	__index = ZF12InputStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function ZF12InputStrategy.new()

	local self = setmetatable({}, ZF12InputStrategy_mt)
	self.maxEffectiveGear = 12
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function ZF12InputStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function ZF12InputStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function ZF12InputStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first (including unused slots)
	if shifterInputData.currentGroup > 4 or shifterInputData.currentGroup < 1 
		or shifterInputData.currentGearSlot == 1
		or shifterInputData.currentGearSlot == 4
		or (shifterInputData.currentGearSlot == 2 and shifterInputData.currentGroup > 2)
		or shifterInputData.currentGearSlot > 6 then

		return GearSelectionHint.new(0, 0, self.maxEffectiveGear, 0, 0)
	end

	local direction
	local effectiveGear
	local gearGroup
	local gearInGroup

	if shifterInputData.currentGearSlot == 2 then
		-- bottom left => one reverse gear in the low range. The high range has already been handled above
		direction = -1
		effectiveGear = 1
		gearGroup = 1
		gearInGroup = 1
	elseif shifterInputData.currentGearSlot == 3 or shifterInputData.currentGearSlot == 5 or shifterInputData.currentGearSlot == 6 then
		-- Slots 3, 5 and 6 in the gear shifter => Everything between 1L and 6H (12)
		direction = 1

		-- Gear within the group: Slot 3 = 1, Slot 5 = 2, Slot 6 = 3
		local gearWithinGroup = shifterInputData.currentGearSlot == 3 and 1 or (shifterInputData.currentGearSlot == 5 and 2 or 3)

		-- For the effective gear, each slot represents two gears (low and high) within the same range
		-- Therefore we multiply the gear slot (skipping empty slots) by 2, and remove 1 if it's the L version (in either low or high range)
		effectiveGear = gearWithinGroup * 2 - (shifterInputData.currentGroup % 2 == 0 and 0 or 1)
		-- add +6 if the range selector is in high range
		effectiveGear = effectiveGear + 6 * (shifterInputData.currentGroup > 2 and 1 or 0)

		gearGroup = shifterInputData.currentGroup
		gearInGroup = gearWithinGroup
	else
		-- Player has selected the neutral gear
		direction = 0
		effectiveGear = 0
		gearGroup = 1
		gearInGroup = 0
	end
	return GearSelectionHint.new(direction, effectiveGear, self.maxEffectiveGear, gearGroup, gearInGroup)
end

---Tells the caller whether this strategy supports Queueing up group changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function ZF12InputStrategy:supportsQueueingForGroups()
	-- For now, support queueing in all the strategies
	return true
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function ZF12InputStrategy:supportsQueueingForGears()
	return false
end