dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/data/VehicleGearboxInfo.lua")
dofile("src/domain/data/GearCalculationResult.lua")
dofile("src/domain/core/OutputTransformationStrategy.lua")
dofile("src/domain/core/outputStrategy/SequentialOutputStrategy.lua")

describe("Sequential output strategy", function()
	it("should select gears 1:1 when the vehicle has only one group", function()
		-- GIVEN
		local strategy = SequentialOutputStrategy.new()
		local vehicleGearboxInfo = VehicleGearboxInfo.new(false, false, false, 1, 3, 2) -- 3 forward gears, two reverse gears

		local gearSelectinHintTestCases = {
			{ name = "N",  direction =  0, effectiveGear = 0, expectedGear = 0 },
			{ name = "R1", direction = -1, effectiveGear = 1, expectedGear = 1 },
			{ name = "R2", direction = -1, effectiveGear = 2, expectedGear = 2 },
			{ name = "1",  direction =  1, effectiveGear = 1, expectedGear = 1 },
			{ name = "2",  direction =  1, effectiveGear = 2, expectedGear = 2 },
			{ name = "3",  direction =  1, effectiveGear = 3, expectedGear = 3 },
			-- Note: Invalid/Mismatching gear selection hints are already checked in the domain core, so we don't test it here
		}

		-- WHEN / THEN
		for i, testCase in ipairs(gearSelectinHintTestCases) do
			-- WHEN
			local calculatedGearData = strategy:calculateGearSelection(
				GearSelectionHint.new(testCase.direction, testCase.effectiveGear, 3, testCase.gearGroup, testCase.gearInGroup),
				vehicleGearboxInfo
			)

			-- THEN
			local expectedDirection = testCase.direction
			local expectedGroup = 1
			local expectedGear = testCase.expectedGear

			assert.is.not_nil(calculatedGearData, string.format("\n\nTest case for gear %s (one available group) failed. No gear data returned.", testCase.name))
			assert.are.equals(expectedDirection, calculatedGearData.direction, string.format("\n\nTest case for gear %s (one available group) failed. Direction does not match.", testCase.name))
			assert.are.equals(expectedGroup, calculatedGearData.group, string.format("\n\nTest case for gear %s (one available group) failed. Gear group does not match.", testCase.name))
			assert.are.equals(expectedGear, calculatedGearData.gear, string.format("\n\nTest case for gear %s (one available group) failed. Gear does not match.", testCase.name))
		end
	end)

	it("should select gears in sequential order when the vehicle has multiple groups", function()
		-- GIVEN
		local strategy = SequentialOutputStrategy.new()
		-- 3 groups with 4 gears each, and 2 reverse gears
		local vehicleGearboxInfo = VehicleGearboxInfo.new(false, false, false, 3, 4, 2)

		local gearSelectinHintTestCases = {
			{ name = "N",  direction = 0,  effectiveGear = 0,  expectedGear = 0, expectedGroup = 1 },
			{ name = "R1", direction = -1, effectiveGear =  1, expectedGear = 1, expectedGroup = 1 },
			{ name = "R2", direction = -1, effectiveGear =  2, expectedGear = 2, expectedGroup = 1 },
			{ name =  "1", direction =  1, effectiveGear =  1, expectedGear = 1, expectedGroup = 1 },
			{ name =  "2", direction =  1, effectiveGear =  2, expectedGear = 2, expectedGroup = 1 },
			{ name =  "3", direction =  1, effectiveGear =  3, expectedGear = 3, expectedGroup = 1 },
			{ name =  "4", direction =  1, effectiveGear =  4, expectedGear = 4, expectedGroup = 1 },
			{ name =  "5", direction =  1, effectiveGear =  5, expectedGear = 1, expectedGroup = 2 },
			{ name =  "6", direction =  1, effectiveGear =  6, expectedGear = 2, expectedGroup = 2 },
			{ name =  "7", direction =  1, effectiveGear =  7, expectedGear = 3, expectedGroup = 2 },
			{ name =  "8", direction =  1, effectiveGear =  8, expectedGear = 4, expectedGroup = 2 },
			{ name =  "9", direction =  1, effectiveGear =  9, expectedGear = 1, expectedGroup = 3 },
			{ name = "10", direction =  1, effectiveGear = 10, expectedGear = 2, expectedGroup = 3 },
			{ name = "11", direction =  1, effectiveGear = 11, expectedGear = 3, expectedGroup = 3 },
			{ name = "12", direction =  1, effectiveGear = 12, expectedGear = 4, expectedGroup = 3 },
			-- Note: Invalid/Mismatching gear selection hints are already checked in the domain core, so we don't test it here
		}

		-- WHEN / THEN
		for i, testCase in ipairs(gearSelectinHintTestCases) do
			-- WHEN
			local calculatedGearData = strategy:calculateGearSelection(
				GearSelectionHint.new(testCase.direction, testCase.effectiveGear, 3, testCase.gearGroup, testCase.gearInGroup),
				vehicleGearboxInfo
			)

			-- THEN
			local expectedDirection = testCase.direction
			local expectedGroup = testCase.expectedGroup
			local expectedGear = testCase.expectedGear

			assert.is.not_nil(calculatedGearData, string.format("\n\nTest case for gear %s (multiple available groups) failed. No gear data returned.", testCase.name))
			assert.are.equals(expectedDirection, calculatedGearData.direction, string.format("\n\nTest case for gear %s (multiple available groups) failed. Direction does not match.", testCase.name))
			assert.are.equals(expectedGroup, calculatedGearData.group, string.format("\n\nTest case for gear %s (multiple available groups) failed. Gear group does not match.", testCase.name))
			assert.are.equals(expectedGear, calculatedGearData.gear, string.format("\n\nTest case for gear %s (multiple available groups) failed. Gear does not match.", testCase.name))
		end
	end)
end)