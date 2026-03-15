---Uses the Volvo 12+2 transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The crawler gears won't be used, so the player can effectively select 12 forward and 2 reverse gears
---
---The shifting pattern is like this, where each position has a high and low splitter version, and a high and low range version,
---resulting in 4 possible gears per position.
---
---    N    4 H/L  6 H/L  (High Range)
---   C1/2  1 H/L  3 H/L  (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
--- RHL/RHH 5 H/L    N  (High Range)
--- RLL/RLH 2 H/L    N  (Low Range)
--- ---
---The strategy will transform the input into 4 groups (LL, LH, HL, HH) with 3 forward gears each and 1 reverse gear each.
---Additionally, input will be transformed into a sequential number between2 (RH) and 12 (6H) for output strategies which need that.
---
---@class Volvo12TransformationStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
Volvo12TransformationStrategy = {}
local Volvo12TransformationStrategy_mt = {
	__metatable = setmetatable(Volvo12TransformationStrategy, {__index = InputTransformationStrategy}),
	__index = Volvo12TransformationStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function Volvo12TransformationStrategy.new()

	local self = setmetatable({}, Volvo12TransformationStrategy_mt)
	self.maxEffectiveGear = 12
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function Volvo12TransformationStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function Volvo12TransformationStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function Volvo12TransformationStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first (including unused slots)
	if shifterInputData.currentGroup > 4 or shifterInputData.currentGroup < 1 or shifterInputData.currentGearSlot == 1 or shifterInputData.currentGearSlot >= 6 then
		return GearSelectionHint.new(0, 0, self.maxEffectiveGear, 0, 0)
	end

	local direction
	local effectiveGear
	local gearGroup
	local gearInGroup

	if shifterInputData.currentGearSlot == 2 then
		-- bottom left => reverse, one gear per group, and four groups, so the group equals the effective gear
		-- we map that to one group with four gears, however
		direction = -1
		effectiveGear = shifterInputData.currentGroup
		gearGroup = 1
		gearInGroup = shifterInputData.currentGroup
	elseif shifterInputData.currentGearSlot > 2 and shifterInputData.currentGearSlot < 6 then
		-- Slots 3-5 in the gear shifter => Everything between 1L and 6H (12)
		direction = 1

		-- Gear within the group: Slot 3 = 1, Slot 4 = 2, Slot 5 = 3
		local gearWithinGroup = shifterInputData.currentGearSlot - 2

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
function Volvo12TransformationStrategy:supportsQueueingForGroups()
	-- In Eaton Fuller transmissions, the splitter or range selector can be switched at any time, and only when pressing and releasing the clutch,
	-- the change will actually be performed.
	return true
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function Volvo12TransformationStrategy:supportsQueueingForGears()
	return false
end