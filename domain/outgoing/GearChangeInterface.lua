---This interface allows the domain core to trigger vehicle gear changes while staying independent of FS25 code
---@class GearChangeInterface
GearChangeInterface = {}

---Selects the given group and gear
---@param group number @The gear group to select (if applicable).
---@param gear number @The gear to select within the given gear group
function GearChangeInterface:changeGroupAndGear(group, gear)
	error("Method 'changeGroupAndGear' not defined in implementing class")
end