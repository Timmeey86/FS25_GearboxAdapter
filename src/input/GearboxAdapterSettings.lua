---This class stores settings for the gearbox adapter mod.
---@class GearboxAdapterSettings
---@field inputStrategy number @The index of the selected input strategy
---@field outputStrategy number @The index of the selected output strategy
GearboxAdapterSettings = {}
local GearboxAdapterSettings_mt = Class(GearboxAdapterSettings)

---Constructor
---@return GearboxAdapterSettings
function GearboxAdapterSettings.new()
	local self = setmetatable({}, GearboxAdapterSettings_mt)
	return self
end