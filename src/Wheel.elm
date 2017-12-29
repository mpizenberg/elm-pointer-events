-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/


module Wheel
    exposing
        ( DeltaMode(..)
        , Event
        , eventDecoder
        , onWheel
        , onWithOptions
        )

{-| Handling wheel events.

@docs Event, DeltaMode


# Basic Usage

@docs onWheel


# Advanced Usage

@docs onWithOptions, eventDecoder

-}

import Html
import Html.Events
import Json.Decode as Decode exposing (Decoder)
import Mouse


{-| Type that get returned by a browser wheel event.
Its purpose is to provide all useful properties of JavaScript
[WheelEvent] in the context of the elm programming language.

`deltaX` and `deltaZ` properties are not provided by default
since not compatible with Safari.
If you really need them, you can very easily build your own wheel event
decoder by extending this one,
or looking at the source code of this module and recoding one.

[WheelEvent]: https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent

-}
type alias Event =
    { mouseEvent : Mouse.Event
    , deltaY : Float
    , deltaMode : DeltaMode
    }


{-| The deltaMode property of a Wheel event.
-}
type DeltaMode
    = DeltaPixel
    | DeltaLine
    | DeltaPage


{-| Listen to `wheel` events.
Let's say that we have a message type like this:

    type Msg
        = ZoomIn
        | ZoomOut

And we want to zoom in or out on an element depending on a wheel event:

    chooseZoom : Wheel.Event -> Msg
    chooseZoom wheelEvent =
        if wheelEvent.deltaY > 0 then
            ZoomOut
        else
            ZoomIn

    div
        [ Wheel.onWheel chooseZoom ]
        [ text "some zoomable area like an image" ]

-}
onWheel : (Event -> msg) -> Html.Attribute msg
onWheel =
    onWithOptions stopOptions


{-| Enable personalization of html events options (prevent default and stop propagation)
in case the default options do not fit your needs.
The `Options` type here is the standard [`Html.Events.Options`][html-options] type.
You can change options like follows:

    onWheel : (Wheel.Event -> msg) -> Html.Attribute msg
    onWheel =
        { stopPropagation = False, preventDefault = True }
            |> Wheel.onWithOptions

[html-options]: http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html-Events#Options

-}
onWithOptions : Html.Events.Options -> (Event -> msg) -> Html.Attribute msg
onWithOptions options tag =
    Decode.map tag eventDecoder
        |> Html.Events.onWithOptions "wheel" options


stopOptions : Html.Events.Options
stopOptions =
    { stopPropagation = True
    , preventDefault = True
    }


{-| Wheel event decoder.
It is provided in case you want to extend this `Wheel.Event` type with
non provided properties (like `deltaX`, `deltaZ`).
-}
eventDecoder : Decoder Event
eventDecoder =
    Decode.map3 Event
        Mouse.eventDecoder
        (Decode.field "deltaY" Decode.float)
        (Decode.field "deltaMode" deltaModeDecoder)


deltaModeDecoder : Decoder DeltaMode
deltaModeDecoder =
    let
        intToMode int =
            case int of
                1 ->
                    DeltaLine

                2 ->
                    DeltaPage

                _ ->
                    DeltaPixel
    in
    Decode.map intToMode Decode.int
