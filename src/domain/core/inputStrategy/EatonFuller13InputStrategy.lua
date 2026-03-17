---Uses the Eaton Fuller 13 speed transmission as a basis for the player's shifting pattern.
---This strategy assumes they have a 6-gear H shifter with a truck shifting knob which offers a splitter and a range selector.
---The splitter will only be used within the high range.
---
---The shifting pattern is like this
---
---   RH    5L/H   7L/H  (High Range)
---   RL      1      3   (Low Range)
---    |      |      |
---    |------N------|
---    |      |      |
---    L    6L/H   8L/H  (High Range)
---    N      2      4   (Low Range)
--- 
--- Note that the L gear is not supported
---
---The strategy will transform the input into 3 forward groups (L, LH, HH) with 4 forward gears each and one reverse group with two gears.
---Since the L gear is unuseable, this strategy can only actually produce 12 forward gears despite the name.
---Additionally, input will be transformed into a sequential number between -2 (RH) and 12 for output strategies which need that.
---
---@class EatonFuller13InputStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
EatonFuller13InputStrategy = {}
-- Define a class-like subclass metatable without relying on the FS-specific Class() function
local EatonFuller13InputStrategy_mt = {
	__metatable = setmetatable(EatonFuller13InputStrategy, {__index = InputTransformationStrategy}),
	__index = EatonFuller13InputStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function EatonFuller13InputStrategy.new()

	local self = setmetatable({}, EatonFuller13InputStrategy_mt)
	self.maxEffectiveGear = 13
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function EatonFuller13InputStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function EatonFuller13InputStrategy:setInputControllerInfo(inputControllerInfo)
	-- Not required for this strategy
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function EatonFuller13InputStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first
	if shifterInputData.currentGroup > 4 or shifterInputData.currentGroup < 1 or shifterInputData.currentGearSlot > 6 or shifterInputData.currentGearSlot == 2 then
		return GearSelectionHint.new(0, 0, self.maxEffectiveGear, 0, 0)
	end

	local direction
	local effectiveGear
	local gearGroup
	local gearInGroup

	if shifterInputData.currentGearSlot == 1 then
		-- top left => reverse, only the range matters, not the splitter
		direction = -1
		effectiveGear = (shifterInputData.currentGroup > 2 and 2 or 1)
		gearGroup = 1
		gearInGroup = effectiveGear
	elseif shifterInputData.currentGearSlot > 2 and shifterInputData.currentGearSlot < 7 then
		-- Slots 3-6 in the gear shifter => 1-4 in the low range, 5L-8H in the high range (respecting the splitter)

		if shifterInputData.currentGroup < 3 then
			-- low range
			effectiveGear = shifterInputData.currentGearSlot - 2
			gearGroup = 1
			gearInGroup = effectiveGear
		else
			-- high range
			-- Get the gear number starting from slot 3 = 1
			local gearWithinGroup = shifterInputData.currentGearSlot - 2
			-- Multiply by 2 and subtract -1 if the splitter is on the low setting
			local highRangePart = gearWithinGroup * 2 - (shifterInputData.currentGroup == 3 and 1 or 0)
			-- Add 4 since the high range starts at 5 rather than 1
			effectiveGear = highRangePart + 4

			gearGroup = shifterInputData.currentGroup - 1 -- 2 for low splitter, high range, and 3 for high splitter, high range
			gearInGroup = gearWithinGroup
		end
		direction = 1
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
function EatonFuller13InputStrategy:supportsQueueingForGroups()
	-- In Eaton Fuller transmissions, the splitter or range selector can be switched at any time, and only when pressing and releasing the clutch,
	-- the change will actually be performed.
	return true
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function EatonFuller13InputStrategy:supportsQueueingForGears()
	return false
end