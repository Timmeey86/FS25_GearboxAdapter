dofile("src/domain/data/GearCalculationResult.lua")
dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/data/InputControllerInfo.lua")
dofile("src/domain/data/ShifterInputData.lua")
dofile("src/domain/data/VehicleGearboxInfo.lua")
dofile("src/domain/incoming/GearboxAdapterInterface.lua")
dofile("src/domain/core/inputStrategy/EatonFuller18InputStrategy.lua")
dofile("src/domain/core/outputStrategy/SequentialOutputStrategy.lua")
dofile("src/domain/core/DomainGearboxAdapter.lua")

local mockGearChangeImpl = {
  applyChanges = function(gearCalculationResult) end,
  showClutchWarningForGroupChange = function() end,
  showClutchWarningForGearChange = function() end,
  showManualDirectionChangeWarning = function() end
}

local mockClutchIsEnabled = true
local mockClutchEnabledFunc = function() return mockClutchIsEnabled end

local gearboxAdapter = DomainGearboxAdapter.new(mockGearChangeImpl, mockClutchEnabledFunc)

describe("DomainGearboxAdapter", function()
	it("should call setters when changing the active input strategy", function()
		-- GIVEN
		local actualGearboxInfo = nil
		local actualControllerInfo = nil
		local mockInputStrategy = {
			setGearboxInfo = function(self, gearboxInfo) actualGearboxInfo = gearboxInfo end,
			setInputControllerInfo = function(self, controllerInfo) actualControllerInfo = controllerInfo end
		}
		local expectedGearboxInfo = VehicleGearboxInfo.new(false, false, false, 3, 6, 1)
		local expectedControllerInfo = InputControllerInfo.new(2, 3)
		gearboxAdapter:setGearboxInfo(expectedGearboxInfo)
		gearboxAdapter:setInputControllerInfo(expectedControllerInfo)

		-- WHEN
		gearboxAdapter.inputStrategies["mock"] = mockInputStrategy
		gearboxAdapter:setInputTransformationStrategy("mock")

		-- THEN
		assert.are.equals(expectedGearboxInfo, actualGearboxInfo)
		assert.are.equals(expectedControllerInfo, actualControllerInfo)
		assert.are.equals(gearboxAdapter.activeInputStrategy, mockInputStrategy)
	end)

	it("should error on unknown input strategies", function()
		-- GIVEN

		-- WHEN / THEN
		assert.has_error(function() gearboxAdapter:setInputTransformationStrategy("does not exist") end)
	end)

	it("should error on unknown output strategies", function()
		-- GIVEN

		-- WHEN / THEN
		assert.has_error(function() gearboxAdapter:setOutputTransformationStrategy("does not exist") end)
	end)

	it("should allow switching output strategies", function()
		-- GIVEN
		local mockOutputStrategy = {}
		gearboxAdapter.outputStrategies["mock"] = mockOutputStrategy

		-- WHEN
		gearboxAdapter:setOutputTransformationStrategy("mock")

		-- THEN
		assert.are.equals(gearboxAdapter.activeOutputStrategy, mockOutputStrategy)
	end)
end)