# avUI

**avUI** is a small, modular, personal use World of Warcraft UI addon, featuring default Blizzard UI-targeted enhancements and theming.

## Architecture

- Framework libraries: `AceAddon-3.0`, `AceEvent-3.0`, `AceHook-3.0`, `CallbackHandler-1.0`, `LibStub`.
- Modular structure.

## Modules

> [!INFO]
> No manual module configuration is present at the moment, all modules are **enabled** by default, unless stated otherwise.

- `Theme.lua` &mdash; darker theme for the default Blizzard UI.
- `UnitFrames`
  - `Absorbs.lua` &mdash; _Overabsorb_ display on raid-style party frames;
  - `Auras.lua` &mdash; Coloring of StatusText part on raid-style party frames when _Atonement_ buff is present;
  - ~~`Defensives.lua`~~ <sup>(disabled)</sup> &mdash; _Big defensive_ placement and visuals configuration.
- `Nameplates`
  - `Mouseover.lua` &mdash; Border display around the mouseovered nameplate;
  - `Opacity.lua` &mdash; Opacity configuration for the non-focused nameplates;
  - `Size.lua` &mdash; Nameplate healthbar size configuration;
  - `Execute.lua` &mdash; _20% execute_ range border around the nameplate healthbar.

## Credits

These addons are the inspiration for **avUI**. Go check them out!

- [SUI](https://www.curseforge.com/wow/addons/sui), [mUI](https://www.curseforge.com/wow/addons/muleyoui)
- [Platynator](https://www.curseforge.com/wow/addons/platynator)
- [Danders Frames](https://www.curseforge.com/wow/addons/danders-frames)
