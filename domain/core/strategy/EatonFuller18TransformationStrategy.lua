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
--- This is very similar to the ZF16 shifter pattern, except for the position and amount of the reverse gears.
--- 
--- When driving various vehicles with this fixed input strategy, mapping will be performed as follows:
--- We will reference the 1/5 position as position 1, 2/6 as position 2 and so on.
---
---Example 1: Vehicle has 16 gears:
---		=== Low Range ===
---		Position 1, Low  Splitter -> Output Gear  1 (= 1L)
---		Position 1, High Splitter -> Output Gear  2 (= 1H)
---		Position 2, Low  Splitter -> Output Gear  3 (= 2L)
---		Position 2, High Splitter -> Output Gear  4 (= 2H)
---		Position 3, Low  Splitter -> Output Gear  5 (= 3L)
---		Position 3, High Splitter -> Output Gear  6 (= 3H)
---		Position 4, Low  Splitter -> Output Gear  7 (= 4L)
---		Position 4, High Splitter -> Output Gear  8 (= 4H)
---		=== High Range ===
---		Position 1, Low  Splitter -> Output Gear  9 (= 5L)
---		Position 1, High Splitter -> Output Gear 10 (= 5H)
---		Position 2, Low  Splitter -> Output Gear 11 (= 6L)
---		Position 2, High Splitter -> Output Gear 12 (= 6H)
---		Position 3, Low  Splitter -> Output Gear 13 (= 7L)
---		Position 3, High Splitter -> Output Gear 14 (= 7H)
---		Position 4, Low  Splitter -> Output Gear 15 (= 8L)
---		Position 4, High Splitter -> Output Gear 16 (= 8H)
---
---Example 1: Vehicle has 3 groups with 4 gears each:
---		=== Low Range ===
---		Position 1, Low  Splitter -> Output Group 1, Gear 1
---		Position 1, High Splitter -> Output Group 1, Gear 2
---		Position 2, Low  Splitter -> Output Group 1, Gear 3
---		Position 2, High Splitter -> Output Group 1, Gear 4
---		Position 3, Low  Splitter -> Output Group 2, Gear 1
---		Position 3, High Splitter -> Output Group 2, Gear 2
---		Position 4, Low  Splitter -> Output Group 2, Gear 3
---		Position 4, High Splitter -> Output Group 2, Gear 4
---		=== High Range ===
---		Position 1, Low  Splitter -> Output Group 3, Gear 1
---		Position 1, High Splitter -> Output Group 3, Gear 2
---		Position 2, Low  Splitter -> Output Group 3, Gear 3
---		Position 2, High Splitter -> Output Group 3, Gear 4
---		Position 3, Low  Splitter -> Output Group 3, Gear 4
---		Position 3, High Splitter -> Output Group 3, Gear 4
---		Position 4, Low  Splitter -> Output Group 3, Gear 4
---		Position 4, High Splitter -> Output Group 3, Gear 4
---
---@class EatonFuller18TransformationStrategy
---@field vehicleGroupCount number @The number of gear groups the current vehicle has
---@field vehicleGearCount number @The number of gears per gear group the current vehicle has
---@field totalVehicleGears number @The total number of gears the current vehicle has, calculated from the above two parameters
---@field pendingGroup number|nil @Non-nil while the player has activated the splitter or range selector, but hasn't pressed and released the clutch yet.
---@field clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
EatonFuller18TransformationStrategy = {}
local EatonFuller18TransformationStrategy_mt = Class(EatonFuller18TransformationStrategy, InputTransformationStrategy)

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@param clutchEnabledFunc function @A function which checks whether the clutch is enabled in the settings.
---@return InputTransformationStrategy @The public interface of the class
function EatonFuller18TransformationStrategy.new(clutchEnabledFunc)
	local self = setmetatable({}, EatonFuller18TransformationStrategy_mt)
	self.vehicleGroupCount = nil
	self.vehicleGearCount = nil
	self.totalVehicleGears = nil
	self.pendingGroup = nil
	self.clutchEnabledFunc = clutchEnabledFunc
	return self
end

---Tells the strategy that the clutch was pressed or released.
---@param isPressed boolean @True if the clutch is pressed, false otherwise.
function EatonFuller18TransformationStrategy:setClutchPressed(isPressed)
	if not self.clutchEnabledFunc() then
		return
	end

	Logging.info("Clutch state: %s", isPressed)
end

---Registers a new vehicle gear/group layout to be processed from now on
---@param groupCount number @The number of gear groups in the vehicle.
---@param gearCount number @The number of gears per group in the vehicle.
---@param totalGearCount number @The total number of gears in the vehicle. Usually maxGroups * maxGears, but might be lower if e.g. some vehicle has less gears in the last group or something.
function EatonFuller18TransformationStrategy:changeVehicle(groupCount, gearCount,  totalGearCount)
	self.vehicleGroupCount = groupCount
	self.vehicleGearCount = gearCount
	self.totalVehicleGears = totalGearCount
end

---Sets the number of gear groups and gears the player can select with their controller.
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
---@param totalGearCount number @The total number of gears the player can select with their controller. Usually maxGroups * maxGears.
function EatonFuller18TransformationStrategy:setInputLimits(maxGroups, maxGears, totalGearCount)
	-- ignore, eaton fuller 18 only really works with two switches (4 groups) and 6 gears
end

---Transforms the generic gear group and gear inputs into a gear selection.
---@param groupInput number @The gear group which was selected.
---@param gearInput number @The gear input which was selected.
---@return number, number @The transformed group and gear to select in the vehicle. The group will be nil if the vehicle doesn't support groups.
function EatonFuller18TransformationStrategy:transformGearInput(groupInput, gearInput)
	return 1,1
end