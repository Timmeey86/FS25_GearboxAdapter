---This is the public interface of the domain core
---@class GearboxAdapterInterface
GearboxAdapterInterface = {
	INPUT_STRATEGY = {
		EATON_FULLER_18 = "eatonFuller18"
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

---Tells the domain core how many gear groups and gears per gear group the vehicle has. Supply nil to both parameters when leaving a vehicle
---@param groupCount number|nil @The number of gear groups the vehicle has
---@param forwardGearCount number|nil @The number of gears per gear group the vehicle has. If groupCount is nil, 0 or 1, this is the total number of gears.
---@param reverseGearCount number|nil @The number of reverse gears the vehicle has.
---@param needsClutch boolean|nil @True if the clutch needs to be pressed for changes to happen. Powershift transmissions don't need that, for example.
function GearboxAdapterInterface:setGearboxInfo(vehicleGearboxInfo)
	error("Method 'setGearboxInfo' not defined in implementing class")
end

---Tells the domain core how many gears and groups the player can select
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxForwardGears number @The number of forward gears the player can select with their controller.
function GearboxAdapterInterface:setInputLimits(maxGroups, maxForwardGears)
	error("Method 'setInputLimits' not defined in implementing class")
end

---Tells the domain core to process a change in the gear group input. Dependent on the transformation strategy, this may or may not result in this very gear group being selected in the vehicle.
---@param group number @The new gear group number
function GearboxAdapterInterface:setGearGroupInput(group)
	error("Method 'setGearGroupInput' not defined in implementing class")
end

---Tells the domain core to process a change in the gear input. Dependent on the transformation strategy, this may or may not result in this very gear being selected in the vehicle.
---@param gear number @The new gear number
function GearboxAdapterInterface:setGearInput(gear)
	error("Method 'setGearInput' not defined in implementing class")
end

---Call this function when the clutch state changes
---@param inputValue number @The clutch's input value (0..1, where 1 = pressed)
function GearboxAdapterInterface:setClutchState(inputValue)
	error("Method 'setClutchState' not defined in implementing class")
end