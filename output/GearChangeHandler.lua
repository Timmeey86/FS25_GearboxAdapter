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
	if group and motor.gearGroups ~= nil then
		motor:selectGroup(group, true)
	-- else: don't change group
	end

	-- Change direction, unless it's a vehicle which uses forward gears in both directions
	local newDirection = gear >= 0 and 1 or -1
	if not motor.directionChangeUseInverse and newDirection ~= motor.currentDirection then
		motor:changeDirection(newDirection)
	end

	-- FS25 always treats gears as positive numbers, even backwards ones.
	motor:selectGear(gear < 0 and -gear or gear, gear ~= 0)
end