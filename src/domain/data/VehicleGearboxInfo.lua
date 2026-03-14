---This POD provides information about the current vehicle's gearbox/transmission/motor
---@class VehicleGearboxInfo
---@field hasAutomaticShift boolean @True if the vehicle has an automatic gearbox like a CVT one
---@field needsClutchForGroups boolean @True if the clutch needs to be pressed to change gear groups
---@field needsClutchForGears boolean @True if the clutch needs to be pressed to change gears within a gear group
---@field maxGroups number @The number of gear groups the vehicle has (if not CVT)
---@field maxForwardGears number @The number of forward gears per gear group the vehicle has (if not CVT)
---@field maxReverseGears number @The number of reverse gears the vehicle has (if not CVT)
VehicleGearboxInfo = {}

---Creates a new instance of the VehicleGearboxInfo class
---@param hasAutomaticShift boolean True if the vehicle has a continuous variable transmission gearbox
---@param needsClutchForGroups boolean True if the clutch needs to be pressed to change gear groups
---@param needsClutchForGears boolean True if the clutch needs to be pressed to change gears within a gear group
---@param maxGroups number The number of gear groups the vehicle has (if not CVT)
---@param maxForwardGears number The number of forward gears per gear group the vehicle has (if not CVT)
---@param maxReverseGears number The number of reverse gears the vehicle has (if not CVT)
---@return VehicleGearboxInfo
function VehicleGearboxInfo.new(hasAutomaticShift, needsClutchForGroups, needsClutchForGears, maxGroups, maxForwardGears, maxReverseGears)
	local self = setmetatable({}, {__index = VehicleGearboxInfo})
	self.hasAutomaticShift = hasAutomaticShift
	self.needsClutchForGroups = needsClutchForGroups
	self.needsClutchForGears = needsClutchForGears
	self.maxGroups = maxGroups
	self.maxForwardGears = maxForwardGears
	self.maxReverseGears = maxReverseGears
	return self
end