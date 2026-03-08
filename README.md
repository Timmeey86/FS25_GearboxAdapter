# FS25 Gearbox Adapter

## Why is the mod necessary?

Farming Simulator 25 allows using H shifter controllers, but it can't properly handle controllers which have switches, and it doesn't allow you to re-use the same H shifter slot for multiple gears based on additional switches. Real life trucks allow selecting up to 18 gears + 4 reverse gears with just 6 shifter slots. They can do that by having a low and high variant of each gear, and by switching between two sets of gear ranges (each with a low and high variant in each slot).

The controller switch issue can currently only be solved with an AutoHotkey script; being able to shift like in real life trucks can be done through a normal game mod.

## Mod Overview

![Architecture Overview](doc/ArchitectureOverview.png)

## How to install

Coming soon

## FAQ

### Will the mod be on Mod Hub?

No, with it relying on an additional script which must be executed separately, that is unlikely.

### Is the AutoHotkey script really necessary?

If you are using a truck shifter knob like in the picture above, then yes, it is necessary. If you are using some kind of different setup like two H-shifters at the same time, you might be able to cope without the script

## Detailed Architecture

This mod tries to increase portability between game versions using a hexagonal architecture (ports and adapters) approach:

- The domain package contains the main logic of transforming various abstract inputs into a gear selection based on the desired strategy. It knows nothing about Farming Simulator. Instead, it exposes an incoming interface (port) to be implemented by FS-specific classes (adapters), and performs calls on outgoing interfaces (also adapters).
- The gear input adapter translates between specific Farming Simulator input actions and generic domain inputs.
- The gear change adapter implements the domain core's outgoing interfaces and translates the generic actions into specific Farming Simulator commands.
- The GearboxAdapter.lua is the composition root which assembles all the required objects.

Some of the benefits of doing this are:
- The domain core can be easily unit tested, without having to rely on knowledge about complex game tables.
- The domain core is reusable between different Farming Simulator versions - "only" the adapters have to be implemented.
- The domain core has a much lower complexity since it does not mix domain logic with Farming Simulator specifics.