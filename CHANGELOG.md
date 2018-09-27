# Changelog

All notable changes to this project will be documented in this file.

## Unreleased - [(diff with 3.1.0)][diff-unreleased]

## [3.1.0] - 2018-09-27 - [(diff with 3.0.0)][diff-3.1.0]

### Added

- Exposed the forgotten type `EventOptions`.

### Changed

- Do not stop propagation anymore by default
  (Except for drag events).

## [3.0.0] - 2018-08-21 - [(diff with 2.0.0)][diff-3.0.0]

### Added

- This `CHANGELOG` to record important changes.
- Drag events are now all supported.
- File drop example.
- Drag and drop example.
- Port files to setup drag ports `src/DragPorts.js` and `src/DragPorts.elm`.

### Changed

- This is now an elm 0.19 package so there are upgrade changes.
- All modules are now under the namespace `Html.Events.Extra`.
  For example `Html.Events.Extra.Mouse`.
- Tagged version commit is orphanned and stripped down
  to only keep the necessary for elm packaging.

### Removed

- `elm-pep/` is not anymore a git sub-module.
- Previous drag example.

## [2.0.0] - 2018-02-18 - [(diff with 1.0.0)][diff-2.0.0]

### Added

- `src/Mouse.elm` module to handle mouse events.
- `src/Touch.elm` module to handle touch events.
- `src/Wheel.elm` module to handle wheel events.
- `src/Drag.elm` module to handle drag events.
- Examples for the Mouse, Touch, Wheel and Drag modules.

### Changed

- Update `README` to reflect addition of mouse, touch, wheel and drag events.
- Improve `elm-pep/` polyfill to better handle Apple devices.

## [1.0.0] - 2017-10-17

### Added

- `src/Pointer.elm` module providing pointer events to elm.
- `examples/` containing one fully functional pointer events example.
- `elm-pep/` as a submodule to a pointer event polyfill.
- `README` describing this package.
- `LICENSE` under MPL-2.0.

[3.1.0]: https://github.com/mpizenberg/elm-pointer-events/releases/tag/3.1.0
[3.0.0]: https://github.com/mpizenberg/elm-pointer-events/releases/tag/3.0.0
[2.0.0]: https://github.com/mpizenberg/elm-pointer-events/releases/tag/2.0.0
[1.0.0]: https://github.com/mpizenberg/elm-pointer-events/releases/tag/1.0.0
[diff-unreleased]: https://github.com/mpizenberg/elm-pointer-events/compare/3.0.0...HEAD
[diff-3.1.0]: https://github.com/mpizenberg/elm-pointer-events/compare/3.0.0...3.1.0
[diff-3.0.0]: https://github.com/mpizenberg/elm-pointer-events/compare/2.0.0...3.0.0
[diff-2.0.0]: https://github.com/mpizenberg/elm-pointer-events/compare/1.0.0...2.0.0
