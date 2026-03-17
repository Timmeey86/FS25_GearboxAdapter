---Uses the ZF 16 speed transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The two low gears won't be used, so the player can effectively select 16 forward and 4 reverse gears
---
---The shifting pattern is like this, where each position has a high and low splitter version, and a high and low range version,
---resulting in 4 possible gears per position.
---
---    N    5 H/L  7 H/L  (High Range)
---    N    1 H/L  3 H/L  (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
---    N    6 H/L  8 H/L  (High Range)
---    R    2 H/L  4 H/L  (Low Range)
--- 
---This is very similar to the Eaton Fuller shifter pattern, except for the position and amount of the reverse gears.
---
---The strategy will transform the input into 4 groups (LL, LH, HL, HH) with 4 forward and 1 reverse gear each.
---Since the two Crawler gears (bottom left) are unuseable, this strategy can only actually produce 16 forward gears despite the name.
---Additionally, input will be transformed into a sequential number between -4 (RHH) and 16 (8H) for output strategies which need that.
---
---@class ZF16InputStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
ZF16InputStrategy = {}
-- Define a class-like subclass metatable without relying on the FS-specific Class() function
local ZF16InputStrategy_mt = {
	__metatable = setmetatable(ZF16InputStrategy, {__index = InputTransformationStrategy}),
	__index = ZF16InputStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function ZF16InputStrategy.new()

	local self = setmetatable({}, ZF16InputStrategy_mt)
	self.maxEffectiveGear = 16
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function ZF16InputStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function ZF16InputStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function ZF16InputStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first (including unused crawler gears)
	if shifterInputData.currentGroup > 4 or shifterInputData.currentGroup < 1 or shifterInputData.currentGearSlot > 6
		or shifterInputData.currentGearSlot == 1
		or (shifterInputData.currentGearSlot == 2 and shifterInputData.currentGroup > 2 ) then

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
	elseif shifterInputData.currentGearSlot > 2 and shifterInputData.currentGearSlot < 7 then
		-- Slots 3-6 in the gear shifter => Everything between 1L and 8H (16)
		direction = 1

		-- Gear within the group: Slot 3 = 1, Slot 4 = 2, Slot 5 = 3, Slot 6 = 4
		local gearWithinGroup = shifterInputData.currentGearSlot - 2

		-- For the effective gear, each slot represents two gears (low and high) within the same range
		-- Therefore we multiply the slot by 2, and remove 1 if it's the L version (in either low or high range)
		effectiveGear = gearWithinGroup * 2 - (shifterInputData.currentGroup % 2 == 0 and 0 or 1)
		-- add +8 if the range selector is in high range
		effectiveGear = effectiveGear + 8 * (shifterInputData.currentGroup > 2 and 1 or 0)

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
function ZF16InputStrategy:supportsQueueingForGroups()
	-- In Eaton Fuller transmissions, the splitter or range selector can be switched at any time, and only when pressing and releasing the clutch,
	-- the change will actually be performed.
	return true
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function ZF16InputStrategy:supportsQueueingForGears()
	return false
end