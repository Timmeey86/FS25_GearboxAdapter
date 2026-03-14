---This POD stores information about the current input of the player's shifter and shifter group controllers
---@class ShifterInputData
---@field currentGroup number @The currently selected shifter group (1 if not applicable)
---@field currentGearSlot number @The currently selected shifter slot
---@field clutchIsPressed boolean @True if the clutch is currently pressed
ShifterInputData = {}

---Creates a new instance of ShifterInputData
---@param currentGroup number The currently selected shifter group (1 if not applicable)
---@param currentGearSlot number The currently selected shifter slot
---@param clutchIsPressed boolean True if the clutch is currently pressed
---@return ShifterInputData
function ShifterInputData.new(currentGroup, currentGearSlot, clutchIsPressed)
	local self = setmetatable({}, {__index = ShifterInputData})
	self.currentGroup = currentGroup
	self.currentGearSlot = currentGearSlot
	self.clutchIsPressed = clutchIsPressed
	return self
end