dofile("src/domain/data/ShifterInputData.lua")
dofile("src/domain/data/GearSelectionHint.lua")
dofile("src/domain/core/InputTransformationStrategy.lua")
dofile("src/domain/core/inputStrategy/EatonFuller18InputStrategy.lua")

describe("Eaton Fuller 18 input strategy", function()
	it("should calculate values as expected", function()
		-- GIVEN
		local inputsAndExpectedOutputs = {
			{ group = 1, slot = 1, expectedDirection = -1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 }, -- RLL
			{ group = 2, slot = 1, expectedDirection = -1, expectedEffectiveGear =  2, expectedGroup = 2, expectedGearInGroup = 1 }, -- RHL
			{ group = 3, slot = 1, expectedDirection = -1, expectedEffectiveGear =  3, expectedGroup = 3, expectedGearInGroup = 1 }, -- RLH
			{ group = 4, slot = 1, expectedDirection = -1, expectedEffectiveGear =  4, expectedGroup = 4, expectedGearInGroup = 1 }, -- RHH
			{ group = 1, slot = 3, expectedDirection =  1, expectedEffectiveGear =  1, expectedGroup = 1, expectedGearInGroup = 1 }, -- 1L
			{ group = 2, slot = 3, expectedDirection =  1, expectedEffectiveGear =  2, expectedGroup = 2, expectedGearInGroup = 1 }, -- 1H
			{ group = 1, slot = 4, expectedDirection =  1, expectedEffectiveGear =  3, expectedGroup = 1, expectedGearInGroup = 2 }, -- 2L
			{ group = 2, slot = 4, expectedDirection =  1, expectedEffectiveGear =  4, expectedGroup = 2, expectedGearInGroup = 2 }, -- 2H
			{ group = 1, slot = 5, expectedDirection =  1, expectedEffectiveGear =  5, expectedGroup = 1, expectedGearInGroup = 3 }, -- 3L
			{ group = 2, slot = 5, expectedDirection =  1, expectedEffectiveGear =  6, expectedGroup = 2, expectedGearInGroup = 3 }, -- 3H
			{ group = 1, slot = 6, expectedDirection =  1, expectedEffectiveGear =  7, expectedGroup = 1, expectedGearInGroup = 4 }, -- 4L
			{ group = 2, slot = 6, expectedDirection =  1, expectedEffectiveGear =  8, expectedGroup = 2, expectedGearInGroup = 4 }, -- 4H
			{ group = 3, slot = 3, expectedDirection =  1, expectedEffectiveGear =  9, expectedGroup = 3, expectedGearInGroup = 1 }, -- 5L
			{ group = 4, slot = 3, expectedDirection =  1, expectedEffectiveGear = 10, expectedGroup = 4, expectedGearInGroup = 1 }, -- 5H
			{ group = 3, slot = 4, expectedDirection =  1, expectedEffectiveGear = 11, expectedGroup = 3, expectedGearInGroup = 2 }, -- 6L
			{ group = 4, slot = 4, expectedDirection =  1, expectedEffectiveGear = 12, expectedGroup = 4, expectedGearInGroup = 2 }, -- 6H
			{ group = 3, slot = 5, expectedDirection =  1, expectedEffectiveGear = 13, expectedGroup = 3, expectedGearInGroup = 3 }, -- 7L
			{ group = 4, slot = 5, expectedDirection =  1, expectedEffectiveGear = 14, expectedGroup = 4, expectedGearInGroup = 3 }, -- 7H
			{ group = 3, slot = 6, expectedDirection =  1, expectedEffectiveGear = 15, expectedGroup = 3, expectedGearInGroup = 4 }, -- 8L
			{ group = 4, slot = 6, expectedDirection =  1, expectedEffectiveGear = 16, expectedGroup = 4, expectedGearInGroup = 4 }, -- 8H
			{ group = 1, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- Neutral (unused)
			{ group = 2, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- Neutral (unused)
			{ group = 3, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- Neutral (unused)
			{ group = 4, slot = 2, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- Neutral (unused)
			{ group = 5, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- out of range
			{ group = 0, slot = 1, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- out of range
			{ group = 1, slot = 7, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- out of range
			{ group = 0, slot = 0, expectedDirection =  0, expectedEffectiveGear =  0, expectedGroup = 0, expectedGearInGroup = 0 }, -- out of range
		}
		local testCaseToString = function(testCase)
			return string.format("Input: group=%d, slot=%d    Output: direction=%d, effectiveGear=%d", testCase.group, testCase.slot, testCase.expectedDirection, testCase.expectedEffectiveGear)
		end

		local strategy = EatonFuller18TransformationStrategy.new()


		-- WHEN / THEN
		for i, testCase in ipairs(inputsAndExpectedOutputs) do
			-- WHEN
			local result = strategy:calculateEffectiveGear(ShifterInputData.new(testCase.group, testCase.slot, true))

			-- THEN
			assert.are.equals(testCase.expectedDirection, result.direction, testCaseToString(testCase) .. ": Direction does not match")
			assert.are.equals(testCase.expectedEffectiveGear, result.effectiveGear, testCaseToString(testCase) .. ": Effective gear does not match")
			assert.are.equals(testCase.expectedGroup, result.gearGroup, testCaseToString(testCase) .. ": Gear group does not match")
			assert.are.equals(testCase.expectedGearInGroup, result.gearInGroup, testCaseToString(testCase) .. ": Gear in group does not match")
			assert.are.equals(16, result.maxNumGears, testCaseToString(testCase) .. ": Max number of gears does not match")
		end
	end)
end)