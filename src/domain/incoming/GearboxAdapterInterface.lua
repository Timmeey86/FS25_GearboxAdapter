---This is the public interface of the domain core
---@class GearboxAdapterInterface
GearboxAdapterInterface = {
	INPUT_STRATEGY = {
		EATON_FULLER_18 = "eatonFuller18",
		EATON_FULLER_13 = "eatonFuller13"
	},
	OUTPUT_STRATEGY = {
		SEQUENTIAL = "sequential"
	}
}

---Sets the input transformation strategy to be used.
---@param strategy string the identifier of the strategy to be used.
function GearboxAdapterInterface:setInputTransformationStrategy(strategy)
	error("Method 'setInputTransformationStrategy' not defined in implementing class")
end

---Sets the output transformation strategy to be used.
---@param strategy string the identifier of the strategy to be used.
function GearboxAdapterInterface:setOutputTransformationStrategy(strategy)
	error("Method 'setOutputTransformationStrategy' not defined in implementing class")
end

---Forwards information about the current vehicle to the domain core
---@param vehicleGearboxInfo VehicleGearboxInfo|nil information about the vehicle's gearbox or nil if no vehicle
function GearboxAdapterInterface:setGearboxInfo(vehicleGearboxInfo)
	error("Method 'setGearboxInfo' not defined in implementing class")
end

---Tells the domain core what kind of input controller the player is using
---@param inputControllerInfo InputControllerInfo @information about the player's input controller(s)
function GearboxAdapterInterface:setInputControllerInfo(inputControllerInfo)
	error("Method 'setInputControllerInfo' not defined in implementing class")
end

---Ask the domain core to process a change in the gear group input. Dependent on the transformation strategy, this may or may not result in this very gear group being selected in the vehicle.
---@param group number @The new gear group number
function GearboxAdapterInterface:setGearGroupInput(group)
	error("Method 'setGearGroupInput' not defined in implementing class")
end

---Ask the domain core to process a change in the gear input. Dependent on the transformation strategy, this may or may not result in this very gear being selected in the vehicle.
---@param gear number @The new gear number
function GearboxAdapterInterface:setGearInput(gear)
	error("Method 'setGearInput' not defined in implementing class")
end

---Call this function when the clutch state changes
---@param inputValue number @The clutch's input value (0..1, where 1 = pressed)
function GearboxAdapterInterface:setClutchState(inputValue)
	error("Method 'setClutchState' not defined in implementing class")
end