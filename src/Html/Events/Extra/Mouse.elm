-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Html.Events.Extra.Mouse
    exposing
        ( Button(..)
        , Event
        , Keys
        , eventDecoder
        , onClick
        , onContextMenu
        , onDoubleClick
        , onDown
        , onEnter
        , onLeave
        , onMove
        , onOut
        , onOver
        , onUp
        , onWithOptions
        )

{-| Handling detailed mouse events.

@docs Event, Keys, Button


# Basic Usage

The three default mouse events are `mousedown`, `mousemove` and `mouseup`.

@docs onDown, onMove, onUp


# Other Supported Events

The other supported events by this library are
`click`, `dblclick`, `mouseenter`, `mouseover`, `mouseleave` and `mouseout`.
You can use them exactly like the previous examples.

@docs onClick, onDoubleClick

@docs onEnter, onOver, onLeave, onOut

@docs onContextMenu


# Advanced Usage

@docs onWithOptions

@docs eventDecoder

-}

import Html exposing (Attribute)
import Html.Events as Events
import Internal.Decode
import Json.Decode as Decode exposing (Decoder)



-- MOUSE EVENT #######################################################


{-| Type that get returned by a browser mouse event.
Its purpose is to provide all useful properties of
JavaScript [MouseEvent][js-mouse-event] in the context of
the elm programming language.

Coordinates of a specific kind (`clientX/Y`, `pageX/Y`, ...)
are available under the attribute of the same name grouped by pairs.
For example, if `mouseEvent` is of type `Mouse.Event` then
`mouseEvent.clientPos` holds the `( clientX, clientY )`
properties of the event.

For some applications like drawing in a canvas, relative coordinates are needed.
Beware that those coordinates are called `offsetX/Y` in a mouse event.
Therefore they are available here with attribute `offsetPos`.

    relativePos : Mouse.Event -> ( Float, Float )
    relativePos mouseEvent =
        mouseEvent.offsetPos

The `movementX/Y` properties not being compatible with Safari / iOS,
they are not provided by this package.
The `x` and `y` properties being equivalent to `clientX/Y`,
are not provided either.
The `screenPos` attribute provides `screenX/Y` properties in case needed,
but you shall use instead the `clientPos` attribute when in doubt.
`screenX/Y` values are not given in CSS pixel sizes and thus not very useful.
More info is available in the excellent
article [A tale of two viewports][tale-viewports].

[js-mouse-event]: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent
[tale-viewports]: https://www.quirksmode.org/mobile/viewports.html

-}
type alias Event =
    { keys : Keys
    , button : Button
    , clientPos : ( Float, Float )
    , offsetPos : ( Float, Float )
    , pagePos : ( Float, Float )
    , screenPos : ( Float, Float )
    }


{-| The keys that might have been pressed during mouse event.
Key modifiers of mouse events are available in the key attribute.
Checking if the ctrl key was hold when the event triggered is as easy as:

    isCtrlKeyPressed : Mouse.Event -> Bool
    isCtrlKeyPressed mouseEvent =
        mouseEvent.keys.ctrl

Since the `metaKey` property is not detected on linux,
it is not provided by this package.

-}
type alias Keys =
    { alt : Bool, ctrl : Bool, shift : Bool }


{-| The button pressed for the event.
The button that was used to trigger the mouse event is available
in the `button` attribute. However, beware that its value is not reliable
for events such as `mouseenter`, `mouseleave`, `mouseover`, `mouseout` or `mousemove`.

The `buttons` (with an "s") property of a mouse event is not provided here since
it is not compatible with mac / safari.

-}
type Button
    = ErrorButton
    | MainButton
    | MiddleButton
    | SecondButton
    | BackButton
    | ForwardButton



-- SIMPLE USAGE ######################################################


{-| Listen to `mousedown` events.
Let's say that we have a message type like this:

    type Msg
        = DownMsg ( Float, Float )
        | MoveMsg ( Float, Float )
        | UpMsg ( Float, Float )

Then we could listen to `mousedown` events like below:

    div
        [ Mouse.onDown (\event -> DownMsg event.clientPos) ]
        [ text "click here" ]

In a curried style, this can also be written:

    div
        [ Mouse.onDown (.clientPos >> DownMsg) ]
        [ text "click here" ]

-}
onDown : (Event -> msg) -> Attribute msg
onDown =
    onWithOptions "mousedown" stopOptions


{-| Listen to `mousemove` events.
Similarly than with `onDown`, we can write something like:

    div
        [ Mouse.onMove (.clientPos >> MoveMsg) ]
        [ text "move here" ]

-}
onMove : (Event -> msg) -> Attribute msg
onMove =
    onWithOptions "mousemove" stopOptions


{-| Listen to `mouseup` events.
Similarly than with `onDown`, we can write something like:

    div
        [ Mouse.onUp (.clientPos >> UpMsg) ]
        [ text "click here" ]

-}
onUp : (Event -> msg) -> Attribute msg
onUp =
    onWithOptions "mouseup" stopOptions



-- EVENTS ############################################################


{-| Listen to `click` events.
-}
onClick : (Event -> msg) -> Attribute msg
onClick =
    onWithOptions "click" stopOptions


{-| Listen to `dblclick` events.
-}
onDoubleClick : (Event -> msg) -> Attribute msg
onDoubleClick =
    onWithOptions "dblclick" stopOptions


{-| Listen to `mouseenter` events.
This event is fired when a mouse is moved over the element
that has the listener attached.
It is similar to `mouseover` but doesn't bubble.
More details available on the [MDN documentation][mdn-mouseenter].

[mdn-mouseenter]: https://developer.mozilla.org/en-US/docs/Web/Events/mouseenter

-}
onEnter : (Event -> msg) -> Attribute msg
onEnter =
    onWithOptions "mouseenter" stopOptions


{-| Listen to `mouseover` events.
-}
onOver : (Event -> msg) -> Attribute msg
onOver =
    onWithOptions "mouseover" stopOptions


{-| Listen to `mouseleave` events.
This event is fired when a mouse is moved out of the element
that has the listener attached.
It is similar to `mouseout` but doesn't bubble.
More details available on the [MDN documentation][mdn-mouseleave].

[mdn-mouseleave]: https://developer.mozilla.org/en-US/docs/Web/Events/mouseleave

-}
onLeave : (Event -> msg) -> Attribute msg
onLeave =
    onWithOptions "mouseleave" stopOptions


{-| Listen to `mouseout` events.
-}
onOut : (Event -> msg) -> Attribute msg
onOut =
    onWithOptions "mouseout" stopOptions


{-| Listen to `contextmenu` events.
Fired on right mousedown, before the context menu is displayed.
-}
onContextMenu : (Event -> msg) -> Attribute msg
onContextMenu =
    onWithOptions "contextmenu" stopOptions


{-| Choose the mouse event to listen to, and specify the event options.
If for some reason the default behavior of this package
(stop propagation and prevent default) does not fit your needs,
you can change it with for example:

    onDown : (Mouse.Event -> msg) -> Html.Attribute msg
    onDown =
        { stopPropagation = False, preventDefault = True }
            |> Mouse.onWithOptions "mousedown"

-}
onWithOptions : String -> EventOptions -> (Event -> msg) -> Attribute msg
onWithOptions event options tag =
    eventDecoder
        |> Decode.map (\ev -> { message = tag ev, stopPropagation = options.stopPropagation, preventDefault = options.preventDefault })
        |> Events.custom event


stopOptions : EventOptions
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }


{-| Options for the event.
-}
type alias EventOptions =
    { stopPropagation : Bool
    , preventDefault : Bool
    }



-- DECODERS ##########################################################


{-| An `Event` decoder for mouse events.
The decoder is provided so that you can extend `Mouse.Event` with
specific properties you need. If for example you need the `movementX/Y`
properties and you can guaranty that users will not use safari,
you could do:

    type alias EventWithMovement =
        { mouseEvent : Mouse.Event
        , movement : ( Float, Float )
        }

    decodeWithMovement : Decoder EventWithMovement
    decodeWithMovement =
        Decode.map2 EventWithMovement
            Mouse.eventDecoder
            movementDecoder

    movementDecoder : Decoder ( Float, Float )
    movementDecoder =
        Decode.map2 (\a b -> ( a, b ))
            (Decode.field "movementX" Decode.float)
            (Decode.field "movementY" Decode.float)

And use it like follows:

    type Msg
        = Movement ( Float, Float )

    div
        [ onMove (.movement >> Movement) ]
        [ text "move here" ]


    onMove : (EventWithMovement -> msg) -> Html.Attribute msg
    onMove tag =
        let
            options =
                { stopPropagation = True, preventDefault = True }
        in
        Decode.map tag decodeWithMovement
            |> Html.Events.onWithOptions "mousemove" options

-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map6 Event
        Internal.Decode.keys
        buttonDecoder
        Internal.Decode.clientPos
        Internal.Decode.offsetPos
        Internal.Decode.pagePos
        Internal.Decode.screenPos


buttonDecoder : Decoder Button
buttonDecoder =
    Decode.map buttonFromId
        (Decode.field "button" Decode.int)


buttonFromId : Int -> Button
buttonFromId id =
    case id of
        0 ->
            MainButton

        1 ->
            MiddleButton

        2 ->
            SecondButton

        3 ->
            BackButton

        4 ->
            ForwardButton

        _ ->
            ErrorButton
