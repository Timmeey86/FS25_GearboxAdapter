---This class is responsible for changing gears as requested by the domain core
---@class GearChangeHandler
GearChangeHandler = {}
local GearChangeHandler_mt = Class(GearChangeHandler, GearChangeInterface)

---Constructor
---@return GearChangeInterface @The public interface of the class
function GearChangeHandler.new()
	local self = setmetatable({}, GearChangeHandler_mt)
	return self
end

---Selects the given group and gear
---@param group number @The gear group to select (if applicable).
---@param gear number @The gear to select within the given gear group
function GearChangeHandler:changeGroupAndGear(group, gear)
	if not g_localPlayer then
		return
	end

	local vehicle = g_localPlayer:getCurrentVehicle()
	if not vehicle then
		Logging.warning("Can't change gear: Player has no current vehicle")
		return
	end

	local motor = vehicle.spec_motorized and vehicle.spec_motorized.motor
	if not motor then
		Logging.warning("Can't change gear: Player's current vehicle has no motor")
		return
	end

	Logging.info("FS25 Adapter: Changing group and gear to %s and %s", group, gear)
	if group then
		motor:setGearGroup(group, false)
	-- else: don't change group
	end

	-- TODO: Use VehicleMotor:changeDirection or something so the vehicle doesn't instantly turn around
	motor.currentDirection = motor.directionChangeUseGear and (gear >= 0 and 1 or -1) or 1
	motor:setGear(gear < 0 and -gear or gear)
end