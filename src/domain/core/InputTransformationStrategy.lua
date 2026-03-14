---An internal interface for interpreting controller inputs based on the player's choice.
---Note that this isn't really an interface with type checks or similar, but it helps with maintaining a clean architecture and separation of concerns.
---@class InputTransformationStrategy
InputTransformationStrategy = {}

---Lets the strategy know details about the current vehicle
---@param vehicleGearboxInfo VehicleGearboxInfo|nil @information about the vehicle's gearbox or nil if no vehicle
function InputTransformationStrategy:setGearboxInfo(vehicleGearboxInfo)
	error("Method 'setGearboxInfo' not defined in implementing class")
	-- Note: If you don't need this in the implementation, define the method anyway, but leave it empty.
end

---Lets the strategy know details about the input controller the player is using
---@param inputControllerInfo InputControllerInfo|nil @information about the player's input controller(s)
function InputTransformationStrategy:setInputControllerInfo(inputControllerInfo)
	error("Method 'setInputControllerInfo' not defined in implementing class")
	-- Note: If you don't need this in the implementation, define the method anyway, but leave it empty.
end

---Calculates the effective gear based on the player's controller input, where 0 = neutral, <0 = reverse and >0 = forward
---@param shifterInputData ShifterInputData @The current state of the player's controller input.
---@return GearSelectionHint @Hints about which gear to be selected. This will be transformed again by the output strategy.
function InputTransformationStrategy:calculateEffectiveGear(shifterInputData)
	error("Method 'calculateEffectiveGear' not defined in implementing class")
	return GearSelectionHint.new(0, 0, 0)
end

---Tells the caller whether this strategy supports Queueing up group changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function InputTransformationStrategy:supportsQueueingForGroups()
	error("Method 'supportsQueueingForGroups' not defined in implementing class")
	return false
end

---Tells the caller whether this strategy supports Queueing up gear changes until the clutch is pressed
---@return boolean @True if the strategy supports Queueing in general.
function InputTransformationStrategy:supportsQueueingForGears()
	error("Method 'supportsQueueingForGears' not defined in implementing class")
	return false
end