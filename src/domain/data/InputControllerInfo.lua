---This POD provides information about the controller setup of the player
---@class InputControllerInfo
---@field maxGroups number @The maximum number of groups the player can input
---@field maxGears number @The maximum number of gears the player can input
InputControllerInfo = {}

---Creates a new instance of the InputControllerInfo class
---@param maxGroups number the maximum number of groups the player can input
---@param maxGears number the maximum number of gears the player can input
---@return InputControllerInfo
function InputControllerInfo.new(maxGroups, maxGears)
	local self = setmetatable({}, {__index = InputControllerInfo})
	self.maxGroups = maxGroups
	self.maxGears = maxGears
	return self
end