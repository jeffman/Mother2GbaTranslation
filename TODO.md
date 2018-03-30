### M2 - non-script things
- [X] Translate dad text
- [X] Translate enemy names
- [X] Translate item names
- [X] Translate menu choices
- [X] Translate misc text
- [X] Translate PSI names
- [X] Translate PSI text
- [X] Translate PSI targets

### M2 - main script
- [X] Produce blank skeleton for main script (all strings in the game point to "@Test")
- [ ] Translate battle actions
  - [ ] Add pronoun control codes
- [X] Translate PSI help text
- [X] Translate item help text
- [X] Translate TPT text
- [ ] Translate object text (doors, etc.)
- [ ] Translate phone text
- [X] Translate dad text
- [ ] Translate prayer text
- [X] Translate enemy encounter/death text
- [ ] Translate Lumine Hall text

### M2 - main script tool
- [X] Start a GUI tool to help the main script translation

### M2 - hacking (main, high priority)
- [X] VWF core
- [X] VWF for Talk
- [X] VWF for Check
- [X] VWF for Goods menu
- [X] VWF for PSI menu
- [X] VWF for Status window
- [X] VWF for cash window
- [X] Make PSI sub-menus (from Status window) redraw only when needed (currently they redraw continuously when they're not needed, and likewise they don't redraw when they are needed)
- [ ] Make Status window redraw properly when exiting from a PSI sub-menu
- [ ] VWF for HP/PP boxes
- [ ] VWF for naming screens
- [X] VWF for battles
- [ ] VWF for credits sequence
- [ ] Add Saturn font
- [ ] Add small font (names on HP/PP, Goods, PSI, etc. windows)
- [ ] Add big font (flyovers)
- [ ] VWF for Saturn font
- [ ] VWF for small font
- [ ] VWF for big font
  - [ ] Flyovers (already implemented this in a past project, just need to migrate it)
  - [ ] Coffee/tea scenes
- [ ] VWF for Lumine Hall text
- [ ] Pronoun control codes
- [X] BUG: jump control codes seem to be resetting pixel X values when they shouldn't
- [ ] TODO: replace load/store chains with ldmia/stmia

### M2 - hacking (misc, lower priority)
- [X] Incorporate Mato's M1 translation
- [ ] Insert EB's title screen
- [ ] EB graphical localization (hospital crosses, cultist sprites, etc.)
- [ ] M1+2 bugfixes:
  - [ ] Exit mouse in Giygas lair
  - [ ] Poison Giygas to death