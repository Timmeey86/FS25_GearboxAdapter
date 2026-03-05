---This is the public interface of the domain core
---@class GearboxAdapterInterface
GearboxAdapterInterface = {
	STRATEGY = {
		SEQUENTIAL = "sequential",
		EATON_FULLER_18 = "eatonFuller18"
	}
}

---Sets the input transformation strategy to be used.
---@param strategy string the identifier of the strategy to be used.
function GearboxAdapterInterface:setTransformationStrategy(strategy)
	error("Method 'setTransformationStrategy' not defined in implementing class")
end

---Tells the domain core how many gear groups and gears per gear group the vehicle has. Supply nil to both parameters when leaving a vehicle
---@param groupCount number|nil @The number of gear groups the vehicle has
---@param gearCount number|nil @The number of gears per gear group the vehicle has. If groupCount is nil, 0 or 1, this is the total number of gears.
function GearboxAdapterInterface:setCurrentGearLayout(groupCount, gearCount)
	error("Method 'setCurrentGearLayout' not defined in implementing class")
end

---Tells the domain core how many gears and groups the player can select
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
function GearboxAdapterInterface:setInputLimits(maxGroups, maxGears)
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