---This interface allows the domain core to trigger vehicle gear changes while staying independent of FS25 code
---@class GearChangeInterface
GearChangeInterface = {}

---Selects the given group, gear and direction
---@param gearCalculationResult GearCalculationResult the group and gear to be selected
function GearChangeInterface:applyChanges(gearCalculationResult)
	error("Method 'applyChanges' not defined in implementing class")
end

---Asks the implementation to show a warning that the clutch needs to be pressed before changing groups
function GearChangeInterface:showClutchWarningForGroupChange()
	error("Method 'showClutchWarningForGroupChange' not defined in implementing class")
end

---Asks the implementation to show a warning that the clutch needs to be pressed before changing gears
function GearChangeInterface:showClutchWarningForGearChange()
	error("Method 'showClutchWarningForGearChange' not defined in implementing class")
end

---Asks the implementation to show a warning that direction needs to be changed manually, not through gears/groups
function GearChangeInterface:showManualDirectionChangeWarning()
	error("Method 'showManualDirectionChangeWarning' not defined in implementing class")
end