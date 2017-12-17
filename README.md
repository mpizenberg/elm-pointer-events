# elm-pointer-events

[![][badge-license]][license]
[![][badge-doc]][doc]

[badge-doc]: https://img.shields.io/badge/documentation-latest-yellow.svg?style=flat-square
[doc]: http://package.elm-lang.org/packages/mpizenberg/elm-pointer-events/latest
[badge-license]: https://img.shields.io/badge/license-MPL--2.0-blue.svg?style=flat-square
[license]: https://www.mozilla.org/en-US/MPL/2.0/

> Warning: merge in progress (issue #1).
>
> The goal being to merge all my pointer-related packages here for elm 0.19, namely:
>
> * [elm-mouse-events]
> * [elm-touch-events]
> * [elm-pointer-events]
>
> Remark: other improvements might also happen before next major version (see issue #2)

[elm-mouse-events]: https://github.com/mpizenberg/elm-mouse-events
[elm-touch-events]: https://github.com/mpizenberg/elm-touch-events
[elm-pointer-events]: https://github.com/mpizenberg/elm-pointer-events

This package aims at handling all kinds of pointer events in elm.
To be more specific, this means:

* [`MouseEvent`][mouse-events]: standard mouse events
* [`TouchEvent`][touch-events]: standard touch events
* [`PointerEvent`][pointer-events]: new pointer events

If you are looking for only one standard kind of interaction (mouse or touch),
I recommend that you use the `Mouse` or `Touch`/`SingleTouch`/`MultiTouch` modules.
If however, you are designing a multi-device (desktop/tablet/mobile/...) experience,
I recommend that you use the `Pointer` module.

Pointer events are a unified interface for similar input devices
(mouse, pen, touch, ...).
Since maintaining both mouse and touch events for compatibility
is really cumbersome, using a unified pointer events interface
is a relief.

Beware though, that the pointer API [is not well supported by all browsers][caniuse-pointer].
So I strongly recommend to use it in pair with the [elm-pep polyfill][elm-pep]
for compatibility with major browsers.

[mouse-events]: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent
[touch-events]: https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent
[pointer-events]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
[caniuse-pointer]: https://caniuse.com/#feat=pointer
[elm-pep]: https://github.com/mpizenberg/elm-pep


## Usage

### Mouse and Pointer

The `Mouse` and `Pointer` modules have very similar API
so I will use `Mouse` as an example.
Let's say you want the coordinates of a mouse down event relative to the DOM
element that triggered it.
In JavaScript, these are provided by the [`offsetX` and `offsetY` properties][offsetX]
of the mouse event.
Using this module, these are similarly provided by the `offsetPos` attribute
of a mouse `Event`:


```elm
import Mouse

-- ...

type Msg
    = MouseDownAt ( Float, Float )

view =
    div
        [Mouse.onDown (\event -> MouseDownAt event.offsetPos)]
        [text "click here"]
```

If you are using the `Pointer` module,
it is recommended that you deactivate `touch-action`
to disable browsers scroll/pinch/... touch behaviors.


```elm
div
    [ Pointer.onMove ...
    -- no touch-action
    , Html.Attributes.style [ ( "touch-action", "none" ) ]
    ]
    []
```

[offsetX]: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/offsetX

### Touch

Touch interactions can be managed using the `Touch`, `SingleTouch` and `MultiTouch` modules.
The `Touch` module, regroups data structures common to both single- and multi-touch interactions.
In case of simple, single touch interactions, one might use the `SingleTouch` module like below:

```elm
import SingleTouch
import Touch

-- ...

type Msg
    = TouchStartAt ( Float, Float )

view =
    div
        [SingleTouch.onStart (\coord -> TouchStartAt (Touch.clientPos coord))]
        [text "touch here"]
```

In order to have a finer grained control of the touch event,
consider using the `MultiTouch` module.


## Examples

Working examples are available in the `examples/` directory.
To test one example, `cd` into one of them and compile the elm file with the command:

```shell
elm-make Main.elm --output Main.js
```

Then use any static http server like:

```shell
$ python3 -m http.server 8888
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


## Contributors

Matthieu Pizenberg - @mpizenberg
