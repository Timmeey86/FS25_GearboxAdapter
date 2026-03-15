--- This strategy simply uses the input groups and gears 1:1, including the reverse gear
--- It also calculates an effective gear based on the number of gears and groups the player can input
---
--- This is basically like base game with the addition of detecting the neutral gear. The player may however still use any output strategy of choice.
---
---@class GearsAndGroupsInputStrategy : InputTransformationStrategy
---@field maxEffectiveGear number @The highest possible number this strategy could produce
---@field numGroups number @The number of groups the player's controller supports.
---@field numGears number @The number of gears slots the player's controller supports.
GearsAndGroupsInputStrategy = {}
local GearsAndGroupsInputStrategy_mt = {
	__metatable = setmetatable(GearsAndGroupsInputStrategy, {__index = InputTransformationStrategy}),
	__index = GearsAndGroupsInputStrategy
}

---Constructor. When creating an object, make sure to connect it with clutch event handlers
---@return InputTransformationStrategy @The public interface of the class
function GearsAndGroupsInputStrategy.new()

	local self = setmetatable({}, GearsAndGroupsInputStrategy_mt)
	self.maxEffectiveGear = 24
	self.numGroups = 0
	self.numGears = 0
	return self
end

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function GearsAndGroupsInputStrategy:setGearboxInfo(vehicleGearboxInfo)
	-- Not required for this strategy
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function GearsAndGroupsInputStrategy:setInputControllerInfo(inputControllerInfo)
	if inputControllerInfo ~= nil then
		self.numGears = inputControllerInfo.maxGears
		self.numGroups = inputControllerInfo.maxGroups
		self.maxEffectiveGear = self.numGears * self.numGroups
	else
		self.numGears = 6
		self.numGroups = 4
		self.maxEffectiveGear = 24
	end
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function GearsAndGroupsInputStrategy:calculateEffectiveGear(shifterInputData)

	-- Handle invalid data first (including unused slots)
	if shifterInputData.currentGroup > self.numGroups or shifterInputData.currentGearSlot > self.numGears or shifterInputData.currentGroup == 0 then
		return GearSelectionHint.new(0, 0, self.maxEffectiveGear, 0, 0)
	end

	local direction
	local effectiveGear
	local gearGroup
	local gearInGroup

	if shifterInputData.currentGearSlot == -1 then
		-- reverse gear: ignore the group
		direction = -1
		effectiveGear = 1
		gearGroup = 1
		gearInGroup = 1
	elseif shifterInputData.currentGearSlot == 0 then
		-- neutral gear
		direction = 0
		effectiveGear = 0
		gearGroup = 1
		gearInGroup = 0
	else
		-- normal gears: Map 1:1
		direction = 1
		gearGroup = shifterInputData.currentGroup
		gearInGroup = shifterInputData.currentGearSlot
		effectiveGear = (gearGroup - 1) * self.numGears + gearInGroup
	end

	return GearSelectionHint.new(direction, effectiveGear, self.maxEffectiveGear, gearGroup, gearInGroup)
end

---Tells the caller whether this strategy supports Queueing up group changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function GearsAndGroupsInputStrategy:supportsQueueingForGroups()
	-- No queueing support for simple shifting
	return false
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function GearsAndGroupsInputStrategy:supportsQueueingForGears()
	-- No queueing support for simple shifting
	return false
end