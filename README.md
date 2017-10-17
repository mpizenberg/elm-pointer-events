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
So I strongly recommend to use it in pair with a the [elm-pep polyfill][elm-pep]
for compatibility with all major browsers.

[pointer-events]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
[caniuse-pointer]: https://caniuse.com/#feat=pointer
[elm-pep]: https://github.com/mpizenberg/elm-pep


## Usage

The following functions can easilly be used
to generate attribute messages:

```elm
Pointer.onDown : (Pointer.Event -> msg) -> Html.Attribute msg
Pointer.onMove : (Pointer.Event -> msg) -> Html.Attribute msg
Pointer.onUp : (Pointer.Event -> msg) -> Html.Attribute msg
```

If you are using the [elm-pep][elm-pep] polyfill
for compatibility with Firefox and Safari,
you have to add the `elm-pep` attribute.
It is also recommended that you deactivate `touch-action`
to disable browsers scroll behaviors.


```elm
div
	[ Pointer.onDown ...
	, Pointer.onMove ...
	, Pointer.onUp ...
	-- no touch-action
	, Html.Attributes.style [ ( "touch-action", "none" ) ]
	-- Add this to your list of attribute messages
	, Html.Attributes.attribute "elm-pep" "true"
	]
	[]
```


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

Matthieu Pizenberg: matthieu.pizenberg@gmail.com
