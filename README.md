# elm-pointer-events

[![][badge-license]][license]
[![][badge-doc]][doc]

[badge-doc]: https://img.shields.io/badge/documentation-latest-yellow.svg?style=flat-square
[doc]: http://package.elm-lang.org/packages/mpizenberg/elm-pointer-events/latest
[badge-license]: https://img.shields.io/badge/license-MPL--2.0-blue.svg?style=flat-square
[license]: https://www.mozilla.org/en-US/MPL/2.0/

This package aims at handling [pointer events][pointer-events] in elm.
Pointer events are a unified interface for similar input devices
(mouse, pen, touch, ...).

Since maintaining both mouse and touch events for compatibility
is really cumbersome, using a unified pointer events interface
is a relief.
However this API [is not well supported by all browsers][caniuse-pointer].
So I strongly recommend to use it in pair with a [polyfill][poly-pointer]
for compatibility with all major browsers.

[pointer-events]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
[caniuse-pointer]: https://caniuse.com/#feat=pointer
[poly-pointer]: https://github.com/jquery/PEP


## Usage


## Example

An example is available in the `examples/` directory.
To test it, compile the elm file with the command:

```shell
elm-make PointerEvents.elm --output PointerEvents.js
```

Then use any static http server like:

```shell
python3 -m http.server 8888
```

And open your browser at localhost:8888
to load the `index.html` page.


## Want to contribute?

If you are interested in contributing in any way
(feedback, bug report, implementation of new functionality, ...)
don't hesitate to reach out on slack (user mattpiz)
and/or open an issue.


## Documentation [![][badge-doc]][doc]

The package documentation is available on the [elm package website][doc].


## License [![][badge-license]][license]

This Source Code Form is subject to the terms of the Mozilla Public License,v. 2.0.
If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.


## Authors

Original author: Matthieu Pizenberg (matthieu.pizenberg@gmail.com)
