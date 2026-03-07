---An internal interface for interpreting controller inputs based on the player's choice.
---@class InputTransformationStrategy
InputTransformationStrategy = {}

---Sets the number of gear groups and gears the player can select with their controller. Note that some input strategies might ignore this. It is mainly meant for those which e.g. support 6 and 8 gear shifters for groups and/or gears.
---@param maxGroups number @The number of gear groups the player can select with their controller.
---@param maxGears number @The number of gears per gear group the player can select with their controller.
function InputTransformationStrategy:setInputLimits(maxGroups, maxGears)
	error("Method 'setInputLimits' not defined in implementing class")
end

---Sets the given gear group active.
---@param newGroup number @The group which was selected by the input controller
function InputTransformationStrategy:changeGearGroup(newGroup)
	error("Method 'changeGearGroup' not defined in implementing class")
	-- Note: When implementing, ask for the OutputTransformationStrategy in the constructor and call methods on it in the implementation if necessary.
end

---Sets the given gear active.
function InputTransformationStrategy:changeGear(newGear)
	error("Method 'changeGear' not defined in implementing class")
	-- Note: When implementing, ask for the OutputTransformationStrategy in the constructor and call methods on it in the implementation if necessary.
end

---Tells the strategy that the clutch's pressed state has changed. This allows things like pre-queuing gear changes for some input strategies.
---@param isPressed boolean @True if the clutch is pressed, false otherwise.
function InputTransformationStrategy:setClutchPressed(isPressed)
	error("Method 'setClutchPressed' not defined in implementing class")
	-- Note: When implementing, ask for the OutputTransformationStrategy in the constructor and call methods on it in the implementation if necessary.
end