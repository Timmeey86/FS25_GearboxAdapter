---Uses the Eaton Fuller 18 speed transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The two low gears won't be used, so the player can effectively select 16 forward and 4 reverse gears
---
---The shifting pattern is like this, where each position has a high and low splitter version, and a high and low range version,
---resulting in 4 possible gears per position.
---
--- R2 H/L  5 H/L  7 H/L  (High Range)
--- R1 H/L  1 H/L  3 H/L  (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
---    X    6 H/L  8 H/L  (High Range)
---    X    2 H/L  4 H/L  (Low Range)
--- 
---This is very similar to the ZF16 shifter pattern, except for the position and amount of the reverse gears.
---
---The strategy will transform the input into 4 groups (LL, LH, HL, HH) with 4 forward and 1 reverse gear each.
---Additionally, input will be transformed into a sequential number between -4 (RHH) and 16 (8H) for output strategies which need that.
---
---@class EatonFuller18TransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
EatonFuller18TransformationStrategy = {}
local EatonFuller18TransformationStrategy_mt = Class(EatonFuller18TransformationStrategy, InputTransformationStrategy)

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function EatonFuller18TransformationStrategy.new()
	local self = setmetatable({}, EatonFuller18TransformationStrategy_mt)
	self.maxEffectiveGear = 16
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function EatonFuller18TransformationStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function EatonFuller18TransformationStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function EatonFuller18TransformationStrategy:calculateEffectiveGear(shifterInputData)
	local direction
	local effectiveGear
	if shifterInputData.currentGearSlot == 1 then
		-- top left => reverse, one gear per group, and four groups, so the group equals the effective gear
		direction = -1
		effectiveGear = shifterInputData.currentGroup
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
	else
		-- Player has selected the neutral gear or an unsupported slot like the crawler/low gears or 7 and 8 if their shifter supports it.
		direction = 0
		effectiveGear = 0
	end
	return GearSelectionHint.new(direction, effectiveGear, self.maxEffectiveGear)
end

---Tells the caller whether this strategy supports queuing up group changes until the clutch is pressed
---@return boolean @True if the strategy supports queuing in general.
function EatonFuller18TransformationStrategy:supportsQueuingForGroups()
	-- In Eaton Fuller transmissions, the splitter or range selector can be switched at any time, and only when pressing and releasing the clutch,
	-- the change will actually be performed.
	return true
end

---Tells the caller whether this strategy supports queuing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports queuing in general.
function EatonFuller18TransformationStrategy:supportsQueuingForGears()
	return false
end