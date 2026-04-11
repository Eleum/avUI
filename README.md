# avUI

**avUI** is a small, modular, personal use World of Warcraft UI addon, featuring default Blizzard UI-targeted enhancements and theming.

## Architecture

- Framework libraries: `AceAddon-3.0`, `AceEvent-3.0`, `AceHook-3.0`, `CallbackHandler-1.0`, `LibStub`.
- Modular structure.

## Modules

> [!WARNING]
> No module configuration is present at the moment, all modules are enabled by default

- `Theme.lua` &mdash; darker theme for the default Blizzard UI.
- `UnitFrames`
  - `Absorbs.lua` &mdash; Overabsorb display on raid-style party frames;
  - `Auras.lua` &mdash; StatusText coloring on raid-style party frames when Atonement buff is present;
  - `Defensives.lua` &mdash; Big defensive placement configuration.
- `Nameplates`
  - `Mouseover.lua` &mdash; Border display around the mouseovered nameplate;
  - `Opacity.lua` &mdash; Opacity configuration for the non-focused nameplates;
  - `Execute.lua` &mdash; 20% execute range border around the nameplate healthbar;
  - `Size.lua` &mdash; Nameplate healthbar size configuration.

## Credits

These addons are the inspiration for **avUI**. Go check them out!

- [SUI](https://www.curseforge.com/wow/addons/sui), [mUI](https://www.curseforge.com/wow/addons/muleyoui)
- [Platynator](https://www.curseforge.com/wow/addons/platynator)
- [Danders Frames](https://www.curseforge.com/wow/addons/danders-frames)
