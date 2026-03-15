---Uses the Eaton Fuller 10 speed transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The splitter won't be used, but the range selector will be.
---
---The shifting pattern is like this, where each position has a high and low range version,
---resulting in 2 possible gears per position.
---
---   RH      7      9  (High Range)
---   RL      2      4  (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
---    6      8     10  (High Range)
---    1      3      5  (Low Range)
--- 
---
---The strategy will transform the input into 2 groups (L, H) with 5 forward and 1 reverse gears each.
---Additionally, input will be transformed into a sequential number between -2 (RH) and 10 for output strategies which need that.
---
---@class EatonFuller10InputStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
EatonFuller10InputStrategy = {}
local EatonFuller10InputStrategy_mt = {
	__metatable = setmetatable(EatonFuller10InputStrategy, {__index = InputTransformationStrategy}),
	__index = EatonFuller10InputStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function EatonFuller10InputStrategy.new()

	local self = setmetatable({}, EatonFuller10InputStrategy_mt)
	self.maxEffectiveGear = 10
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function EatonFuller10InputStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function EatonFuller10InputStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function EatonFuller10InputStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first
	if shifterInputData.currentGroup > 4 or shifterInputData.currentGroup < 1 or shifterInputData.currentGearSlot > 6 then
		return GearSelectionHint.new(0, 0, self.maxEffectiveGear, 0, 0)
	end

	local direction
	local effectiveGear
	local gearGroup
	local gearInGroup

	local gearGroupIgnoringSplitter = (shifterInputData.currentGroup - 1) // 2 + 1

	if shifterInputData.currentGearSlot == 1 then
		-- top left => reverse, only the range matters, not the splitter
		direction = -1
		effectiveGear = gearGroupIgnoringSplitter
		gearGroup = 1
		gearInGroup = effectiveGear
	elseif shifterInputData.currentGearSlot > 1 and shifterInputData.currentGearSlot < 7 then
		-- Slots 2-6 in the gear shifter => Everything between 1-5 in low range and 6-10 in high range
		direction = 1

		-- Gear within the group: Slot 2 = 1, Slot 3 = 2, Slot 4 = 3, Slot 5 = 4, Slot 6 = 5
		local gearWithinGroup = shifterInputData.currentGearSlot - 1

		-- For the effective gear, each slot represents only one gear within the same range
		-- Therefore we use the gear number (starting from slot 2) and add 5 if in high range
		effectiveGear = gearWithinGroup + (shifterInputData.currentGroup > 2 and 5 or 0)

		gearGroup = gearGroupIgnoringSplitter
		gearInGroup = gearWithinGroup
	else
		-- neutral gear
		direction = 0
		effectiveGear = 0
		gearGroup = 1
		gearInGroup = 0
	end
	return GearSelectionHint.new(direction, effectiveGear, self.maxEffectiveGear, gearGroup, gearInGroup)
end

---Tells the caller whether this strategy supports Queueing up group changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function EatonFuller10InputStrategy:supportsQueueingForGroups()
	-- In Eaton Fuller transmissions, the splitter or range selector can be switched at any time, and only when pressing and releasing the clutch,
	-- the change will actually be performed.
	return true
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function EatonFuller10InputStrategy:supportsQueueingForGears()
	return false
end