# FS25 Gearbox Adapter

## What does the mod do?

- The mod allows the usage of USB Truck shifter controllers in Farming Simulator 25.
- It allows using various realistic shifting patterns, and various gear selection strategies to be used (work in progress).
- It also detects switching to neutral gear with a regular H shifter (only for manual transmission)

## Supported shifter patterns (work in progress)
Courtesy of killer2239 on [reddit](https://www.reddit.com/r/trucksim/comments/l83z5o/shift_pattern_compilation_pic/) (with their own edit in the comments):
[![Shifter Patterns](https://i.imgur.com/eAvSFEH.png)](https://imgur.com/eAvSFEH)

Note: The selected shifter pattern is not saved, yet, so you'd have to select it each time you load into a save

## How to use the mod

### One-time setup:

1. Download the zip from the "Assets" section in the newest release on the [releases](https://github.com/Timmeey86/FS25_GearboxAdapter/releases) page.
2. Go into the settings, find "Gearbox Adapter" and assign all the controls you have, leave the rest empty. When assigning switches for groups, you need to turn the switch "on" and "off" when assigning the button. The Gear group 1-8 controls are intended for people who use two H shifters (one for groups and one for gears). With a truck shifting knob + 6-gear H shifter combo, you usually only want to set "Gear Switch 1" (Splitter), "Gear Switch 2" (Range Selector), Gears 1-6 and the R gear (currently unused).
3. If you have it, bind "Switch direction" to the push button on your truck shifting knob. You will need that for vehicles which can change direction rather than having dedicated reverse gears.
3. Remove any basegame gear/group controls you have set to the same buttons (in future, this step might not be necessary)
4. You can now start using the advanced shifting patterns in non-CVT vehicles!

### How it works ingame

- Currently, CVT transmissions are not handled by the mod, so you can simple use your "Change direction" binding and not worry about the shifter
- In manual and powershift transmissions, you can currently use [the Eaton 18 shifter pattern, except for the LH/LL gears](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fhlsg1dpl4ce61.png). In the future, you'll be able to select your favourite pattern.
- If the vehicle has powershift for gear groups, or gears, you can do changes without pressing the clutch.
- For manual transmissions, you'll have to press the clutch. You can however pre-queue gear group changes, which will then get selected as soon as you press the clutch. If you remove a gear without pressing the clutch, or release the clutch while in neutral, your vehicle will be in neutral gear.
- If the vehicle has more than 16 gears, you can currently not reach anything beyong 16
- If the vehicle uses gear groups, your input will select the gears and gear groups sequentially, so for 3 groups with 5 gears each, 1L => 1.1, 1H => 1.2, ... , 3L => 1.5, 3H => 2.1 and so on

## FAQ

### Will the mod be on Mod Hub?

Yes, eventually it will be.

### Why can't I reverse some machines?

You are likely sitting in a machine which doesn't have backwards gears or gear groups, but instead allows the same gears in two directions. For these vehicles, you need to toggle the driving direction manually, as it is done in real life. If you are using a truck shifter knob that has a button on top of the two switches, it is recommended to bind that to the base game setting for changing directions (Space key by default).

## For curious developers

### Detailed Architecture

This mod tries to increase portability between game versions using a hexagonal architecture (ports and adapters) approach:

- The domain package contains the main logic of transforming various abstract inputs into a gear selection based on the desired strategy. It knows nothing about Farming Simulator. Instead, it exposes an incoming interface (port) to be implemented by FS-specific classes (adapters), and performs calls on outgoing interfaces (also adapters).
- The gear input adapter translates between specific Farming Simulator input actions and generic domain inputs.
- The gear change implementation implements the domain core's outgoing interfaces and translates the generic actions into specific Farming Simulator commands.
- The GearboxAdapter.lua is the composition root which assembles all the required objects.

Some of the benefits of doing this are:
- The domain core can be easily unit tested, without having to rely on knowledge about complex game tables.
- The domain core is reusable between different Farming Simulator versions - "only" the adapters have to be implemented.
- The domain core has a much lower complexity since it does not mix domain logic with Farming Simulator specifics.

### Unit Testing

This mod uses the [busted](https://lunarmodules.github.io/busted/) framework for unit-testing the domain core.

In order to do this, you'll need the following things:

- The [lua compiler](https://www.lua.org/download.html)
- The [lua package manager](https://luarocks.org/)
- `luarocks install busted` (For executing unit tests)
- `luarocks install luacov` (For generating code coverage)
- `luarocks install luacov-reporter-lcov` (For converting code coverage to a more common format)
- The [Coverage Gutters plugin for VSCode](https://github.com/ryanluker/vscode-coverage-gutters) (You can find it in the VSCode marketplace for free)

Once you've got that all set up, you can create a local batch file like

```bat
::run_test.bat:

:: Delete the coverage file since otherwise line hits will accumulate
del luacov.stats.out

:: Run the tests with coverage on anything inside the "test" folder and use the .luacov in that folder for configuration
busted --coverage --coverage-config-file=test\.luacov -o plainTerminal test\*
```

In the .vscode folder, select, add the following configuration in the settings.json:

```json
{
	"coverage-gutters.coverageFileNames": [
		"luacov.report.out"
	]
}
```

If you then press Ctrl+Shift+P in VSCode and execute "Coverage Gutters: Watch", you'll start seeing Code Coverage markers as soon as you execute the run_tests.bat