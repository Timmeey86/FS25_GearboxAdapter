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
---@field pendingGroup number|nil @Non-nil while the player has activated the splitter or range selector, but hasn't pressed and released the clutch yet.
---@field pendingGear number|nil @The gear which should be selected once the player has released the clutch.
---@field clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
---@field forwardToOutputStrategyFunc function @A function which forwards the calculated gear selection data to the output strategy.
---@field currentGroup number @The currently selected input group.
---@field currentGear number @The currently selected input gear.
---@field maxSequentialGear number @The highest possible number this strategy could produce
EatonFuller18TransformationStrategy = {}
local EatonFuller18TransformationStrategy_mt = Class(EatonFuller18TransformationStrategy, InputTransformationStrategy)

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@param clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
---@param forwardToOutputStrategyFunc function @A function which forwards the calculated gear selection data to the output strategy
---@return InputTransformationStrategy @The public interface of the class
function EatonFuller18TransformationStrategy.new(clutchEnabledFunc, forwardToOutputStrategyFunc)
	local self = setmetatable({}, EatonFuller18TransformationStrategy_mt)
	self.pendingGroup = nil
	self.pendingGear = nil
	self.clutchEnabledFunc = clutchEnabledFunc
	self.forwardToOutputStrategyFunc = forwardToOutputStrategyFunc
	self.currentGroup = 1
	self.currentGear = 1
	self.maxSequentialGear = 16
	return self
end

---Tells the strategy that the clutch was pressed or released.
---@param isPressed boolean @True if the clutch is pressed, false otherwise.
function EatonFuller18TransformationStrategy:setClutchPressed(isPressed)
	if not self.clutchEnabledFunc() then
		return
	end

	if (self.pendingGroup ~= nil or self.pendingGear ~= nil) and not isPressed then
		-- The player has activated the splitter or range selector, and released the clutch afterwards.
		-- => Change the gear now
		local newGroup = self.pendingGroup or self.currentGroup
		local newGear = self.pendingGear or self.currentGear
		self.forwardToOutputStrategyFunc(self:transformGearInput(newGroup, newGear))
	end
end

---Sets the number of gear groups and gears the player can select with their controller.
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
---@param totalGearCount number @The total number of gears the player can select with their controller. Usually maxGroups * maxGears.
function EatonFuller18TransformationStrategy:setInputLimits(maxGroups, maxGears, totalGearCount)
	-- ignore, eaton fuller 18 only works with two switches (4 groups) and 6 gears
end

---Sets the given gear group active.
---@param newGroup number @The group which was selected by the input controller
function EatonFuller18TransformationStrategy:changeGearGroup(newGroup)
	if self.clutchEnabledFunc() then
		-- Delay group changes until the clutch is released (even if changed before the clutch was pressed)
		self.pendingGroup = newGroup
	else
		-- Apply instantly
		self.forwardToOutputStrategyFunc(self:transformGearInput(newGroup, self.currentGear))
	end
end

---Sets the given gear active.
function EatonFuller18TransformationStrategy:changeGear(newGear)
	if self.clutchEnabledFunc() then
		-- Delay gear changes until the clutch is released (even if changed before the clutch was pressed)
		self.pendingGear = newGear
	else
		-- Apply instantly
		self.forwardToOutputStrategyFunc(self:transformGearInput(self.currentGroup, newGear or 0))
	end
end

---Transforms the generic gear group and gear inputs into a gear selection.
---@param inputGroup number @The gear group which was selected by the input controller
---@param inputGear number @The gear which was selected by the input controller
---@return GearSelectionData @The transformed group and gear to select in the vehicle.
function EatonFuller18TransformationStrategy:transformGearInput(inputGroup, inputGear)
	self.currentGroup = inputGroup
	self.currentGear = inputGear

	local calculatedGearGroup = self.currentGroup -- the group is currently already calculated by the AutoHotkey script

	local calculatedGear
	local calculatedSequentialGear
	if self.currentGear == 1 then
		-- top left => reverse gears.
		calculatedGear = -1
		calculatedSequentialGear = calculatedGearGroup and -calculatedGearGroup or -1
	elseif self.currentGear > 2 and self.currentGear < 7 then
		-- Slots 3-6 in the gear shifter => Everything between 1L and 8H (16)

		-- Gear within the group: Slot 3 = 1, Slot 4 = 2, Slot 5 = 3, Slot 6 = 4
		calculatedGear = self.currentGear - 2

		-- For the sequential gear, each slot represents two gears (low and high) within the same range
		-- Therefore we multiply the slot by 2, and remove 1 if it's the L version (in either low or high range)
		calculatedSequentialGear = calculatedGear * 2 - (self.currentGroup % 2 == 0 and 0 or 1)
		-- add +8 if the range selector is in high range
		calculatedSequentialGear = calculatedSequentialGear + 8 * (self.currentGroup > 2 and 1 or 0)
	else
		-- Player has selected the neutral gear or an unsupported slot like the crawler/low gears or 7 and 8 if their shifter supports it.
		calculatedGear = 0
		calculatedSequentialGear = 0
	end

	Logging.info("Input: Transformed (%d, %d) -> (%d, %d, %d)", self.currentGroup, self.currentGear, calculatedGearGroup, calculatedGear, calculatedSequentialGear)

	return GearSelectionData.new(calculatedGearGroup, calculatedGear, calculatedSequentialGear, self.maxSequentialGear)
end