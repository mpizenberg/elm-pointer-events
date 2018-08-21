# elm-pointer-events

[![][badge-license]][license]
[![][badge-doc]][doc]

[badge-doc]: https://img.shields.io/badge/documentation-latest-yellow.svg?style=flat-square
[doc]: http://package.elm-lang.org/packages/mpizenberg/elm-pointer-events/latest
[badge-license]: https://img.shields.io/badge/license-MPL--2.0-blue.svg?style=flat-square
[license]: https://www.mozilla.org/en-US/MPL/2.0/

> If upgrading from [elm-mouse-events] or [elm-touch-events],
> please read the [upgrade notes][upgrade].
> Otherwise, if upgrading from elm-pointer-events 2.0.0,
> reading the [CHANGELOG][changelog] should be enough.

[elm-mouse-events]: https://github.com/mpizenberg/elm-mouse-events
[elm-touch-events]: https://github.com/mpizenberg/elm-touch-events
[upgrade]: https://github.com/mpizenberg/elm-pointer-events/blob/master/upgrade.md
[changelog]: https://github.com/mpizenberg/elm-pointer-events/blob/master/CHANGELOG.md

```elm
import Html.Events.Extra.Pointer as Pointer
-- ... example usage
div [ Pointer.onDown (\event -> PointerDownMsg event.pointer.offsetPos) ] [ text "click here" ]
```

This package aims at handling all kinds of pointer events in elm.
To be more specific, this means:

* [`MouseEvent`][mouse-events]: standard mouse events
* [`WheelEvent`][wheel-events]: standard wheel events
* [`DragEvent`][drag-events]: HTML5 drag events
* [`TouchEvent`][touch-events]: standard touch events
* [`PointerEvent`][pointer-events]: new pointer events

If you are looking for only one standard kind of interaction (mouse or touch),
I recommend that you use the `Mouse` or `Touch` modules.
If however, you are designing a multi-device (desktop/tablet/mobile/...) experience,
I recommend that you use the `Pointer` module.

Pointer events are a unified interface for similar input devices
(mouse, pen, touch, ...).
Since maintaining both mouse and touch events for compatibility
is really cumbersome, using a unified pointer events interface
is a relief.

Beware though, that the pointer API is not well supported by all browsers.
Firefox < 59 and Safari do not natively support pointer events.
So I strongly recommend to use this package in pair with the [elm-pep polyfill][elm-pep]
for compatibility with major browsers.

[mouse-events]: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent
[wheel-events]: https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent
[drag-events]: https://developer.mozilla.org/en-US/docs/Web/API/DragEvent
[touch-events]: https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent
[pointer-events]: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
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
import Html.Events.Extra.Mouse as Mouse

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

Also, if you are designing some kind of drawing application,
you want to be able to keep track of a pointer that leave the
drawing area to know if the pointer went up.
This is possible using what is called [pointer capture][pointer-capture].
But requires the use of ports. Look at `examples/Pointer/`
if you are interested in how to do this.


```elm
div
    [ Pointer.onDown ...
    , Pointer.onMove ...
    , Pointer.onUp ...

    -- no touch-action
    , Html.Attributes.style "touch-action" "none"
    ]
    [ -- the drawing area
    ]
```

[offsetX]: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/offsetX
[pointer-capture]: https://developer.mozilla.org/en-US/docs/Web/API/Element/setPointerCapture


### Touch

Multi-touch interactions can be managed using the `Touch` module.
In case you only want to handle single touch interactions,
you could do something like below:

```elm
import Html.Events.Extra.Touch as Touch

-- ...

type Msg
    = StartAt ( Float, Float )
    | MoveAt ( Float, Float )
    | EndAt ( Float, Float )

view =
    div
        [ Touch.onStart (StartAt << touchCoordinates)
        , Touch.onMove (MoveAt << touchCoordinates)
        , Touch.onEnd (EndAt << touchCoordinates)
        ]
        [text "touch here"]

touchCoordinates : Touch.Event -> ( Float, Float )
touchCoordinates touchEvent =
    List.head touchEvent.changedTouches
        |> Maybe.map .clientPos
        |> Maybe.withDefault ( 0, 0 )

```


### Wheel

You can manage `Wheel` events with the corresponding module.
Since it is an extension to the `Mouse` module all mouse inherited properties
are also available in the attribute `mouseEvent`.

To simply check for wheel rolling up or down you could do something like below:

```elm
import Html.Events.Extra.Wheel as Wheel

-- ...

type Msg
    = Scrolling Float

view =
    div
        [Wheel.onWheel (\event -> Scrolling event.deltaY)]
        [text "scroll here"]
```


### Drag

The API presented by this package is slightly opinionated,
to mitigate most errors induced by the complicated HTML5 drag events.
This API is organized around two use cases:

1. Dropping files from OS
2. Drag and drop of DOM elements

For dropping files, everything can be done purely in elm so the API reflects that.
For drag and drop however some events require JavaScript function calls.
Consequently it requires the use of ports.
Two files, `DragPorts.js` and `Ports.elm` are provided in the source code
of this repo to help setup things.

More info is available in the module documentation.
One example for each use case is present in the `examples/` directory.


## Examples

Minimalist working examples are available for each module in the `examples/` directory.
To test one example, `cd` into one of them and compile the elm file with the command:

```shell
elm make Main.elm --output Main.js
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
don't hesitate to reach out on slack (user @mattpiz)
and/or open an issue.
Discussion is the best way to start any contribution.


## Documentation

[![][badge-doc]][doc]

The package documentation is available on the [elm package website][doc].


## License

[![][badge-license]][license]

This Source Code Form is subject to the terms of the Mozilla Public License,v. 2.0.
If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.


## Contributors

* Matthieu Pizenberg - @mpizenberg
* Thomas Forgione - @tforgione ([elm-pep] polyfill)
* Robert Vollmert - @robx ([elm-pep] polyfill)
