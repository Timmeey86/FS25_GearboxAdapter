---This class is responsible for changing gears as requested by the domain core
---@class GearChangeHandler : GearChangeInterface
GearChangeHandler = {}

---Constructor
---@return GearChangeInterface @The public interface of the class
function GearChangeHandler.new()
	local self = setmetatable({}, {__index = GearChangeHandler})
	return self
end

---Selects the given group, gear and direction
---@param gearCalculationResult GearCalculationResult the group and gear to be selected
function GearChangeHandler:applyChanges(gearCalculationResult)

	local spec_motorized = self:getMotorizedSpec()
	if not spec_motorized then
		Logging.warning("Can't change gear/group: Player's current vehicle has no motorized spec")
		return
	end

	local motor = spec_motorized.motor
	if not motor then
		Logging.warning("Can't change gear: Player's current vehicle has no motor")
		return
	end

	if gearCalculationResult.group and motor.gearGroups ~= nil then
		motor:selectGroup(gearCalculationResult.group, true)
	-- else: don't change group
	end

	-- Change direction, unless it's a vehicle which uses forward gears in both directions
	local newDirection = gearCalculationResult.direction >= 0 and 1 or -1
	if not motor.directionChangeUseInverse and newDirection ~= motor.currentDirection then
		motor:changeDirection(newDirection)
	end

	local isNeutral = gearCalculationResult.direction == 0
	-- Select the gear, unless it's the neutral gear (second parameter)
	motor:selectGear(gearCalculationResult.gear, not isNeutral)
end



---Shows a warning that the clutch needs to be pressed before changing groups
function GearChangeHandler:showClutchWarningForGroupChange()
	local spec_motorized = self:getMotorizedSpec()
	if spec_motorized then
		SpecializationUtil.raiseEvent(g_localPlayer:getCurrentVehicle(), "onClutchCreaking", false, true, nil, nil)
	end
end

---Shows a warning that the clutch needs to be pressed before changing gears
function GearChangeHandler:showClutchWarningForGearChange()
	local spec_motorized = self:getMotorizedSpec()
	if spec_motorized then
		SpecializationUtil.raiseEvent(g_localPlayer:getCurrentVehicle(), "onClutchCreaking", false, false, nil, nil)
	end
end

---Shows a warning that direction needs to be changed manually, not through gears/groups
function GearChangeHandler:showManualDirectionChangeWarning()
	g_currentMission:showBlinkingWarning(g_i18n:getText("GA_WARNING_NO_REVERSE_GEARS", MOD_NAME), 2000)
end

---Retrieves the spec_motorized of the current vehicle
function GearChangeHandler:getMotorizedSpec()
	if not g_localPlayer then
		return nil
	end

	local vehicle = g_localPlayer:getCurrentVehicle()
	if not vehicle then
		Logging.warning("Can't change gear/group: Player has no current vehicle")
		return nil
	end

	return vehicle.spec_motorized
end