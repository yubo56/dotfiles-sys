# dotfiles-sys

All my major dotfiles are in here, basically all my shell/system related dotfiles.

Directory structure is
- `bin` holds all scripts and can link to `lib`
- `lib` holds code for any code that wants to be in `bin` but would include
  extraneous files, e.g. solve24, for which I plan to make both a python and
  C++ version
